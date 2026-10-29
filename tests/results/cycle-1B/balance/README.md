# 1.B balance matrix — incomplete, to be re-run

`report.md` and `summary.json` here hold **27 of 80 runs** and are **not** the 1.B campaign
result: do not compare them with the 1.A baseline. They were committed by the merge of
CI run 40884928446, which was cancelled 45 minutes in — its merge job still ran on the
first batch of each shard. The full run (40893197894) merged all 80, but its commit
conflicted with these files and was lost (the CI now skips cancelled runs and lets a
run's own files win). Run locally, two of the missing runs (seed 3003, military-first
and accept-all) finish cleanly in 12–15 minutes: the simulation was never at fault.

The re-run replays the 1.B code (12d792d plus the CI fixes) and replaces these files,
adding `ops.csv` and `weeks.csv` for EA_TASKS P1.C1.
