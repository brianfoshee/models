// Self-watering pot: an outer pot and a soil insert in one print. The insert's underside
// is a 45 degree cone rising from a solid stem on the pot floor; the space between is the
// water reservoir. A rubber tube holding the wick presses down through a collar in the
// cone and hangs into the water. Water is poured into the gap between the walls through an opening in the rim, closed by a cap.
// Origin: pot axis on Z, Z=0 at the underside, the fill opening centred on +X; mm, +Z up.

/* [View] */
view = "assembly"; // [assembly, cutaway, print]
// Part shown in print view
part = "all"; // [all, pot, cap]

/* [Pot] */
// Outside diameter at the rim; 176 leaves margin on an A1 mini's 180 mm bed
pot_d = 176; // [80:1:250]
// Outside diameter at the base; less than pot_d tapers the sides
base_d = 150; // [60:1:250]
height = 176; // [60:1:250]
// Outer wall; it holds water, so leave room for several perimeters
wall = 2.4; // [1.2:0.2:5]
floor_thickness = 3; // [1.2:0.2:6]

/* [Insert] */
// Water gap between the pot wall and the insert, just under the rim
gap = 10; // [4:0.5:20]
// Inward lean of the insert wall from vertical; the gap widens toward the bottom
insert_taper = 10; // [0:1:40]
insert_wall = 2; // [1.2:0.2:4]
// Solid rim over the gap, above its 45 degree underside
rim_height = 4; // [2:0.5:10]
// Height of the soil's lowest point (the cone's tip) above the pot floor
reservoir_depth = 40; // [10:1:100]
// Post under the cone's tip
stem_d = 16; // [6:1:40]

/* [Wick tube] */
// PLACEHOLDER, not measured: set to the rubber tube's outside diameter
tube_od = 8; // [3:0.5:20]
// Clearance per side around the tube; negative squeezes it to seal
tube_clearance = 0; // [-0.5:0.05:0.5]
// Collar gripping the tube, measured up from the cone at the tube's centre
tube_grip = 8; // [0:1:30]

/* [Fill opening and cap] */
// Arc of the rim opened for pouring
opening_angle = 20; // [5:1:60]
// Clearance per side between the cap and the opening
cap_clearance = 0.2; // [0:0.05:0.5]
// Cap top plate, flush in a recess in the rim
cap_lip = 1.6; // [0.8:0.2:3]
// 45-degree chamfer on the lip's top edge, which prints on the bed, against elephant's foot
cap_chamfer = 0.4; // [0:0.1:1]
// How far the lip reaches past the opening's edges
cap_overlap = 1; // [0.5:0.1:3]
// Plug length below the lip
cap_plug = 8; // [2:0.5:20]
// Fingernail notch at the end of the recess for lifting the cap
notch_d = 6; // [0:0.5:12]

/* [Cutaway] */
// Show the tube and wick, for illustration only
show_wick = true;

/* [Hidden] */
$fa = 1;
$fs = 0.4;
eps = 0.01;

H = height;
k = (pot_d - base_d) / 2 / H; // outward taper per mm of height
t = tan(insert_taper); // insert wall's outward lean per mm of height
stem_r = stem_d / 2;
z_soil = floor_thickness + reservoir_depth;
// horizontal thickness of the cone wall for a perpendicular insert_wall at 45 degrees
cone_t = insert_wall * sqrt(2);

// Rim underside: tall enough that it overhangs no more than 45 degrees across the taper
z_roof_top = H - rim_height;
z_roof_bot = z_roof_top - gap / (1 - k);

// Wall surfaces: radius at height z
function r_out(z) = base_d / 2 + k * z;
function r_pot_in(z) = r_out(z) - wall;
function r_ins_out(z) = r_pot_in(z_roof_bot) - gap - t * (z_roof_bot - z);
function r_ins_in(z) = r_ins_out(z) - insert_wall / cos(insert_taper);

// Cone surfaces rise at 45 degrees from the tip at z_soil; they meet the leaning insert
// wall at z where r0 + (z - z_soil) = r_wall(0) + t * z
z_cone_in = (r_ins_in(0) + z_soil) / (1 - t);
z_cone_out = (r_ins_out(0) - cone_t + z_soil) / (1 - t);
z_stem = z_soil + stem_r - cone_t; // outer cone meets the stem

// Tube hole on +X, below the fill opening; the hanging tube clears the stem by 2 mm
tube_x = stem_r + tube_od / 2 + 2;
z_collar_top = z_soil + tube_x + tube_grip;

r_mid = (r_ins_out(H) + r_pot_in(H)) / 2; // middle of the gap at the rim
function deg(mm) = mm / r_mid * 180 / PI; // arc length at r_mid to degrees
recess_angle = opening_angle + 2 * deg(cap_overlap);

assert(cap_chamfer < cap_lip, "cap_chamfer must be less than cap_lip");

// ---------------------------------------------------------------- pot

// Half cross-section in the XZ plane, as [r, z] points
module section() {
  difference() {
    polygon([[0, 0], [r_out(0), 0], [r_out(H), H], [0, H]]);
    // reservoir
    polygon([
      [stem_r, floor_thickness],
      [r_pot_in(floor_thickness), floor_thickness],
      [r_pot_in(z_roof_top), z_roof_top],
      [r_ins_out(z_roof_bot), z_roof_bot],
      [r_ins_out(z_cone_out), z_cone_out],
      [stem_r, z_stem],
    ]);
    // soil
    polygon([
      [0, z_soil],
      [r_ins_in(z_cone_in), z_cone_in],
      [r_ins_in(H + 1), H + 1],
      [0, H + 1],
    ]);
  }
}

