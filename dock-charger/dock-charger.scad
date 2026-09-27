// Dock charger U-bracket: clamps over an edge, with a back plate for mounting the charger.
// Origin: X centered on the width, Y centered in the clamp gap, Z=0 at the underside of the top.
// Prints standing on its -X end; pockets and teardrop holes are shaped for that.
// The charger bolts on first (its nuts are captive on the board side), then the bracket
// drops over the board and bolts through it into nuts trapped under the charger.

/* [View] */
view = "assembly"; // [assembly, exploded, print]
// Charger, bolts and board in the assembly views, for illustration
show_hardware = true;
explode_gap = 40; // [0:1:100]

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
// How far the plate extends below the legs; reaches past the charger's lower holes
plate_drop = 75; // [0:1:150]
plate_thickness = 14; // [5:0.5:30]

/* [Bolts through the board] */
// Clearance for M6 bolts through both legs and the board
screw_d = 7; // [2:0.5:12]
// Solid area kept around each bolt for its washer on the front face
washer_d = 20; // [0:0.5:30]
// Captive nut in the back face, under the charger (M6, ISO 4032)
bolt_nut_af = 10; // [4:0.1:20]
bolt_nut_h = 5.2; // [2:0.1:10]
// Bolt length; the nut pocket is as deep as it takes for the bolt to end just past the nut
bolt_l = 65; // [20:5:120]
screw_x = [-75, 0, 75];
screw_z = -50;

/* [Charger] */
// Battery Tender 022-0258-DL-WH body, from Battery Tender's product photos (7.5 x 5.5 x 1.75 in)
charger_l = 190.5; // [100:0.5:300]
charger_w = 139.7; // [50:0.5:200]
charger_h = 44.5; // [10:0.5:100]
// Mounting holes, two on each wing along the long edges. ESTIMATED from product photos, not measured.
// Spacing of the two holes on one wing
hole_dx = 90; // [20:0.5:200]
// Spacing between the two wings' holes
hole_dz = 150; // [50:0.5:200]
// Height of the upper row of holes; the lower row is hole_dz below
hole_z = -12; // [-100:0.5:-8]
// Wing thickness (estimated from photos)
wing_t = 3; // [1:0.5:10]

/* [Charger screws] */
// Clearance for M5 screws
charger_screw_d = 5.5; // [2:0.1:10]
// Screw length under the head
charger_screw_l = 20; // [8:1:40]
// Captive nut on the board side (M5, ISO 4032)
charger_nut_af = 8; // [4:0.1:20]
charger_nut_h = 4.7; // [2:0.1:10]
// Solid plastic between the charger and each nut
nut_seat = 8; // [3:0.5:15]
// Extra space per side around captive nuts
nut_clearance = 0.15; // [0:0.05:0.5]

/* [Pockets] */
// Material removed as Warren-truss triangles; ribs run along the width and at 45 degrees
pockets = true;
rib = 4; // [2:0.5:10]
// Solid margin (rib centerline) around the edge of each pocketed face
border = 6; // [3:0.5:15]
// Solid wall left on the board side of the back-leg and plate pockets
skin = 4; // [2:0.5:10]
front_rows = 3; // [1:1:4]
back_rows = 3; // [1:1:4]
plate_rows = 2; // [1:1:3]

/* [Reference] */
// 2x6 drawn in the assembly view: standard dressed-lumber size, not measured
board_t = 38.1; // [20:0.1:60]
board_h = 139.7; // [50:0.1:300]

/* [Hidden] */
$fn = 64;
eps = 0.01;

front_y = -gap / 2 - front_thickness;
back_y = gap / 2 + back_thickness;
through = back_y - front_y + 2;
x_half = width / 2 - border; // rib centerline at the ends

// Standard sizes of the hardware drawn in the assembly: ISO 4017 heads, ISO 7089 washers
bolt_head = [10, 4]; // M6 [across flats, height]
bolt_washer = [12, 1.6]; // M6 [outer diameter, thickness]
charger_screw_head = [8, 3.5]; // M5
charger_washer = [10, 1]; // M5
hardware_color = "#b8bec4";

// Through-bolt's end, and where its nut seats (pulled toward the head)
bolt_end_y = front_y - bolt_washer[1] + bolt_l;
bolt_nut_y = bolt_end_y - 0.5 - bolt_nut_h;
assert(bolt_end_y <= back_y, "bolt_l is too long: the bolt would stick out under the charger");
assert(bolt_nut_y >= back_y - back_thickness + 2, "bolt_l is too short to reach a nut in the back leg");

// Charger screw's end, and the face its nut seats against
charger_screw_end_y = back_y + wing_t + charger_washer[1] - charger_screw_l;
charger_nut_y = back_y - nut_seat;
assert(charger_screw_end_y <= charger_nut_y - charger_nut_h, "charger_screw_l is too short to go through the nut");
assert(charger_screw_end_y > board_t / 2, "charger_screw_l is too long: it would hit the board");

charger_holes = [for (sx = [-1, 1], z = [hole_z, hole_z - hole_dz]) [sx * hole_dx / 2, z]];
charger_z = hole_z - hole_dz / 2; // center of the charger on the back face

