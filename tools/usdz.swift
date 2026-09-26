// Converts a model (.scad, .stl, .obj, .ply) to a USDZ for AR Quick Look on iOS.
// Usage: swift tools/usdz.swift [-D name=value]... <input> [output.usdz]
// -D is passed through to OpenSCAD to override a .scad file's parameters.
//
// Input is treated as OpenSCAD/print space: millimetres, +Z up. The output is
// millimetres (metersPerUnit = 0.001), +Y up, centred on X/Z and resting on
// Y = 0 so it sits on the floor at real-world size.
//
// A .scad file's color() calls carry through: it is rendered to 3MF, and each
// colour becomes its own mesh and material. Uncoloured geometry and mesh
// inputs use the default colour.

import Foundation
import ModelIO

// Faces meeting at less than this angle are smooth-shaded; sharper edges stay hard.
let creaseAngleDegrees: Float = 30
let defaultColor = SIMD3<Float>(0.16, 0.34, 0.46)

func die(_ message: String) -> Never {
  FileHandle.standardError.write(Data("usdz: \(message)\n".utf8))
  exit(1)
}

func run(_ args: [String], in dir: URL? = nil) {
  let p = Process()
  p.executableURL = URL(fileURLWithPath: "/usr/bin/env")
  p.arguments = args
  if let dir { p.currentDirectoryURL = dir }
  do { try p.run() } catch { die("could not run \(args[0]): \(error)") }
  p.waitUntilExit()
  if p.terminationStatus != 0 { die("\(args[0]) failed with status \(p.terminationStatus)") }
}

// MARK: - Arguments

let usage = "usage: swift tools/usdz.swift [-D name=value]... <input> [output.usdz]"
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
guard (1...2).contains(args.count) else { die(usage) }
let input = URL(fileURLWithPath: args.first!)
let output = args.count == 2
  ? URL(fileURLWithPath: args.last!)
  : input.deletingPathExtension().appendingPathExtension("usdz")
if !defines.isEmpty && input.pathExtension.lowercased() != "scad" {
  die("-D only applies to .scad input")
}

let tmp = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
try FileManager.default.createDirectory(at: tmp, withIntermediateDirectories: true)
defer { try? FileManager.default.removeItem(at: tmp) }

// MARK: - Triangles grouped by colour, welding identical positions

struct Group {
  let color: SIMD3<Float>
  var points: [SIMD3<Float>] = []
  var pointIndex: [SIMD3<Float>: Int] = [:]
  var triangles: [SIMD3<Int>] = []

  mutating func weld(_ p: SIMD3<Float>) -> Int {
    if let i = pointIndex[p] { return i }
    points.append(p)
    pointIndex[p] = points.count - 1
    return points.count - 1
  }
}

var groups: [Group] = [] // in order of first appearance
var groupIndex: [SIMD3<Float>: Int] = [:]

// Adds a Z-up triangle to its colour's group, converting it to Y-up
func addTriangle(_ a: SIMD3<Float>, _ b: SIMD3<Float>, _ c: SIMD3<Float>, color: SIMD3<Float>) {
  // Z-up -> Y-up: rotate -90 degrees about X
  func yUp(_ p: SIMD3<Float>) -> SIMD3<Float> { SIMD3(p.x, p.z, -p.y) }
  let g = groupIndex[color] ?? {
    groups.append(Group(color: color))
    groupIndex[color] = groups.count - 1
    return groups.count - 1
  }()
  groups[g].triangles.append(SIMD3(groups[g].weld(yUp(a)), groups[g].weld(yUp(b)), groups[g].weld(yUp(c))))
}

// MARK: - Load a mesh file through Model I/O

func loadMesh(_ url: URL) {
  let asset = MDLAsset(url: url)
  let meshes = asset.childObjects(of: MDLMesh.self) as! [MDLMesh]
  guard !meshes.isEmpty else { die("no meshes in \(url.path)") }

  for mesh in meshes {
    let world = MDLTransform.globalTransform(with: mesh, atTime: 0)
    guard let pos = mesh.vertexAttributeData(forAttributeNamed: MDLVertexAttributePosition, as: .float3) else {
      die("mesh has no positions")
    }
    func position(_ i: UInt32) -> SIMD3<Float> {
      let p = pos.dataStart.advanced(by: Int(i) * pos.stride).assumingMemoryBound(to: Float.self)
      let w = world * SIMD4<Float>(p[0], p[1], p[2], 1)
      return SIMD3(w.x, w.y, w.z)
    }
    for case let sub as MDLSubmesh in mesh.submeshes ?? [] {
      guard sub.geometryType == .triangles else { die("only triangle meshes are supported") }
      let buffer = sub.indexBuffer(asIndexType: .uInt32)
      let idx = buffer.map().bytes.bindMemory(to: UInt32.self, capacity: sub.indexCount)
      for t in stride(from: 0, to: sub.indexCount - 2, by: 3) {
        addTriangle(position(idx[t]), position(idx[t + 1]), position(idx[t + 2]), color: defaultColor)
      }
    }
  }
}

