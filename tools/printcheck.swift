// Checks that a model prints without supports on the Bambu printers (.scad, .stl).
// Usage: swift -O tools/printcheck.swift [-D name=value]... <input>
// -D is passed through to OpenSCAD to override a .scad file's parameters.
//
// Input is millimetres, +Z up, in print orientation; its lowest point is the bed.
// It reports:
//   - size against the A1 mini (warning) and the P2S (error)
//   - undersides that start in mid-air with nothing below them (error)
//   - flat undersides: bridges longer than maxBridge, and parts that no bridge
//     reaches and that stick out more than maxLedge from the wall below. A slicer
//     bridges each region in one direction, so the best single direction is used.
//   - sloped undersides steeper than maxOverhang from vertical
//   - OpenSCAD warnings and errors (error)
// It exits non-zero if there are any errors.

import Foundation

let a1MiniSize = 180.0
let p2sSize = 256.0
let maxOverhang = 45.0 // degrees from vertical
let maxBridge = 15.0 // mm between the supports a bridge lands on
let maxLedge = 1.0 // mm a flat underside may stick out from the wall below it
let bridgeDirections = 36
let maxSamples = 5000.0 // per flat region; spacing grows past this
let zTolerance = 1e-4
let flatNormalZ = -0.9999 // faces pointing further down than this are flat
let minOverhangArea = 0.1 // mm²; smaller sloped undersides are tessellation noise

func die(_ message: String) -> Never {
  FileHandle.standardError.write(Data("printcheck: \(message)\n".utf8))
  exit(1)
}

// Formats a number, never as "-0.0"
func fmt(_ v: Double, _ digits: Int = 1) -> String {
  let s = String(format: "%.\(digits)f", v)
  return Double(s) == 0 ? String(format: "%.\(digits)f", 0.0) : s
}

// MARK: - Arguments

let usage = "usage: swift -O tools/printcheck.swift [-D name=value]... <input.scad|.stl>"
var defines: [String] = []
var args: [String] = []
var remaining = Array(CommandLine.arguments.dropFirst())
while !remaining.isEmpty {
  let arg = remaining.removeFirst()
  if arg == "-D" {
    guard !remaining.isEmpty else { die(usage) }
    defines.append(remaining.removeFirst())
  } else {
    args.append(arg)
  }
}
guard args.count == 1 else { die(usage) }
let input = URL(fileURLWithPath: args[0])
let inputType = input.pathExtension.lowercased()
guard ["scad", "stl"].contains(inputType) else { die("unsupported input: \(input.path)") }
if !defines.isEmpty && inputType != "scad" { die("-D only applies to .scad input") }

// MARK: - Findings

var errors = 0
var warnings = 0

func error(_ message: String) {
  print("ERROR \(message)")
  errors += 1
}

func warn(_ message: String) {
  print("WARN  \(message)")
  warnings += 1
}

// MARK: - Rendering

var stlURL = input
var openscadMessages: [Substring] = []
if inputType == "scad" {
  let tmp = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
  try FileManager.default.createDirectory(at: tmp, withIntermediateDirectories: true)
  stlURL = tmp.appendingPathComponent("model.stl")
  let p = Process()
  p.executableURL = URL(fileURLWithPath: "/usr/bin/env")
  p.arguments = ["openscad", "--backend", "manifold", "--export-format", "binstl", "-o", stlURL.path]
    + defines.flatMap { ["-D", $0] } + [input.path]
  let stderr = Pipe()
  p.standardError = stderr
  p.standardOutput = FileHandle.nullDevice
  do { try p.run() } catch { die("could not run openscad: \(error)") }
  let log = String(decoding: stderr.fileHandleForReading.readDataToEndOfFile(), as: UTF8.self)
  p.waitUntilExit()
  openscadMessages = log.split(separator: "\n").filter { $0.contains("WARNING:") || $0.contains("ERROR:") }
  if p.terminationStatus != 0 {
    die(([Substring("openscad failed with status \(p.terminationStatus)")] + openscadMessages).joined(separator: "\n"))
  }
}

// MARK: - Mesh, welding identical positions

