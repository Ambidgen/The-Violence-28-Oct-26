# Cycle 1.A — the balance harness

**Date:** 2026-10-28
**Task:** EA_TASKS P1.A1–P1.A3 (P1.A4, the 20-seed baseline, is still open)
**Branch:** `arena/17cdd2d5-the-violence-28-oct-26`

## What this cycle had to prove

The four policies run a full 40-week campaign end to end and produce per-run JSON plus a
summary, and every later Phase 1 number is measured through this harness. The bands file
exists and is **report-only**.

## What was built

| File | What it is |
|---|---|
| `tests/policies.gd` | The four policies as code: inheritance, contracts and programs by tag, offers, events, hiring, courses, internal affairs, kit, and which calls to take. Deterministic — every answer is derived from the desk, never from a random number. |
| `tests/rogue_balance_test.gd` | The matrix runner: one child process per seed × policy, its own `XDG_DATA_HOME`, a per-run timeout and kill, then `report.md` + `summary.json` + `run-<seed>-<policy>.json`. |
| `tests/balance_bands.json` | Thirteen Gate 1 bands with aggregation and rationale; `"status": "report-only"`, `"enforce": false`. |
| `tests/policies_test.gd` | Quick-tier gates on the policy layer alone. |

## Evidence in this directory

| File | Status |
|---|---|
| `README.md` (this file) | written |
| `pilot/report.md`, `pilot/summary.json` | **run 40807612351** — 2 seeds × 4 policies × 40 weeks, 8 runs, 2537 s, Godot 4.7.2, **0 broken runs**, 36 band misses (report-only) |
| the smoke | **green** — `rogue_balance_test --smoke` is in the quick tier and passed on 4.7.2 and 4.4.1 in the same runs as `policies_test.gd` (run 40800062910 onward) |
| `baseline/` (20 seeds × 4 policies) | **not run** — P1.A4, one `Run workflow` away (tier=balance); the job commits it here |

This directory is deliberately honest about what has and has not run. The code in this
cycle was written in a sandbox with **no Godot engine**, so it was checked with static
tools only:

- `gdparse` (gdtoolkit 4.5.0) — all three new scripts parse.
- `tools/gd47_check.py` — clean over 131 files (4.7 API, no 4.4-only calls).
- `bash -n tools/run_tests.sh` — clean; `--list` shows the two new suites.
- `.github/workflows/ci.yml` — parsed as YAML; jobs `static`, `headless`, `balance`,
  `full`; events `push`, `pull_request`, `workflow_dispatch`, `schedule`.

What static tools **cannot** confirm is runtime behaviour: child-process spawning, the
per-run data directory actually isolating saves, the 40-week loop terminating in the step
guard, and the derived metrics landing in sane ranges. That is what the first CI run is
for, and this file is updated with its output rather than pre-empting it.

## The pilot, read

The two-seed pilot is not the baseline, but it is the first time the run layer has been
measured through the harness at all, and the shape is the playtest's:

| | cautious | minimal | military-first | accept-all |
|---|---|---|---|---|
| lowest fit | 6.5 | 8 | 6.5 | **2** |
| weeks below $0 | 3 | 0 | 4.5 | **13** |
| lowest account | −$12,748 | $40,386 | −$19,395 | **−$156,073** |
| civilians killed | 3.5 | 4 | 3.5 | **20.5** |
| killed per operation | 0.38 | 0.30 | **0.21** | 0.38 |
| allies lost at the end | 3 | 2 | 3.5 | 4 |
| allies won back | 0 | 0 | 0 | 0 |
| chief kept | 2/2 | 1/2 | 2/2 | 1/2 |

- **The policies separate**, which is the first thing this had to show: `minimal` never
  spends and ends with $414k; `military-first` has the best lethality (0.21) and still
  runs out of money; `accept-all` bankrupts itself (−$302k at the low), kills 20–33
  civilians and is the only policy whose roster reaches zero fit officers.
- **Fit collapses on every policy** (lowest 0–8 against a roster floor of 10), and the
  weeks-under-12 counters are 7.5–28.5 of 40. That is finding B1/B2 territory, now with
  numbers and a reproducible command.
- **Nobody wins allies back.** `allies_regained` is 0 for all eight runs, against a band
  that asks for 0.25. Either the recovery path (standing back above 40) is unreachable
  under these policies, or nothing in the run loop pushes standing back up. Worth a
  look in 1.B/1.C; it is not a harness bug — the line the harness counts is the line
  `politics.gd` prints.
- **Lethality is 0.21–0.38 officers killed per operation** against a band of 0.15, on
  every policy including the careful one. That is the Gate 1 gap in one number.
- **36 of 52 band checks miss, and none of them is enforced.** The bands are the
  playtest's own figures turned into thresholds; the pilot says the playtest's shape is
  the whole 40-week run, not an edge case. P1.I decides whether the thresholds move or
  the game does.
- **Wall clock: 21 minutes per 40-week run.** Four at a time on a 4-vCPU runner is ~40
  minutes per two seeds; twenty seeds is ~7 hours, which is why the balance job's timeout
  is 12 hours and why the weekly schedule runs eight seeds rather than twenty.

## How to reproduce

```
GODOT=/path/to/godot tests/rogue_balance_test.gd --smoke
GODOT=/path/to/godot tests/rogue_balance_test.gd --seeds=20 --policy=all --weeks=40 --jobs=4 --json=build/balance
```

`--smoke` is the two-seed shakedown and is part of the quick tier. The second command is
the baseline and takes hours; in CI it is the `balance` job (dispatch with `tier=balance`,
weekly on a schedule, and a two-seed pilot on every `arena/*` push).

## What has to be checked when the first report lands

1. **No broken runs.** Done for the pilot: `broken: []` for all eight runs, and the
   harness exits 1 when a run is broken, so the green job is itself the check.
2. **The shape matches the 28 Oct playtest:** fit collapses, deficits persist, allies are
   lost. If a policy ends comfortably, the policy does not match the game yet.
3. **The policies are actually different** — doctrine, contracts, allies and score should
   separate them. Identical rows for all four mean an answer is being ignored.
4. **The bands' provisional thresholds** against those numbers, as input to P1.I. They are
   the owner's decision and none are enforced yet.
