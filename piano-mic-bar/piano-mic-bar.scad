// End bracket for a microphone bar across an upright piano (Yamaha U1): a rubber-lined U hooks
// over the top edge of a side panel, and a cup below it holds the end of a wooden closet rod.
// Origin: the side panel's inside face at its top edge, Y centred on the bracket. +X points into
// the piano along the rod, +Z up. Both ends use the same part, turned 180 degrees.
// Prints lying on its side (its -Y face down), so the U's profile is in the bed plane. The cup's
// round bore needs supports along its top in that orientation; the screw hole is small enough not to.
// Assembly: screw a bracket onto each end of the rod, then lower the bar in so the U's hook
// over both panels. The lid closes on top of the U's.

/* [View] */
view = "assembly"; // [assembly, section, print]
// section cuts the assembly through the middle of the bracket, looking from the front
// Piano side panels, lid and rod in the assembly view, for illustration
show_piano = true;
// Draw the lid closed on the brackets
show_lid = true;
// Brackets on the print plate: 1 for a test fit, 2 for the bar
copies = 1; // [1:1:2]
// Draw the room below the edge as a red plane at the top of the action
show_action = true;

/* [Piano (measured)] */
// Side panel thickness at its top edge, measured by Brian
panel_t = 23; // [10:0.1:50]
// Between the inside faces of the side panels, 1 in below the top edge, measured by Brian
inner_w = 1430; // [500:1:1600]
// How far the closed lid reaches past the outside of each side panel, measured by Brian
lid_overhang = 12.7; // [0:0.1:50]
// Room inside the piano below the top edge, measured by Brian
depth_below = 100; // [30:1:200]

/* [Rubber lining] */
// Everbilt 1/16 in rubber packaging sheet, glued on top of the U and inside it
rubber_t = 1.6; // [0.5:0.1:5]
// Clearance per side between the lined U and the panel
fit = 0.1; // [0:0.05:1]

/* [Rod] */
// Everbilt oak closet rod, sold as 1.3 in; MEASURE before printing
rod_d = 33.0; // [20:0.1:60]
// Clearance per side between the rod and the cup
rod_clearance = 0.3; // [0:0.05:1]
// Top of the rod below the panel's top edge, to leave room for the mics above it
rod_drop = 25.4; // [5:0.1:60]
// How far the rod goes into the cup
socket_depth = 25; // [10:1:60]

/* [Bracket] */
// The U's top, under the lid; the lid rises by this plus two rubber layers
web_t = 2; // [1.2:0.1:5]
outer_leg_t = 2; // [1.2:0.1:5]
// How far the outer leg reaches down the outside of the panel
outer_leg_l = 15; // [5:1:40]
// The inner leg is also the cup's end wall, so it has to hold the screw's countersunk head
inner_leg_t = 4; // [3:0.1:8]
cup_wall = 2.4; // [1.2:0.1:5]
// 45 degree chamfer on the cup's long edges
cup_chamfer = 3; // [0:0.5:6]
// Radius on the U's outside corners
corner_r = 2; // [0:0.5:4]
// 45 degree chamfer on the bed-side edges of the U's opening, for elephant's foot
bed_chamfer = 0.4; // [0:0.1:1]

/* [Screw] */
// #8 x 1-1/2 in flat-head (82 degree) wood screw along the rod's axis, into a 1/8 in pilot hole
// Clearance hole for #8 (0.164 in major diameter)
screw_d = 4.6; // [3:0.1:6]
// Countersink diameter at the face: #8 flat head is 0.332 in max (ASME B18.6.1), plus 0.4 mm
screw_head_d = 8.8; // [6:0.1:12]
screw_l = 38.1; // [20:0.1:60]

/* [Context (not measured)] */
// Depth of the side panels' top edge, front to back; illustration only
case_depth = 300; // [100:1:700]
// Where the bar sits along the panels, from the front; illustration only
bar_y = 150; // [0:1:700]
// Lid thickness; illustration only
lid_t = 18; // [5:1:40]
// How much of the side panels to draw below the top edge
panel_shown = 200; // [50:1:1200]

/* [Hidden] */
$fn = 96;
eps = 0.01;

s = rubber_t + fit; // lined clearance on each face of the panel
xi_in = s; // inner leg's panel-side face
xi = xi_in + inner_leg_t; // inner leg's rod-side face (the cup's end wall)
xo_in = -panel_t - s; // outer leg's panel-side face
xo = xo_in - outer_leg_t; // outer leg's outside face
z_web = rubber_t; // underside of the web, resting on the rubber on the panel's top edge
z_top = z_web + web_t;

bore_r = rod_d / 2 + rod_clearance;
cup_h = bore_r + cup_wall; // half-size of the cup's square section
width = 2 * cup_h; // bracket width along the panel (Y)
zc = -rod_drop - rod_d / 2; // rod axis
z_bottom = zc - cup_h;

countersink_h = (screw_head_d - screw_d) / 2 / tan(41);
rod_l = inner_w - 2 * xi;

assert(-z_bottom <= depth_below, "the cup reaches below the room inside the piano");
assert(countersink_h < inner_leg_t - 1, "inner_leg_t is too thin for the countersink");

echo(str("Rod length: ", rod_l, " mm (", rod_l / 25.4, " in)"));
echo(str("Lid rises: ", web_t + 2 * rubber_t, " mm"));
echo(str("Bracket: ", xi + socket_depth - xo, " x ", width, " x ", z_top - z_bottom, " mm"));