func readSTL(_ url: URL) -> [[SIMD3<Double>]] {
  guard let data = try? Data(contentsOf: url) else { die("could not read \(url.path)") }
  var triangles: [[SIMD3<Double>]] = []
  let count = data.count >= 84 ? data.withUnsafeBytes { Int($0.loadUnaligned(fromByteOffset: 80, as: UInt32.self)) } : -1
  if data.count == 84 + 50 * count {
    data.withUnsafeBytes { bytes in
      for t in 0..<count {
        triangles.append((0..<3).map { v in
          let o = 84 + 50 * t + 12 + 12 * v
          return SIMD3((0..<3).map { Double(bytes.loadUnaligned(fromByteOffset: o + 4 * $0, as: Float32.self)) })
        })
      }
    }
  } else {
    var current: [SIMD3<Double>] = []
    for line in String(decoding: data, as: UTF8.self).split(whereSeparator: \.isNewline) {
      let fields = line.split(separator: " ")
      guard fields.first == "vertex", fields.count == 4 else { continue }
      current.append(SIMD3(fields[1...].map { Double($0) ?? 0 }))
      if current.count == 3 {
        triangles.append(current)
        current = []
      }
    }
  }
  if triangles.isEmpty { die("no triangles in \(url.path)") }
  return triangles
}

var points: [SIMD3<Double>] = []
var pointIndex: [SIMD3<Double>: Int] = [:]
var tris: [SIMD3<Int>] = []
for t in readSTL(stlURL) {
  let i = SIMD3(t.map { p -> Int in
    if let i = pointIndex[p] { return i }
    points.append(p)
    pointIndex[p] = points.count - 1
    return points.count - 1
  })
  if i.x != i.y && i.y != i.z && i.x != i.z { tris.append(i) }
}

func cross(_ a: SIMD3<Double>, _ b: SIMD3<Double>) -> SIMD3<Double> {
  SIMD3(a.y * b.z - a.z * b.y, a.z * b.x - a.x * b.z, a.x * b.y - a.y * b.x)
}

let normals = tris.map { t -> SIMD3<Double> in cross(points[t.y] - points[t.x], points[t.z] - points[t.x]) }
let areas = normals.map { ($0 * $0).sum().squareRoot() / 2 }
let normalZ = zip(normals, areas).map { $1 > 0 ? $0.z / (2 * $1) : 0 }

struct Edge: Hashable {
  let a: Int, b: Int
  init(_ a: Int, _ b: Int) { (self.a, self.b) = a < b ? (a, b) : (b, a) }
}

func edges(_ t: SIMD3<Int>) -> [Edge] { [Edge(t.x, t.y), Edge(t.y, t.z), Edge(t.z, t.x)] }

var edgeTriangles: [Edge: [Int]] = [:]
var neighbours = Array(repeating: Set<Int>(), count: points.count)
for (i, t) in tris.enumerated() {
  for e in edges(t) {
    edgeTriangles[e, default: []].append(i)
    neighbours[e.a].insert(e.b)
    neighbours[e.b].insert(e.a)
  }
}

let lo = points.reduce(points[0]) { pointwiseMin($0, $1) }
let hi = points.reduce(points[0]) { pointwiseMax($0, $1) }
let bedZ = lo.z
let size = hi - lo
let onBed = Set((0..<tris.count).filter { i in
  normalZ[i] < flatNormalZ && [tris[i].x, tris[i].y, tris[i].z].allSatisfy { points[$0].z < bedZ + zTolerance }
})
print("\(fmt(size.x, 2)) x \(fmt(size.y, 2)) x \(fmt(size.z, 2)) mm, \(fmt(onBed.map { areas[$0] }.reduce(0, +), 0)) mm² on the bed")

// Groups the triangles for which include() is true into regions sharing edges
func regions(_ include: (Int) -> Bool) -> [[Int]] {
  var seen = Set<Int>()
  var result: [[Int]] = []
  for start in 0..<tris.count where include(start) && !seen.contains(start) {
    var region: [Int] = []
    var stack = [start]
    seen.insert(start)
    while let i = stack.popLast() {
      region.append(i)
      for e in edges(tris[i]) {
        for j in edgeTriangles[e]! where include(j) && !seen.contains(j) {
          seen.insert(j)
          stack.append(j)
        }
      }
    }
    result.append(region)
  }
  return result
}

// "z=… near (x, y)" at the middle of the points' bounding box
func place(_ indices: [Int]) -> String {
  let ps = indices.map { points[$0] }
  let mid = (ps.reduce(ps[0]) { pointwiseMin($0, $1) } + ps.reduce(ps[0]) { pointwiseMax($0, $1) }) / 2
  return "near (\(fmt(mid.x)), \(fmt(mid.y)))"
}

