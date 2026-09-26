#!/bin/sh
# Tests for usdz.swift. Run: tools/test-usdz.sh
set -eu

here=$(cd "$(dirname "$0")" && pwd)
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

# Asserts the USDZ is ARKit-valid, in mm, Y-up, and that its bounds match
# expected "minX maxX minY maxY minZ maxZ".
check_usdz() {
  usdchecker --arkit "$1" >"$tmp/check.log" 2>&1 || fail "usdchecker: $(cat "$tmp/check.log")"
  usdcat "$1" | python3 -c '
import re, sys
usda = sys.stdin.read()
expected = [float(v) for v in sys.argv[1].split()]
assert re.search(r"metersPerUnit = 0\.001\b", usda), "metersPerUnit is not 0.001"
assert re.search(r"upAxis = \"Y\"", usda), "upAxis is not Y"
pts = [tuple(map(float, p))
       for block in re.findall(r"point3f\[\] points = \[(.*?)\]", usda, re.S)
       for p in re.findall(r"\(([-\d.e]+), ([-\d.e]+), ([-\d.e]+)\)", block)]
bounds = [f(p[i] for p in pts) for i in range(3) for f in (min, max)]
assert all(abs(a - b) < 1e-3 for a, b in zip(bounds, expected)), f"bounds {bounds} != {expected}"
' "$2" || fail "$1"
}

# 10 (X) x 20 (Y) x 30 (Z) mm box, deliberately off-origin.
printf 'translate([5, 5, 5]) cube([10, 20, 30]);\n' >"$tmp/box.scad"
openscad --backend manifold -q -o "$tmp/box.stl" "$tmp/box.scad"

# Z-up mm -> Y-up mm, centred on X/Z, resting on Y=0.
expected="-5 5 0 30 -10 10"

# STL input, explicit output path
swift "$here/usdz.swift" "$tmp/box.stl" "$tmp/out.usdz" >/dev/null
check_usdz "$tmp/out.usdz" "$expected"

# SCAD input, default output path next to the input
rm "$tmp/box.stl"
swift "$here/usdz.swift" "$tmp/box.scad" >/dev/null
check_usdz "$tmp/box.usdz" "$expected"

# OpenSCAD color() becomes one mesh and material per colour, converted from sRGB
# to linear; uncoloured geometry, including faces cut by difference(), keeps the
# default colour.
cat >"$tmp/colors.scad" <<'EOF'
color("#e07a3a") cube(10);
color("SteelBlue") translate([20, 0, 0]) cube(10);
translate([40, 0, 0]) difference() { cube(10); cube(5); }
EOF
swift "$here/usdz.swift" "$tmp/colors.scad" >/dev/null
check_usdz "$tmp/colors.usdz" "-25 25 0 10 -5 5"
usdcat "$tmp/colors.usdz" | python3 -c '
import re, sys
usda = sys.stdin.read()
meshes = len(re.findall(r"def Mesh ", usda))
assert meshes == 3, f"{meshes} meshes, expected 3"
colors = sorted(tuple(float(c) for c in m.split(","))
                for m in re.findall(r"color3f inputs:diffuseColor = \(([^)]*)\)", usda))
expected = sorted([(0.7454, 0.1946, 0.0423), (0.0612, 0.2232, 0.4564), (0.16, 0.34, 0.46)])
assert len(colors) == 3 and all(abs(a - b) < 1e-3 for c, e in zip(colors, expected) for a, b in zip(c, e)), \
    f"colors {colors} != {expected}"
' || fail "colors"

# -D overrides reach OpenSCAD, including quoted strings
printf 'shape = "box";\nw = shape == "wide" ? 40 : 10;\ntranslate([5, 5, 5]) cube([w, 20, 30]);\n' >"$tmp/param.scad"
swift "$here/usdz.swift" -D 'shape="wide"' "$tmp/param.scad" "$tmp/wide.usdz" >/dev/null
check_usdz "$tmp/wide.usdz" "-20 20 0 30 -10 10"
swift "$here/usdz.swift" -D 'shape="wide"' -D 'w=6' "$tmp/param.scad" "$tmp/narrow.usdz" >/dev/null
check_usdz "$tmp/narrow.usdz" "-3 3 0 30 -10 10"

# -D only applies to .scad input
openscad --backend manifold -q -o "$tmp/box.stl" "$tmp/box.scad"
if swift "$here/usdz.swift" -D 'w=6' "$tmp/box.stl" "$tmp/x.usdz" >/dev/null 2>"$tmp/err.log"; then
  fail "-D with a mesh input should exit non-zero"
fi
grep -q "only applies to .scad" "$tmp/err.log" || fail "unexpected error: $(cat "$tmp/err.log")"

# -D without a value fails with usage
if swift "$here/usdz.swift" "$tmp/box.scad" -D >/dev/null 2>"$tmp/err.log"; then
  fail "-D without a value should exit non-zero"
fi
grep -q "usage:" "$tmp/err.log" || fail "unexpected error: $(cat "$tmp/err.log")"

# Unsupported input fails with a message
if swift "$here/usdz.swift" "$tmp/box.txt" >/dev/null 2>"$tmp/err.log"; then
  fail "unsupported input should exit non-zero"
fi
grep -q "unsupported input" "$tmp/err.log" || fail "unexpected error: $(cat "$tmp/err.log")"

echo "PASS"
