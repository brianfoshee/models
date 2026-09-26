// Two-speed planetary gearbox desk toy. Turn the crank (sun gear); twist the collar to shift.
// The ring gear slides up and down inside the housing, carried by pins from the collar:
//   low:     dogs on the housing floor hold the ring still, so the carrier and its pointer
//            turn 1 / (1 + ring_teeth / sun_teeth) as fast as the crank;
//   neutral: the ring is free, so the crank turns nothing;
//   direct:  dogs under the carrier lock the ring to it, so everything turns together at 1:1.
// Each gear sits in a flat step of the slots in the housing wall, so the collar stays put.
// Every part prints without supports and assembles without hardware:
//   ring into housing, collar over housing, pins press through the collar into the ring's groove,
//   sun + planets, carrier onto the planets, lid snaps on, pointer presses into the carrier,
//   crank presses onto the sun, knob snaps onto the crank.
// View -> Animate runs it; $t from 0 to 1 is one full turn of the carrier (of the sun in neutral).
// Origin: gearbox axis on Z, Z=0 at the bottom of the housing; mm, +Z up.

use <gears.scad>

/* [View] */
view = "assembly"; // [assembly, exploded, print]
gear = "low"; // [low, neutral, direct]
// Part shown in print view
part = "all"; // [all, housing, ring, collar, pin, sun, planet, carrier, pointer, lid, crank, knob]
explode_gap = 20; // [0:1:60]

/* [Gears] */
// Tooth size; 1.25 to 2 prints well with a 0.4 mm nozzle
gear_module = 1.5; // [1:0.25:3]
// 25 degrees keeps a small sun gear free of undercut and gives stronger teeth
pressure_angle = 25; // [20, 25]
sun_teeth = 12; // [8:1:30]
planet_teeth = 18; // [8:1:30]
planet_count = 3; // [2:1:6]
// Circumferential play per mesh, split between the two gears
backlash = 0.2; // [0:0.05:0.6]

/* [Fits] */
// Radial clearance for parts that turn or slide on pins or in bores
clearance = 0.25; // [0.1:0.05:0.5]
// Radial clearance for the hex and pin press fits (negative = interference)
press_clearance = 0.05; // [-0.1:0.025:0.2]
// Vertical gap between stacked moving parts
z_gap = 0.3; // [0.1:0.05:0.6]

/* [Housing] */
floor_height = 3; // [2:0.5:6]
wall = 2.5; // [1.5:0.25:5]
sun_pin_d = 5; // [3:0.5:8]

/* [Shifter] */
// Ring material behind the tooth roots; the dog notches and the pin groove are cut into it
ring_wall = 4; // [3:0.25:6]
// Dogs on the housing floor and under the carrier, and notches in each face of the ring
dog_count = 8; // [4:1:12]
dog_height = 2; // [1:0.25:4]
// Angular play between each dog and its notch; more is easier to shift and sloppier to turn
dog_play = 3; // [1:0.5:8]
// Vertical gap between the ring and the dogs on either side in neutral
dog_gap = 0.6; // [0.3:0.1:1.5]
// Side of the square pins that carry the ring
pin_size = 3; // [2:0.5:5]
groove_depth = 1.5; // [1:0.25:3]
collar_wall = 4; // [2:0.5:8]
collar_height = 9; // [6:0.5:16]
// Collar travel within each gear, measured around the housing
dwell_length = 6; // [3:0.5:10]

/* [Windows] */
// Open the floor, leaving a shelf the planets ride on and spokes out to the sun pin's hub
bottom_window = true;
// Width of the shelf, inward from the ring's tooth tips
shelf_width = 4; // [2:0.5:10]
spoke_width = 4; // [2:0.5:10]
// Open the lid and the carrier plate between spokes, to watch the planets from above
top_windows = true;
// How far inside the ring's tooth tips the top windows stop
rim_overlap = 1.5; // [1:0.5:4]

/* [Carrier and pointer] */
plate_height = 4; // [2:0.5:8]
planet_pin_d = 7; // [3:0.5:10]
// Across-flats of the hex that keys the pointer into the carrier
pointer_hex = 14; // [8:1:20]
pointer_hub_r = 12; // [8:0.5:20]
pointer_height = 2; // [1:0.5:5]

