// LED control box: holds a 5 V power supply, with an IEC C14 inlet and switch on the -X end,
// a cable exit on the +X end, and a lid that slides in from +X along grooves and clicks shut.
// Origin: X/Y centred on the cavity, Z=0 at the underside; mm, +Z up.
// The box prints upright; the lid prints top face down.

/* [View] */
view = "assembly"; // [assembly, print]
// Part shown in print view
part = "all"; // [all, box, lid]
// Power supply and IEC socket in the assembly view, for illustration
show_hardware = true;

/* [Box] */
// Cavity below the lid (9 in)
inner_l = 228.6; // [100:0.1:240]
inner_w = 72.6; // [40:0.1:200]
// Cavity height below the lid (4 in)
inner_h = 101.6; // [40:0.1:200]
// Sides and floor
wall = 4; // [2:0.2:8]
// Outside corner radius; the inside corners are rounded to keep the wall even
corner_r = 8; // [0:0.5:20]

/* [Lid] */
lid_thickness = 3; // [2:0.2:6]
// How far the lid's edges reach into the grooves in the walls
groove_depth = 1.6; // [1:0.2:3]
// Wall above the lid that holds it down
lip = 1.2; // [0.8:0.2:3]
// Clearance per side for the sliding fits: lid in its grooves, snap bump in its notch
clearance = 0.2; // [0.1:0.05:0.5]

/* [Snap tab] */
// Cantilever cut into the lid's +X end; a bump under it clicks into a notch in the end wall
tab_width = 10; // [5:1:30]
tab_length = 25; // [10:1:50]
// Slot cut either side of the tab so it can flex
tab_gap = 1; // [0.6:0.1:3]
// Height of the bump; it also sets how far the tab lifts to open
bump = 0.8; // [0.4:0.1:1.5]
// Grip past the end wall for lifting the tab
tab_pull = 4; // [2:0.5:10]

/* [Power supply] */
// Length (X), width (Y), height (Z); it stands on the floor against the -Y wall
psu_size = [143, 59, 40];
// Centre along X
psu_x = 0; // [-50:1:50]
// Screw holes in its -Y side: inset from each end (3/16 in), height above its base (5/8 in below its top)
psu_screw_inset = 4.7625;
psu_screw_z = 24.125;
psu_screw_d = 3.175;
// Added to screw diameters for the holes in the box
screw_clearance = 0.4; // [0:0.05:0.8]

/* [IEC socket] */
// C14 inlet with rocker switch and fuse, screwed on from outside the -X end.
// Flange width (Y), height (Z), thickness. Height from the BC Robotics listing for this module
// style (58.6 x 49.1 mm flange); not measured on the part in hand.
iec_frame = [58.3, 49.1, 2.4];
// Body behind the flange: width (Y), height (Z), depth
iec_body = [46.8, 27, 16.5];
// Narrower end of the body, toward +Y: width, height
iec_neck = [6.35, 14.2875];
// Flange screw holes, above and below the body
iec_screw_spacing = 40; // [30:0.5:50]
iec_screw_d = 4.5; // [2:0.1:6]
// Socket centre above the inside floor; the default centres it on the end wall
iec_z = 50.8; // [30:0.5:75]
// Clearance per side around the body in the cutout
iec_clearance = 0.3; // [0:0.05:1]

/* [Cable exit] */
// Hole in the +X end for the LED output; 12.5 fits a PG7 cable gland (3-6.5 mm cable)
cable_d = 12.5; // [3:0.5:25]
// Centre above the inside floor
cable_z = 20; // [8:1:80]

/* [Vents] */
// Vertical slots through the long walls, spread along the power supply
vent_width = 3; // [2:0.5:6]
vent_pitch = 8; // [5:0.5:15]
// Rows as [wall (1 = +Y, -1 = -Y), bottom, top] above the inside floor. The power supply
// covers the -Y wall up to 40 mm, so that wall only gets the upper row.
vent_rows = [[1, 8, 36], [1, 55, 90], [-1, 55, 90]];

/* [Hidden] */
$fa = 2;
$fs = 0.4;
eps = 0.01;