func corners(_ region: [Int]) -> [Int] { region.flatMap { [tris[$0].x, tris[$0].y, tris[$0].z] } }

for line in openscadMessages { error("openscad: \(line)") }

// MARK: - Size

let longest = max(size.x, size.y, size.z)
if longest > p2sSize {
  error("size: \(fmt(longest)) mm is over the P2S's \(fmt(p2sSize, 0)) mm")
} else if longest > a1MiniSize {
  warn("size: \(fmt(longest)) mm is over the A1 mini's \(fmt(a1MiniSize, 0)) mm")
}

// MARK: - Floating starts: a vertex, or a level patch of them, with nothing lower beside it
// and facing down. (Facing up, it is the bottom of a pit, with material below.)

var vertexTriangles = Array(repeating: [Int](), count: points.count)
for (i, t) in tris.enumerated() { for v in [t.x, t.y, t.z] { vertexTriangles[v].append(i) } }

var visited = Set<Int>()
var floating: [(z: Double, plateau: [Int])] = []
for v in points.indices where points[v].z > bedZ + zTolerance && !visited.contains(v) {
  var plateau: [Int] = []
  var stack = [v]
  visited.insert(v)
  var lowest = true
  while let i = stack.popLast() {
    plateau.append(i)
    for n in neighbours[i] {
      let dz = points[n].z - points[i].z
      if dz < -zTolerance {
        lowest = false
      } else if dz <= zTolerance && !visited.contains(n) {
        visited.insert(n)
        stack.append(n)
      }
    }
  }
  let around = Set(plateau.flatMap { vertexTriangles[$0] })
  let facing = around.map { normals[$0].z }.reduce(0, +)
  if lowest && facing < 0 { floating.append((points[v].z, plateau)) }
}
for f in floating.sorted(by: { $0.z < $1.z }) {
  error("floating at z=\(fmt(f.z, 2)) \(place(f.plateau)): needs support")
}

// MARK: - Flat undersides: bridges and ledges

typealias Point = SIMD2<Double>

func cross2(_ a: Point, _ b: Point) -> Double { a.x * b.y - a.y * b.x }

func distance(_ p: Point, _ a: Point, _ b: Point) -> Double {
  let ab = b - a
  let t = max(0, min(1, ((p - a) * ab).sum() / (ab * ab).sum()))
  let d = p - (a + t * ab)
  return (d * d).sum().squareRoot()
}

struct Boundary {
  let a: Point, b: Point
  let supported: Bool
}

// Distance along the ray to the region's edge if it lands on support there, else infinity
func landing(_ p: Point, _ u: Point, _ boundary: [Boundary]) -> Double {
  var nearest = Double.infinity
  var supported = false
  for e in boundary {
    let ab = e.b - e.a
    let denom = cross2(u, ab)
    if abs(denom) < 1e-12 { continue }
    let ap = e.a - p
    let t = cross2(ap, ab) / denom
    let s = cross2(ap, u) / denom
    if t > 1e-9 && s >= -1e-9 && s <= 1 + 1e-9 && t < nearest {
      nearest = t
      supported = e.supported
    }
  }
  return supported ? nearest : .infinity
}

