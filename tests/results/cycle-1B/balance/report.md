# Run-layer balance — 20 seed(s) × 4 policy(ies), 40 weeks

27 run(s), 0 s wall clock, 4.7.2-stable (official).

| metric | cautious | minimal | military-first | accept-all |
|---|---|---|---|---|
| lowest fit officers | 5.14 [3–8] | 7.38 [2–10] | 4.83 [2–8] | 5.50 [5–7] |
| weeks under 12 fit | 19.86 [13–34] | 14.50 [3–38] | 27.33 [17–35] | 20.67 [12–24] |
| weeks below $0 | 5 [1–13] | 0 [0–0] | 6.67 [1–15] | 6 [3–10] |
| weeks below $0 (1-12) | 1.29 [0–5] | 0 [0–0] | 2.50 [1–8] | 1.33 [1–2] |
| account at week 40 | -9966.29 [-58335–16434] | 456728 [218424–608118] | 8507.83 [-5986–17266] | 820.33 [-52714–15745] |
| lowest account | -32280 [-68306–-676] | 38626 [30499–40556] | -18903.50 [-46465–-1032] | -24176 [-52714–-4207] |
| highest account | 26470 [19062–39784] | 466159 [293871–608118] | 28810 [18061–56959] | 19837 [12495–24540] |
| situations unattended | 58.29 [50–66] | 86.12 [79–92] | 57.50 [51–68] | 42.33 [36–51] |
| officers killed | 21.71 [15–28] | 11.50 [8–18] | 16.67 [13–21] | 21.50 [16–28] |
| killed per operation | 0.33 [0.19–0.49] | 0.30 [0.20–0.50] | 0.25 [0.19–0.34] | 0.26 [0.18–0.35] |
| civilians killed | 5.71 [2–8] | 3.25 [0–10] | 3.83 [1–6] | 5 [3–9] |
| findings | 71.14 [57–93] | 40.88 [22–81] | 73.17 [50–97] | 79.67 [63–98] |
| allies lost at the end | 3 [3–3] | 2.38 [2–4] | 3.50 [3–4] | 3.33 [3–4] |
| allies won back | 0 [0–0] | 0.12 [0–1] | 0 [0–0] | 0 [0–0] |
| run score | -746.29 [-947–-507] | -504.62 [-972–-238] | -551 [-965–-176] | -690.67 [-973–-464] |
| chief kept | 5/7 | 7/8 | 4/6 | 4/6 |

## Gate 1 bands — report-only

```
MISS roster-floor               cautious     >= 10  (got 3)
MISS roster-floor               minimal      >= 10  (got 2)
MISS roster-floor               military     >= 10  (got 2)
MISS roster-floor               accept_all   >= 10  (got 5)
MISS roster-weeks               cautious     <= 8  (got 34)
MISS roster-weeks               minimal      <= 8  (got 38)
MISS roster-weeks               military     <= 8  (got 35)
MISS roster-weeks               accept_all   <= 8  (got 24)
MISS money-deficit              cautious     <= 8  (got 13)
ok   money-deficit              minimal      <= 8  (got 0)
MISS money-deficit              military     <= 8  (got 15)
MISS money-deficit              accept_all   <= 8  (got 10)
ok   money-debt                 cautious     >= -75000  (got -68306)
ok   money-debt                 minimal      >= -75000  (got 30499)
ok   money-debt                 military     >= -75000  (got -46465)
ok   money-debt                 accept_all   >= -75000  (got -52714)
MISS money-end                  cautious     >= 0  (got -9966.29)
ok   money-end                  minimal      >= 0  (got 456728)
ok   money-end                  military     >= 0  (got 8507.83)
ok   money-end                  accept_all   >= 0  (got 820.33)
MISS coverage                   cautious     <= 48  (got 58.29)
MISS coverage                   minimal      <= 48  (got 86.12)
MISS coverage                   military     <= 48  (got 57.50)
ok   coverage                   accept_all   <= 48  (got 42.33)
MISS deaths                     cautious     <= 8  (got 21.71)
MISS deaths                     minimal      <= 8  (got 11.50)
MISS deaths                     military     <= 8  (got 16.67)
MISS deaths                     accept_all   <= 8  (got 21.50)
MISS lethality                  cautious     <= 0.15  (got 0.49)
MISS lethality                  minimal      <= 0.15  (got 0.50)
MISS lethality                  military     <= 0.15  (got 0.34)
MISS lethality                  accept_all   <= 0.15  (got 0.35)
ok   civilians                  cautious     <= 6  (got 5.71)
ok   civilians                  minimal      <= 6  (got 3.25)
ok   civilians                  military     <= 6  (got 3.83)
ok   civilians                  accept_all   <= 6  (got 5)
MISS allies-held                cautious     <= 2  (got 3)
MISS allies-held                minimal      <= 2  (got 2.38)
MISS allies-held                military     <= 2  (got 3.50)
MISS allies-held                accept_all   <= 2  (got 3.33)
MISS ally-recovery              cautious     >= 0.25  (got 0)
MISS ally-recovery              minimal      >= 0.25  (got 0.12)
MISS ally-recovery              military     >= 0.25  (got 0)
MISS ally-recovery              accept_all   >= 0.25  (got 0)
MISS score                      cautious     >= 0  (got -746.29)
MISS score                      minimal      >= 0  (got -504.62)
MISS score                      military     >= 0  (got -551)
MISS score                      accept_all   >= 0  (got -690.67)
ok   election                   cautious     >= 0.50  (got 0.71)
ok   election                   minimal      >= 0.50  (got 0.88)
ok   election                   military     >= 0.50  (got 0.67)
ok   election                   accept_all   >= 0.50  (got 0.67)
```