outer = [inner_l + 2 * wall, inner_w + 2 * wall];
inner_r = max(corner_r - wall, 0);
x_end = inner_l / 2 + wall; // +X outside face
z_lid = wall + inner_h; // lid underside
z_top = z_lid + lid_thickness + clearance + lip;
// Vertical face of the snap bump when the lid is closed, mid-way through the +X end wall
x_notch = inner_l / 2 + wall / 2;
// Bump under the tab in the XZ plane, relative to the lid underside: ramp on the -X side for
// sliding in, square on +X so it holds until the tab is lifted
bump_profile = [[x_notch - bump, eps], [x_notch, eps], [x_notch, -bump]];
psu_center = [psu_x, -inner_w / 2 + psu_size.y / 2, wall + psu_size.z / 2];

assert(wall - groove_depth >= 1.2, "groove leaves less than 1.2 mm of wall behind it");
assert(lid_thickness - groove_depth >= 1, "lid's edges are under 1 mm thick in the grooves");
assert(vent_rows == [] || max([for (r = vent_rows) r[2]]) < inner_h - clearance,"vents reach the lid grooves");
assert(iec_z + iec_frame.y / 2 < inner_h, "IEC flange sticks up past the lid");

// ---------------------------------------------------------------- shapes

module rounded_rect(size, r) {
  offset(r) offset(-r) square(size, center=true);
}

// Circle with a 45 degree point toward +Y, so a horizontal hole prints without sagging
module teardrop(d) {
  circle(d=d);
  polygon([[0, d / 2 * sqrt(2)], [d / 2 * cos(45), d / 2 * sin(45)], [-d / 2 * cos(45), d / 2 * sin(45)]]);
}

// Teardrop holes through a wall, pointing up; p is the centre of the hole
module hole_x(p, d, length) {
  translate(p) rotate([90, 0, 90]) linear_extrude(length, center=true) teardrop(d);
}
module hole_y(p, d, length) {
  translate(p) rotate([90, 0, 0]) linear_extrude(length, center=true) teardrop(d);
}

// Cavity outline grown by grow, with its -X corners rounded concentric with the box's and its
// +X end squared off at x1
module lid2d(grow, x1) {
  hull() {
    rounded_rect([inner_l + 2 * grow, inner_w + 2 * grow], inner_r + grow);
    translate([x1 - eps, -inner_w / 2 - grow]) square([eps, inner_w + 2 * grow]);
  }
}

// Lid grown by c on every face, running to x1 at its +X end: full width until groove_depth
// below its top, then a 45 degree bevel in to the opening. c = 0 is the lid; c = clearance
// cuts the grooves.
module lid_volume(c, x1) {
  g = groove_depth;
  hull() {
    translate([0, 0, z_lid - c]) linear_extrude(lid_thickness - g + 2 * c) lid2d(g + c, x1);
    translate([0, 0, z_lid + lid_thickness + c - eps]) linear_extrude(eps) lid2d(c, x1);
  }
}

// IEC socket body outline in the YZ plane, centred on the socket
module iec_body2d() {
  hull() {
    translate([-iec_neck.x / 2, 0]) square([iec_body.x - iec_neck.x, iec_body.y], center=true);
    translate([iec_body.x / 2 - iec_neck.x / 2, 0]) square(iec_neck, center=true);
  }
}

// ---------------------------------------------------------------- box

// Where the snap bump sits when the lid is closed
module snap_notch() {
  translate([0, 0, z_lid]) rotate([90, 0, 0]) linear_extrude(tab_width + 2 * clearance, center=true) {
    offset(delta=clearance) polygon(bump_profile);
    translate([x_notch - bump - 2 * clearance, 0]) square([bump + 3 * clearance, 1]);
  }
}

module iec_cutout() {
  translate([-x_end - 1, 0, wall + iec_z]) rotate([90, 0, 90])
    linear_extrude(wall + 2) offset(delta=iec_clearance) iec_body2d();
  for (s = [-1, 1])
    hole_x([-x_end + wall / 2, 0, wall + iec_z + s * iec_screw_spacing / 2], iec_screw_d, wall + 2);
}

module psu_screw_holes() {
  for (s = [-1, 1])
    hole_y(
      [psu_x + s * (psu_size.x / 2 - psu_screw_inset), -inner_w / 2 - wall / 2, wall + psu_screw_z],
      psu_screw_d + screw_clearance, wall + 2
    );
}

