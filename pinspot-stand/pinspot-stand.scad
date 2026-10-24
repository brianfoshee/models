// Tabletop stand for an ADJ Pinspot LED II on a 2.5 in wide base, with no hardware: the light's
// own hanging bracket slides its tab into a slot on top of the post, and a printed peg dropped
// through the tab's bolt hole locks it there. A steel bar slid into a channel in the base
// weighs it down. Tilt is the bracket's knob; pan is turning the stand on the table.
// Origin: post axis, Z=0 at the underside of the base (the bed). The lens points +X.
// The stand prints as modelled, base down, with the slot's mouth on its -Y side. The peg
// prints head down.

/* [View] */
view = "assembly"; // [assembly, exploded, print]
// Which part the print view lays out
part = "all"; // [all, stand, peg]
// Light in the assembly views, for illustration
show_light = true;
explode_gap = 40; // [0:1:100]
// Tilt of the light on its bracket knob, up from horizontal. Past about 65 degrees the body
// hits the post; that limit is set by the bracket, not the stand
tilt = 45; // [-60:1:65]

/* [Base] */
// Along X, under the light's length; as long as an A1 mini's 180 mm bed allows with a margin
base_l = 170; // [80:1:180]
// Across Y; 2.5 in, to sit on a 2.5 in surface
base_w = 63.5; // [40:0.5:180]
// Chamfer on the base's top edge
base_chamfer = 2; // [0:0.5:5]
// Solid plastic under and over the bar's channel
base_floor = 2; // [1.2:0.2:5]
base_roof = 2; // [1.2:0.2:5]

/* [Ballast] */
// Steel flat bar, nominal 1/2 x 1 x 6 in, slid into the base from the -X end and glued. It sits
// toward the -Y edge, away from the light, where it does the most to stop the stand tipping
bar_w = 25.4; // [10:0.1:50]
bar_t = 12.7; // [3:0.1:25]
bar_l = 152.4; // [50:0.1:180]
// Clearance per side around the bar
bar_clearance = 0.3; // [0:0.05:1]
// Plastic between the channel and the base's -Y edge
bar_wall = 2; // [1.2:0.2:5]
// Extra height for the channel's bridged roof to sag into
bar_sag = 0.5; // [0:0.1:1]

/* [Post] */
// Nearly the base's width: the wider the post, the further back its mouth face sits and the
// closer the light's weight comes to the base's centre line
post_d = 60; // [30:1:80]
// Height of the post above the base
post_h = 30; // [15:1:100]
// 45 degree flare where the post meets the base
post_flare = 1.5; // [0:0.5:20]

/* [Slot] */
// Clearance per side around the bracket's tab, so it slides in by hand
slot_clearance = 0.2; // [0:0.05:0.5]
// How far the lips reach in over each edge of the tab, holding it down. Their undersides
// slope at 45 degrees so nothing bridges; the opening between them is too narrow to drop the tab in
lip = 3; // [1:0.5:6]
// Lip thickness above its slope
lip_t = 2; // [1:0.5:5]
// Solid wall beside the slot at the post's mouth face
wall = 4; // [2:0.5:10]
// 45 degree lead-in around the mouth, for starting the tab
mouth_chamfer = 1; // [0:0.25:3]

/* [Peg] */
// The peg drops through the bracket's bolt hole into a socket in the slot's floor; its head
// rests on the tab, between the lips. Clearance per side to the bracket's hole
peg_clearance = 0.15; // [0:0.05:0.5]
// Clearance per side to the socket in the floor
socket_clearance = 0.2; // [0:0.05:0.5]
// How far the peg goes into the floor
peg_depth = 8; // [4:0.5:15]
head_d = 16; // [8:0.5:25]
head_h = 5; // [2:0.5:10]
// Chamfer on the head's bed-side edge (elephant's foot) and lead-in on the tip
peg_chamfer = 0.5; // [0:0.1:1]
tip_chamfer = 1; // [0:0.25:3]

