// Tabletop stand for an ADJ Pinspot LED II: a disc base with a post that the light's own
// hanging bracket bolts down onto, so it pans on the bolt and tilts on the bracket's knob.
// Origin: post axis, Z=0 at the underside of the base (the bed). The lens points +X.
// Prints as modelled, base down. The bolt screws into a thread printed in the post.

/* [View] */
view = "assembly"; // [assembly, exploded, print]
// Light, bolt and washer in the assembly views, for illustration
show_hardware = true;
explode_gap = 30; // [0:1:100]
// Tilt of the light on its bracket knob, up from horizontal
tilt = 10; // [-60:1:60]

/* [Base] */
base_d = 160; // [80:1:180]
base_t = 6; // [3:0.5:15]
// Chamfer on the base's top edge
base_chamfer = 2; // [0:0.5:5]

/* [Post] */
post_d = 32; // [20:1:60]
// Height of the bracket's seat above the base
post_h = 45; // [20:1:150]
// 45 degree flare where the post meets the base
post_flare = 8; // [0:1:20]

/* [Bolt] */
// M8 x 1.25 bolt down through the bracket's hole into a thread printed in the post
bolt_d = 8; // [4:0.5:12]
bolt_pitch = 1.25; // [0.5:0.05:2]
// Extra radius on the printed thread so the bolt turns in freely
thread_clearance = 0.2; // [0:0.05:0.5]
// Bolt length under the head; the hole is as deep as it takes for the bolt to end just short of the bottom
bolt_l = 25; // [10:1:60]
// Washer under the bolt head (M8, ISO 7089), spanning the bracket's larger hole
washer_d = 16; // [8:0.5:30]
washer_t = 1.6; // [0.5:0.1:4]

/* [Pinspot] */
// ADJ Pinspot LED II, drawn for illustration and to check clearances. Only the overall size
// (184 x 99 x 61 mm) and weight (0.5 kg) are published (ADJ user manual). Everything below is
// ESTIMATED from product photos scaled to the 61 mm body, not measured. Correct with calipers.
// Rear section of the body (the larger diameter, with the vents)
pin_rear_d = 61; // [40:0.5:80]
pin_rear_l = 62; // [30:0.5:100]
// Front barrel, up to the lens ring
pin_front_d = 54; // [40:0.5:80]
pin_front_l = 112; // [50:0.5:150]
// Lens retainer ring at the front
pin_ring_d = 58; // [40:0.5:80]
pin_ring_l = 10; // [3:0.5:20]
pin_lens_d = 48; // [30:0.5:70]
// Pivot axis, from the rear face along the body
pin_pivot_x = 72; // [20:0.5:150]
// Pivot hub on the body's side, between the body and the bracket arm
pin_hub_d = 26; // [10:0.5:40]
pin_hub_l = 13; // [3:0.5:30]
// Bracket bar
pin_bracket_w = 27; // [15:0.5:40]
pin_bracket_t = 3; // [1:0.1:5]
// Pivot axis to the tab's underside, along the arm
pin_arm_rise = 80; // [30:0.5:120]
// Hole in the arm, above the pivot
pin_arm_hole_z = 50; // [10:0.5:100]
pin_arm_hole_d = 9; // [3:0.5:15]
// Tab length and its holes, from the arm's outer face
pin_tab_l = 30; // [15:0.5:50]
pin_tab_hole_x = 22; // [5:0.5:40]
pin_tab_hole_d = 11; // [6:0.5:16]
pin_safety_hole_x = 11; // [3:0.5:30]
pin_safety_hole_d = 3.5; // [2:0.5:8]
// Ball-ended lever knob on the arm's outer face
pin_knob_d = 16; // [8:0.5:25]
pin_lever_l = 20; // [5:0.5:40]
pin_lever_d = 8; // [3:0.5:12]
// Cord leaving the rear face: strain relief boss and cable, offset toward the bracket side
pin_cord_boss_d = 14; // [5:0.5:20]
pin_cord_boss_l = 8; // [2:0.5:15]
pin_cord_d = 7; // [3:0.5:10]
pin_cord_offset = [-17, -3];
pin_cord_l = 40; // [0:1:100]

/* [Hidden] */
$fn = 64;
eps = 0.01;

seat_z = base_t + post_h; // top of the post, where the bracket's tab sits
// Thread sizes (ISO 68 internal, plus clearance) and the blind hole's depth
thread_major = bolt_d + 2 * thread_clearance;
thread_minor = bolt_d - 1.0825 * bolt_pitch + 2 * thread_clearance;
thread_depth = bolt_l - pin_bracket_t - washer_t + 2;
assert(thread_depth >= 5 * bolt_pitch, "bolt_l is too short to catch more than a few threads");
assert(thread_depth + 3 <= post_h, "bolt_l is too long: the hole would reach the base");

// Standard sizes of the hardware drawn in the assembly: ISO 4017 head
bolt_head = [13, 5.3]; // M8 [across flats, height]
hardware_color = "#b8bec4";

// Pinspot frame: the tab's hole on the Z axis, the tab's underside at Z=0, the arm on the
// -Y side and the body above, lens toward +X
pin_arm_y = -pin_tab_hole_x; // arm's outer face
pin_body_y = pin_arm_y + pin_bracket_t + pin_hub_l + pin_rear_d / 2; // body axis
pin_pivot_z = pin_bracket_t + pin_arm_rise;

// ---------------------------------------------------------------- stand

module base() {
  rotate_extrude()
    polygon([
      [0, 0],
      [base_d / 2, 0],
      [base_d / 2, base_t - base_chamfer],
      [base_d / 2 - base_chamfer, base_t],
      [0, base_t],
    ]);
}

