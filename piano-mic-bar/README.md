# Piano mic bar

End brackets for a microphone bar across a Yamaha U1 upright piano. The bar is
a wooden closet rod; a printed bracket on each end hooks over the top edge of a
side panel, lined with rubber, and the lid still closes on top. Two AKG C414s
will mount on the rod (holders not designed yet).

## Files

- `piano-mic-bar.scad` — source. `view` switches between `assembly`,
  `section` (cut through a bracket, looking from the front) and `print`.
- `piano-mic-bar.3mf` — one bracket, for a test fit. Set `copies = 2` for
  both on one plate.
- `piano-mic-bar.usdz` — the bar in the piano's side panels, lid hidden, for
  AR Quick Look.
- `piano-mic-bar-parts.usdz` — the print plate.
- The `.stl` files are the same views, for viewing on GitHub.

## Measurements

From the piano: side panels 23 mm thick at the top edge, 1430 mm apart inside,
the lid overhangs them by 1/2 in, and there's 100 mm of room below the edge.
The case depth, lid thickness and the bar's position front to back in the
model are for the picture only.

The rod is an Everbilt oak closet rod, sold as 1.3 in. **Measure it** and set
`rod_d` before the final print; the cup has 0.3 mm of clearance per side.

## Printing

- One bracket is 57 × 65 × 38 mm; two side by side are 120 × 65 × 38 mm.
  Either fits an A1 mini. PLA.
- Each bracket prints on its side, so the U's profile is in the bed plane.
- The rod's socket is a round hole lying horizontally, so it needs supports
  along its top. Use tree supports, on build plate only, so none end up in the
  U's opening.

## Hardware

- 2 × #8 × 1-1/2 in flat-head (82°) wood screws.
- 1/16 in rubber sheet (Everbilt packaging sheets) and contact cement.

## Assembly

1. Cut the rod to the inside width minus 11.4 mm (1418.6 mm for 1430 mm). Measure
   the inside width where the bar will sit, front and back, and cut 1–2 mm
   short; the rubber takes up the gap. The `assembly` view echoes the length.
2. Drill a 1/8 in pilot hole in the centre of each end of the rod.
3. Push a bracket onto each end and screw through the countersunk hole into
   the rod. The two brackets are the same part, turned 180° to each other.
4. Cut and glue the rubber, all 38.4 mm wide (along the panel), per bracket:
   - on top of the U: 32.4 mm
   - inside the U's top, on the panel's edge: 26.4 mm
   - inside the outer leg: 15 mm
   - inside the inner leg, over the screw head: 61 mm
5. Lower the bar in so both U's hook over the side panels. The closed lid
   sits 5.2 mm higher, on the brackets.