/* [Pinspot] */
// ADJ Pinspot LED II, drawn for illustration and to check clearances. Only the overall size
// (184 x 99 x 61 mm) and weight (0.5 kg) are published (ADJ user manual). Everything below is
// ESTIMATED from product photos scaled to the 61 mm body unless marked measured. Correct with
// calipers.
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
// Bracket bar. Width and thickness size the slot
pin_bracket_w = 23; // [15:0.5:40] measured
pin_bracket_t = 3; // [1:0.1:5] measured
// Arm length from the tab's underside to its rounded end
pin_arm_l = 93; // [40:0.5:130] measured
// Hole in the arm, above the pivot
pin_arm_hole_z = 50; // [10:0.5:100]
pin_arm_hole_d = 9; // [3:0.5:15]
// Tab length from the arm's outer face
pin_tab_l = 34; // [15:0.5:50] measured
// Bolt hole, centred across the tab: its diameter and its edge's distance from the tab's end
pin_tab_hole_d = 10; // [6:0.5:16] measured
pin_tab_hole_end = 5; // [1:0.5:20] measured
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

// Channel for the bar, through the -X end of the base and stopping short of the +X end
channel_w = bar_w + 2 * bar_clearance;
channel_h = bar_t + 2 * bar_clearance + bar_sag;
channel_l = bar_l + 2 * bar_clearance;
channel_y = -base_w / 2 + bar_wall + channel_w / 2; // centre line
base_t = base_floor + channel_h + base_roof;
assert(channel_w + 2 * bar_wall <= base_w, "the bar's channel is wider than the base");
assert(channel_l + bar_wall <= base_l, "the bar's channel is longer than the base");

post_top = base_t + post_h;
slot_w = pin_bracket_w + 2 * slot_clearance;
slot_h = pin_bracket_t + 2 * slot_clearance;
slot_floor = post_top - slot_h - lip - lip_t;
// Mouth face: a flat on the post's -Y side wide enough for the slot plus a wall each side
assert(post_d > slot_w + 2 * wall, "post_d is too thin for the slot and a wall each side");
mouth_y = -sqrt(pow(post_d / 2, 2) - pow(slot_w / 2 + wall, 2));
assert(slot_floor > base_t + post_flare + 2, "post_h is too short for the slot above the flare");
assert(mouth_y + pin_tab_l - pin_bracket_t < post_d / 2, "the tab would stick out the back of the post");
assert(post_d + 2 * post_flare <= base_w, "the post's flare is wider than the base");

// Pinspot frame: the tab's hole on the Z axis, the tab's underside at Z=0, the arm on the
// -Y side and the body above, lens toward +X
pin_tab_hole_x = pin_tab_l - pin_tab_hole_end - pin_tab_hole_d / 2; // hole centre from the arm's outer face
pin_arm_y = -pin_tab_hole_x; // arm's outer face
pin_body_y = pin_arm_y + pin_bracket_t + pin_hub_l + pin_rear_d / 2; // body axis
pin_pivot_z = pin_arm_l - pin_bracket_w / 2; // pivot at the centre of the arm's rounded end (estimated)

// Where the tab's hole lands with the tab slid in and the arm against the mouth face
tab_y = mouth_y + pin_tab_hole_x - pin_bracket_t;
tab_top = slot_floor + slot_clearance + pin_bracket_t;

peg_d = pin_tab_hole_d - 2 * peg_clearance;
// Shank from the head's underside to the tip: through the tab's space and into the floor,
// stopping short of the socket's bottom so the head seats on the tab
peg_l = slot_h + peg_depth - 0.5;
assert(head_d + 1 <= slot_w - 2 * lip, "head_d doesn't fit between the lips");
assert(slot_floor - peg_depth > base_t + post_flare, "peg_depth reaches down into the post's flare");

// ---------------------------------------------------------------- stand

// Rectangle with its top edge chamfered at 45 degrees
module base() {
  hull() {
    translate([-base_l / 2, -base_w / 2, 0]) cube([base_l, base_w, base_t - base_chamfer]);
    translate([-base_l / 2 + base_chamfer, -base_w / 2 + base_chamfer, 0])
      cube([base_l - 2 * base_chamfer, base_w - 2 * base_chamfer, base_t]);
  }
}

