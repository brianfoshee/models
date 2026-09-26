# Self-watering pot

A pot and wicking insert printed as one piece, plus a cap for the fill opening.
Water goes into the gap between the walls through the opening in the rim. A
rubber tube holding a wick presses through the insert's funnel floor and hangs
into the reservoir.

## Files

- `self-watering-pot.scad` — source. `view` switches between `assembly`,
  `cutaway` and `print`; `part` picks `all`, `pot` or `cap` in print view.
- `self-watering-pot.3mf` — pot and cap on one plate.
- `self-watering-pot.usdz` — assembled pot and cap, for AR Quick Look.
- `self-watering-pot-cutaway.usdz` — a quarter cut away through the fill
  opening, with an illustrative tube and wick.

## Printing

- Pot: 176 × 176 × 176 mm. With the cap beside it the plate is ~194 mm wide,
  which fits a P2S but not an A1 mini. For an A1 mini, export `part="pot"` and
  `part="cap"` separately.
- No supports needed. The pot prints upright, the cap lip-face down.
- Use PETG and 4 or more wall loops. The outer wall holds water, and default
  settings may seep.
- `tube_od` is a placeholder (8 mm) until the tube is measured. The hole is
  sized to grip the tube so it seals.

### Filament

Estimated from the mesh volume, not from a slicer:

| Part  | Volume    |
| ----- | --------- |
| Pot   | 410 cm³   |
| Cap   | 2 cm³     |
| Total | 412 cm³   |

That's about **510 g of PLA** or **525 g of PETG** (~170 m of 1.75 mm
filament), about half a 1 kg spool. The walls print solid, so a slicer's
estimate should be close. The 16 mm solid stem (~8 cm³) is the only part that
gets partial infill.

About half the volume is the 2.4 mm outer wall. Thinning it to 2.0 mm saves
~45 g, but it's the wall that holds the water.