module post() {
  translate([0, 0, base_t - eps]) {
    cylinder(d=post_d, h=post_h + eps);
    cylinder(d1=post_d + 2 * post_flare, d2=post_d, h=post_flare);
  }
}

// Internal V thread: the hole's radius runs from the minor to the major diameter and back
// once per turn, so twisting that profile one turn per pitch sweeps the groove down a helix
module thread_cut(h) {
  n = 72;
  profile = [
    for (i = [0:n - 1])
      let(a = 360 * i / n, r = (thread_minor + (thread_major - thread_minor) * (1 - abs(1 - 2 * i / n))) / 2)
        r * [cos(a), sin(a)],
  ];
  linear_extrude(h, twist=-360 * h / bolt_pitch, slices=ceil(h / bolt_pitch * n / 2), convexity=10)
    polygon(profile);
}

// Blind threaded hole down from the seat, with a lead-in at its mouth to start the bolt
module bolt_hole() {
  translate([0, 0, seat_z - thread_depth]) thread_cut(thread_depth + 1);
  translate([0, 0, seat_z - 0.5]) cylinder(d1=thread_major, d2=thread_major + 1, h=0.5 + eps);
}

module stand() {
  difference() {
    union() {
      base();
      post();
    }
    bolt_hole();
  }
}

// ---------------------------------------------------------------- pinspot

// Body along +X with the pivot axis on the Y axis
module pin_body() {
  rear_x = -pin_pivot_x;
  front_x = rear_x + pin_rear_l;
  ring_x = front_x + pin_front_l;
  module along_x(x, d, l) translate([x, 0, 0]) rotate([0, 90, 0]) cylinder(d=d, h=l);
  difference() {
    union() {
      along_x(rear_x, pin_rear_d, pin_rear_l);
      along_x(front_x - eps, pin_front_d, pin_front_l + 2 * eps);
      along_x(ring_x, pin_ring_d, pin_ring_l);
    }
    along_x(ring_x + pin_ring_l - 3, pin_lens_d, 4);
  }
  translate([rear_x, pin_cord_offset[0], pin_cord_offset[1]]) rotate([0, -90, 0]) {
    cylinder(d=pin_cord_boss_d, h=pin_cord_boss_l);
    cylinder(d=pin_cord_d, h=pin_cord_boss_l + pin_cord_l);
  }
}

// L-shaped bar: tab lying on Z=0 toward +Y, arm rising at its -Y end to a rounded end past the pivot
module pin_bracket() {
  w = pin_bracket_w;
  t = pin_bracket_t;
  difference() {
    union() {
      translate([-w / 2, pin_arm_y, 0]) cube([w, pin_tab_l, t]);
      hull() {
        translate([-w / 2, pin_arm_y, 0]) cube([w, t, pin_pivot_z]);
        translate([0, pin_arm_y, pin_pivot_z]) rotate([-90, 0, 0]) cylinder(d=w, h=t);
      }
    }
    translate([0, 0, -1]) cylinder(d=pin_tab_hole_d, h=t + 2);
    translate([0, pin_arm_y + pin_safety_hole_x, -1]) cylinder(d=pin_safety_hole_d, h=t + 2);
    for (z = [pin_arm_hole_z, pin_pivot_z])
      translate([0, pin_arm_y - 1, z]) rotate([-90, 0, 0]) cylinder(d=pin_arm_hole_d, h=t + 2);
  }
}

// Hub between the body and the arm, and the lever knob outside the arm, on the pivot axis
module pin_pivot() {
  translate([0, pin_arm_y + pin_bracket_t - eps, pin_pivot_z]) rotate([-90, 0, 0])
    cylinder(d=pin_hub_d, h=pin_hub_l + 2 * eps);
  translate([0, pin_arm_y, pin_pivot_z]) rotate([90, 0, 0]) {
    cylinder(d=pin_lever_d + 4, h=5);
    rotate([0, 0, -90]) rotate([0, -30, 0]) {
      cylinder(d=pin_lever_d, h=pin_lever_l);
      translate([0, 0, pin_lever_l]) sphere(d=pin_knob_d);
    }
  }
}

module pinspot() {
  color("#333333") pin_bracket();
  color("#2a2a2a") pin_pivot();
  color("#1e1e1e") translate([0, pin_body_y, pin_pivot_z]) rotate([0, -tilt, 0]) pin_body();
}

// ---------------------------------------------------------------- hardware

// Hex bolt along +Z with the underside of its head at Z=0; head = [across flats, height]
module hex_bolt(d, l, head) {
  translate([0, 0, -head[1]]) rotate(30) cylinder(d=head[0] / cos(30), h=head[1], $fn=6);
  cylinder(d=d, h=l);
}

// Washer along +Z from Z=0; size = [outer diameter, thickness]
module washer(d, size) {
  difference() {
    cylinder(d=size[0], h=size[1]);
    translate([0, 0, -1]) cylinder(d=d + 0.4, h=size[1] + 2);
  }
}

// g spreads the parts apart: the light, washer and bolt up off the post
module assembly(g=0) {
  color("#4a6378") stand();
  if (show_hardware) {
    translate([0, 0, seat_z + g]) pinspot();
    color(hardware_color) {
      tab_top = seat_z + pin_bracket_t;
      translate([0, 0, tab_top + washer_t + 2.5 * g]) rotate([180, 0, 0]) hex_bolt(bolt_d, bolt_l, bolt_head);
      translate([0, 0, tab_top + 2 * g]) washer(bolt_d, [washer_d, washer_t]);
    }
  }
}

if (view == "print") stand();
else if (view == "assembly") assembly();
else if (view == "exploded") assembly(explode_gap);
