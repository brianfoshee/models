// Planetary gearbox desk toy. Turn the crank (sun gear); the ring gear is fixed in the
// housing, so the carrier and its pointer turn 1 / (1 + ring_teeth / sun_teeth) as fast.
// Every part prints without supports and assembles without hardware:
//   housing <- sun + planets, carrier onto the planets, lid snaps on,
//   pointer presses into the carrier, crank presses onto the sun, knob snaps onto the crank.
// View -> Animate runs it; $t from 0 to 1 is one full turn of the carrier.
// Origin: gearbox axis on Z, Z=0 at the bottom of the housing; mm, +Z up.

/* [View] */
view = "assembly"; // [assembly, exploded, print]
// Part shown in print view
part = "all"; // [all, housing, sun, planet, carrier, pointer, lid, crank, knob]
explode_gap = 20; // [0:1:60]

/* [Gears] */
// Tooth size; 1.25 to 2 prints well with a 0.4 mm nozzle
gear_module = 1.5; // [1:0.25:3]
// 25 degrees keeps a small sun gear free of undercut and gives stronger teeth
pressure_angle = 25; // [20, 25]
sun_teeth = 12; // [8:1:30]
planet_teeth = 18; // [8:1:30]
planet_count = 3; // [2:1:6]
gear_height = 10; // [5:1:20]
// Circumferential play per mesh, split between the two gears
backlash = 0.2; // [0:0.05:0.6]

/* [Fits] */
// Radial clearance for parts that turn on pins or in bores
clearance = 0.25; // [0.1:0.05:0.5]
// Radial clearance for the hex press fits (negative = interference)
press_clearance = 0.05; // [-0.1:0.025:0.2]
// Vertical gap between stacked moving parts
z_gap = 0.3; // [0.1:0.05:0.6]

/* [Housing] */
floor_height = 3; // [2:0.5:6]
wall = 2.5; // [1.5:0.25:5]
sun_pin_d = 5; // [3:0.5:8]

/* [Windows] */
// Openings in the housing wall, between the lid tabs, to watch the planets go by
windows = true;
// Width of each window; its top edge is a bridge of about this arc at the outer wall
window_angle = 40; // [10:5:70]
// Taller windows leave thinner bands of ring teeth above and below
window_height = 5; // [2:0.5:7]
// Open the floor, leaving a shelf under the ring and spokes out to the sun pin's hub
bottom_window = true;
// Width of the shelf the planets ride on, inward from the ring's tooth tips
shelf_width = 4; // [2:0.5:10]
spoke_width = 4; // [2:0.5:10]
// Open the lid and the carrier plate between spokes, to watch the planets from above
top_windows = true;
// Width of the carrier rim and the lid ring inside the ring's tooth tips; the carrier rides on the teeth
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

function pitch_r(teeth) = m * teeth / 2;
center_distance = pitch_r(sun_teeth) + pitch_r(planet_teeth);
ring_root_r = pitch_r(ring_teeth) + 1.25 * m;
counterbore_r = ring_root_r + 1.5;
housing_r = counterbore_r + wall + tab_thickness + clearance;
// Rotates the ring so its teeth mesh with a planet sitting on +X
ring_phase = planet_teeth % 2 == 0 ? 180 / ring_teeth : 0;

assert((sun_teeth + ring_teeth) % planet_count == 0, "planets can't be evenly spaced: sun + ring teeth must divide by planet_count");
assert(2 * center_distance * sin(180 / planet_count) > 2 * (pitch_r(planet_teeth) + m) + 1, "planets collide with each other");
assert(shaft_d / 2 < pitch_r(sun_teeth) - 1.25 * m - 1, "shaft too thick for the sun gear");
assert(crank_hex / cos(30) < shaft_d, "crank hex must fit inside the shaft to leave a shoulder");
assert(gear_height - window_height >= 3, "windows must leave at least 1.5 mm of ring teeth above and below");
assert(!bottom_window || bottom_window_r > hub_r + 5, "shelf too wide for a bottom window");
assert(!top_windows || pointer_hex / cos(30) / 2 + 1.5 < pointer_hub_r, "pointer hub too small to wall the carrier's hex socket");
assert(!top_windows || top_window_r < housing_r - 9, "top windows run into the dial's long ticks");

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
window_angles = windows ? [for (a = tab_angles) a + 60] : [];
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