/* [Lid] */
lid_height = 2.4; // [1.5:0.2:5]
tab_width = 8; // [4:0.5:15]
tab_length = 11; // [6:0.5:16]
tab_thickness = 1.6; // [1:0.1:3]
barb_depth = 0.8; // [0.3:0.1:1.5]

/* [Crank and knob] */
shaft_d = 8; // [5:0.5:12]
// Across-flats of the hex that keys the crank onto the sun
crank_hex = 6; // [4:0.5:10]
crank_length = 32; // [15:1:60]
crank_hub_height = 8; // [4:0.5:15]
arm_thickness = 4; // [2:0.5:8]
knob_d = 12; // [8:0.5:20]
knob_height = 14; // [8:1:25]
knob_pin_d = 5; // [3:0.5:8]

/* [Hidden] */
$fa = 3;
$fs = 0.25;
eps = 0.01;
m = gear_module;

ring_teeth = sun_teeth + 2 * planet_teeth;
ratio = 1 + ring_teeth / sun_teeth;
level = gear == "low" ? 0 : gear == "neutral" ? 1 : 2;

function pitch_r(teeth) = m * teeth / 2;
center_distance = pitch_r(sun_teeth) + pitch_r(planet_teeth);
ring_root_r = pitch_r(ring_teeth) + 1.25 * m;
ring_r = ring_root_r + ring_wall;
// Notches start 1 mm outside the tooth roots so the teeth stay attached to the wall
notch_r = ring_root_r + 1;
bore_r = ring_r + clearance;
// The carrier plate sits on the ledge between the bore and this
counterbore_r = bore_r + 1.5;
housing_r = counterbore_r + wall + tab_thickness + clearance;
// Rotates the ring so its teeth mesh with a planet sitting on +X
ring_phase = planet_teeth % 2 == 0 ? 180 / ring_teeth : 0;

// Ring travel from one gear to the next: clear the dogs, plus the gap
shift_step = dog_height + dog_gap;
notch_depth = dog_height + z_gap;
notch_angle = 180 / dog_count;
dog_angle = notch_angle - dog_play;
dog_chamfer = 0.5;
groove_w = pin_size + 2 * clearance;
// Solid ring between the notches and the groove
groove_margin = 0.8;
ring_height = 2 * (notch_depth + groove_margin) + groove_w + groove_depth;
// Planets and sun stay in full mesh with the ring over its whole travel
gear_height = 2 * shift_step + ring_height + z_gap;

// Heights, bottom to top
gear_z0 = floor_height;
gear_z1 = gear_z0 + gear_height;
plate_z1 = gear_z1 + plate_height;
lid_z0 = plate_z1 + z_gap;
lid_z1 = lid_z0 + lid_height;
pointer_z0 = lid_z1 + z_gap; // underside of the pointer arm
pointer_z1 = pointer_z0 + pointer_height;
crank_z0 = pointer_z1 + 1;
crank_z1 = crank_z0 + crank_hub_height;
knob_z0 = crank_z0 + arm_thickness + z_gap;
knob_z1 = knob_z0 + knob_height;
sun_pin_z1 = gear_z0 + gear_height * 0.6;
socket_depth = plate_height - 1.5;
lid_hole_r = pointer_hub_r + 2 * clearance;
tab_angles = [for (i = [0:2]) i * 120 + 60];
planet_angles = [for (i = [0:planet_count - 1]) i * 360 / planet_count];
dog_angles = [for (i = [0:dog_count - 1]) i * 360 / dog_count];
bottom_window_r = pitch_r(ring_teeth) - m - shelf_width;
hub_r = sun_pin_d / 2 + 3;
top_window_r = pitch_r(ring_teeth) - m - rim_overlap;
lid_hub_r = lid_hole_r + 3;
// Boss around each planet pin where it meets the carrier's spoke
pin_boss_r = planet_pin_d / 2 + 2;
engrave_depth = 0.6;
tab_z0 = lid_z0 - tab_length;
barb_height = 2 * barb_depth;
knob_lip = 0.6;
knob_lip_height = 1.5;
crank_hub_r = crank_hex / cos(30) / 2 + 2.5;

