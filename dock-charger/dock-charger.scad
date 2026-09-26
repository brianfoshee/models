// Dock charger U-bracket: clamps over an edge, with a back plate for mounting the charger.
// Origin: X centered on the width, Y centered in the clamp gap, Z=0 at the underside of the top.

/* [Clamp] */
// Opening between the legs (edge thickness + clearance)
gap = 40.1; // [10:0.1:80]
// Length along the edge
width = 230; // [50:1:300]
top_thickness = 10; // [3:0.5:20]
front_thickness = 8; // [3:0.5:20]
back_thickness = 19; // [5:0.5:30]
// Leg length below the underside of the top
leg_length = 100; // [20:1:200]

/* [Back plate] */
// How far the plate extends below the legs
plate_drop = 50; // [0:1:150]
plate_thickness = 14; // [5:0.5:30]

/* [Screw holes] */
screw_d = 7; // [2:0.5:12]
counterbore_d = 20; // [0:0.5:30]
counterbore_depth = 7; // [0:0.5:15]
screw_x = [-75, 0, 75];
screw_z = -50;

/* [Slots] */
slot_w = 7.5; // [2:0.5:15]
// Overall slot length, including the rounded ends
slot_len = 38; // [8:1:80]
slot_x = [-97, -45, 45, 97];
// Slot center heights
slot_z = [-27, -127];

/* [Hidden] */
$fn = 64;
eps = 0.01;

front_y = -gap / 2 - front_thickness;
back_y = gap / 2 + back_thickness;
through = back_y - front_y + 2;

// Side profile in the YZ plane, as [y, z] points
module profile() {
  polygon([
    [front_y, top_thickness],
    [back_y, top_thickness],
    [back_y, -leg_length - plate_drop],
    [back_y - plate_thickness, -leg_length - plate_drop],
    [back_y - plate_thickness, -leg_length],
    [gap / 2, -leg_length],
    [gap / 2, 0],
    [-gap / 2, 0],
    [-gap / 2, -leg_length],
    [front_y, -leg_length],
  ]);
}

module body() {
  // profile lies in XY; rotate so its X->Y and Y->Z, then extrude along X
  rotate([90, 0, 90])
    linear_extrude(width, center=true, convexity=4)
      profile();
}

// Hole along Y, through both legs, counterbored on the back face
module screw_hole(x) {
  translate([x, 0, screw_z]) rotate([-90, 0, 0]) {
    translate([0, 0, front_y - 1]) cylinder(d=screw_d, h=through);
    translate([0, 0, back_y - counterbore_depth]) cylinder(d=counterbore_d, h=counterbore_depth + 1);
  }
}

// Vertical stadium slot through the back leg/plate
module slot(x, z) {
  translate([x, gap / 2 - 1, z]) rotate([-90, 0, 0])
    linear_extrude(back_y - gap / 2 + 2)
      hull()
        for (s = [-1, 1]) translate([0, s * (slot_len - slot_w) / 2]) circle(d=slot_w);
}

difference() {
  body();
  for (x = screw_x) screw_hole(x);
  for (x = slot_x, z = slot_z) slot(x, z);
}