// ---------------------------------------------------------------- gears

// Involute function, degrees in and out
function inv(a) = (tan(a) - a * PI / 180) * 180 / PI;

// 2D spur gear with one tooth centered on +X. thicken widens each tooth at the pitch circle
// (negative for backlash). A ring gear is cut with this shape, so its tooth spaces are these teeth.
module gear2d(teeth, addendum, dedendum, thicken) {
  rp = pitch_r(teeth);
  rb = rp * cos(pressure_angle);
  ra = rp + addendum;
  rf = rp - dedendum;
  r0 = max(rb, rf); // below the base circle the flank is radial
  half_pitch = 90 / teeth + (thicken / 2) / rp * 180 / PI;
  half = function(r) max(0.1, half_pitch + inv(pressure_angle) - inv(acos(rb / r)));
  polar = function(r, a) [r * cos(a), r * sin(a)];
  steps = 10;
  radii = [for (i = [0:steps]) r0 + (ra - r0) * i / steps];
  tooth = concat(
    [polar(rf - 0.1, -half(r0))],
    [for (r = radii) polar(r, -half(r))],
    [for (i = [steps:-1:0]) polar(radii[i], half(radii[i]))],
    [polar(rf - 0.1, half(r0))]
  );
  circle(r=rf, $fn=teeth * 8);
  for (i = [0:teeth - 1]) rotate(i * 360 / teeth) polygon(tooth);
}

module external_gear(teeth, height) {
  linear_extrude(height, convexity=4) gear2d(teeth, m, 1.25 * m, -backlash / 2);
}

module hex_prism(across_flats, height) {
  linear_extrude(height) circle(d=across_flats / cos(30), $fn=6);
}

// ---------------------------------------------------------------- parts
// Each part is modeled in its assembled position, with the gearbox axis on Z.