// Shifter, modeled in low: the pins' center height, the collar, and the pins' reach into the groove
pin_z = gear_z0 + notch_depth + groove_margin + groove_w / 2;
collar_r = housing_r + clearance;
collar_out_r = collar_r + collar_wall;
collar_z0 = pin_z - collar_height / 2;
pin_tip_r = ring_r - groove_depth + clearance;
pin_head = 2;
// One gate slot in the wall between each pair of lid tabs
slot_angles = [for (a = tab_angles) a + 60];
// Gate slot, as [angle, z] of the pin's center: a flat dwell for each gear, joined by 45 degree ramps
dwell_a = dwell_length / housing_r * 180 / PI;
ramp_a = shift_step / housing_r * 180 / PI;
gate_start = -(3 * dwell_a + 2 * ramp_a) / 2;
gate_path = [
  for (i = [0:2]) each [
    [gate_start + i * (dwell_a + ramp_a), i * shift_step],
    [gate_start + i * (dwell_a + ramp_a) + dwell_a, i * shift_step],
  ],
];
// Where the pins sit in each gear, measured from the slot's center
function level_angle(i) = gate_start + i * (dwell_a + ramp_a) + dwell_a / 2;
label_size = 3;
// Gear names engraved on the housing above each dwell, clear of the collar in direct
label_z = pin_z + 2 * shift_step + collar_height / 2 + 0.5 + label_size / 2;
labels = [str(round(ratio * 10) / 10, ":1"), "N", "1:1"];

assert((sun_teeth + ring_teeth) % planet_count == 0, "planets can't be evenly spaced: sun + ring teeth must divide by planet_count");
assert(2 * center_distance * sin(180 / planet_count) > 2 * (pitch_r(planet_teeth) + m) + 1, "planets collide with each other");
assert(shaft_d / 2 < pitch_r(sun_teeth) - 1.25 * m - 1, "shaft too thick for the sun gear");
assert(crank_hex / cos(30) < shaft_d, "crank hex must fit inside the shaft to leave a shoulder");
assert(!bottom_window || bottom_window_r > hub_r + 5, "shelf too wide for a bottom window");
assert(!top_windows || pointer_hex / cos(30) / 2 + 1.5 < pointer_hub_r, "pointer hub too small to wall the carrier's hex socket");
assert(!top_windows || top_window_r < housing_r - 9, "top windows run into the dial's long ticks");
assert(ring_r - notch_r - 2 * clearance >= 1.5, "ring_wall too thin for the dogs");
assert(groove_depth <= ring_wall - 1.5, "groove too deep for ring_wall");
assert(dog_angle - 2 * dog_chamfer / notch_r * 180 / PI > 2, "dog_play too large for dog_count");
assert(label_z + label_size / 2 + 0.5 <= lid_z0, "no room for the gear labels between the collar and the lid");
assert(-gate_start + (groove_w / 2 + 1) / housing_r * 180 / PI < 60 - (tab_width / 2 + 1) / housing_r * 180 / PI,
  "gate slots run into the lid tabs: shorten dwell_length");

// ---------------------------------------------------------------- shapes

module external_gear(teeth, height) {
  linear_extrude(height, convexity=4) gear2d(teeth, m, pressure_angle, m, 1.25 * m, -backlash / 2);
}

// Pie slice of radius r centered on +X
module wedge2d(angle, r) {
  polygon(concat([[0, 0]], [for (i = [0:8]) r * [cos(-angle / 2 + i * angle / 8), sin(-angle / 2 + i * angle / 8)]]));
}

module annulus2d(r0, r1) {
  difference() {
    circle(r=r1);
    circle(r=r0);
  }
}

// Dog centered on +X, rising from z=0; its sides are chamfered at the tip to find the notch
module dog(r0, r1) {
  chamfer_a = dog_chamfer / r0 * 180 / PI;
  intersection() {
    linear_extrude(dog_height) annulus2d(r0, r1);
    hull() {
      linear_extrude(dog_height - dog_chamfer) wedge2d(dog_angle, r1 + 1);
      linear_extrude(dog_height) wedge2d(dog_angle - 2 * chamfer_a, r1 + 1);
    }
  }
}