// The U and inner leg, in the XZ plane as [x, z]
// The outside corners are rounded by clipping to a rounded box
module profile() {
  intersection() {
    translate([xo + corner_r, z_bottom + corner_r])
      offset(r=corner_r) square([xi - xo - 2 * corner_r, z_top - z_bottom - 2 * corner_r]);
    polygon([
      [xo, -outer_leg_l],
      [xo, z_top],
      [xi, z_top],
      [xi, z_bottom],
      [xi_in, z_bottom],
      [xi_in, z_web],
      [xo_in, z_web],
      [xo_in, -outer_leg_l],
    ]);
  }
}

// Extrudes a shape in the XZ plane through Y = -h/2..h/2
module extrude_y(h) {
  rotate([90, 0, 0]) linear_extrude(h, center=true, convexity=4) children();
}

// Square with 45 degree chamfered corners, centred
module chamfered_square(size, c) {
  offset(delta=c, chamfer=true) square([size.x - 2 * c, size.y - 2 * c], center=true);
}

// Runs a shape in the YZ plane along +X from x, centred on the rod axis; its +Y stays +Y
module along_rod(x, l) {
  translate([x, 0, zc]) rotate([0, 90, 0]) linear_extrude(l) children();
}

module cup() {
  along_rod(xi_in, xi - xi_in + socket_depth) chamfered_square([2 * cup_h, 2 * cup_h], cup_chamfer);
}

// The U's opening, chamfered where it meets each Y face
module opening() {
  module open2d(d) translate([xo_in - d, -outer_leg_l - 1]) square([xi_in - xo_in + 2 * d, z_web + outer_leg_l + 1 + d]);
  for (m = [0, 1]) mirror([0, m, 0])
    hull() {
      translate([0, width / 2 - bed_chamfer, 0]) extrude_y(eps) open2d(0);
      translate([0, width / 2 + eps, 0]) extrude_y(eps) open2d(bed_chamfer + eps);
    }
}

// Round: small enough to print horizontally without supports; any sag at the top is in the
// screw's clearance
module screw_hole() {
  along_rod(xi_in - 1, inner_leg_t + 2) circle(d=screw_d);
  // countersink, widest at the panel-side face
  translate([xi_in - 1, 0, zc]) rotate([0, 90, 0]) {
    cylinder(d=screw_head_d, h=1 + eps);
    translate([0, 0, 1]) cylinder(d1=screw_head_d, d2=screw_d, h=countersink_h);
  }
}

module bracket() {
  difference() {
    union() {
      extrude_y(width) profile();
      cup();
    }
    opening();
    along_rod(xi, socket_depth + 1) circle(bore_r);
    screw_hole();
  }
}

// ---------------------------------------------------------------- assembly

// The rubber pieces for one bracket: on top of the web, on the panel's top edge, and on each face
module rubber() {
  translate([xo, -width / 2, z_top]) cube([xi - xo, width, rubber_t]);
  translate([xo_in, -width / 2, 0]) cube([xi_in - xo_in, width, rubber_t]);
  translate([-panel_t - rubber_t, -width / 2, -outer_leg_l]) cube([rubber_t, width, outer_leg_l]);
  translate([0, -width / 2, z_bottom]) cube([rubber_t, width, -z_bottom]);
}

// Flat-head screw with the top of its head at x = xi_in, pointing +X along the rod
module screw() {
  translate([xi_in, 0, zc]) rotate([0, 90, 0]) {
    cylinder(d1=screw_head_d - 0.4, d2=screw_d - 0.4, h=countersink_h);
    cylinder(d=screw_d - 0.4, h=screw_l);
  }
}

// In the section view, keeps only what is behind y (in the frame it's called from)
module clip(y) {
  if (view == "section")
    intersection() {
      children();
      translate([-2 * inner_w, y, -2 * depth_below]) cube([4 * inner_w, 2 * case_depth, 4 * depth_below]);
    }
  else children();
}

// One end of the bar in its own frame: bracket, rubber and screw
module end() {
  color("#4a6378") clip(0) bracket();
  color("#7a3b2e") clip(0) rubber();
  color("#b8bec4") clip(0) screw();
}

module assembly() {
  for (side = [-1, 1])
    translate([side * inner_w / 2, bar_y, 0]) rotate(side < 0 ? 0 : 180) end();
  if (show_piano) {
    color("#c8a26a") clip(bar_y) translate([-rod_l / 2, bar_y, zc]) rotate([0, 90, 0]) cylinder(d=rod_d, h=rod_l);
    color("#1a1a1a") clip(bar_y) for (side = [-1, 1])
      translate([side * (inner_w / 2 + panel_t / 2), case_depth / 2, -panel_shown / 2])
        cube([panel_t, case_depth, panel_shown], center=true);
    // top of the action: the room below the edge ends here
    if (show_action) color("#d04040", 0.25) translate([-inner_w / 2, 0, -depth_below - 2]) cube([inner_w, case_depth, 2]);
    if (show_lid) {
      lid_w = inner_w + 2 * (panel_t + lid_overhang);
      color("#1a1a1a", 0.35) clip(bar_y) translate([-lid_w / 2, 0, z_top + rubber_t]) cube([lid_w, case_depth, lid_t]);
    }
  }
}

if (view == "assembly" || view == "section") assembly();
else if (view == "print")
  // side by side; at top level so --enable=lazy-union exports each as its own 3MF object
  for (i = [0:copies - 1])
    translate([i * (xi + socket_depth - xo + 5), 0, cup_h]) rotate([90, 0, 0]) color("#4a6378") bracket();