// MARK: - Load an OpenSCAD 3MF, keeping colours

// "#RRGGBB" or "#RRGGBBAA" (sRGB) -> linear RGB, which UsdPreviewSurface expects
func linearColor(hex: String) -> SIMD3<Float>? {
  let digits = hex.dropFirst()
  guard hex.hasPrefix("#"), digits.count >= 6, let v = UInt32(digits.prefix(6), radix: 16) else { return nil }
  func linear(_ byte: UInt32) -> Float {
    let c = Float(byte) / 255
    return c <= 0.04045 ? c / 12.92 : pow((c + 0.055) / 1.055, 2.4)
  }
  return SIMD3(linear(v >> 16 & 0xFF), linear(v >> 8 & 0xFF), linear(v & 0xFF))
}

// OpenSCAD paints faces cut by an uncoloured difference() with its colour scheme's
// cut-face colour, even in exports. The scheme is pinned so this is the colour to ignore.
let colorScheme = "Cornfield"
let cutFaceColor = "#9DCB51"

// Reads the objects, vertices, triangles and base materials OpenSCAD writes. OpenSCAD
// sets a triangle's colour with pid/p1; triangles without p1 are uncoloured.
final class ThreeMFReader: NSObject, XMLParserDelegate {
  var baseColors: [String: [SIMD3<Float>]] = [:] // basematerials id -> colour per index
  var currentBasesID: String?
  var vertices: [SIMD3<Float>] = []
  var failure: String?

  func parser(_ parser: XMLParser, didStartElement name: String, namespaceURI: String?,
              qualifiedName: String?, attributes a: [String: String] = [:]) {
    switch name {
    case "basematerials":
      currentBasesID = a["id"]
      if let id = currentBasesID { baseColors[id] = [] }
    case "base":
      guard let id = currentBasesID else { break }
      let hex = a["displaycolor"] ?? ""
      let isCutFace = hex.uppercased().hasPrefix(cutFaceColor)
      baseColors[id]!.append(isCutFace ? defaultColor : linearColor(hex: hex) ?? defaultColor)
    case "object":
      vertices = []
    case "vertex":
      guard let x = a["x"].flatMap(Float.init), let y = a["y"].flatMap(Float.init), let z = a["z"].flatMap(Float.init)
      else { return fail(parser, "bad vertex \(a)") }
      vertices.append(SIMD3(x, y, z))
    case "triangle":
      guard let v1 = a["v1"].flatMap(Int.init), let v2 = a["v2"].flatMap(Int.init), let v3 = a["v3"].flatMap(Int.init),
            [v1, v2, v3].allSatisfy(vertices.indices.contains)
      else { return fail(parser, "bad triangle \(a)") }
      var color = defaultColor
      if let p1 = a["p1"].flatMap(Int.init) {
        guard let bases = baseColors[a["pid"] ?? ""], bases.indices.contains(p1)
        else { return fail(parser, "triangle refers to a missing material \(a)") }
        color = bases[p1]
      }
      addTriangle(vertices[v1], vertices[v2], vertices[v3], color: color)
    case "item":
      if a["transform"] != nil { fail(parser, "build item transforms are not supported") }
    case "components":
      fail(parser, "3MF components are not supported")
    default:
      break
    }
  }

  func parser(_ parser: XMLParser, didEndElement name: String, namespaceURI: String?, qualifiedName: String?) {
    if name == "basematerials" { currentBasesID = nil }
  }

  func fail(_ parser: XMLParser, _ message: String) {
    failure = message
    parser.abortParsing()
  }
}

func load3MF(_ url: URL) {
  run(["unzip", "-q", "-o", url.path, "3D/3dmodel.model", "-d", tmp.path])
  guard let parser = XMLParser(contentsOf: tmp.appendingPathComponent("3D/3dmodel.model")) else {
    die("could not read \(url.path)")
  }
  let reader = ThreeMFReader()
  parser.delegate = reader
  if !parser.parse() { die("3MF: \(reader.failure ?? parser.parserError.map { "\($0)" } ?? "parse failed")") }
}

switch input.pathExtension.lowercased() {
case "scad":
  let model = tmp.appendingPathComponent("model.3mf")
  let overrides = defines.flatMap { ["-D", $0] }
  // lazy-union keeps top-level objects apart instead of fusing touching parts
  run(["openscad", "--backend", "manifold", "--enable=lazy-union", "--colorscheme=\(colorScheme)", "-q"]
    + overrides + ["-o", model.path, input.path])
  load3MF(model)
case "stl", "obj", "ply":
  guard FileManager.default.fileExists(atPath: input.path) else { die("no such file: \(input.path)") }
  loadMesh(input)
default:
  die("unsupported input .\(input.pathExtension) (expected .scad, .stl, .obj or .ply)")
}
guard !groups.isEmpty else { die("no triangles in \(input.path)") }