// Annular opening from r_in to r_out, less a spoke along each of angles
module spoked_window2d(r_in, r_out, angles) {
  difference() {
    circle(r=r_out);
    circle(r=r_in);
    for (a = angles) rotate(a) translate([0, -spoke_width / 2]) square([r_out + 1, spoke_width]);
  }
}

// ---------------------------------------------------------------- parts
// Each part is modeled in its assembled position in low, with the gearbox axis on Z.

module housing() {
  difference() {
    rotate_extrude()
      polygon([[0, 0], [housing_r - 0.8, 0], [housing_r, 0.8], [housing_r, lid_z0], [0, lid_z0]]);
    translate([0, 0, gear_z0]) cylinder(r=bore_r, h=lid_z0);
    translate([0, 0, gear_z1]) cylinder(r=counterbore_r, h=lid_z0);
    for (a = tab_angles) rotate(a) tab_recess();
    for (a = slot_angles) rotate(a) gate_slot();
    rotate(slot_angles[0]) gear_labels();
    // floor opening inside the shelf, leaving the sun pin's hub and spokes in line with the lid tabs
    if (bottom_window) translate([0, 0, -eps])
      linear_extrude(floor_height + 2 * eps) spoked_window2d(hub_r, bottom_window_r, tab_angles);
  }
  // sun gear pivot
  cylinder(d=sun_pin_d, h=sun_pin_z1);
  for (a = dog_angles) rotate(a) translate([0, 0, gear_z0 - eps]) dog(notch_r + clearance, bore_r + eps);
}

// Channel the lid's tab slides down, and the pocket its barb snaps into
module tab_recess() {
  r_in = housing_r - tab_thickness;
  w = tab_width + 2 * clearance;
  translate([r_in - clearance, -w / 2, tab_z0 - clearance])
    cube([tab_thickness + clearance + 1, w, lid_z0 - tab_z0 + clearance + 1]);
  translate([r_in - barb_depth - clearance, -w / 2, tab_z0 - clearance])
    cube([barb_depth + eps, w, barb_height + clearance + 0.1]);
}

// Stepped slot through the wall, centered on +X, that a pin follows as the collar turns
module gate_slot() {
  for (i = [0:len(gate_path) - 2]) hull() {
    for (p = [gate_path[i], gate_path[i + 1]])
      rotate(p[0]) translate([bore_r - 1, -groove_w / 2, pin_z + p[1] - groove_w / 2])
        cube([housing_r - bore_r + 2, groove_w, groove_w]);
  }
}

// Gear names on the outside of the wall, centered on +X above the slot
module gear_labels() {
  for (i = [0:2])
    rotate(level_angle(i)) translate([housing_r - engrave_depth, 0, label_z]) rotate([90, 0, 90])
      linear_extrude(engrave_depth + 1)
        text(labels[i], size=label_size, halign="center", valign="center", font="Liberation Sans:style=Bold");
}

module ring() {
  z1 = gear_z0 + ring_height;
  groove_z0 = pin_z - groove_w / 2;
  groove_z1 = pin_z + groove_w / 2;
  difference() {
    translate([0, 0, gear_z0]) cylinder(r=ring_r, h=ring_height);
    translate([0, 0, gear_z0 - eps]) rotate(ring_phase)
      linear_extrude(ring_height + 2 * eps, convexity=4) gear2d(ring_teeth, m, pressure_angle, 1.25 * m, m, backlash / 2);
    // groove the pins ride in; its top is chamfered to print without support
    rotate_extrude()
      polygon([
        [ring_r - groove_depth, groove_z0],
        [ring_r + 1, groove_z0],
        [ring_r + 1, groove_z1 + groove_depth + 1],
        [ring_r - groove_depth, groove_z1],
      ]);
    for (a = dog_angles) rotate(a) {
      translate([0, 0, gear_z0 - eps]) linear_extrude(notch_depth + eps) notch2d();
      translate([0, 0, z1 - notch_depth]) linear_extrude(notch_depth + eps) notch2d();
    }
  }
}

module notch2d() {
  intersection() {
    annulus2d(notch_r, ring_r + 1);
    wedge2d(notch_angle, ring_r + 2);
  }
}

