# The Violence — Early Access task plan (fix / playtest / debug cycles)

2026-10-28. Breaks [`EARLY_ACCESS_ROADMAP.md`](EARLY_ACCESS_ROADMAP.md) into tasks, grouped into cycles. Every task names the files it touches; every cycle names the command that playtests it and the number that ends it. Evidence for the problems: [`PLAYTEST_2026-10-28_CAMPAIGN.md`](PLAYTEST_2026-10-28_CAMPAIGN.md).

Sizes: **S** ≤ 1 day · **M** 2–4 days · **L** 1–2 weeks. IDs are stable so commits and changelog lines can cite them (`P1.B3`).

---

## How every cycle runs

```
FIX       one small change on a branch, with the task ID in the commit
CHECK     tools/run_tests.sh --check && --quick                          (~6 min)
PROBE     the cycle's targeted harness (named in the cycle)
PLAYTEST  balance smoke: tests/rogue_balance_test.gd --seeds=3            (~1 h, 4 policies)
          rendered walk: tests/ui_walk.gd to week 2, read the screenshots (~10 min)
DEBUG     if the exit number is missed: the cycle's trace tool, then back to FIX
LOG       CHANGELOG line + tests/results/<date>-<cycle>/ (logs, JSON, screenshots)
```

At the end of each **phase**: the full tier, the full balance run (20 seeds × 4 policies, overnight), and one human session (§3.E). A phase is not done until its gate is green on the merged commit.

Phase 0 builds two of the tools that every later cycle uses: the four-policy balance harness and the rendered walk. That's why it comes first.

---

## Phase 0 — Make the build trustworthy *(≈ 1 week)*

### Cycle 0.A — Harnesses that fail honestly
| ID | Task | Files | Size |
|---|---|---|---|
| P0.A1 | Give every diagnostic an exit code (`quit(1 if failures > 0 else 0)`): `civ`, `equip`, `hold`, `lethality`, `maps`, `nav_door`, `op`, `fuzz`, `perf`, `playtest`, `sim`, `stall`, `trace`, `duel_probe`, `rig_gallery`. Then delete the runner's log-scanning fallback. | `tests/*.gd`, `tools/run_tests.sh` | M |
| P0.A2 | Set the runner's default `TIMEOUT_SCALE` from `nproc` (×2 on ≤ 2 cores). Give `orders_test` an explicit budget. | `tools/run_tests.sh` | S |
| P0.A3 | Activate CI: `git mv tools/ci/ci.yml .github/workflows/ci.yml`. Run the quick tier on push (4.7.2 and 4.4.1) and upload logs on failure. | `.github/workflows/ci.yml` | S |
| P0.A4 | Move `determinism_test` from the quick tier to the full tier until Phase 1 ends, with a note that the fixture is known stale (22/35). Do **not** `--write`. | `tools/run_tests.sh`, `README.md` | S |

- **Playtest:** break one assertion in each harness on purpose. The runner must go red and name it.
- **Exit:** `--quick` green; every suite in `--full` can fail.

**Status 2026-10-28: done.** Runner self-tests 13/13; all 14 changed harnesses exit 1 when their check is broken; `--quick` 16/16; `--full` 25 pass, 1 KNOWN, 2 FAIL on pre-existing simulation bugs B1–B3 (below). Two additions beyond the plan: a KNOWN failure must show its signature (a crash in an xfail suite is a FAIL), and `perf`/`trace` now dispose their World (the engine-error scan would otherwise fail them every soak run). Also fixed: CI passed `GODOT=~/...`, which never expands, so every headless job would have stopped before running. Evidence: `tests/results/cycle-0A/`.

### Cycle 0.B — Playtest tooling in the tree
| ID | Task | Files | Size |
|---|---|---|---|
| P0.B1 | Bring in the rendered walk from this playtest. Add `--steps=` (title, desk, brief, run, debrief, endweek, screens), `--resolution`, and a check that no visible control's rect leaves the viewport. | `tests/ui_walk.gd` (from `tests/results/playtest-2026-10-28-campaign/logs/ui_walk.gd`) | M |
| P0.B2 | `tools/campaign_report.py`: parse `op_test`/balance logs into the playtest table. Columns: min fit, weeks < 12 fit, weeks < $0, max balance, unattended, deaths, allies lost/regained with weeks, winner/kept, run score. | new | S |
| P0.B3 | `op_test.gd --json=path`: emit the same metrics directly, so the report doesn't scrape text. | `tests/op_test.gd` | S |

- **Exit:** one command reproduces this report's campaign table and screenshots.

**Status 2026-10-28: done.** `tools/playtest.sh` (no arguments) reproduces the 28 Oct table and screenshots; `tests/ui_walk.gd` runs headless in the quick tier and rendered under the playtest; `op_test --json` and `tools/campaign_report.py` (which reproduces the 28 Oct numbers from the old logs). Found on the way: op_test never printed an ally lost to an operation or a desk answer (the union was lost in week 10 of seed 1001, not "by week 27"). Evidence: `tests/results/cycle-0B/`.

