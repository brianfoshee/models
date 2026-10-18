# Pinspot stand

A stand for an ADJ Pinspot LED II on a 2.5 in (63.5 mm) wide rectangular base,
with no hardware. The light's own
hanging bracket slides its tab into a slot on top of the post, and a printed
peg dropped through the tab's bolt hole locks it there. Tilt is the bracket's
knob; pan is turning the stand on the table. It is meant to be aimed once, at
a disco ball.

## Files

- `pinspot-stand.scad` — source. `view` switches between `assembly`,
  `exploded` and `print`; `part` picks `all`, `stand` or `peg` in print view.
- `pinspot-stand.3mf` — stand and peg on one plate.
- `pinspot-stand.usdz` — assembled, with the light, for AR Quick Look.
- `pinspot-stand-exploded.usdz` — the light slid out and the peg lifted.
- `pinspot-stand-parts.usdz` — the print plate.
- The `.stl` files are the same views, for viewing on GitHub.

## Printing

- Plate: 170 × 81.5 × 36 mm, fits an A1 mini. No supports: the slot is open on
  top and its lips slope at 45°.
- The light hangs about 25 mm off the post toward the slot's open side, so the
  narrow width of the base is the tipping direction. The stand tips at about
  1 N (100 g) of sideways pull on the cord. Weight on the base on the side
  away from the light helps most.
- Stand prints base down, peg head down. PLA is fine.

## Assembly

1. Slide the bracket's tab into the slot from the flat side of the post until
   the arm touches the post.
2. Drop the peg through the tab's bolt hole into the socket in the slot floor.
3. Tilt the light on its knob. Turn the stand to pan.

## Measurements

Only the light's overall size (184 × 99 × 61 mm) and weight (0.5 kg) are
published. Everything in the `Pinspot` section of the source is estimated from
product photos and needs calipers. The ones that set the fit:

- `pin_bracket_w`, `pin_bracket_t` — the slot's width and height.
- `pin_tab_hole_d` — the peg's diameter.
- `pin_tab_hole_x` — where the peg's socket sits.
- `pin_arm_rise` — how high the light sits, and where its body swings. The
  body hits the post past about 65° of tilt; that limit comes from the bracket.