module collar() {
  hole = pin_size + 2 * press_clearance;
  translate([0, 0, collar_z0]) difference() {
    cylinder(r=collar_out_r, h=collar_height);
    translate([0, 0, -eps]) cylinder(r=collar_r, h=collar_height + 2 * eps);
    for (a = slot_angles) rotate(a + level_angle(0))
      translate([collar_r - 1, -hole / 2, collar_height / 2 - hole / 2]) cube([collar_wall + 2, hole, hole]);
  }
}

// Square pin along +X from the ring's groove out through the collar, with a head to push on
module shift_pin() {
  translate([pin_tip_r, -pin_size / 2, pin_z - pin_size / 2]) cube([collar_out_r - pin_tip_r, pin_size, pin_size]);
  translate([collar_out_r - eps, -pin_size, pin_z - pin_size / 2]) cube([pin_head + eps, 2 * pin_size, pin_size]);
}

module sun() {
  difference() {
    union() {
      translate([0, 0, gear_z0 + z_gap]) external_gear(sun_teeth, gear_height - 2 * z_gap);
      translate([0, 0, gear_z1 - z_gap - eps]) cylinder(d=shaft_d, h=crank_z0 - gear_z1 + z_gap + eps);
      translate([0, 0, crank_z0 - eps]) hex_prism(crank_hex, crank_hub_height + eps);
    }
    translate([0, 0, gear_z0 + z_gap - eps])
      cylinder(d=sun_pin_d + 2 * clearance, h=sun_pin_z1 - gear_z0 + eps);
  }
}

module planet() {
  translate([0, 0, gear_z0 + z_gap]) difference() {
    external_gear(planet_teeth, gear_height - 2 * z_gap);
    translate([0, 0, -eps]) cylinder(d=planet_pin_d + 2 * clearance, h=gear_height);
  }
}

module carrier() {
  pin_z0 = gear_z0 + z_gap + 1;
  difference() {
    union() {
      translate([0, 0, gear_z1]) cylinder(r=counterbore_r - clearance, h=plate_height);
      for (a = planet_angles)
        rotate(a) translate([center_distance, 0, pin_z0])
          cylinder(d=planet_pin_d, h=gear_z1 - pin_z0 + eps);
      for (a = dog_angles)
        rotate(a) translate([0, 0, gear_z1 + eps]) mirror([0, 0, 1]) dog(notch_r + clearance, ring_r - clearance);
    }
    translate([0, 0, gear_z1 - eps]) cylinder(d=shaft_d + 2 * clearance, h=plate_height + 2 * eps);
    translate([0, 0, plate_z1 - socket_depth])
      hex_prism(pointer_hex + 2 * press_clearance, socket_depth + eps);
    // opening between the pointer's hub and the rim, leaving a spoke through each planet pin
    if (top_windows) translate([0, 0, gear_z1 - eps]) linear_extrude(plate_height + 2 * eps)
      difference() {
        spoked_window2d(pointer_hub_r, top_window_r, planet_angles);
        for (a = planet_angles) rotate(a) translate([center_distance, 0]) circle(r=pin_boss_r);
      }
  }
}

module pointer() {
  arm_length = housing_r - 3;
  arm_w = 6;
  difference() {
    union() {
      translate([0, 0, plate_z1 - socket_depth + 0.2]) hex_prism(pointer_hex, socket_depth - 0.2 + eps);
      translate([0, 0, plate_z1]) cylinder(r=pointer_hub_r, h=pointer_z1 - plate_z1);
      translate([0, 0, pointer_z0]) linear_extrude(pointer_height)
        polygon([
          [0, -arm_w / 2],
          [arm_length - arm_w, -arm_w / 2],
          [arm_length, 0],
          [arm_length - arm_w, arm_w / 2],
          [0, arm_w / 2],
        ]);
    }
    translate([0, 0, plate_z1 - socket_depth]) cylinder(d=shaft_d + 2 * clearance, h=pointer_z1);
  }
}