// Ring sector of a [r, z] profile, centred on +X
module sector(angle) {
  rotate(-angle / 2) rotate_extrude(angle=angle) children();
}

// Annular sector in the XY plane from radius r0 to r1, centred on +X
module sector2d(angle, r0, r1) {
  R = r1 / cos(angle / 2) + 1;
  intersection() {
    difference() {
      circle(r=r1);
      circle(r=r0);
    }
    polygon([[0, 0], [R * cos(angle / 2), -R * sin(angle / 2)], [R * cos(angle / 2), R * sin(angle / 2)]]);
  }
}

// linear_extrude with the top edge chamfered by cap_chamfer, in 0.1 mm steps
module top_chamfered_extrude(height) {
  n = ceil(cap_chamfer / 0.1);
  step = n > 0 ? cap_chamfer / n : 0;
  linear_extrude(height - cap_chamfer + (n > 0 ? eps : 0)) children();
  for (i = [0:1:n - 1])
    translate([0, 0, height - cap_chamfer + i * step])
      linear_extrude(step + (i < n - 1 ? eps : 0)) offset(delta=-(i + 1) * step) children();
}

module fill_opening() {
  // the gap between the walls, widened by eps into each
  sector(opening_angle)
    polygon([
      for (z = [z_roof_bot - 1, H + 1]) [r_pot_in(z) + eps, z],
      for (z = [H + 1, z_roof_bot - 1]) [r_ins_out(z) - eps, z],
    ]);
  // recess for the cap's lip
  sector(recess_angle)
    translate([r_ins_out(H) - cap_overlap, H - cap_lip])
      square([r_pot_in(H) - r_ins_out(H) + 2 * cap_overlap, cap_lip + 1]);
  if (notch_d > 0)
    rotate(recess_angle / 2) translate([r_mid, 0, H - cap_lip - 1]) cylinder(d=notch_d, h=cap_lip + 2);
}

// Sleeve around the tube hole, rising from the middle of the cone wall into the soil
module tube_collar() {
  zm = z_soil - cone_t / 2; // mid-wall height on the axis
  R = r_out(H);
  intersection() {
    translate([tube_x, 0, 0]) cylinder(d=tube_od + 2 * insert_wall, h=z_collar_top);
    rotate_extrude() polygon([[0, zm], [R, zm + R], [0, zm + R]]);
  }
}

module tube_hole() {
  translate([tube_x, 0, floor_thickness + 1]) cylinder(d=tube_od + 2 * tube_clearance, h=z_collar_top);
}

module pot() {
  difference() {
    union() {
      rotate_extrude() section();
      tube_collar();
    }
    fill_opening();
    tube_hole();
  }
}

// ---------------------------------------------------------------- cap

// In place in the opening. The plug's sides are vertical, clearing the insert wall at its
// top and the pot wall at its bottom, where each leans in closest.
module cap() {
  c = cap_clearance;
  z0 = H - cap_lip - cap_plug;
  z1 = H - cap_lip;
  sector(opening_angle - 2 * deg(c))
    translate([r_ins_out(z1) + c, z0]) square([r_pot_in(z0) - r_ins_out(z1) - 2 * c, cap_plug + eps]);
  translate([0, 0, z1]) top_chamfered_extrude(cap_lip)
    sector2d(recess_angle - 2 * deg(c), r_ins_out(H) - cap_overlap + c, r_pot_in(H) + cap_overlap - c);
}

// ---------------------------------------------------------------- views

module assembly() {
  color("#c96f4a") pot();
  color("#6b8f71") cap();
}

// Removes the quadrant between -Y and +X, slicing through the fill opening and cap
module cutaway() {
  difference() {
    assembly();
    color("#e8b83a") translate([0, -pot_d, -1]) cube([pot_d, pot_d, H + 2]);
  }
  // tube from the collar down to near the floor; wick from the soil, out the tube's end
  // and along the floor
  if (show_wick) translate([tube_x, 0, 0]) {
    z_tube = floor_thickness + 12;
    wick_d = tube_od / 2;
    color("#3a3a3a") translate([0, 0, z_tube]) cylinder(d=tube_od, h=z_collar_top + 5 - z_tube);
    color("#f2ede3") translate([0, 0, floor_thickness + wick_d / 2 + 0.1]) {
      cylinder(d=wick_d, h=z_collar_top + 25 - floor_thickness);
      sphere(d=wick_d);
      rotate([0, 90, 0]) cylinder(d=wick_d, h=40);
    }
  }
}

// One part, oriented for printing with its bottom at z = 0
module print_part(name) {
  if (name == "pot") pot();
  // lip face down
  else if (name == "cap") translate([0, 0, H]) rotate([180, 0, 0]) translate([-r_mid, 0, 0]) cap();
}

if (view == "assembly") assembly();
else if (view == "cutaway") cutaway();
else if (view == "print") {
  // cap beside the rim with 5 mm between them
  cap_x = pot_d / 2 + 5 + (r_pot_in(H) - r_ins_out(H)) / 2 + cap_overlap;
  if (part == "all") {
    print_part("pot");
    translate([cap_x, 0, 0]) print_part("cap");
  } else print_part(part);
}
