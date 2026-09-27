# Dock charger bracket

U-bracket that clamps over the top edge of a 2x6 under a dock and holds a
Battery Tender 5A 12V/24V charger (022-0258-DL-WH), long edge horizontal, on
its back face.

Assembly order:

1. Drop M5 nuts into the hex pockets on the board side and M6 nuts into the
   pockets in the back face.
2. Screw the charger's four wing holes into the M5 nuts. The charger covers
   the M6 nuts and holds them in.
3. Set the bracket over the 2x6, drill the board through the bracket's bolt
   holes, and bolt through from the front leg into the M6 nuts.

## Files

- `dock-charger.scad`: the source, with reference models of the charger,
  the bolts and the board. `view` switches between `assembly`, `exploded` and
  `print`. `show_hardware` turns the reference models on and off.
- `dock-charger.usdz`: the assembled bracket with the charger, hardware and
  board, for AR Quick Look.
- `dock-charger-exploded.usdz`: the same, spread apart.
- `dock-charger.stl`, `dock-charger-exploded.stl`: copies of the two USDZ
  views for viewing on GitHub. They aren't for printing.
- `dock-charger-u-bracket-edge.stl`, `.usdz`: the original mesh the `.scad`
  was rebuilt from.

There's no print export yet. The charger's hole pattern is a guess (see
below).

## Printing

- 230 × 185 × 67 mm. It fits a P2S but not an A1 mini.
- It prints standing on its end with no supports. The holes are teardrops
  and the nut pockets have flat roofs, both shaped for that orientation.
- Use PETG or ASA, and stainless hardware.

### Hardware

| Qty | Part              | Where                                 |
| --- | ----------------- | ------------------------------------- |
| 3   | M6 × 65 hex bolt  | Through both legs and the board       |
| 3   | M6 washer         | Under the bolt heads on the front leg |
| 3   | M6 nut            | Captive in the back face              |
| 4   | M5 × 20 hex screw | Through the charger's wings           |
| 4   | M5 washer         | Under the screw heads                 |
| 4   | M5 nut            | Captive on the board side             |

`bolt_l` and `charger_screw_l` set the hardware lengths. The M6 nut
pockets deepen to suit `bolt_l`. The render fails if either length is too
short to reach its nut, or too long for the space behind it.

### Not measured

- **Charger mounting holes**: Battery Tender doesn't publish the pattern.
  `hole_dx` (90 mm, the spacing of the holes on one wing), `hole_dz` (150 mm,
  the spacing between the wings) and `wing_t` (3 mm) are estimates from
  product photos. Measure the charger before printing.
- **Charger body**: 7.5 × 5.5 × 1.75 in, from Battery Tender's product
  photos.
- **Board**: drawn as a standard 1.5 × 5.5 in 2x6. `gap` (40.1 mm) came from
  the original mesh.

### Filament

Estimated from the mesh volume, not from a slicer. The bracket is 858 cm³
solid. Taking the surface as shell and filling the rest with infill:

| Slicer settings     | Volume  | PETG    | ASA   | 1.75 mm filament |
| ------------------- | ------- | ------- | ----- | ---------------- |
| 2 walls, 15% infill | 275 cm³ | 350 g   | 295 g | ~115 m           |
| 4 walls, 25% infill | 455 cm³ | 580 g   | 490 g | ~190 m           |
| Solid               | 858 cm³ | 1.09 kg | 920 g | ~355 m           |

The shells overlap in the thin areas, so the first two rows are ±20%. Use
4 walls for this part: it carries the charger's 1.7 kg outdoors.