### Cycle 0.C — Duplicate procurement charge
| ID | Task | Files | Size |
|---|---|---|---|
| P0.C1 | When dealing procurement, skip contracts whose items are all already stocked. | `rogue.gd` `_open_contracts()` | S |
| P0.C2 | After any stocking change (doctrine `_doctrine()`, offer `_sign(...bought=false)`), revalidate the open drafts. Replace a redundant card from the same tier; draw the replacement from a **separate** RNG sub-stream so the rest of the desk stays seed-stable. | `rogue.gd` | S |
| P0.C3 | Guard in `pick()`: refuse, with a line and no charge, if every item is already stocked. | `rogue.gd` `pick()` | S |
| P0.C4 | Regression in `rogue_test`. Cover seeds 1–12 × every inheritance × every contract, expecting 0 wasted purchases. Add a case where a free military contract arrives by offer mid-week. | `tests/rogue_test.gd` (fold in `dup_probe.gd`) | S |

- **Debug:** if "same seed deals the same desk" fails, the replacement consumed the main RNG. Move it to its own stream.
- **Exit:** 0 wasted purchases; reproducibility still passes.

**Status 2026-10-28: done.** The deal-time filter the plan asks for in C1 already existed (`_open_contracts` skipped a contract whose every item was stocked) and could not help: the week-1 procurement draft is dealt in `on_week_start()` **before** the inheritance is chosen, so the stocking that made the card redundant happened afterwards. `contract_stocked()` is now the one predicate, used by the deal, by a new `_revalidate_drafts()` (C2: after a doctrine pick, a signed contract or a free contract from an offer), and by a refusal in `pick()` (C3: a line, no charge, the draft stays open; `from_data()` re-validates restored drafts, so a save written before this change is repaired on load). The replacement draws from its own stream, `draft_rng` (seeded from the run seed, saved as `draft_rng_state`), so the desk's `rng` does not move: same seed, same desk, same later weeks. C4 folds `dup_probe.gd` into `rogue_test`: seeds 1–12 × every inheritance × every contract still offered afterwards must charge exactly the contract's cost and add at least one item; plus the guard, the mid-week free military contract, and an assertion that a re-dealt card advances the replacement stream while the desk's rng stays put. The board's procurement line reads its card count instead of assuming three. Verified: the quick tier (which includes `rogue_test`) is green on **Godot 4.7.2 and 4.4.1** in CI run 40785806997 on PR #1 — any of the new assertions failing would have failed the suite and the job. No engine was available in the sandbox that wrote the change, so the job conclusions, not quoted PASS lines (the CI log blob host is unreachable from it), are the evidence; the static audit (`gd47_check`, 128 files) and `gdparse` on the changed files are clean. Evidence: `tests/results/cycle-0C/`.

### Cycle 0.D — Version, licence, hygiene
| ID | Task | Files | Size |
|---|---|---|---|
| P0.D1 | **Decide the version line.** Going from 1.2.1 down to 0.9 can confuse save and legacy migrations and players. Recommended: **1.3.x = Early Access** (labelled "Early Access" in the title corner), **2.0 = release**. This supersedes the 0.9 suggestion in the roadmap. Run `tools/sync_version.py`. | `scripts/version.gd` +2 | S |
| P0.D2 | Add `LICENSE` (your choice) and `THIRD_PARTY_NOTICES` (Godot MIT, Patrick Hand OFL, fonts used in videos). Make the credits screen match. | root, `ui/front.gd` | S |
| P0.D3 | **Remotion licence:** confirm whether your situation needs a company licence. If it does and you won't buy one, plan to re-render the openers and shorts with other tooling (this links to P4.C). | — | S (decision) |
| P0.D4 | Set `application/config/use_custom_user_dir` and a fixed user-dir name now, so Steam Cloud paths (P2.C4) never move. Keep `Settings.migrate()` for the old dir. | `project.godot`, `ui/settings.gd` | S |

