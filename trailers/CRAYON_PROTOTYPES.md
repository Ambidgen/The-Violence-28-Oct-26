# Crayon cutscene prototype trailers (not the five rejected cuts)

Three 12-second prototypes of the **election-night crayon cutscene**
(`scripts/view/proto/cutscene_view.gd` — a crossroads in the rain, riot line,
crowd, searchlight, captions printed on, final stamp), generated 2026-10-29 by
`.github/workflows/cutscene-trailers.yml` (Run workflow on main, or push to an
`arena/*` branch touching the trailer pipeline — GitHub gates manual dispatch
to the default branch). They are deliberately *the same
scene*: staging, camera move, timing and drawing are identical, so the only
thing being judged is a slight deviation of hand/grade at encode time
(`tools/make_cutscene_trailer.sh`):

| # | Variant | Deviation | Intended feel |
|---|---|---|---|
| 1 | `pencil-light` | brightness lifted, contrast/saturation down | softer pencil, more paper showing |
| 2 | `charcoal-night` | darker, contrast pressed up | charcoal laid on harder, night denser |
| 3 | `warm-paper` | warm colour balance, slight saturation up | aged/cream paper stock |

Each CI artifact (`cutscene-trailer-<variant>-<runid>`, 90 days) contains
`<variant>.mp4` (review), `<variant>.ogv` (Godot-ready Ogg Theora), the
labelled contact sheet, the stills, and `capture.json`. **Silent** — the
prototype has no sound design; do not judge pacing against finished trailers.

Reproduce/re-encode locally (display + Godot + ffmpeg required):

```sh
GODOT=/path/to/godot XVFB=1 tools/cutscene_capture.sh --which=cutscene --every=1
tools/make_cutscene_trailer.sh --variant=charcoal-night \
  --frames=build/cutscene-captures/cutscene --out=build/trailers
```

Judge them against the reference plates in `docs/overhaul/` and write the
verdict next to the winning row above. If none wins, the deviation wanted is
probably in the drawing itself (boil amount, hatch density, palette) — that
lives in `scripts/view/crayon.gd`, not in the encode grade; say which plate it
should move toward and the next prototypes should deviate there instead.
