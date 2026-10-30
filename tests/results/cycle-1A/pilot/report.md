# Run-layer balance — 2 seed(s) × 4 policy(ies), 40 weeks

8 run(s), 2512 s wall clock, 4.7.2-stable (official).

| metric | cautious | minimal | military-first | accept-all |
|---|---|---|---|---|
| lowest fit officers | 5.50 [4–7] | 8 [6–10] | 7.50 [7–8] | 1 [0–2] |
| weeks under 12 fit | 18 [8–28] | 3.50 [3–4] | 26 [24–28] | 17.50 [12–23] |
| weeks below $0 | 36 [33–39] | 0 [0–0] | 1.50 [1–2] | 35 [33–37] |
| weeks below $0 (1-12) | 10 [9–11] | 0 [0–0] | 1.50 [1–2] | 8 [7–9] |
| account at week 40 | -31561.50 [-35866–-27257] | 461249 [441645–480853] | 10937.50 [9539–12336] | -4463.50 [-7365–-1562] |
| lowest account | -42100 [-43435–-40765] | 40386 [40216–40556] | -1247.50 [-1463–-1032] | -15421.50 [-17077–-13766] |
| highest account | 4049.50 [273–7826] | 461249 [441645–480853] | 21616 [18368–24864] | 5703.50 [2516–8891] |
| situations unattended | 55.50 [47–64] | 87.50 [83–92] | 56 [55–57] | 43 [31–55] |
| officers killed | 28.50 [25–32] | 10.50 [9–12] | 17 [16–18] | 29.50 [25–34] |
| killed per operation | 0.39 [0.32–0.46] | 0.27 [0.23–0.30] | 0.24 [0.24–0.24] | 0.36 [0.27–0.45] |
| civilians killed | 6 [4–8] | 0 [0–0] | 2.50 [1–4] | 2 [0–4] |
| findings | 89 [79–99] | 22.50 [22–23] | 52.50 [50–55] | 85.50 [72–99] |
| allies lost at the end | 3 [3–3] | 2 [2–2] | 3 [3–3] | 3.50 [3–4] |
| allies won back | 0 [0–0] | 0 [0–0] | 0 [0–0] | 0 [0–0] |
| run score | -1033.50 [-1276–-791] | -285 [-306–-264] | -399.50 [-470–-329] | -852 [-1087–-617] |
| chief kept | 1/2 | 2/2 | 2/2 | 2/2 |

## Gate 1 bands — report-only

```
MISS roster-floor               cautious     >= 10  (got 4)
MISS roster-floor               minimal      >= 10  (got 6)
MISS roster-floor               military     >= 10  (got 7)
MISS roster-floor               accept_all   >= 10  (got 0)
MISS roster-weeks               cautious     <= 8  (got 28)
ok   roster-weeks               minimal      <= 8  (got 4)
MISS roster-weeks               military     <= 8  (got 28)
MISS roster-weeks               accept_all   <= 8  (got 23)
MISS money-deficit              cautious     <= 8  (got 39)
ok   money-deficit              minimal      <= 8  (got 0)
ok   money-deficit              military     <= 8  (got 2)
MISS money-deficit              accept_all   <= 8  (got 37)
ok   money-debt                 cautious     >= -75000  (got -43435)
ok   money-debt                 minimal      >= -75000  (got 40216)
ok   money-debt                 military     >= -75000  (got -1463)
ok   money-debt                 accept_all   >= -75000  (got -17077)
MISS money-end                  cautious     >= 0  (got -31561.50)
ok   money-end                  minimal      >= 0  (got 461249)
ok   money-end                  military     >= 0  (got 10937.50)
MISS money-end                  accept_all   >= 0  (got -4463.50)
MISS coverage                   cautious     <= 48  (got 55.50)
MISS coverage                   minimal      <= 48  (got 87.50)
MISS coverage                   military     <= 48  (got 56)
ok   coverage                   accept_all   <= 48  (got 43)
MISS deaths                     cautious     <= 8  (got 28.50)
MISS deaths                     minimal      <= 8  (got 10.50)
MISS deaths                     military     <= 8  (got 17)
MISS deaths                     accept_all   <= 8  (got 29.50)
MISS lethality                  cautious     <= 0.15  (got 0.46)
MISS lethality                  minimal      <= 0.15  (got 0.30)
MISS lethality                  military     <= 0.15  (got 0.24)
MISS lethality                  accept_all   <= 0.15  (got 0.45)
ok   civilians                  cautious     <= 6  (got 6)
ok   civilians                  minimal      <= 6  (got 0)
ok   civilians                  military     <= 6  (got 2.50)
ok   civilians                  accept_all   <= 6  (got 2)
MISS allies-held                cautious     <= 2  (got 3)
ok   allies-held                minimal      <= 2  (got 2)
MISS allies-held                military     <= 2  (got 3)
MISS allies-held                accept_all   <= 2  (got 3.50)
MISS ally-recovery              cautious     >= 0.25  (got 0)
MISS ally-recovery              minimal      >= 0.25  (got 0)
MISS ally-recovery              military     >= 0.25  (got 0)
MISS ally-recovery              accept_all   >= 0.25  (got 0)
MISS score                      cautious     >= 0  (got -1033.50)
MISS score                      minimal      >= 0  (got -285)
MISS score                      military     >= 0  (got -399.50)
MISS score                      accept_all   >= 0  (got -852)
ok   election                   cautious     >= 0.50  (got 0.50)
ok   election                   minimal      >= 0.50  (got 1)
ok   election                   military     >= 0.50  (got 1)
ok   election                   accept_all   >= 0.50  (got 1)
```

33 band miss(es); report-only until P1.I (balance_bands.json "enforce").

## What each policy does

- **cautious** — Hire to 14 (an emergency lateral below 12 fit, a standing order for 18 on the books), train, restraint contracts, no military hardware, answer the gravest two calls and keep high-trauma officers off crowd duty.
- **minimal** — No hiring, no courses, no contracts, no programs, every offer declined, cases left to lapse, one call a week.
- **military-first** — Military contracts and kit, Kettering's offers, cases cleared, hire to 16 (an emergency lateral below 12 fit), three calls a week including crowd events.
- **accept-all** — Sign the cheapest contract and program on the desk, accept every offer and answer every event, hire to 18 (a standing order for 20 on the books), let plans buy kit, three calls a week.