35 band miss(es); report-only until P1.I (balance_bands.json "enforce").

## Broken runs

- seed 3003 cautious: no run in any shard
- seed 3003 minimal: no run in any shard
- seed 3003 military: no run in any shard
- seed 3003 accept_all: no run in any shard
- seed 4004 cautious: no run in any shard
- seed 4004 minimal: no run in any shard
- seed 4004 military: no run in any shard
- seed 4004 accept_all: no run in any shard
- seed 6006 cautious: no run in any shard
- seed 6006 minimal: no run in any shard
- seed 6006 military: no run in any shard
- seed 6006 accept_all: no run in any shard
- seed 7007 cautious: no run in any shard
- seed 7007 minimal: no run in any shard
- seed 7007 military: no run in any shard
- seed 7007 accept_all: no run in any shard
- seed 8008 cautious: no run in any shard
- seed 8008 minimal: no run in any shard
- seed 8008 military: no run in any shard
- seed 8008 accept_all: no run in any shard
- seed 10010 cautious: no run in any shard
- seed 10010 military: no run in any shard
- seed 10010 accept_all: no run in any shard
- seed 11011 cautious: no run in any shard
- seed 11011 minimal: no run in any shard
- seed 11011 military: no run in any shard
- seed 11011 accept_all: no run in any shard
- seed 12012 cautious: no run in any shard
- seed 12012 minimal: no run in any shard
- seed 12012 military: no run in any shard
- seed 12012 accept_all: no run in any shard
- seed 14014 military: no run in any shard
- seed 14014 accept_all: no run in any shard
- seed 15015 cautious: no run in any shard
- seed 15015 minimal: no run in any shard
- seed 15015 military: no run in any shard
- seed 15015 accept_all: no run in any shard
- seed 16016 cautious: no run in any shard
- seed 16016 minimal: no run in any shard
- seed 16016 military: no run in any shard
- seed 16016 accept_all: no run in any shard
- seed 18018 cautious: no run in any shard
- seed 18018 minimal: no run in any shard
- seed 18018 military: no run in any shard
- seed 18018 accept_all: no run in any shard
- seed 19019 cautious: no run in any shard
- seed 19019 minimal: no run in any shard
- seed 19019 military: no run in any shard
- seed 19019 accept_all: no run in any shard
- seed 20020 cautious: no run in any shard
- seed 20020 minimal: no run in any shard
- seed 20020 military: no run in any shard
- seed 20020 accept_all: no run in any shard

## What each policy does

- **cautious** — Hire to 14, train, restraint contracts, no military hardware, answer the gravest two calls and keep high-trauma officers off crowd duty.
- **minimal** — No hiring, no courses, no contracts, no programs, every offer declined, cases left to lapse, one call a week.
- **military-first** — Military contracts and kit, Kettering's offers, cases cleared, hire to 16, three calls a week including crowd events.
- **accept-all** — Sign the cheapest contract and program on the desk, accept every offer and answer every event, hire to 18, let plans buy kit, three calls a week.