var bridges: [(z: Double, message: String)] = []
var ledges: [(z: Double, message: String)] = []
let flat = regions { i in normalZ[i] < flatNormalZ && !onBed.contains(i) }
for region in flat {
  let members = Set(region)
  let z = points[tris[region[0]].x].z
  var boundary: [Boundary] = []
  for i in region {
    for e in edges(tris[i]) {
      let others = edgeTriangles[e]!.filter { !members.contains($0) }
      guard let other = others.first else { continue }
      let t = tris[other]
      let opposite = [t.x, t.y, t.z].first { $0 != e.a && $0 != e.b }!
      boundary.append(Boundary(
        a: Point(points[e.a].x, points[e.a].y), b: Point(points[e.b].x, points[e.b].y),
        supported: others.count == 1 && points[opposite].z < z - zTolerance))
    }
  }
  let supports = boundary.filter(\.supported)
  if supports.isEmpty { continue } // reported as floating

  // Sample points just inside each triangle
  let area = region.map { areas[$0] }.reduce(0, +)
  let spacing = max(0.5, (area / maxSamples).squareRoot())
  var samples: [Point] = []
  for i in region {
    let t = tris[i]
    let (a, b, c) = (points[t.x], points[t.y], points[t.z])
    let (pa, pb, pc) = (Point(a.x, a.y), Point(b.x, b.y), Point(c.x, c.y))
    let centroid = (pa + pb + pc) / 3
    let longestEdge = [pb - pa, pc - pb, pa - pc].map { ($0 * $0).sum().squareRoot() }.max()!
    let n = max(1, Int((longestEdge / spacing).rounded(.up)))
    for j in 0...n {
      for k in 0...(n - j) {
        let p = pa + (pb - pa) * Double(j) / Double(n) + (pc - pa) * Double(k) / Double(n)
        let toCentroid = centroid - p
        let d = (toCentroid * toCentroid).sum().squareRoot()
        samples.append(d > 1e-3 ? p + toCentroid * (1e-3 / d) : p)
      }
    }
  }
  let reach = samples.map { p in supports.map { distance(p, $0.a, $0.b) }.min()! }
  let spans = samples.map { p in
    (0..<bridgeDirections).map { k -> Double in
      let angle = Double.pi * Double(k) / Double(bridgeDirections)
      let u = Point(cos(angle), sin(angle))
      return landing(p, u, boundary) + landing(p, -u, boundary)
    }
  }
  // A sample close to a wall is held by it; a farther one needs a bridge, or it is a ledge
  func cost(_ s: Int, _ k: Int) -> Double {
    reach[s] <= maxLedge ? 0 : spans[s][k].isFinite ? spans[s][k] / maxBridge : reach[s] / maxLedge
  }
  // Sums how far each sample is over its limit: summed rather than worst, so parts no
  // direction can bridge don't hide the rest, and only overages, so a direction within
  // the limits everywhere wins over one that is shorter on average
  let totals = (0..<bridgeDirections).map { k in samples.indices.map { max(0, cost($0, k) - 1) }.reduce(0, +) }
  let best = totals.indices.min { totals[$0] < totals[$1] }!
  var longestSpan = 0.0
  var farthestReach = 0.0
  for s in samples.indices where reach[s] > maxLedge {
    if spans[s][best].isFinite {
      longestSpan = max(longestSpan, spans[s][best])
    } else {
      farthestReach = max(farthestReach, reach[s])
    }
  }
  let at = "z=\(fmt(z, 2)) \(place(corners(region)))"
  if longestSpan > maxBridge {
    bridges.append((z, "bridge at \(at): \(fmt(longestSpan)) mm span over \(fmt(area, 0)) mm² (max \(fmt(maxBridge, 0)))"))
  }
  if farthestReach > maxLedge {
    ledges.append((z, "ledge at \(at): \(fmt(farthestReach)) mm from support over \(fmt(area, 0)) mm² (max \(fmt(maxLedge, 0)))"))
  }
}
for b in bridges.sorted(by: { $0.z < $1.z }) { warn(b.message) }
for l in ledges.sorted(by: { $0.z < $1.z }) { warn(l.message) }

// MARK: - Sloped undersides

let degrees = 180 / Double.pi
let steep = regions { i in
  normalZ[i] >= flatNormalZ && asin(max(-1, min(1, -normalZ[i]))) * degrees > maxOverhang + 0.5
}
var overhangs: [(z: Double, message: String)] = []
for region in steep {
  let area = region.map { areas[$0] }.reduce(0, +)
  if area < minOverhangArea { continue }
  let zs = corners(region).map { points[$0].z }
  let angle = region.map { asin(-normalZ[$0]) * degrees }.max()!
  overhangs.append((zs.min()!, "overhang at z=\(fmt(zs.min()!, 2))-\(fmt(zs.max()!, 2)) \(place(corners(region))): "
    + "\(fmt(angle, 0))° from vertical over \(fmt(area, 0)) mm² (max \(fmt(maxOverhang, 0))°)"))
}
for o in overhangs.sorted(by: { $0.z < $1.z }) { warn(o.message) }

// MARK: - Summary

func count(_ n: Int, _ noun: String) -> String? { n == 0 ? nil : "\(n) \(noun)\(n == 1 ? "" : "s")" }
let summary = [count(errors, "error"), count(warnings, "warning")].compactMap { $0 }
print(summary.isEmpty ? "OK" : summary.joined(separator: ", "))
exit(errors > 0 ? 1 : 0)
