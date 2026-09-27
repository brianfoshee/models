// Involute gear profiles and small shared shapes for the planetary gearboxes; `use` this file.
// Origin: gear axis on Z; 2D shapes lie in the XY plane; mm.

// Involute function, degrees in and out
function inv(a) = (tan(a) - a * PI / 180) * 180 / PI;

// 2D spur gear with one tooth centered on +X. thicken widens each tooth at the pitch circle
// (negative for backlash). A ring gear is cut with this shape, so its tooth spaces are these teeth.
module gear2d(teeth, m, pressure_angle, addendum, dedendum, thicken) {
  rp = m * teeth / 2;
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

eps = 0.01;

module hex_prism(across_flats, height) {
  linear_extrude(height) circle(d=across_flats / cos(30), $fn=6);
}

// linear_extrude with the bottom and top edges chamfered by chamfer, in 0.1 mm steps
module chamfered_extrude(height, chamfer) {
  n = ceil(chamfer / 0.1);
  step = chamfer / n;
  // each layer overlaps its neighbour toward the middle by eps, so they fuse
  if (n > 0) for (i = [0:n - 1], end = [0, 1])
    translate([0, 0, end == 0 ? i * step : height - (i + 1) * step - eps])
      linear_extrude(step + eps, convexity=4) offset(delta=-(chamfer - i * step)) children();
  translate([0, 0, chamfer]) linear_extrude(height - 2 * chamfer, convexity=4) children();
}

// Cutter widening the mouth of an opening shaped like children() by chamfer, in 0.1 mm
// steps; mouth at z = 0, opening along +Z
module chamfered_mouth(chamfer) {
  n = ceil(chamfer / 0.1);
  step = chamfer / n;
  if (n > 0) for (i = [0:n - 1])
    translate([0, 0, i * step - eps])
      linear_extrude(step + eps, convexity=4) offset(delta=chamfer - i * step) children();
}

// Chamfer widening a hex socket's mouth; mouth at z = 0, socket along +Z
module hex_mouth_chamfer(across_flats, chamfer) {
  translate([0, 0, -eps]) linear_extrude(chamfer + eps, scale=across_flats / (across_flats + 2 * chamfer))
    circle(d=(across_flats + 2 * chamfer) / cos(30), $fn=6);
}