// Across-corners size of a nut pocket
function nut_pocket(af) = (af + 2 * nut_clearance) / cos(30);

// Keep-outs pockets must clear by a rib: [sample points [x, z], radius]
bolt_keepouts = [for (x = screw_x) [[[x, screw_z]], washer_d / 2]];
charger_keepouts = [for (h = charger_holes) [[h], nut_pocket(charger_nut_af) / 2]];

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

// Circle with a 45 degree point toward +X, so a horizontal hole prints without sagging
module teardrop(d) {
  circle(d=d);
  polygon([[d / 2 * sqrt(2), 0], [d / 2 * cos(45), d / 2 * sin(45)], [d / 2 * cos(45), -d / 2 * sin(45)]]);
}

// Nut pocket with flats toward +X, so its roof prints as a short bridge
module nut_hex(af) {
  rotate(30) circle(d=nut_pocket(af), $fn=6);
}

// Bolt hole along Y through both legs, with a captive nut pocket in the back face
module screw_hole(x) {
  translate([x, 0, screw_z]) rotate([-90, 0, 0]) {
    translate([0, 0, front_y - 1]) linear_extrude(through) teardrop(screw_d);
    translate([0, 0, bolt_nut_y]) linear_extrude(back_y - bolt_nut_y + 1) nut_hex(bolt_nut_af);
  }
}

// Charger screw hole along Y through the back leg/plate, with a captive nut pocket on the board side
module charger_hole(x, z) {
  translate([x, 0, z]) rotate([-90, 0, 0]) {
    translate([0, 0, gap / 2 - 1]) linear_extrude(back_y - gap / 2 + 2) teardrop(charger_screw_d);
    translate([0, 0, gap / 2 - 1]) linear_extrude(back_y - nut_seat - gap / 2 + 1) nut_hex(charger_nut_af);
  }
}

// ---------------------------------------------------------------- pockets
// Triangles are [[x, z], [x, z], [x, z]] on a face in the XZ plane.

// Warren truss between rib centerlines z0..z1: rows of alternating up/down triangles
// with 45 degree sides, symmetric about x = 0
function truss(z0, z1, rows) =
  let(h = (z1 - z0) / rows, n = ceil(x_half / h) + 1)
  [
    for (r = [0:rows - 1], k = [-n:n])
      let(zl = z0 + r * h, zh = zl + h, c = k * h)
        abs(k) % 2 == 0 ? [[c - h, zl], [c + h, zl], [c, zh]] : [[c - h, zh], [c + h, zh], [c, zl]],
  ];

// Shrinks a triangle toward its incenter so its edges move in by d
function inset(t, d) =
  let(
    a = norm(t[1] - t[2]),
    b = norm(t[0] - t[2]),
    c = norm(t[0] - t[1]),
    center = (a * t[0] + b * t[1] + c * t[2]) / (a + b + c),
    inradius = abs(cross(t[1] - t[0], t[2] - t[0])) / (a + b + c),
    k = (inradius - d) / inradius
  ) [for (v = t) center + k * (v - center)];

function segment_distance(p, a, b) =
  let(ab = b - a, s = max(0, min(1, (p - a) * ab / (ab * ab)))) norm(p - (a + s * ab));
function inside(p, t) =
  let(s = [for (i = [0:2]) cross(t[(i + 1) % 3] - t[i], p - t[i])]) min(s) >= 0 || max(s) <= 0;
function triangle_distance(p, t) =
  inside(p, t) ? 0 : min([for (i = [0:2]) segment_distance(p, t[i], t[(i + 1) % 3])]);

// A pocket is kept only if it is whole (inside the end ribs) and clears every keep-out by a rib
function clear(t, keepouts) =
  let(gaps = [for (k = keepouts, p = k[0]) triangle_distance(p, t) - k[1]])
    max([for (v = t) abs(v[0])]) <= x_half - rib / 2 && (gaps == [] || min(gaps) >= rib);

module pockets2d(z0, z1, rows, keepouts) {
  for (t = truss(z0, z1, rows)) let(p = inset(t, rib / 2)) if (clear(p, keepouts)) polygon(p);
}

// Extrudes a 2D shape in the XZ plane through y_from..y_to
module face_cut(y_from, y_to) {
  translate([0, y_to, 0]) rotate([90, 0, 0]) linear_extrude(y_to - y_from) children();
}

module lightening() {
  plate_top = -leg_length - rib / 2; // plate pockets stop a rib below the legs
  // windows through the front leg
  face_cut(front_y - 1, -gap / 2 + 1)
    pockets2d(-leg_length + border, -border, front_rows, bolt_keepouts);
  // pockets in the back leg, open to the charger face
  face_cut(gap / 2 + skin, back_y + 1)
    pockets2d(-leg_length + border, -border, back_rows, concat(bolt_keepouts, charger_keepouts));
  // pockets in the plate below the legs, open to the charger face
  if (plate_drop > 2 * border)
    face_cut(back_y - plate_thickness + skin, back_y + 1)
      pockets2d(-leg_length - plate_drop + border, plate_top, plate_rows, charger_keepouts);
}

