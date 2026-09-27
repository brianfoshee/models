#!/bin/sh
# Tests for printcheck.swift. Run: tools/test-printcheck.sh
set -eu

here=$(cd "$(dirname "$0")" && pwd)
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

# Runs printcheck on a .scad snippet ($1) with any extra arguments, capturing
# output in $tmp/out.log and the exit status in $status.
check() {
  printf '%s\n' "$1" >"$tmp/model.scad"
  shift
  status=0
  swift -O "$here/printcheck.swift" "$@" "$tmp/model.scad" >"$tmp/out.log" 2>&1 || status=$?
}

expect_status() {
  [ "$status" -eq "$1" ] || fail "$2: exit $status, expected $1: $(cat "$tmp/out.log")"
}

expect_line() {
  grep -Eq "$1" "$tmp/out.log" || fail "$2: no line matching '$1' in: $(cat "$tmp/out.log")"
}

expect_no_line() {
  if grep -Eq "$1" "$tmp/out.log"; then fail "$2: unexpected '$1' in: $(cat "$tmp/out.log")"; fi
}

# Asserts the first number after "$1" in the output is within 0.2 of $2.
expect_value() {
  awk -v pat="$1" -v want="$2" '
    index($0, pat) { s = substr($0, index($0, pat) + length(pat)); match(s, /[0-9.]+/)
                     v = substr(s, RSTART, RLENGTH); found = 1; exit }
    END { if (!found || v - want > 0.2 || want - v > 0.2) exit 1 }' "$tmp/out.log" ||
    fail "$3: expected '$1' about $2 in: $(cat "$tmp/out.log")"
}

# A plain block has nothing to report
check 'cube([20, 20, 10]);'
expect_status 0 "block"
expect_line '^20\.00 x 20\.00 x 10\.00 mm, 400 mm² on the bed$' "block summary"
expect_line '^OK$' "block"

# A 40 mm bridge is reported with its span; a 10 mm one is fine
check 'difference() { cube([50, 10, 10]); translate([5, -1, -1]) cube([40, 12, 6]); }'
expect_status 0 "long bridge"
expect_line '^WARN  bridge at z=5\.00 ' "long bridge"
expect_value 'bridge at z=5.00 near (25.0, 5.0): ' 40 "long bridge span"
expect_line '^1 warning$' "long bridge"
check 'difference() { cube([20, 10, 10]); translate([5, -1, -1]) cube([10, 12, 6]); }'
expect_status 0 "short bridge"
expect_line '^OK$' "short bridge"

# A flat ledge sticking 5 mm out from a wall is reported by how far it reaches
check 'cube([10, 10, 10]); translate([0, 0, 10]) cube([15, 10, 2]);'
expect_status 0 "ledge"
expect_value 'ledge at z=10.00 near (12.5, 5.0): ' 5 "ledge reach"
expect_no_line 'bridge' "ledge"

# The bridge direction suits the region as a whole, even when part of it can't
# be bridged in any direction (here a flange past the piers, turned off the axes)
check 'rotate(30) { cube([5, 10, 10]); translate([45, 0, 0]) cube([5, 10, 10]); translate([0, 0, 10]) cube([50, 20, 2]); }'
expect_line '^WARN  bridge at z=10\.00 ' "bridge beside a ledge"
expect_line '^WARN  ledge at z=10\.00 ' "bridge beside a ledge"
grep 'bridge at z=10.00' "$tmp/out.log" | grep -q ': 40\.0 mm span' || fail "bridge beside a ledge span: $(cat "$tmp/out.log")"

# A 0.5 mm lip is fine
check 'cube([10, 10, 10]); translate([0, 0, 10]) cube([10.5, 10, 2]);'
expect_line '^OK$' "small lip"

# The ceiling of a pocket open to the bed is bridged across the pocket
check 'difference() { cube([30, 30, 6]); translate([10, 10, -1]) cube([10, 10, 4]); }'
expect_line '^OK$' "pocket ceiling"

# A horizontal hole's flat top is bridged wall to wall, even turned off the directions
# printcheck samples: bridge lines along its open ends still land on both walls
check 'rotate(2.5) difference() { translate([-10, -2, 0]) cube([20, 4, 10]); translate([-6, -5, 4]) cube([12, 10, 3]); }'
expect_line '^OK$' "turned hole ceiling"
# Through a round wall the hole's ends are arcs, bowing slightly past the lines along
# them, but no more than a bridge line's half width
check 'rotate(7) difference() { cylinder(r=50, h=10); translate([0, 0, -1]) cylinder(r=46, h=12); translate([44, -1.5, 4]) cube([10, 3, 3]); }'
expect_line '^OK$' "hole through a round wall"

# A hex ceiling 14 mm across flats is fine bridged flat to flat, though longer across corners
check 'difference() { cylinder(r=15, h=6); translate([0, 0, -1]) cylinder(d=14 / cos(30), h=3.5, $fn=6); }'
expect_line '^OK$' "hex ceiling"

