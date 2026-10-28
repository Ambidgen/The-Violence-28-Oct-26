# The Violence

A Godot 4 tactical autobattler set in **Port Carrick**, a rust-belt city on the edge of collapse. As police chief, manage the department, choose situations to answer and plan operations that play out hands-off. Civilian harm and excessive force have political consequences before an election ends the forty-week campaign.

This is a **1.3 candidate**, not a finished release: the runtime and export metadata still say 1.2.1. The authoritative city model is [Port Carrick v0.4](port-carrick/README.md); the game now reads its generated `city.json`. The twelve tactical maps remain stylized, schematic layouts, not surveyed replicas of the city sites.

## Play

1. Install a Godot 4 executable (the project declares 4.4 and 4.7; 4.7.2 is its primary target and 4.4.1 the compatibility target).
2. Open `project.godot` in the editor and press **F5**, or run `./play.sh` from this folder on Linux. The title screen offers a new/continued campaign and the test range.
3. From the weekly board, choose a call, read the briefing, assign officers and orders, then watch and review the operation. The map on the board shows the six wards, water, major streets and numbered call sites. Hover over a site for its address; older calls without location data are listed as unlocated.

See [the game guide](docs/GAME_README.md) for controls, saves, campaign systems and individual test commands. The project uses Godot's compatibility renderer. Existing binaries must be **rebuilt** to include changes in this checkout; the Windows binary is not tracked in Git.

## The city and the game

- [`port-carrick/city.json`](port-carrick/city.json) is the canonical, deterministic model: six wards, 275 streets, 12,666 buildings and 25 authored sites. Its site IDs, addresses, ward, visibility and coordinates now drive new calls; they are displayed on the board and in briefings.
- Fourteen recurring sites have explicit, type-compatible mappings to the existing tactical layouts. Public events use **Civic Plaza** because the event simulation requires that plaza; the historical Bridge Street eviction is not treated as a recurring call. A location and its playable layout are not the same thing.
- Ward trust remains in the existing save-compatible order: Northgate, Riverside, Old Town, Ironworks, Eastport, Kilbride. Site choices use a separate seeded RNG, so location selection is reproducible and does not consume the simulation's random stream.
- Existing saved boards are not rewritten to claim invented locations. New sites store a snapshot of their ID, address, ward and position. If the city resource cannot be loaded or validated, the game warns and generates explicitly **unlocated** calls rather than guessing an address or applying ward effects to an arbitrary neighborhood.
- The JSON is included by the export presets. The Python generator is not required to play. See the [city integration guide](port-carrick/README.md#using-the-model-in-the-game) before changing site IDs, wards or generation rules.
- Operations use [top-down animated patrol, SWAT and public-order/riot looks plus five criminal clothing models](docs/CHARACTER_ROSTER.md). The selected look is cosmetic; only equipped helmets, armour and shields provide their simulated protection. Replays keep the same appearance and do not reveal disguised attackers early.

## Tests and development

From the repository root:

```sh
python3 tools/gd47_check.py                 # static audit, not a Godot parser
python3 tools/sync_version.py --check       # runtime/project/export metadata
python3 -m unittest discover -s tests -p test_runner.py -v
tools/run_tests.sh --list                  # available tiers and suites
GODOT=/path/to/godot tools/run_tests.sh --range # tactical regressions; no campaign playtests
GODOT=/path/to/godot tools/run_tests.sh --quick
GODOT=/path/to/godot tools/run_tests.sh --full  # includes determinism and long simulations
```

The runner stores individual logs in `build/test-logs/`, returns nonzero for failed scripts or timeouts, and supports positive `JOBS` and `TIMEOUT_SCALE` environment variables (`TIMEOUT_SCALE` defaults to 2 on a machine with two cores or fewer). Every harness sets its own exit code; the runner trusts it and additionally fails any suite whose log shows a GDScript or engine error. `determinism_test` is marked as a **known failure** (reported as `KNOWN`, does not fail the tier) until its fixture is rebaselined in Phase 1; if it starts passing it reports `XPASS` and fails, so the mark is removed with the reason. GitHub Actions CI is active in `.github/workflows/ci.yml`: static audit, runner tests and version check, the quick tier on Godot 4.7.2 and 4.4.1, the full tier on `main`. Full, soak and balance tiers can take a long time. The range tier has its own post-fix tactical determinism fixture. The older full-suite fixture includes campaign scenarios, predates the latest simulation changes, and was not silently rebaselined; review campaign effects before deliberately updating it with `tests/determinism_test.gd -- --write`. `tests/city_integration_test.gd` specifically covers location selection, mapping, save round-trips and city fallbacks.

The city generator and validator have separate Python dependencies and commands; see [Port Carrick](port-carrick/README.md#run-it). Character art is generated by `tools/make_character_assets.py` (Pillow 13.0.0); run it with `--check` to verify the committed vector sources and three-frame sprite bakes. `tests/character_assets_test.gd` checks the models, role selection, equipment overlays and replays. The [historical test-range study](docs/TEST_RANGE_PLAYTEST_2026-10-27.md) contains preset, team-size, SOF habit and equipment playtests; the [post-fix debug report](docs/TEST_RANGE_DEBUG_2026-10-27.md) describes the changes and fresh checks. Headless tests do not replace a visual review, an export test or human playtesting.

## Known gaps and release status

- The [test-range fixes](docs/TEST_RANGE_DEBUG_2026-10-27.md) resolve the two reproduced friendly-lane and reload/cover stalemates in regression replays. Other layouts and edge cases can still stall; the shield-response prototype and resistance-adjusted bad-habit stress need broader balance and visual review.
- The [2026-10-27 playtest](docs/PLAYTEST_2026-10-27.md) found a serious trauma-related misjudgment spike in crowds. The suggested-plan mitigation is **not** a fix; the event-probe balance gate remains necessary. The roster availability, economy, lost-allies recovery and run-layer balance also need work and measurement.
- The board overview and automatic-kit-purchase fix address parts of that playtest, but the existing level designs are proxies. The four planned 1.5 maps (12–15), squad command layer and related tests are not present; see [level constraints](docs/design/LEVEL_DESIGN_CONSTRAINTS.md). Bridge closures are modeled in city data, not as a campaign mechanic.
- Cutscene coverage, music, crayon re-rendering and graphics performance gates remain incomplete. The Windows executable is unsigned and has not been tested on Windows; licensing/notices and a proper release build are still needed. CI is defined in `.github/workflows/ci.yml` but has not yet run on GitHub.
- The city's author-edit pass and final review of placeholder street/landmark names remain open. Some older design/playtest documents describe earlier snapshots and may use superseded addresses or art direction; this README and the current code describe the working tree.

## Repository map

- `scripts/campaign/`, `scripts/sim/`, `scripts/ui/`, `scripts/maps/`: campaign, simulation, interface and tactical layouts.
- `port-carrick/`: official city generator, validator, viewer, data and model specification.
- `tests/`, `tools/run_tests.sh`: headless regression, determinism and balance harnesses.
- `docs/GAME_README.md`, `docs/CURRENT_MODEL.md`, `docs/ROGUELIKE_PLAN.md`, `docs/VISUAL_OVERHAUL.md`: game guide and design history.
- `CHANGELOG.md`, `RELEASE_READINESS.md`, `release/README.md`: historical releases and remaining shipping work.