module lid() {
  difference() {
    rotate_extrude()
      polygon([
        [lid_hole_r, lid_z0],
        [housing_r, lid_z0],
        [housing_r, lid_z1 - 0.8],
        [housing_r - 0.8, lid_z1],
        [lid_hole_r, lid_z1],
      ]);
    dial();
    // opening between the ring around the pointer and the dial, leaving spokes in line with the tabs
    if (top_windows) translate([0, 0, lid_z0 - eps])
      linear_extrude(lid_height + 2 * eps) spoked_window2d(lid_hub_r, top_window_r, tab_angles);
  }
  for (a = tab_angles) rotate(a) tab();
}

// Tick every 10 degrees, long ticks every 90
module dial() {
  for (i = [0:35]) {
    long = i % 9 == 0;
    rotate(i * 10) translate([housing_r - (long ? 8 : 5), -0.5, lid_z1 - engrave_depth]) cube([long ? 6 : 3, 1, 1]);
  }
}

// Snap tab, flush with the housing wall once seated
module tab() {
  r_in = housing_r - tab_thickness;
  rotate([90, 0, 0]) linear_extrude(tab_width, center=true)
    polygon([
      [housing_r, lid_z0 + eps],
      [housing_r, tab_z0],
      [r_in, tab_z0],
      [r_in - barb_depth, tab_z0 + barb_depth],
      [r_in - barb_depth, tab_z0 + barb_height],
      [r_in, tab_z0 + barb_height],
      [r_in, lid_z0 + eps],
    ]);
}

module crank() {
  difference() {
    union() {
      translate([0, 0, crank_z0]) cylinder(r=crank_hub_r, h=crank_hub_height);
      translate([0, 0, crank_z0]) linear_extrude(arm_thickness)
        hull() {
          circle(d=10);
          translate([crank_length, 0]) circle(d=10);
        }
      translate([crank_length, 0, crank_z0 + arm_thickness - eps]) snap_pin();
    }
    translate([0, 0, crank_z0 - eps]) hex_prism(crank_hex + 2 * press_clearance, crank_hub_height + 2 * eps);
  }
}

// Split pin with a barbed tip; the knob spins on it
module snap_pin() {
  h = knob_z1 - 0.1 - (crank_z0 + arm_thickness);
  difference() {
    union() {
      cylinder(d=knob_pin_d, h=h - knob_lip_height);
      translate([0, 0, h - knob_lip_height])
        cylinder(r1=knob_pin_d / 2 + knob_lip, r2=knob_pin_d / 2 - 0.3, h=knob_lip_height);
    }
    translate([-knob_pin_d, -0.75, h - knob_lip_height - 5]) cube([2 * knob_pin_d, 1.5, knob_lip_height + 5 + eps]);
  }
}

module knob() {
  counterbore_depth = knob_lip_height + 0.2;
  translate([crank_length, 0, knob_z0]) difference() {
    cylinder(d=knob_d, h=knob_height);
    translate([0, 0, -eps]) cylinder(d=knob_pin_d + 2 * clearance, h=knob_height);
    translate([0, 0, knob_height - counterbore_depth])
      cylinder(d=knob_pin_d + 2 * knob_lip + 2 * clearance, h=counterbore_depth + eps);
  }
}

// ---------------------------------------------------------------- views