**Status 2026-10-28: done** (the owner's decisions, taken in this session).

| ID | What was decided and done |
|---|---|
| P0.D1 | **Version line: 1.3.x = Early Access, 2.0 = the 1.0 release.** `Version.VALUE` is **1.3.0**, `Version.CHANNEL` is "Early Access"; `tools/sync_version.py` wrote 1.3.0 / 1.3.0.0 into `project.godot` and `export_presets.cfg`. The title plate carries a red **EARLY ACCESS** stamp and `V1.3.0` in its corner, drawn from `Version.CHANNEL`, not from a literal. `tools/patch_rc.py`'s hardcoded `FALLBACK_VERSION` is gone: a Windows build that cannot read `scripts/version.gd` now stops instead of stamping the exe with a number nobody bumped. |
| P0.D2 | **Licence: proprietary, all rights reserved** (`LICENSE`): reading, forking for review and quoting in reviews are permitted; redistribution, commercial use, derivative works and reuse of the art, audio, text or city data are not. **`THIRD_PARTY_NOTICES`** carries the Godot MIT text, the Patrick Hand OFL pointer and text file, Remotion and the render-time fonts (Courier Prime, Oswald, Open Sans — OFL), React (MIT), and the Python asset tools (numpy/scipy BSD, Pillow MIT-CMU). Both files are in every export preset's `include_filter`, and the credits screen names the licence, the notices and the development state. |
| P0.D3 | **Remotion: the free licence applies.** Remotion is free for an individual, a team of up to three people, or a non-profit ([licence FAQ](https://www.remotion.dev/docs/license/faq)); this project qualifies, so **no company licence is required and no re-render is needed** — P4.C1 keeps the red-ink openers as they are. The position and the version (4.0.537) are recorded in `THIRD_PARTY_NOTICES`. **Re-check on a change of circumstance**: more than three people on the project, a publisher, or a company formed around it turns this into a $25/seat/month Company Licence. |
| P0.D4 | **The user directory is fixed now**: `application/config/use_custom_user_dir=true` with `custom_user_dir_name="TheViolence"`, so a rename can never move a save and the Steam Cloud path (P2.C4) is decided before it is needed. `Settings.migrate()` now walks every folder earlier builds wrote — `The Violence - Vertical Slice`, then `The Violence` — and carries `campaign.json(.bak)`, `department.json(.bak)`, `settings.cfg` **and `legacy.json`**, never over an existing file. `improvements_test` pins the project key to `Settings.USER_DIR`, the three legacy folders, and that both files ship. |

- **Evidence:** `tests/results/cycle-0D/`. The static audit and the CI quick tier (both engines) are the checks; `improvements_test` is in that tier and now fails if the version line drifts off 1.3, if the title or credits stop naming the channel, the licence or the notices, if `project.godot`'s user-directory key disagrees with `Settings.USER_DIR`, or if an export preset stops shipping `LICENSE`/`THIRD_PARTY_NOTICES`.

**Gate 0:** `--quick` and CI green with honest exit codes; the duplicate regression passes; the version line and licence are decided.

**Gate 0 on 2026-10-28: met.** 0.A, 0.B, 0.C and 0.D are done: the quick tier is green on Godot 4.7.2 and 4.4.1 with honest exit codes, the duplicate regression passes, and the version line (1.3.0 Early Access) and the licence (proprietary; Remotion free) are decided and recorded. What Gate 0 deliberately does **not** cover is Phase 1's work: the stale determinism fixture (rebaseline at P1.I1) and the three simulation findings B1–B3.

---

## Phase 1 — Make a forty-week run hold together *(≈ 4–6 weeks; the critical path)*

### Cycle 1.A — The balance harness (build it first; every later cycle is measured by it)
| ID | Task | Files | Size |
|---|---|---|---|
| P1.A1 | Policies as code, `tests/policies.gd`: **cautious**, **minimal**, **military-first**, **accept-all**. Each policy sets the desk choices by tag (deterministic, not random), the hiring rule, training, IA decisions, and which calls to take. **Match the UI:** choose the inheritance before the first op, and use current kit unless the policy buys kit. (The current `op_test` issues suggested kit and answers the desk after operations.) | new | M |
| P1.A2 | `tests/rogue_balance_test.gd --seeds=N --policy=all --json=out/`: one process per seed × policy, with a separate `XDG_DATA_HOME` per run. Writes per-run JSON and a summary table. | new | M |
| P1.A3 | `tests/balance_bands.json`: the Gate 1 thresholds, in report-only mode until P1.I. | new | S |
| P1.A4 | **Baseline:** run 20 seeds × 4 policies before any tuning and commit `tests/results/balance-baseline.json`. Every later cycle reports its change from this baseline. | — | S + a night of CPU |

- **Cost note:** one 40-week run took 10–15 minutes on two cores here, so 80 runs is about 7–10 h on two cores or about 2 h on eight. Use the 3-seed smoke during cycles and the full run overnight or in weekly CI.
- **Exit:** the baseline reproduces the playtest's shape (fit collapses, deficits, allies lost). If it doesn't, the policies don't match the game yet.

### Cycle 1.B — Crowd cliff *(root cause located)*
**Diagnosis.**
- `department.gd:771` sets `stress0 = min(0.3, trauma × 0.015)`.
- Line 776 adds `(60 − morale) / 1200`.
- `world.gd` stress decay (around line 3264) never takes stress below `stress0`.
- `misjudge_p()` treats an officer as `calm` only when `stress < 0.2`.

So at **trauma ≥ 13.4** (≈ 11.7 at morale 30) an officer can never be calm. The "a calm officer makes no new mistake about someone already cleared" branch stops applying, every cleared face in the crowd is re-rolled at ×0.1 instead of 0, the first mistake fires, the crowd panics, stress rises, and the cascade follows. That matches the probe: 0 civilians struck at trauma 10, 52 killed at 14.

| ID | Task | Files | Size |
|---|---|---|---|
| P1.B1 | Extend `event_probe.gd`: count **distinct** civilians struck (id set), add `--attack` seeds, and record time to the first police shot at the real attacker and how many people the attacker hit. Sweep `--trauma=0,10,12,13,14,16,20 --morale=30,60 --n=20`. | `tests/event_probe.gd` | S |
| P1.B2 | **Fix A:** make "calm" relative to the officer's own floor: `calm = not in_combat(o) and (o.stress − stress0) < 0.2`. Trauma still raises the base misjudgment rate through `eff`, but it stops disabling the cleared-face rule. | `world.gd misjudge_p()` | S |
| P1.B3 | **Fix B (defence in depth):** after a police round strikes someone later judged a civilian, call a squad-wide **check-fire**: a 20 s hold on new engagements of non-attackers, crowd-panic stress gain halved for that squad, and a forced rally reset. | `world.gd` (`_hit`, `add_stress`) | M |
| P1.B4 | `tests/crowd_trace.gd`: for each quiet event, print the first misjudgment (officer, stress, stress0, target cstate, filming/running, distance, night). Use it on the **natural-trauma** deaths (seeds 5051, 5068, 5119), which Fix A may not cover. | new | S |
| P1.B5 | Keep the Suggest-a-plan "no trauma ≥ 12 on crowd duty" preference, but explain it in the briefing rather than hiding it. | `autoplan.gd`, `ops_ui.gd` | S |

- **Playtest:** run the probe sweep first, then the balance smoke (watch `crowd_killed` and rally deaths per run).
- **Exit:**
  - ≤ 1 distinct civilian struck per quiet event over 20 seeds at trauma 14 and 20.
  - Natural trauma at or below baseline.
  - On attack seeds, the attacker is engaged no later than baseline and attacker casualties are no worse.

### Cycle 1.C — Roster bleed
| ID | Task | Files | Size |
|---|---|---|---|
| P1.C1 | **Measure first:** from the baseline JSON, officer deaths by situation type, map and cause; injury weeks lost; academy throughput. Find the two or three maps or situation types that produce most of the 0.21–0.25 deaths per operation. | `campaign_report.py` | S |
| P1.C2 | A **next-week strip** on the board: fit next week (counting returning injured and academy graduates) against what this week's open calls want (`Autoplan.want_for`). Show red text below 12. | `ops_ui.gd show_board()`, `campaign.gd` | M |
| P1.C3 | **Emergency lateral**: an applicant who reports the same week at about 2× cost. Show the weekly payroll change on every hire button. | `department.gd`, `ops_ui.gd _applicants()` | S |
| P1.C4 | A **standing order** "keep N officers on the books": the academy auto-enrols when the forecast allows it, and the player can see and cancel it. | `department.gd next_week()`, `ops_ui.gd _roster()` | M |
| P1.C5 | Tune lethality where P1.C1 points: suggested force size on the worst maps, medic/bleed-out timing, and the injured-vs-killed split. Don't touch the hit model unless the data says so. | `autoplan.gd`, `world.gd` (medic) | M |

- **Exit (cautious policy):** ≥ 12 fit in ≥ 90% of week-end snapshots; ≤ 25 unattended over the run.

### Cycle 1.D — Money curve
**Diagnosis from the logs.**
- The week-1 margin is $30,500 allocation − $26,264 payroll = **$4,236 a week**. Each officer costs $1,150–1,400 a week, so three hires use up the whole margin.
- Losing Duff cuts the allocation by 8% (−$2,440 a week). After that the department runs a structural deficit, and a negative account freezes hiring, training and kit.
- The harness also hires whenever the balance is above $3,000, which nothing in the UI prevents.

| ID | Task | Files | Size |
|---|---|---|---|
| P1.D1 | Hire, course and kit buttons say what they do to the four-week forecast ("week 6 goes to −$2,100"). Confirm before going negative. | `ops_ui.gd`, `department.gd forecast()` | S |
| P1.D2 | Replace the hard freeze with a **council overdraft** down to −$25K: weekly interest plus Duff standing cost. The freeze only applies below the limit. | `department.gd frozen()`, `politics.gd` | M |
| P1.D3 | Settle lawsuits in instalments over four weeks instead of one hit. | `politics.gd _land()` | S |
| P1.D4 | **Late-game sinks** with real effects: armoured rescue vehicle (capital item; military tag), training range (courses cheaper and faster), union contract (pay up, morale floor up), and tier-3 programs priced higher. Also "return surplus to council" (Duff standing). | `rogue.gd`, `department.gd`, `data/` | M |
| P1.D5 | Starting reserve: test $25K vs $35K under each policy. | `department.gd found()` | S |

- **Exit:**
  - Cautious: no week below $0 in weeks 1–12 and ≤ 4 such weeks overall.
  - Minimal: week-40 balance ≤ $100K, or the money is visibly spent on sinks.

### Cycle 1.E — Allies that can come back
| ID | Task | Files | Size |
|---|---|---|---|
| P1.E1 | Log every ally standing change with a cause, then chart drift per policy. Find what takes the coalition from 45 to below 25 by week 3–4 in two of three runs. | `politics.gd _ally()` | S |
| P1.E2 | **Reconciliation offers** from lost allies: a big cost, standing +20 on acceptance, at most one every four weeks, one per ally per run. | `rogue.gd OFFERS`, `_deal_offer()` | M |
| P1.E3 | Tune drift so a careful run loses 0–1 allies and a reckless run loses 2–3. Being out of sight should never drift an ally down by itself. | `politics.gd week_end()` | M |

- **Exit:** at least one ally lost *and* won back in ≥ 5 of 20 runs; median allies lost under cautious ≤ 1.

### Cycle 1.F — The election and the score
| ID | Task | Files | Size |
|---|---|---|---|
| P1.F1 | Strengthen the poll response to harm, neglect (unattended calls) and restraint, so the record moves the race visibly. Each Ledger week names the cause. | `politics.gd on_operation()`, `week_end()` | M |
| P1.F2 | **Decide** whether Kettering keeping a brutal chief stays (it's thematically strong). If it stays, the run score must not reward it: make the +60 for keeping office conditional on the record, or rebalance the weights. | `rogue.gd run_score()` | S |
| P1.F3 | Election night shows the score breakdown next to the ending, so the player sees *why*. | `ops_ui.gd _election_night()` | S |

- **Exit:** cautious mean run score is above minimal and military-first over 20 seeds; cautious keeps the office in clearly more seeds than minimal.

### Cycle 1.G — Rally pacing
| ID | Task | Files | Size |
|---|---|---|---|
| P1.G1 | Turn `adaptive_speed` on by default (it already exists). | `ui/settings.gd DEFAULTS` | S |
| P1.G2 | **"Skip to the report"** after 60 s of quiet: the sim keeps stepping headless to the end (still deterministic), then the debrief opens. | `main.gd`, `ops_ui.gd show_run()` | M |
| P1.G3 | Measure the wall time of a full run at default settings on the slowest machine you have. Record it in the results. | — | S |

- **Exit:** a quiet rally costs ≤ 60 s wall time at default settings.

### Cycle 1.H — Planning has to matter
| ID | Task | Files | Size |
|---|---|---|---|
| P1.H1 | Run `op_test --chief=manual` against `--chief=sensible` over 20 seeds. If the informed chief doesn't clearly beat the one-click suggestion, the suggestion is too good or the orders too weak. Tune order costs and benefits, not the suggestion's knowledge. | `tests/op_test.gd`, `orders.gd` | M |

- **Exit:** the manual chief is ahead on the run score in ≥ 70% of seeds (a proposed threshold; set your own).

### Cycle 1.I — Close the phase
| ID | Task | Size |
|---|---|---|
| P1.I1 | Re-run determinism. Account for each changed case by a Phase 1 task ID, then `--write` and say so in the changelog. Move determinism back into the quick tier. | S |
| P1.I2 | Switch `balance_bands.json` from report-only to asserting; the full balance run joins weekly CI. | S |
| P1.I3 | Human playtest of a full 40-week run (you), with notes against the gate numbers. | M |

**Gate 1:** all exits from 1.B to 1.H on the full 20-seed run; determinism rebaselined; bands asserting.

---

## Phase 2 — Steam plumbing *(≈ 3 weeks; 2.A can start in Phase 1)*

### Cycle 2.A — First real Windows run *(do this early: cheapest, highest risk)*
| ID | Task | Size |
|---|---|---|
| P2.A1 | On your PC: install official Godot 4.7.2 plus the export templates. Export Windows with the existing preset and play it. **Checklist:** boot, new run, a full week, save, quit, reload, alt-tab, window resize, fullscreen toggle, audio, the opening cutscene, quit. Note GPU and driver. | S |
| P2.A2 | Run `tools/run_tests.sh --quick` and `determinism_test` on Windows and compare against Linux. A cross-platform hash difference is a finding in its own right. | S |
| P2.A3 | Replace `tools/build_windows_exe.sh` (it compiles Godot from source) with `tools/build_release.sh`, which exports from official templates. Update `tools/inspect_pck.py` for pack format 4. | M |

- **Exit:** the checklist is clean on two Windows machines (one of them low-end or an iGPU).

### Cycle 2.B — The Steam app *(your account; can't be done for you)*
| ID | Task | Size |
|---|---|---|
| P2.B1 | Steamworks partner account, app fee, tax and bank details, then wait out Valve's waiting period. | S + wait |
| P2.B2 | App ID, Windows depot, `default` and `beta` branches, and an upload script (`tools/steam/app_build.vdf`, depot vdf, steamcmd). | S |
| P2.B3 | Upload a build to `beta` and install it through the Steam client on a clean machine. | S |

### Cycle 2.C — GodotSteam
| ID | Task | Files | Size |
|---|---|---|---|
| P2.C1 | Choose a GodotSteam release that matches the engine you ship (prefer the GDExtension build, so official templates still work). **Pin the engine version** from here on. | `addons/godotsteam/` | S |
| P2.C2 | Wrap Steam in `scripts/platform/steam.gd` with a null fallback, so headless harnesses, CI and non-Steam builds behave identically. | new | S |
| P2.C3 | **Achievements** (~20), defined in `scripts/data/achievements.gd` and fired from campaign hooks. Examples: finish a run; keep the office under each candidate; no civilian struck all run; every ally kept; win one back; each doctrine unlocked; 40 weeks with zero officer deaths. Test with a headless harness on a fake backend that asserts each trigger. | `campaign.gd`, `rogue.gd`, `politics.gd` | M |
| P2.C4 | **Steam Auto-Cloud** for `campaign.json(.bak)`, `legacy.json` and `settings.cfg`, using the fixed user dir from P0.D4. Test: play on PC A, continue on PC B, then provoke a conflict. | Steamworks config | S |
| P2.C5 | Rich presence ("Week 17 of 40 · Ironworks raid"). | `steam.gd` | S |

- **Exit:** a build installed through Steam unlocks achievements and round-trips the cloud save between two machines.

### Cycle 2.D — Settings
| ID | Task | Files | Size |
|---|---|---|---|
| P2.D1 | Window mode plus **resolution** list. | `ui/settings.gd`, `front.gd` | S |
| P2.D2 | **UI scale** slider. The engine side already exists as the `--ui-scale` command-line hook in `main.gd`; expose it as a setting. | `settings.gd`, `main.gd` | S |
| P2.D3 | Move the 22 hard-coded `KEY_*` checks in `main.gd`/`ui` into **InputMap actions**, then add a **rebinding** screen. | `project.godot [input]`, `main.gd` | M |
| P2.D4 | Reduced motion (boil off plus no camera moves), a text-size option, and a colourblind-safe alternative to red ink. | `settings.gd`, `view/ink.gd` | S |

### Cycle 2.E — Controller and Steam Deck
| ID | Task | Files | Size |
|---|---|---|---|
| P2.E1 | Focus navigation for every dynamically built `ops_ui` screen: set focus neighbours, grab focus on the first actionable control, and show a visible focus ring. | `ops_ui.gd _btn()`, `ui.gd` theme | M |
| P2.E2 | A cursor mode for map interaction (place, face, entry point on the plan) with a stick or trackpad. | `main.gd map input`, `ops_ui.gd map_click()` | M |
| P2.E3 | A default Steam Input configuration. | Steamworks | S |
| P2.E4 | Run `ui_walk.gd --resolution=1280x800 --input=pad`, driving `ui_accept`/`ui_down` events instead of `pressed.emit()`, so the walk proves pad navigation. | `tests/ui_walk.gd` | S |

- **Exit:** the full first week is playable with a pad at 1280×800, with no off-screen controls. If you can test on real Deck hardware, aim for "Playable" at Early Access launch; leave "Verified" for later.

### Cycle 2.F — Saves and bug reports
| ID | Task | Size |
|---|---|---|
| P2.F1 | Save-migration test: load a save from each earlier version you shipped. Add a "this update cannot load your run" notice path. | S |
| P2.F2 | An in-game **Report a problem** button: copies the version, seed, week, last 200 log lines and settings to the clipboard, and opens the log folder. | S |

### Cycle 2.G — Localization scaffold *(optional for EA, cheap now)*
| ID | Task | Size |
|---|---|---|
| P2.G1 | Wrap **new** strings in `tr()` from now on. Extract the 1,500 existing ones with a script into one CSV. No translations yet. | M |

**Gate 2:** a signed (or clearly flagged) build, installed through Steam on a clean Windows machine, completes a week; the save survives quit and reload; achievements fire; the cloud save round-trips; a pad completes week 1.

---

## Phase 3 — First-hour screens *(≈ 1–2 weeks)*

### Cycle 3.A — The left side of every management screen
| ID | Task | Files | Size |
|---|---|---|---|
| P3.A1 | One helper, `_city_backdrop()`: show `city_map` and hide the tactical layers (floor plan, decals, fog, stamps). Call it from `_desk_draft`, `_desk_offer`, `_desk_event`, `_armory`, `_roster`, `_budget`, `_cases`, `_city_hall`, `_story_file` and `_people`. | `ops_ui.gd`, `main.gd _clear_views()` | S |
| P3.A2 | On those screens, use the left pane for the person or place in question: the ally's portrait on an offer, the officer's file on an IA case, ward pins for the budget. A start is enough for EA. | `city_map.gd` | M |
| P3.A3 | Add an assertion to `ops_ui_test`: on any non-plan/run/debrief screen, `city_map.visible` is true and the floor plan is hidden. | `tests/ops_ui_test.gd` | S |

### Cycle 3.B — Say why, visibly
| ID | Task | Files | Size |
|---|---|---|---|
| P3.B1 | `_btn_reason()`: when a button is disabled, print the reason under it. `ops_ui.gd` disables buttons in 6 places and gives the reasons as tooltips, and the first thing a new player tries is one of them. | `ops_ui.gd` | S |
| P3.B2 | In week 1, scroll to and highlight the Desk card until the inheritance is chosen. | `ops_ui.gd show_board()` | S |
| P3.B3 | End week with open calls: confirm with "2 calls will be recorded as unattended; one is likely to reach the papers". | `ops_ui.gd _end_week()` | S |

### Cycle 3.C — Legible text
| ID | Task | Files | Size |
|---|---|---|---|
| P3.C1 | Centralise font sizes in `UI.make_theme()`. Raise the 10–12 px management text to at least 13–14 px at 1600×900. | `ui/ui.gd`, `ops_ui.gd` | M |
| P3.C2 | `ui_walk` at 1280×720, 1280×800, 1600×900 and 1920×1080, with the overflow check from P0.B1. Read every screenshot. | — | S |
| P3.C3 | A three-line summary at the top of the debrief (result, people, what follows). Keep the arithmetic and timeline below it. | `ops_ui.gd show_debrief()` | S |

### Cycle 3.D — New players *(the human cycle)*
| ID | Task | Size |
|---|---|---|
| P3.D1 | Two people who have never played: no help, screen-recorded, from the title to the end of week 2. Write down every stall over 20 s and every misread. | S |
| P3.D2 | Fix the top three stalls, then repeat with two new people. | M |

**Gate 3:** no stall over 60 s in the second session; the overflow check is clean at all four resolutions; the `ops_ui_test` assertion passes.

---

## Phase 4 — Content and music *(≈ 3–4 weeks; after Gate 1, because content multiplies balance work)*

### Cycle 4.A — Music
| ID | Task | Files | Size |
|---|---|---|---|
| P4.A1 | Four beds: title, board/desk, operation (tension, ducked under radio and gunfire), debrief/election night. Produce them yourself, or commission or license them and record the licence in `THIRD_PARTY_NOTICES`. | `assets/music/` | M–L |
| P4.A2 | A Music bus with crossfade by screen family, a volume slider, ducking on radio, and music silenced by the "nothing happened" fast-forward. | `view/sound.gd`, `settings.gd` | S |
| P4.A3 | Mix check: loudness consistent across beds and against the SFX. | S |

### Cycle 4.B — The ten unplayed shorts
| ID | Task | Files | Size |
|---|---|---|---|
| P4.B1 | For each of the 10, either wire it at the beat `cinematics/SHORTS.md` names (through `play_consequence_short` / `claim_short`) or exclude it from the export preset. | `main.gd`, `ops_ui.gd`, `export_presets.cfg` | M |
| P4.B2 | A harness that forces each trigger condition and asserts the key is claimed once per run. | `tests/shorts_test.gd` | S |

### Cycle 4.C — Cutscene look (decision)
- **P4.C1:** ship the red-ink openers as-is and say so in the Early Access notes, or re-render them in crayon. If the Remotion licence (P0.D3) blocks you, this becomes a re-render with other tooling.

### Cycle 4.D — Variety per run
| ID | Task | Files | Size |
|---|---|---|---|
| P4.D1 | Events 20 → ~35 and offers 14 → ~24, in batches of five. Each new item gets a reproducibility check and an effect assertion in `rogue_test`. Run the balance smoke after every batch. | `rogue.gd EVENTS/OFFERS` | L |
| P4.D2 | A second tier of doctrines unlocked through the legacy file. | `rogue.gd DOCTRINES` | M |

### Cycle 4.E — The 1.5 command layer (decision)
- **P4.E1:** find the session copy that has `deploy.gd`, `command_test.gd`, `strike.gd` and maps 12–15, and either merge it (then `command_test` must pass on all maps and the balance must be re-baselined) or list it as a plan in the Early Access Q&A and ship with 12 maps.

**Gate 4:** music in all four families; no short is half-wired; the balance smoke is still inside the bands after the content batches.

---

## Phase 5 — Store page, demo, testers *(page work starts after Gate 1 and runs in parallel)*

### Cycle 5.A — Store page
| ID | Task | Size |
|---|---|---|
| P5.A1 | Capsule art, library art and logo at the sizes Steamworks currently lists (check its graphical-assets page). The title must be readable at small-capsule size. | M |
| P5.A2 | 6–10 gameplay-only screenshots at 1920×1080 from `ui_walk`, after Phase 3 (no stale maps). | S |
| P5.A3 | A gameplay trailer of 60–90 s, cut with `tools/make_ads.py` plus `mix_soundtrack.py` and your music. | M |
| P5.A4 | Description, tags, content survey (violence, gore toggle, police violence themes), and the AI-content disclosure. Then submit the page for review at least 7 business days ahead. | S |
| P5.A5 | Put the page live as **Coming Soon** as soon as it's approved, so wishlists start accruing. | — |

### Cycle 5.B — Demo
| ID | Task | Files | Size |
|---|---|---|---|
| P5.B1 | A `demo` export feature tag: the run ends after week 10 with a card (score so far, "the election is thirty weeks away"), a separate legacy file, and no achievements. | `campaign.gd`, `export_presets.cfg` | S |
| P5.B2 | A separate demo app and store page. | S |
| P5.B3 | Run the full playtest loop on the demo build, with the balance smoke truncated to 10 weeks. | S |

### Cycle 5.C — Testers
| ID | Task | Size |
|---|---|---|
| P5.C1 | Steam Playtest (or an invite list) of 20–50 people on the `beta` branch, after Gate 1. | S |
| P5.C2 | Weekly loop: build Monday, testers play all week, triage Friday (crash → balance → confusion), fix the following week. Ask testers to attach the **Report a problem** text (P2.F2) and their run JSON. | ongoing |
| P5.C3 | Look for dominant strategies (compare tester runs with the four policies) and for the week where people stop playing. | ongoing |

### Cycle 5.D — Next Fest and launch
| ID | Task | When (Option A) |
|---|---|---|
| P5.D1 | Demo public on its own page. | April 2027 |
| P5.D2 | Register for the June Next Fest. | by **25 Apr 2027** |
| P5.D3 | Submit the demo and page for the press preview. | by **10 May 2027** |
| P5.D4 | Everything submitted. | by **24 May 2027** |
| P5.D5 | Next Fest. | **14–21 Jun 2027** |
| P5.D6 | Write the Early Access Q&A (no dated promises), set the price below the 1.0 price, list known issues, submit the build at least 7 business days before launch. | June 2027 |
| P5.D7 | Early Access launch, then patch every 2–3 weeks for two months. | late June – July 2027 |

---

## Bugs found by the cycles

| ID | Found in | Bug | Where to look | Phase |
|---|---|---|---|---|
| B1 | 0.A full tier | **Wolf brain backwards:** a lone fighter in an unseen fight spends 0.19 of it hidden with the wolf brain on vs 0.28 off (gate wants more). | `scripts/sim/brain.gd` (wolf), `tests/brains_test.gd --only=wolf --n=24 --v` | fix in Phase 1 (sim changes are rebaselined together in P1.I1) |
| B2 | 0.A full tier | **Shield lets more through:** rounds reaching an officer facing 3 rifles at 10 m: 1.02 with the shield vs 0.69 without (gate wants fewer). | `world.gd` shield block / `_notice_shield_stop`, `equip_test.gd` shield case | Phase 1 |
| B4 | first GitHub CI run | **Intermittent quick-tier failure on Godot 4.4.1:** the first CI run (16a76a2) failed one quick-tier suite on 4.4.1 after 7½ minutes; the next run (acace9d) and a local 4.4.1 run passed 17/17. The suite is unknown (the job log could not be read from the sandbox). Failed suites are now reported as annotations, so the next occurrence names itself. | CI annotations on the commit; `gh api repos/.../check-runs/<job>/annotations` | Phase 0 follow-up: if it recurs, fix or quarantine it |
| B3 | 0.A full tier | **Beanbag slows the arrest:** 224 s to cuff a non-compliant unarmed man with beanbags vs 208 s without (gate wants less). | less-lethal-first order, `equip_test.gd` beanbag case | Phase 1 |

## Order and overlap

```
Nov 2026     P0 (all) ─► P1.A baseline ─► P1.B crowd ─► P1.C roster
Dec 2026     P1.D money ─► P1.E allies ─► P1.F election ─► P1.G pacing ─► P1.H
             (in parallel, short bursts: P2.A Windows run, P2.B Steam account)
Jan 2027     P1.I close Gate 1 ─► P3 first-hour screens ─► P2.C–G Steam plumbing
Feb 2027     Gate 2 + 3 ─► P5.A store page live (Coming Soon) ─► P5.C testers start
Mar–Apr      P4 content + music ─► P5.B demo public (April) ─► register NF by 25 Apr
May–Jun      tester cycles ─► NF submissions 10/24 May ─► Next Fest 14–21 Jun
Jun–Jul      Early Access launch
```

These durations assume full-time work; stretch them proportionally for evenings and weekends. Phase 1 is where the schedule is most likely to slip. If a Gate 1 number won't close, simplify the system (fewer allies, simpler money) rather than move the dates.

## Decisions needed before or during the cycles

1. Version line (P0.D1). **Decided 2026-10-28: 1.3.x = Early Access, 1.3.0 now; 2.0 = release.**
2. Licence for the game and the Remotion question (P0.D2–D3). **Decided 2026-10-28: proprietary, all rights reserved; Remotion under its free licence (re-check if headcount passes three or a company is involved).**
3. Gate 1 thresholds (`balance_bands.json`).
4. Whether Kettering keeping a brutal chief stays, and how the score treats it (P1.F2).
5. Cutscenes as-is or re-rendered (P4.C1).
6. Whether to recover the 1.5 command layer before EA (P4.E1).
7. Which Next Fest (roadmap §5).