// MARK: - Centre on X/Z, rest on Y = 0

let allPoints = groups.flatMap(\.points)
let lo = allPoints.reduce(SIMD3<Float>(repeating: .infinity)) { pointwiseMin($0, $1) }
let hi = allPoints.reduce(SIMD3<Float>(repeating: -.infinity)) { pointwiseMax($0, $1) }
let offset = SIMD3(-(lo.x + hi.x) / 2, -lo.y, -(lo.z + hi.z) / 2)
for g in groups.indices { groups[g].points = groups[g].points.map { $0 + offset } }

// MARK: - Crease-angle normals, one per face corner

func creaseNormals(_ g: Group) -> [SIMD3<Float>] {
  let faceNormals = g.triangles.map { t -> SIMD3<Float> in
    let n = simd_cross(g.points[t.y] - g.points[t.x], g.points[t.z] - g.points[t.x])
    let len = simd_length(n)
    return len > 0 ? n / len : .zero
  }
  var facesAtPoint = [[Int]](repeating: [], count: g.points.count)
  for (f, t) in g.triangles.enumerated() {
    for i in 0..<3 { facesAtPoint[t[i]].append(f) }
  }
  let minCos = cos(creaseAngleDegrees * .pi / 180)
  var normals: [SIMD3<Float>] = []
  normals.reserveCapacity(g.triangles.count * 3)
  for (f, t) in g.triangles.enumerated() {
    for i in 0..<3 {
      var sum = SIMD3<Float>.zero
      for h in facesAtPoint[t[i]] where simd_dot(faceNormals[f], faceNormals[h]) >= minCos {
        sum += faceNormals[h]
      }
      normals.append(simd_length(sum) > 0 ? simd_normalize(sum) : faceNormals[f])
    }
  }
  return normals
}

// MARK: - Write USDA and package

func fmt(_ v: Float) -> String { String(format: "%g", v) }
func tuples(_ vs: [SIMD3<Float>]) -> String {
  vs.map { "(\(fmt($0.x)), \(fmt($0.y)), \(fmt($0.z)))" }.joined(separator: ", ")
}

func meshPrim(_ g: Group, _ i: Int) -> String {
  let glo = g.points.reduce(SIMD3<Float>(repeating: .infinity)) { pointwiseMin($0, $1) }
  let ghi = g.points.reduce(SIMD3<Float>(repeating: -.infinity)) { pointwiseMax($0, $1) }
  return """
        def Mesh "Body\(i)" (prepend apiSchemas = ["MaterialBindingAPI"])
        {
            uniform bool doubleSided = 0
            uniform token subdivisionScheme = "none"
            float3[] extent = [\(tuples([glo, ghi]))]
            int[] faceVertexCounts = [\(Array(repeating: "3", count: g.triangles.count).joined(separator: ", "))]
            int[] faceVertexIndices = [\(g.triangles.map { "\($0.x), \($0.y), \($0.z)" }.joined(separator: ", "))]
            point3f[] points = [\(tuples(g.points))]
            normal3f[] normals = [\(tuples(creaseNormals(g)))] (
                interpolation = "faceVarying"
            )
            rel material:binding = </Model/Materials/Plastic\(i)>
        }
    """
}

func materialPrim(_ g: Group, _ i: Int) -> String {
  """
          def Material "Plastic\(i)"
          {
              token outputs:surface.connect = </Model/Materials/Plastic\(i)/PBR.outputs:surface>

              def Shader "PBR"
              {
                  uniform token info:id = "UsdPreviewSurface"
                  color3f inputs:diffuseColor = (\(fmt(g.color.x)), \(fmt(g.color.y)), \(fmt(g.color.z)))
                  float inputs:roughness = 0.55
                  float inputs:metallic = 0
                  token outputs:surface
              }
          }
  """
}

let usda = """
  #usda 1.0
  (
      defaultPrim = "Model"
      metersPerUnit = 0.001
      upAxis = "Y"
  )

  def Xform "Model" (kind = "component")
  {
  \(groups.enumerated().map { meshPrim($1, $0) }.joined(separator: "\n\n"))

      def Scope "Materials"
      {
  \(groups.enumerated().map { materialPrim($1, $0) }.joined(separator: "\n\n"))
      }
  }

  """

let layerName = output.deletingPathExtension().lastPathComponent + ".usda"
try usda.write(to: tmp.appendingPathComponent(layerName), atomically: true, encoding: .utf8)
try? FileManager.default.removeItem(at: output)
run(["usdzip", output.path, layerName], in: tmp)

let size = hi - lo
let triangleCount = groups.reduce(0) { $0 + $1.triangles.count }
let colors = groups.count == 1 ? "1 colour" : "\(groups.count) colours"
print("\(output.path): \(fmt(size.x)) x \(fmt(size.z)) x \(fmt(size.y)) mm (W x D x H), \(triangleCount) triangles, \(colors)")