# A ceiling with a through hole in it is only partly bridged: past the hole, a
# bridge has nothing to land on and the ceiling reaches out from the pocket walls
check 'difference() { cube([30, 30, 6]); translate([5, 5, -1]) cube([20, 20, 4]); translate([10, 10, -1]) cube([10, 10, 8]); }'
expect_value 'ledge at z=3.00 near (15.0, 15.0): ' 5 "ceiling around a hole"
expect_value 'bridge at z=3.00 near (15.0, 15.0): ' 20 "ceiling around a hole"

# An overhang steeper than 45 degrees from vertical is reported; 30 degrees is fine
check 'rotate([90, 0, 0]) linear_extrude(10) polygon([[0, 0], [10, 0], [10 + 10 * tan(60), 10], [0, 10]]);'
expect_status 0 "60-degree overhang"
expect_line '^WARN  overhang at z=0\.00-10\.00 ' "60-degree overhang"
expect_value 'overhang at z=0.00-10.00 near (18.7, -5.0): ' 60 "overhang angle"
check 'rotate([90, 0, 0]) linear_extrude(10) polygon([[0, 0], [10, 0], [10 + 10 * tan(30), 10], [0, 10]]);'
expect_line '^OK$' "30-degree overhang"
# 45 degrees exactly is allowed
check 'rotate([90, 0, 0]) linear_extrude(10) polygon([[0, 0], [10, 0], [20, 10], [0, 10]]);'
expect_line '^OK$' "45-degree overhang"

# Anything that starts in mid-air is an error: a flat underside, or a corner
check 'cube(10); translate([20, 0, 5]) cube(5);'
expect_status 1 "floating block"
expect_line '^ERROR floating at z=5\.00 near \(22\.5, 2\.5\): needs support$' "floating block"
check 'cube(10); translate([30, 0, 15]) rotate([45, atan(1 / sqrt(2)), 0]) cube(5, center=true);'
expect_status 1 "floating corner"
expect_line '^ERROR floating at z=10\.67 near \(30\.0, 0\.0\): needs support$' "floating corner"

# The bottom of a pit is low but has material under it: a flat floor, or a cone's tip
check 'difference() { cube(20); translate([5, 5, 3]) cube([10, 10, 20]); }'
expect_line '^OK$' "pit floor"
check 'difference() { cylinder(r=10, h=15); translate([0, 0, 5]) cylinder(r1=0, r2=10, h=10.01); }'
expect_line '^OK$' "cone pit"

# Parts over 180 mm won't fit an A1 mini; over 256 mm won't fit a P2S
check 'cube([200, 10, 10]);'
expect_status 0 "A1 mini size"
expect_line "^WARN  size: 200\.0 mm is over the A1 mini's 180 mm$" "A1 mini size"
check 'cube([10, 300, 10]);'
expect_status 1 "P2S size"
expect_line "^ERROR size: 300\.0 mm is over the P2S's 256 mm$" "P2S size"

# -D reaches OpenSCAD
check 'w = 10; cube([w, 10, 10]);' -D 'w=200'
expect_line "^WARN  size: 200\.0 mm" "-D"

# OpenSCAD warnings are errors
check 'cube(10); echo(nope);'
expect_status 1 "openscad warning"
expect_line '^ERROR openscad: WARNING: Ignoring unknown variable "nope"' "openscad warning"
expect_line '^10\.00 x 10\.00 x 10\.00 mm' "openscad warning summary first"
head -1 "$tmp/out.log" | grep -q '^10\.00 x' || fail "summary line should come first: $(cat "$tmp/out.log")"

# Binary and ASCII STL input
printf 'difference() { cube([50, 10, 10]); translate([5, -1, -1]) cube([40, 12, 6]); }\n' >"$tmp/bridge.scad"
for format in binstl asciistl; do
  openscad --backend manifold -q --export-format $format -o "$tmp/bridge.stl" "$tmp/bridge.scad"
  status=0
  swift -O "$here/printcheck.swift" "$tmp/bridge.stl" >"$tmp/out.log" 2>&1 || status=$?
  expect_status 0 "$format"
  expect_value 'bridge at z=5.00 near (25.0, 5.0): ' 40 "$format bridge span"
done

# -D only applies to .scad input
status=0
swift -O "$here/printcheck.swift" -D 'w=1' "$tmp/bridge.stl" >"$tmp/out.log" 2>&1 || status=$?
expect_status 1 "-D with STL"
expect_line "only applies to .scad" "-D with STL"

# Missing input fails with usage
status=0
swift -O "$here/printcheck.swift" >"$tmp/out.log" 2>&1 || status=$?
expect_status 1 "no input"
expect_line "^printcheck: usage:" "no input"

echo "PASS"