module vents() {
  n = floor((psu_size.x - vent_width) / vent_pitch) + 1;
  for (r = vent_rows, i = [0:n - 1])
    translate([
      psu_x + (i - (n - 1) / 2) * vent_pitch - vent_width / 2,
      r[0] * (inner_w / 2 + wall / 2) - wall / 2 - 1,
      wall + r[1],
    ])
      cube([vent_width, wall + 2, r[2] - r[1]]);
}

module box() {
  difference() {
    linear_extrude(z_top) rounded_rect(outer, corner_r);
    translate([0, 0, wall]) linear_extrude(z_top) rounded_rect([inner_l, inner_w], inner_r);
    // grooves the lid slides along, open through the +X end
    lid_volume(clearance, x_end + 1);
    // +X end, corners included, cut down to the lid's underside so the lid slides in over it
    translate([inner_l / 2 - eps, -outer.y / 2 - 1, z_lid - clearance]) cube([wall + 1, outer.y + 2, z_top]);
    snap_notch();
    iec_cutout();
    psu_screw_holes();
    hole_x([x_end - wall / 2, 0, wall + cable_z], cable_d, wall + 2);
    vents();
  }
}

// ---------------------------------------------------------------- lid

// Plate in the grooves, widening past them over the +X end wall to become the box's top corners
module lid() {
  difference() {
    intersection() {
      union() {
        lid_volume(0, x_end);
        translate([inner_l / 2 + clearance, -outer.y / 2, z_lid]) cube([wall - clearance, outer.y, lid_thickness]);
      }
      linear_extrude(z_top) rounded_rect(outer, corner_r);
    }
    // slots either side of the snap tab, open at the +X end
    for (s = [-1, 1])
      translate([x_end - tab_length, s * (tab_width + tab_gap) / 2 - tab_gap / 2, z_lid - 1])
        cube([tab_length + 1, tab_gap, lid_thickness + 2]);
  }
  translate([x_end - eps, -tab_width / 2, z_lid]) cube([tab_pull + eps, tab_width, lid_thickness]);
  translate([0, 0, z_lid]) rotate([90, 0, 0]) linear_extrude(tab_width, center=true) polygon(bump_profile);
}

// ---------------------------------------------------------------- hardware
// Bought parts, for checking fit; neither is printed.

// Centred on its bounding box. Terminal recesses at each end, open to +Y and the top.
module power_supply() {
  recess = 11;
  case_wall = 2;
  difference() {
    cube(psu_size, center=true);
    for (s = [-1, 1])
      translate([s * (psu_size.x - recess) / 2, case_wall / 2, case_wall / 2])
        cube([recess + eps, psu_size.y - case_wall + eps, psu_size.z - case_wall + eps], center=true);
  }
}

// Flange's back face at x = 0, body toward +X, centred on the socket
module iec_socket() {
  difference() {
    translate([-iec_frame.z, -iec_frame.x / 2, -iec_frame.y / 2]) cube([iec_frame.z, iec_frame.x, iec_frame.y]);
    for (s = [-1, 1])
      translate([0, 0, s * iec_screw_spacing / 2]) rotate([0, 90, 0])
        cylinder(d=iec_screw_d, h=2 * iec_frame.z + 1, center=true);
  }
  rotate([90, 0, 90]) linear_extrude(iec_body.z) iec_body2d();
}

// ---------------------------------------------------------------- views

module assembly() {
  color("#4a6378") box();
  color("#5d7a91") lid();
  if (show_hardware) {
    color("#9aa5ad") translate(psu_center) power_supply();
    color("#2b2b2b") translate([-x_end, 0, wall + iec_z]) iec_socket();
  }
}

// One part, oriented for printing with its bottom at z = 0
module print_part(name) {
  if (name == "box") box();
  // top face down
  else if (name == "lid") translate([0, 0, z_lid + lid_thickness]) rotate([180, 0, 0]) lid();
}

// Lid beside the box with at least 5 mm between them
print_layout = [["box", [0, 0]], ["lid", [0, outer.y + 5]]];

if (view == "assembly") assembly();
else if (view == "print") {
  // looped at top level so --enable=lazy-union exports each piece as its own 3MF object
  if (part == "all") for (p = print_layout) translate(p[1]) print_part(p[0]);
  else print_part(part);
}