// colors paints each kind of cut, since faces left by a coloured cutter keep its colour
module bracket(colors=false) {
  module paint(c) if (colors) color(c) children(); else children();
  difference() {
    paint("#4a6378") body();
    paint("#e8b83a") {
      for (x = screw_x) screw_hole(x);
      for (h = charger_holes) charger_hole(h[0], h[1]);
    }
    if (pockets) paint("#e07a3a") lightening();
  }
}

// ---------------------------------------------------------------- hardware

// Rounded rectangle centered on the origin
module rounded_rect(size, r) {
  offset(r) square([size.x - 2 * r, size.y - 2 * r], center=true);
}

// Charger lying on its base: long axis along X, wings along the long edges at +-Y, base at Z=0
module charger() {
  corner_r = 25; // plan-view corner radius, from photos
  taper = 8; // how far the top edges sit in from the base, from photos
  tab_d = 14; // wing tab width around each hole, from photos
  cord_d = 12; // cord strain relief at each end
  holes = [for (h = charger_holes) [h[0], h[1] - charger_z]];
  difference() {
    union() {
      hull() {
        linear_extrude(eps) rounded_rect([charger_l, charger_w], corner_r);
        translate([0, 0, charger_h - eps])
          linear_extrude(eps) rounded_rect([charger_l - 2 * taper, charger_w - 2 * taper], corner_r - taper);
      }
      for (h = holes)
        linear_extrude(wing_t) hull() {
          translate(h) circle(d=tab_d);
          translate([h.x, sign(h.y) * charger_w / 4]) square([tab_d, 1], center=true);
        }
      for (s = [-1, 1])
        translate([s * (charger_l / 2 - taper), 0, charger_h / 2]) rotate([0, s * 90, 0]) cylinder(d=cord_d, h=25);
    }
    for (h = holes) translate([h.x, h.y, -1]) cylinder(d=charger_screw_d, h=wing_t + 2);
  }
}

// Hex bolt along +Z with the underside of its head at Z=0; head = [across flats, height]
module hex_bolt(d, l, head) {
  translate([0, 0, -head[1]]) rotate(30) cylinder(d=head[0] / cos(30), h=head[1], $fn=6);
  cylinder(d=d, h=l);
}

// Nut along +Z from Z=0, flats toward +X like its pocket
module nut(d, af, h) {
  difference() {
    rotate(30) cylinder(d=af / cos(30), h=h, $fn=6);
    translate([0, 0, -1]) cylinder(d=d, h=h + 2);
  }
}

// Washer along +Z from Z=0; size = [outer diameter, thickness]
module washer(d, size) {
  difference() {
    cylinder(d=size[0], h=size[1]);
    translate([0, 0, -1]) cylinder(d=d + 0.4, h=size[1] + 2);
  }
}

// Places children on a hole at [x, z] with their +Z along +Y
module on_hole(x, z) {
  translate([x, 0, z]) rotate([-90, 0, 0]) children();
}

// Hardware for one through-bolt: head and washer on the front face, nut in the back face
module bolt_set(x, g=0) {
  on_hole(x, screw_z) {
    translate([0, 0, front_y - bolt_washer[1] - 2 * g]) hex_bolt(6, bolt_l, bolt_head);
    translate([0, 0, front_y - bolt_washer[1] - g]) washer(6, bolt_washer);
    translate([0, 0, bolt_nut_y + g / 2]) nut(6, bolt_nut_af, bolt_nut_h);
  }
}

// Hardware for one charger screw: head and washer on the wing, nut in its pocket on the board side
module charger_screw_set(x, z, g=0) {
  on_hole(x, z) {
    top = back_y + wing_t;
    translate([0, 0, top + charger_washer[1] + 2.5 * g]) rotate([180, 0, 0]) hex_bolt(5, charger_screw_l, charger_screw_head);
    translate([0, 0, top + 2 * g]) washer(5, charger_washer);
    translate([0, 0, charger_nut_y - charger_nut_h - g / 2]) nut(5, charger_nut_af, charger_nut_h);
  }
}

// g spreads the parts apart: the charger and its screws out the back, the bolts out the front,
// and the board down out of the clamp
module assembly(g=0) {
  bracket(colors=true);
  if (show_hardware) {
    color("#2b2b2b") translate([0, back_y + 1.5 * g, charger_z]) rotate([-90, 0, 0]) charger();
    color(hardware_color) {
      for (x = screw_x) bolt_set(x, g);
      for (h = charger_holes) charger_screw_set(h[0], h[1], g);
    }
    color("#c8a26a", 0.4) translate([0, 0, -board_h / 2 - (g > 0 ? leg_length + g : 0)])
      cube([width + 100, board_t, board_h], center=true);
  }
}

// print view stands it on its -X end
if (view == "print") translate([0, 0, width / 2]) rotate([0, -90, 0]) bracket();
else if (view == "assembly") assembly();
else if (view == "exploded") assembly(explode_gap);
