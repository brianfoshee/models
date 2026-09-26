# LED control box

Enclosure for a 5 V LED power supply. Mains comes in through an IEC C14 inlet
with rocker switch and fuse on one end, and the LED output leaves through a
cable gland on the other. The lid slides in along grooves from the cable end
and clicks shut on a snap tab; lift the tab's grip to slide it out.

## Files

- `led-control-box.scad` — source, including reference models of the power
  supply and IEC socket. `view` switches between `assembly` and `print`;
  `part` picks `all`, `box` or `lid` in print view.
- `led-control-box.3mf` — box and lid on one plate.
- `led-control-box.usdz` — assembled box with the power supply and socket, for
  AR Quick Look.

## Printing

- Box: 237 × 81 × 110 mm. Lid: 238 × 78 × 4 mm. Both fit a P2S; neither fits
  an A1 mini.
- No supports needed. The box prints upright, the lid top face down.
- The top edge of the IEC cutout is a ~41 mm bridge; the socket's flange
  covers it.
- PETG is the better choice: the power supply warms the inside of the box, and
  PLA softens around 55 °C.

### Hardware

- Two screws for the IEC socket's flange (4.5 mm holes, matching the flange),
  with nuts inside.
- Two screws into the power supply's side through the -Y wall (3.6 mm holes).
- PG7 cable gland for the LED output (12.5 mm hole, 3–6.5 mm cable).

### Not measured

- IEC flange height (49.1 mm) is from the
  [BC Robotics listing](https://bc-robotics.com/shop/panel-mount-inlet-socket-switch-iec320-c14/)
  for this style of module. Measure the part before printing.
- The listing gives 28 mm behind the panel, including terminals. The
  reference model's body is 16.5 mm deep. There is 43 mm between the -X wall
  and the power supply, so either fits.

### Filament

Estimated from the mesh volume, not from a slicer:

| Part  | Volume  |
| ----- | ------- |
| Box   | 303 cm³ |
| Lid   | 53 cm³  |
| Total | 356 cm³ |

That's at most **440 g of PLA** or **450 g of PETG** (~150 m of 1.75 mm
filament). The 4 mm walls get some infill, so a slicer's estimate will come in
lower.
