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
| `policies-test.log` | **pending** — first CI run of `policies_test.gd` |
| `smoke-report.md`, `smoke-summary.json` | **pending** — CI copies `build/balance-smoke/report.md` here |
| `pilot-report.md`, `pilot-summary.json` | **pending** — the two-seed × four-policy CI pilot |
| `baseline/` (20 seeds × 4 policies) | **not run** — P1.A4, one `Run workflow` away (tier=balance) |

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

## How to reproduce

```
GODOT=/path/to/godot tests/rogue_balance_test.gd --smoke
GODOT=/path/to/godot tests/rogue_balance_test.gd --seeds=20 --policy=all --weeks=40 --jobs=4 --json=build/balance
```

`--smoke` is the two-seed shakedown and is part of the quick tier. The second command is
the baseline and takes hours; in CI it is the `balance` job (dispatch with `tier=balance`,
weekly on a schedule, and a two-seed pilot on every `arena/*` push).

## What has to be checked when the first report lands

1. **No broken runs.** A broken run (hung operation, no election at 40 weeks, unreadable
   JSON) fails the harness; the count must be zero before any number is quoted.
2. **The shape matches the 28 Oct playtest:** fit collapses, deficits persist, allies are
   lost. If a policy ends comfortably, the policy does not match the game yet.
3. **The policies are actually different** — doctrine, contracts, allies and score should
   separate them. Identical rows for all four mean an answer is being ignored.
4. **The bands' provisional thresholds** against those numbers, as input to P1.I. They are
   the owner's decision and none are enforced yet.
