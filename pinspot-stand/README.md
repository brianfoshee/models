# Pinspot stand

A stand for an ADJ Pinspot LED II on a 2.5 in (63.5 mm) wide rectangular base,
with no hardware. The light's own
hanging bracket slides its tab into a slot on top of the post, and a printed
peg dropped through the tab's bolt hole locks it there. A steel flat bar slid
into a channel in the base weighs it down. Tilt is the bracket's
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

- Plate: 170 × 81.5 × 48 mm, fits an A1 mini. No supports: the slot is open on
  top and its lips slope at 45°.
- The channel's roof is a 26 mm bridge inside the base. It's wider than the
  usual 15 mm limit, but it's hidden and nothing seats on it; the channel has
  0.5 mm of extra height for it to sag into.
- The light hangs about 20 mm off the post toward the slot's open side, so the
  narrow width of the base is the tipping direction. Without the bar the stand
  tips at roughly 1 N (100 g) of sideways pull on the cord; with the bar,
  roughly 2.5 N.
- Stand prints base down, peg head down. PLA is fine.

## Assembly

1. Slide a 1/2 × 1 × 6 in steel flat bar into the channel at the base's -X end
   (the end the light's rear points at) and glue it, or it slides out when the
   stand is picked up. The `Ballast` section sets the bar's size and 0.3 mm
   clearance; check a hardware-store bar with calipers, nominal sizes run
   slightly under.
2. Slide the bracket's tab into the slot from the flat side of the post until
   the arm touches the post.
3. Drop the peg through the tab's bolt hole into the socket in the slot floor.
4. Tilt the light on its knob. Turn the stand to pan.

## Measurements

Only the light's overall size (184 × 99 × 61 mm) and weight (0.5 kg) are
published. The bracket's tab, which sets every fit, is measured: 34 mm long
from the arm's outer face, 23 wide, 3 thick, with a 10 mm hole whose edge is
5 mm from the end. The rest of the `Pinspot` section is estimated from product
photos and only affects the illustration and the tilt limit:

- The arm is measured at 93 mm, but where the pivot sits on it is estimated at
  the centre of its rounded end. That sets how high the light sits and where
  its body swings. The body hits the post past about 65° of tilt; that limit
  comes from the bracket.