// gap spreads the parts apart (the collar down, the pins outward); only limits it to one part (e.g. "planet1")
module assembly(gap=0, only="") {
  c = gear == "neutral" ? 0 : 360 * $t; // carrier; in neutral the crank's drag is too small to move it
  s = gear == "low" ? c * ratio : gear == "direct" ? c : 360 * $t; // sun and crank
  r = c - (s - c) * sun_teeth / ring_teeth; // ring
  lift = level * shift_step;
  turn = level_angle(level) - level_angle(0); // collar
  if (only == "" || only == "housing") color("#4a6378") housing();
  if (only == "" || only == "collar") translate([0, 0, lift - gap]) color("#d64545") rotate(turn) collar();
  for (i = [0:len(slot_angles) - 1])
    if (only == "" || only == str("pin", i))
      color("#2b2b2b") rotate(slot_angles[i] + level_angle(level)) translate([gap, 0, lift]) shift_pin();
  if (only == "" || only == "ring") translate([0, 0, lift + gap]) color("#7a9e7e") rotate(r) ring();
  translate([0, 0, 2 * gap]) {
    if (only == "" || only == "sun") color("#e8b83a") rotate(s) sun();
    for (i = [0:planet_count - 1]) {
      phi = i * 360 / planet_count;
      // meshes with the sun at s = 0, then rolls as the sun gains on the carrier
      spin = 180 - 180 / planet_teeth + (phi - (s - c)) * sun_teeth / planet_teeth;
      if (only == "" || only == str("planet", i))
        color("#e07a3a") rotate(c + phi) translate([center_distance, 0, 0]) rotate(spin) planet();
    }
  }
  if (only == "" || only == "carrier") translate([0, 0, 3 * gap]) color("#9aa5ad") rotate(c) carrier();
  if (only == "" || only == "lid") translate([0, 0, 4 * gap]) color("#5d7a91") lid();
  if (only == "" || only == "pointer") translate([0, 0, 5 * gap]) color("#d64545") rotate(c) pointer();
  if (only == "" || only == "crank") translate([0, 0, 6 * gap]) color("#9aa5ad") rotate(s) crank();
  if (only == "" || only == "knob") translate([0, 0, 7 * gap]) color("#2b2b2b") rotate(s) knob();
}

// One part, oriented for printing with its bottom at z = 0
module print_part(name) {
  if (name == "housing") housing();
  else if (name == "ring") translate([0, 0, -gear_z0]) ring();
  else if (name == "collar") translate([0, 0, -collar_z0]) collar();
  else if (name == "pin") translate([-pin_tip_r, 0, pin_size / 2 - pin_z]) shift_pin();
  else if (name == "sun") translate([0, 0, -gear_z0 - z_gap]) sun();
  else if (name == "planet") translate([0, 0, -gear_z0 - z_gap]) planet();
  else if (name == "carrier") translate([0, 0, plate_z1]) rotate([180, 0, 0]) carrier();
  else if (name == "pointer") translate([0, 0, pointer_z1]) rotate([180, 0, 0]) pointer();
  else if (name == "lid") translate([0, 0, lid_z1]) rotate([180, 0, 0]) lid();
  else if (name == "crank") translate([0, 0, -crank_z0]) crank();
  else if (name == "knob") translate([-crank_length, 0, -knob_z0]) knob();
}

planet_r = pitch_r(planet_teeth) + m;
sun_r = pitch_r(sun_teeth) + m;
// On the print plate the planets sit inside the ring, which sits inside the collar
nest_r = (planet_r + 1) / sin(180 / planet_count);
assert(nest_r + planet_r + 1 < pitch_r(ring_teeth) - m, "planets don't fit inside the ring on the print plate");

// Every printed piece as [part, [x, y]], laid out on one plate
print_layout = let(
  space = 4,
  lid_x = 2 * housing_r + space,
  row2 = housing_r + space + collar_out_r,
  // small parts left to right along the top row
  row3 = row2 + collar_out_r + space + pointer_hub_r,
  pointer_x = -collar_out_r + pointer_hub_r,
  sun_x = pointer_x + housing_r - 3 + space + sun_r,
  crank_x = sun_x + sun_r + space + crank_hub_r,
  knob_x = crank_x + crank_length + 5 + space + knob_d / 2,
  pin_x = knob_x + knob_d / 2 + space
) concat(
  [["housing", [0, 0]], ["lid", [lid_x, 0]], ["collar", [0, row2]], ["ring", [0, row2]], ["carrier", [lid_x, row2]]],
  [for (a = planet_angles) ["planet", [nest_r * cos(a + 90), row2 + nest_r * sin(a + 90)]]],
  [["pointer", [pointer_x, row3]], ["sun", [sun_x, row3]], ["crank", [crank_x, row3]], ["knob", [knob_x, row3]]],
  [for (i = [0:len(slot_angles) - 1]) ["pin", [pin_x, row3 - pointer_hub_r + pin_size + i * (2 * pin_size + space)]]]
);

if (view == "assembly") assembly();
else if (view == "exploded") assembly(explode_gap);
else if (view == "print") {
  // looped at top level so --enable=lazy-union exports each piece as its own 3MF object
  if (part == "all") for (p = print_layout) translate(p[1]) print_part(p[0]);
  else print_part(part);
}