module channel() {
  translate([-base_l / 2 - 1, channel_y - channel_w / 2, base_floor]) cube([channel_l + 1, channel_w, channel_h]);
}

// The steel bar, in place in its channel
module bar() {
  translate([-base_l / 2 + bar_clearance, channel_y - bar_w / 2, base_floor + bar_clearance]) cube([bar_l, bar_w, bar_t]);
}

// Cylinder with its flare, cut flat on the -Y side for the slot's mouth
module post() {
  r = post_d / 2 + post_flare;
  intersection() {
    translate([0, 0, base_t - eps]) {
      cylinder(d=post_d, h=post_h + eps);
      cylinder(d1=2 * r, d2=post_d, h=post_flare);
    }
    translate([-r - 1, mouth_y, 0]) cube([2 * r + 2, r + 1, post_top + 1]);
  }
}

// Slot cross-section in the XZ plane, floor at z=0: the tab's space, lips sloping in over
// it at 45 degrees, and the opening between the lips up through the top of the post
module slot_profile() {
  top = post_top - slot_floor + 1;
  polygon([
    [-slot_w / 2, 0],
    [slot_w / 2, 0],
    [slot_w / 2, slot_h],
    [slot_w / 2 - lip, slot_h + lip],
    [slot_w / 2 - lip, top],
    [-slot_w / 2 + lip, top],
    [-slot_w / 2 + lip, slot_h + lip],
    [-slot_w / 2, slot_h],
  ]);
}

// Extrudes a 2D shape in the XZ plane from y_from to y_to
module along_y(y_from, y_to) {
  translate([0, y_to, 0]) rotate([90, 0, 0]) linear_extrude(y_to - y_from) children();
}

module slot() {
  translate([0, 0, slot_floor]) {
    along_y(mouth_y - 1, post_d / 2 + 1) slot_profile();
    // lead-in: the profile widened by the chamfer at the mouth face, closing to size inside
    if (mouth_chamfer > 0)
      hull() {
        along_y(mouth_y - 1, mouth_y + eps) offset(delta=mouth_chamfer + 1) slot_profile();
        along_y(mouth_y + mouth_chamfer, mouth_y + mouth_chamfer + eps) slot_profile();
      }
  }
}

// Socket for the peg in the slot's floor, under the tab's hole
module peg_socket() {
  translate([0, tab_y, slot_floor - peg_depth]) cylinder(d=peg_d + 2 * socket_clearance, h=peg_depth + 1);
}

module stand() {
  difference() {
    union() {
      base();
      post();
    }
    slot();
    peg_socket();
    channel();
  }
}

// Peg in its print orientation: head on the bed, shank up
module peg() {
  cylinder(d1=head_d - 2 * peg_chamfer, d2=head_d, h=peg_chamfer + eps);
  translate([0, 0, peg_chamfer]) cylinder(d=head_d, h=head_h - peg_chamfer);
  translate([0, 0, head_h - eps]) {
    cylinder(d=peg_d, h=peg_l - tip_chamfer + eps);
    translate([0, 0, peg_l - tip_chamfer]) cylinder(d1=peg_d, d2=peg_d - 2 * tip_chamfer, h=tip_chamfer);
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

// g slides the light back out of the slot and lifts it clear, with the peg hovering over its
// hole, and slides the bar out of its channel
module assembly(g=0) {
  color("#4a6378") stand();
  color("#8a8f94") translate([-g, 0, 0]) bar();
  if (show_light) translate([0, tab_y - g, slot_floor + slot_clearance + g / 4]) pinspot();
  color("#e8b83a") translate([0, tab_y - g, tab_top + head_h + 3 * g / 4]) rotate([180, 0, 0]) peg();
}

if (view == "assembly") assembly();
else if (view == "exploded") assembly(explode_gap);
else if (view == "print") {
  // at top level so --enable=lazy-union exports each part as its own 3MF object; the peg
  // sits beside the base's long side
  if (part != "peg") color("#4a6378") stand();
  if (part != "stand")
    translate(part == "all" ? [0, base_w / 2 + head_d / 2 + 2, 0] : [0, 0, 0])
      color("#e8b83a") peg();
}
