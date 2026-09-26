# AGENTS.md

Scratchpad of 3D models. Each model is headed for one or both of:

- **3D printing** on Bambu Lab printers (see [Printers](#printers)).
- **Game meshes** for native macOS/iOS games written in Swift on raw Metal.

Ask which target(s) a new model is for before starting; the constraints differ.

## Layout

One directory per model, lowercase kebab-case for new ones
(`dock-charger/`, `led-control-box/`). Source files and their exports live
side by side in that directory. Older directories (`Star/`, `HoHoHoBox/`) use
other casing — leave them as-is.

Source formats in use:

- `.scad` — OpenSCAD, the preferred source for anything parametric or
  mechanical. Plain text, diffable, scriptable — default to this.
- `.blend` — Blender, for organic/sculpted shapes and game assets that need
  UVs/materials. Binary; `.blend1`, `.blend2`… are Blender's automatic backups.
- `.skp` — SketchUp, legacy only.

Exports: `.stl`/`.3mf` (print), `.usdz` (AR preview / game), `.obj`/`.mtl`
(older mesh exports).

`tools/` holds repo scripts (see [USDZ previews](#usdz-previews-on-ios)).

## Setup (Apple silicon Mac)

This machine is Apple silicon (`arm64`) with Homebrew at `/opt/homebrew`.
Everything below runs natively — no Rosetta.

### OpenSCAD

```sh
brew install --cask openscad@snapshot
```

Use the **snapshot**, not the `openscad` cask: the stable release (2021.01) is
years old, Intel-only, and lacks the Manifold backend. The snapshot cask puts
`openscad` on `PATH`. Always pass `--backend manifold`; CGAL is far slower.

### Blender

```sh
brew install --cask blender
```

The cask installs the native Apple silicon build and a `blender` command
wrapper for headless use (`blender -b file.blend --python script.py`).
If downloading manually from blender.org, pick **macOS – Apple Silicon**.

After first launch: **Preferences → System → Cycles Render Devices → Metal**
and tick the GPU. EEVEE uses Metal automatically.

### Blender MCP (lets Claude drive Blender)

Use the official Blender Lab server
([docs](https://www.blender.org/lab/mcp-server/),
[repo](https://projects.blender.org/lab/blender_mcp)). It needs Blender 5.1+.
It is **not** on PyPI — the PyPI packages `blender-mcp` and `mcp-for-blender`
are an unrelated community project, so don't `uvx` either of them.

It has two parts: a Blender add-on that listens on a TCP socket, and an MCP
server (`blender-mcp`) that Claude launches over stdio.

**Add-on:**

1. Blender → **Preferences → Get Extensions → Repositories → +** → add
   `https://lab.blender.org/`.
2. Search for the MCP add-on, install and enable it. (Alternative: drag the
   `mcp-*.zip` from the repo's releases into Blender.)
3. In the add-on's preferences, start the server (or tick auto-start). Host
   and port are configurable there; default `localhost:9876`.

**MCP server** (per the project's Setup wiki):

```sh
brew install uv
git clone https://projects.blender.org/lab/blender_mcp.git ~/blender_mcp
git -C ~/blender_mcp checkout v1.0.3     # pin a release tag
claude mcp add blender -- uv --directory ~/blender_mcp/mcp run blender-mcp
```

Restart Claude Code with Blender open and the add-on running; `/mcp` should
list `blender`. To update: `git -C ~/blender_mcp fetch --tags` and check out
the newer tag. Claude Desktop can instead install the `blender-*.mcpb` bundle
from the releases page.

Notes:

- It executes model-generated Python in Blender with no guards. Save before
  letting it run; the project recommends not running it on a machine with
  sensitive data.
- Tools cover the Python API, API/manual search, .blend inspection
  (datablocks, missing files, linked libraries) and viewport
  screenshots/renders. It has no asset-library integrations.

### Bambu Studio (slicer)

```sh
brew install --cask bambu-studio
```

### Apple USD tools

`usdzip`, `usdchecker`, `usdcat`, `usdrecord` ship with macOS in `/usr/bin` —
nothing to install. Swift comes with Xcode / Command Line Tools.

## OpenSCAD

```sh
# Render to STL (also the fastest way to check the model is valid)
openscad --backend manifold -o model.stl model.scad

# 3MF for Bambu Studio
openscad --backend manifold -o model.3mf model.scad

# Override a parameter without editing the file
openscad --backend manifold -D 'gap=38.5' -o model.stl model.scad

# PNG preview for a visual check
openscad --backend manifold --autocenter --viewall --imgsize=1024,768 \
  -o preview.png model.scad
```

After changing a `.scad` file, render it and read the output: it must finish
with no `WARNING:` or `ERROR:` lines and report `Status: NoError`. `Genus`
(the number of through-holes) is a quick sanity check against what the design
should have. Look at a PNG preview before calling a geometry change done. Put
previews and other throwaway renders in a temp directory, not the repo.

### Conventions

Follow `dock-charger/dock-charger.scad` for new files:

- Header comment: one line on what the part is, one line defining the origin
  and axes.
- Units are **millimetres**, +Z up.
- Every tunable dimension is a top-level variable with a comment, grouped into
  Customizer sections (`/* [Section] */`) with range hints
  (`// [min:step:max]`). Derived values and `$fn`/`eps` go under
  `/* [Hidden] */`.
- Build shapes from named modules; keep the final `difference()`/`union()` at
  the bottom short and readable.
- Cutters extend past the faces they cut (`eps` or a few mm) to avoid
  coincident faces.
- 2-space indent. Older files use tabs — don't reformat them in unrelated
  changes.

Never invent real-world dimensions (board thickness, hole spacing, device
footprints). If a fit-critical number isn't in the file or the conversation,
ask Brian to measure it. Record where a number came from in its comment when
it's non-obvious.

## Printing

### Printers

| Printer     | Build volume (mm) | Enclosed | Notes                  |
| ----------- | ----------------- | -------- | ---------------------- |
| A1 mini     | 180 × 180 × 180   | No       | Bed slinger            |
| P2S         | 256 × 256 × 256   | Yes      | Must be supported      |
| H2S         | 340 × 320 × 340   | Yes      |                        |

Brian plans to buy an A1 mini or H2S, and prints must also work on a P2S.

- Every part must fit the **P2S (256 mm cube)**. Flag any part over
  **180 mm** in any axis — it won't fit an A1 mini. Split large parts with
  alignment pins/dovetails rather than relying on the H2S.
- Materials must be printable on the P2S. PLA/PETG work everywhere;
  ASA/ABS need an enclosure (P2S, H2S — not the A1 mini).
- Assume a 0.4 mm nozzle and textured PEI plate unless told otherwise.

### Design rules

- Design each part to print without supports where practical — flat face down,
  overhangs ≤ 45°, bridges short.
- Minimum wall ≈ 1.2 mm (3 perimeters at 0.4 mm); ≥ 2 mm for anything
  load-bearing.
- Clearances: ~0.2 mm per side for sliding fits, ~0.1 mm for press fits,
  0.3–0.5 mm oversize on holes for screws/bolts. Make these parameters.
- Holes printed horizontally sag; consider teardrop or flat-topped profiles.
- Export in the print orientation, units mm, one file per separately printed
  part. STL is fine; 3MF is preferred for multi-part or multi-colour (AMS)
  prints.
- Outdoor parts: suggest ASA or PETG, and stainless hardware.

## Game meshes (Swift + Metal)

Brian's games are native macOS/iOS in Swift on raw Metal, loading assets with
Model I/O (`MDLAsset` → `MTKMesh`).

- **Format: USD** (`.usdz` for shipping, `.usda` while iterating). Model I/O
  reads USD, OBJ, STL and PLY but **not glTF**, so don't target glTF.
  Blender exports USD/USDZ directly.
- **Units: metres, +Y up, right-handed, −Z forward** (USD/Apple convention).
  Model I/O ignores `metersPerUnit` on import and hands back raw coordinates,
  so author game assets with `metersPerUnit = 1` and the numbers in metres.
  Print exports are mm/+Z up — keep the two exports separate; a print export is
  not a game asset.
- Triangulated, indexed meshes with normals and UVs; add tangents if the asset
  is normal-mapped (Model I/O can generate them with `addTangentBasis`).
  Consistent outward winding, no degenerate or duplicate faces, transforms
  applied, origin at a sensible pivot (usually bottom-centre).
- Ask for a triangle budget. In OpenSCAD, lower `$fn`/raise `$fs` for game
  exports rather than reusing print-resolution settings.
- Materials as `UsdPreviewSurface`; textures PNG/JPEG, power-of-two sizes
  (the engine converts to ASTC).
- UVs and materials need Blender — OpenSCAD geometry has neither.

## USDZ previews on iOS

`tools/usdz.swift` converts a model to USDZ for AR Quick Look, at real-world
size, standing upright on the floor:

```sh
swift tools/usdz.swift dock-charger/dock-charger.scad            # -> dock-charger/dock-charger.usdz
swift tools/usdz.swift lilliecube/cube.stl /tmp/cube.usdz        # explicit output
```

- Inputs: `.scad` (rendered through OpenSCAD first), `.stl`, `.obj`, `.ply`,
  treated as mm/+Z up. Output: mm (`metersPerUnit = 0.001`), +Y up, centred,
  single plastic material, smooth shading below a 30° crease angle.
- Output is validated with `usdchecker --arkit` in the tests.
- Get it onto the phone by AirDrop or by saving to iCloud Drive; tapping the
  file opens AR Quick Look.
- This is a **preview** tool (mm-scaled). It doesn't produce game assets.

Tests: `tools/test-usdz.sh`. Run them after changing the converter.

## Git

- Commit source (`.scad`, `.blend`) and the exports someone would actually use
  (`.stl`, `.3mf`, `.usdz`). Don't add Blender backup files (`.blend1`…) or
  `.DS_Store` in new commits.
- Binary files don't diff; mention in the commit message what changed in a
  `.blend` or exported mesh.
