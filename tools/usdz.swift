// Converts a model (.scad, .stl, .obj, .ply) to a USDZ for AR Quick Look on iOS.
// Usage: swift tools/usdz.swift <input> [output.usdz]
//
// Input is treated as OpenSCAD/print space: millimetres, +Z up. The output is
// millimetres (metersPerUnit = 0.001), +Y up, centred on X/Z and resting on
// Y = 0 so it sits on the floor at real-world size.

import Foundation
import ModelIO

// Faces meeting at less than this angle are smooth-shaded; sharper edges stay hard.
let creaseAngleDegrees: Float = 30
let color = (0.16, 0.34, 0.46)

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

let args = CommandLine.arguments.dropFirst()
guard (1...2).contains(args.count) else { die("usage: swift tools/usdz.swift <input> [output.usdz]") }
let input = URL(fileURLWithPath: args.first!)
let output = args.count == 2
  ? URL(fileURLWithPath: args.last!)
  : input.deletingPathExtension().appendingPathExtension("usdz")

let tmp = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
try FileManager.default.createDirectory(at: tmp, withIntermediateDirectories: true)
defer { try? FileManager.default.removeItem(at: tmp) }

var meshURL = input
switch input.pathExtension.lowercased() {
case "scad":
  meshURL = tmp.appendingPathComponent("model.stl")
  run(["openscad", "--backend", "manifold", "-q", "-o", meshURL.path, input.path])
case "stl", "obj", "ply":
  break
default:
  die("unsupported input .\(input.pathExtension) (expected .scad, .stl, .obj or .ply)")
}
guard FileManager.default.fileExists(atPath: meshURL.path) else { die("no such file: \(meshURL.path)") }

// MARK: - Load triangles, welding identical positions

var points: [SIMD3<Float>] = []
var pointIndex: [SIMD3<Float>: Int] = [:]
var triangles: [SIMD3<Int>] = []

func weld(_ p: SIMD3<Float>) -> Int {
  if let i = pointIndex[p] { return i }
  points.append(p)
  pointIndex[p] = points.count - 1
  return points.count - 1
}

let asset = MDLAsset(url: meshURL)
let meshes = asset.childObjects(of: MDLMesh.self) as! [MDLMesh]
guard !meshes.isEmpty else { die("no meshes in \(meshURL.path)") }

for mesh in meshes {
  let world = MDLTransform.globalTransform(with: mesh, atTime: 0)
  guard let pos = mesh.vertexAttributeData(forAttributeNamed: MDLVertexAttributePosition, as: .float3) else {
    die("mesh has no positions")
  }
  func position(_ i: Int) -> SIMD3<Float> {
    let p = pos.dataStart.advanced(by: i * pos.stride).assumingMemoryBound(to: Float.self)
    let w = world * SIMD4<Float>(p[0], p[1], p[2], 1)
    // Z-up -> Y-up: rotate -90 degrees about X
    return SIMD3(w.x, w.z, -w.y)
  }
  for case let sub as MDLSubmesh in mesh.submeshes ?? [] {
    guard sub.geometryType == .triangles else { die("only triangle meshes are supported") }
    let buffer = sub.indexBuffer(asIndexType: .uInt32)
    let idx = buffer.map().bytes.bindMemory(to: UInt32.self, capacity: sub.indexCount)
    for t in stride(from: 0, to: sub.indexCount - 2, by: 3) {
      triangles.append(SIMD3(weld(position(Int(idx[t]))), weld(position(Int(idx[t + 1]))), weld(position(Int(idx[t + 2])))))
    }
  }
}

// MARK: - Centre on X/Z, rest on Y = 0

let lo = points.reduce(SIMD3<Float>(repeating: .infinity)) { pointwiseMin($0, $1) }
let hi = points.reduce(SIMD3<Float>(repeating: -.infinity)) { pointwiseMax($0, $1) }
let offset = SIMD3(-(lo.x + hi.x) / 2, -lo.y, -(lo.z + hi.z) / 2)
points = points.map { $0 + offset }

// MARK: - Crease-angle normals, one per face corner

let faceNormals = triangles.map { t -> SIMD3<Float> in
  let n = simd_cross(points[t.y] - points[t.x], points[t.z] - points[t.x])
  let len = simd_length(n)
  return len > 0 ? n / len : .zero
}
var facesAtPoint = [[Int]](repeating: [], count: points.count)
for (f, t) in triangles.enumerated() {
  for i in 0..<3 { facesAtPoint[t[i]].append(f) }
}
let minCos = cos(creaseAngleDegrees * .pi / 180)
var normals: [SIMD3<Float>] = []
normals.reserveCapacity(triangles.count * 3)
for (f, t) in triangles.enumerated() {
  for i in 0..<3 {
    var sum = SIMD3<Float>.zero
    for g in facesAtPoint[t[i]] where simd_dot(faceNormals[f], faceNormals[g]) >= minCos {
      sum += faceNormals[g]
    }
    normals.append(simd_length(sum) > 0 ? simd_normalize(sum) : faceNormals[f])
  }
}

// MARK: - Write USDA and package

func fmt(_ v: Float) -> String { String(format: "%g", v) }
func tuples(_ vs: [SIMD3<Float>]) -> String {
  vs.map { "(\(fmt($0.x)), \(fmt($0.y)), \(fmt($0.z)))" }.joined(separator: ", ")
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
      def Mesh "Body" (prepend apiSchemas = ["MaterialBindingAPI"])
      {
          uniform bool doubleSided = 0
          uniform token subdivisionScheme = "none"
          float3[] extent = [\(tuples([lo + offset, hi + offset]))]
          int[] faceVertexCounts = [\(Array(repeating: "3", count: triangles.count).joined(separator: ", "))]
          int[] faceVertexIndices = [\(triangles.map { "\($0.x), \($0.y), \($0.z)" }.joined(separator: ", "))]
          point3f[] points = [\(tuples(points))]
          normal3f[] normals = [\(tuples(normals))] (
              interpolation = "faceVarying"
          )
          rel material:binding = </Model/Materials/Plastic>
      }

      def Scope "Materials"
      {
          def Material "Plastic"
          {
              token outputs:surface.connect = </Model/Materials/Plastic/PBR.outputs:surface>

              def Shader "PBR"
              {
                  uniform token info:id = "UsdPreviewSurface"
                  color3f inputs:diffuseColor = (\(color.0), \(color.1), \(color.2))
                  float inputs:roughness = 0.55
                  float inputs:metallic = 0
                  token outputs:surface
              }
          }
      }
  }

  """

let layerName = output.deletingPathExtension().lastPathComponent + ".usda"
try usda.write(to: tmp.appendingPathComponent(layerName), atomically: true, encoding: .utf8)
try? FileManager.default.removeItem(at: output)
run(["usdzip", output.path, layerName], in: tmp)

let size = hi - lo
print("\(output.path): \(fmt(size.x)) x \(fmt(size.z)) x \(fmt(size.y)) mm (W x D x H), \(triangles.count) triangles")
