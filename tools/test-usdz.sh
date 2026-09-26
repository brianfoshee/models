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
pts = [tuple(map(float, p)) for p in re.findall(
    r"\(([-\d.e]+), ([-\d.e]+), ([-\d.e]+)\)",
    re.search(r"point3f\[\] points = \[(.*?)\]", usda, re.S).group(1))]
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

# Unsupported input fails with a message
if swift "$here/usdz.swift" "$tmp/box.txt" >/dev/null 2>"$tmp/err.log"; then
  fail "unsupported input should exit non-zero"
fi
grep -q "unsupported input" "$tmp/err.log" || fail "unexpected error: $(cat "$tmp/err.log")"

echo "PASS"