module housing() {
  difference() {
    rotate_extrude()
      polygon([[0, 0], [housing_r - 0.8, 0], [housing_r, 0.8], [housing_r, lid_z0], [0, lid_z0]]);
    translate([0, 0, gear_z0]) rotate(ring_phase)
      linear_extrude(gear_height + eps, convexity=4) gear2d(ring_teeth, 1.25 * m, m, backlash / 2);
    // pocket for the carrier plate, which rests on the ring teeth
    translate([0, 0, gear_z1]) cylinder(r=counterbore_r, h=lid_z0);
    for (a = tab_angles) rotate(a) tab_recess();
    for (a = window_angles) rotate(a) window();
    // floor opening inside the shelf, leaving the sun pin's hub and spokes in line with the lid tabs
    if (bottom_window) translate([0, 0, -eps])
      linear_extrude(floor_height + 2 * eps) spoked_window2d(hub_r, bottom_window_r, tab_angles);
  }
  // sun gear pivot
  cylinder(d=sun_pin_d, h=sun_pin_z1);
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

// Opening through the wall and ring teeth, centered on +X in the middle of the gear band
module window() {
  z0 = gear_z0 + (gear_height - window_height) / 2;
  r0 = pitch_r(ring_teeth) - m - 0.5;
  rotate(-window_angle / 2) rotate_extrude(angle=window_angle)
    translate([r0, z0]) square([housing_r + 1 - r0, window_height]);
}

// Annular opening from r_in to r_out, less a spoke along each of angles
module spoked_window2d(r_in, r_out, angles) {
  difference() {
    circle(r=r_out);
    circle(r=r_in);
    for (a = angles) rotate(a) translate([0, -spoke_width / 2]) square([r_out + 1, spoke_width]);
  }
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
    // gear ratio, reading outward along the arm
    translate([(pointer_hub_r + arm_length - arm_w) / 2, 0, pointer_z1 - engrave_depth]) linear_extrude(1)
      text(str(round(ratio * 10) / 10, ":1"), size=3.5, halign="center", valign="center", font="Liberation Sans:style=Bold");
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

// gap spreads the parts apart vertically; only limits it to one part (e.g. "planet1")
module assembly(gap=0, only="") {
  c = 360 * $t; // carrier
  s = c * ratio; // sun and crank
  if (only == "" || only == "housing") color("#4a6378") housing();
  translate([0, 0, gap]) {
    if (only == "" || only == "sun") color("#e8b83a") rotate(s) sun();
    for (i = [0:planet_count - 1]) {
      phi = i * 360 / planet_count;
      // meshes with the sun at s = 0, then rolls as the sun gains on the carrier
      spin = 180 - 180 / planet_teeth + (phi - (s - c)) * sun_teeth / planet_teeth;
      if (only == "" || only == str("planet", i))
        color("#e07a3a") rotate(c + phi) translate([center_distance, 0, 0]) rotate(spin) planet();
    }
  }
  if (only == "" || only == "carrier") translate([0, 0, 2 * gap]) color("#9aa5ad") rotate(c) carrier();
  if (only == "" || only == "lid") translate([0, 0, 3 * gap]) color("#5d7a91") lid();
  if (only == "" || only == "pointer") translate([0, 0, 4 * gap]) color("#d64545") rotate(c) pointer();
  if (only == "" || only == "crank") translate([0, 0, 5 * gap]) color("#9aa5ad") rotate(s) crank();
  if (only == "" || only == "knob") translate([0, 0, 6 * gap]) color("#2b2b2b") rotate(s) knob();
}

// One part, oriented for printing with its bottom at z = 0
module print_part(name) {
  if (name == "housing") housing();
  else if (name == "sun") translate([0, 0, -gear_z0 - z_gap]) sun();
  else if (name == "planet") translate([0, 0, -gear_z0 - z_gap]) planet();
  else if (name == "carrier") translate([0, 0, plate_z1]) rotate([180, 0, 0]) carrier();
  else if (name == "pointer") translate([0, 0, pointer_z1]) rotate([180, 0, 0]) pointer();
  else if (name == "lid") translate([0, 0, lid_z1]) rotate([180, 0, 0]) lid();
  else if (name == "crank") translate([0, 0, -crank_z0]) crank();
  else if (name == "knob") translate([-crank_length, 0, -knob_z0]) knob();
}

// Every printed piece as [part, [x, y]], laid out on one plate
print_layout = let(
  big = 2 * housing_r + 6,
  space = 4,
  planet_r = pitch_r(planet_teeth) + m,
  sun_r = pitch_r(sun_teeth) + m,
  row = -housing_r - planet_r - 6,
  // small parts left to right along one row
  sun_x = -housing_r + planet_count * (2 * planet_r + space) + sun_r,
  crank_x = sun_x + sun_r + space + crank_hub_r,
  knob_x = crank_x + crank_length + 5 + space + knob_d / 2
) concat(
  [["housing", [0, 0]], ["lid", [big, 0]], ["carrier", [0, big]], ["pointer", [big, big]]],
  [for (i = [0:planet_count - 1]) ["planet", [-housing_r + planet_r + i * (2 * planet_r + space), row]]],
  [["sun", [sun_x, row]], ["crank", [crank_x, row]], ["knob", [knob_x, row]]]
);

if (view == "assembly") assembly();
else if (view == "exploded") assembly(explode_gap);
else if (view == "print") {
  // looped at top level so --enable=lazy-union exports each piece as its own 3MF object
  if (part == "all") for (p = print_layout) translate(p[1]) print_part(p[0]);
  else print_part(part);
}
