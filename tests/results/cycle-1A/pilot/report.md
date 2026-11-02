# Run-layer balance — 2 seed(s) × 4 policy(ies), 40 weeks

8 run(s), 4044 s wall clock, 4.7.2-stable (official).

| metric | cautious | minimal | military-first | accept-all |
|---|---|---|---|---|
| lowest fit officers | 5 [4–6] | 6.50 [3–10] | 6 [5–7] | 5.50 [3–8] |
| weeks under 12 fit | 13 [12–14] | 8.50 [5–12] | 22 [18–26] | 23.50 [21–26] |
| weeks below $0 | 27 [27–27] | 0 [0–0] | 7.50 [6–9] | 32.50 [31–34] |
| weeks below $0 (1-12) | 4 [3–5] | 0 [0–0] | 3 [3–3] | 5.50 [4–7] |
| account at week 40 | -5248 [-6018–-4478] | 515727 [486655–544799] | -25025 [-63931–13881] | -18301.50 [-31151–-5452] |
| lowest account | -63882 [-112810–-14953] | 36687 [33158–40216] | -56908 [-81181–-32635] | -73779 [-87736–-59822] |
| highest account | 7215 [6664–7766] | 515727 [486655–544799] | 17857 [17502–18212] | 7793.50 [6696–8891] |
| situations unattended | 56.50 [51–62] | 87.50 [83–92] | 56.50 [52–61] | 42.50 [40–45] |
| officers killed | 20.50 [18–23] | 11 [9–13] | 15.50 [14–17] | 22.50 [22–23] |
| killed per operation | 0.28 [0.25–0.31] | 0.28 [0.23–0.33] | 0.21 [0.19–0.24] | 0.27 [0.26–0.27] |
| civilians killed | 5 [3–7] | 0 [0–0] | 4.50 [4–5] | 6.50 [3–10] |
| findings | 67.50 [62–73] | 25.50 [22–29] | 57.50 [53–62] | 80 [78–82] |
| allies lost at the end | 3 [3–3] | 2 [2–2] | 4 [4–4] | 3.50 [3–4] |
| allies won back | 0 [0–0] | 0 [0–0] | 0 [0–0] | 0 [0–0] |
| run score | -701.50 [-713–-690] | -308.50 [-383–-234] | -593 [-667–-519] | -763 [-876–-650] |
| chief kept | 2/2 | 2/2 | 1/2 | 2/2 |

## Gate 1 bands — report-only

```
MISS roster-floor               cautious     >= 10  (got 4)
MISS roster-floor               minimal      >= 10  (got 3)
MISS roster-floor               military     >= 10  (got 5)
MISS roster-floor               accept_all   >= 10  (got 3)
MISS roster-weeks               cautious     <= 8  (got 14)
MISS roster-weeks               minimal      <= 8  (got 12)
MISS roster-weeks               military     <= 8  (got 26)
MISS roster-weeks               accept_all   <= 8  (got 26)
MISS money-deficit              cautious     <= 8  (got 27)
ok   money-deficit              minimal      <= 8  (got 0)
MISS money-deficit              military     <= 8  (got 9)
MISS money-deficit              accept_all   <= 8  (got 34)
MISS money-debt                 cautious     >= -75000  (got -112810)
ok   money-debt                 minimal      >= -75000  (got 33158)
MISS money-debt                 military     >= -75000  (got -81181)
MISS money-debt                 accept_all   >= -75000  (got -87736)
MISS money-end                  cautious     >= 0  (got -5248)
ok   money-end                  minimal      >= 0  (got 515727)
MISS money-end                  military     >= 0  (got -25025)
MISS money-end                  accept_all   >= 0  (got -18301.50)
MISS coverage                   cautious     <= 48  (got 56.50)
MISS coverage                   minimal      <= 48  (got 87.50)
MISS coverage                   military     <= 48  (got 56.50)
ok   coverage                   accept_all   <= 48  (got 42.50)
MISS deaths                     cautious     <= 8  (got 20.50)
MISS deaths                     minimal      <= 8  (got 11)
MISS deaths                     military     <= 8  (got 15.50)
MISS deaths                     accept_all   <= 8  (got 22.50)
MISS lethality                  cautious     <= 0.15  (got 0.31)
MISS lethality                  minimal      <= 0.15  (got 0.33)
MISS lethality                  military     <= 0.15  (got 0.24)
MISS lethality                  accept_all   <= 0.15  (got 0.27)
ok   civilians                  cautious     <= 6  (got 5)
ok   civilians                  minimal      <= 6  (got 0)
ok   civilians                  military     <= 6  (got 4.50)
MISS civilians                  accept_all   <= 6  (got 6.50)
MISS allies-held                cautious     <= 2  (got 3)
ok   allies-held                minimal      <= 2  (got 2)
MISS allies-held                military     <= 2  (got 4)
MISS allies-held                accept_all   <= 2  (got 3.50)
MISS ally-recovery              cautious     >= 0.25  (got 0)
MISS ally-recovery              minimal      >= 0.25  (got 0)
MISS ally-recovery              military     >= 0.25  (got 0)
MISS ally-recovery              accept_all   >= 0.25  (got 0)
MISS score                      cautious     >= 0  (got -701.50)
MISS score                      minimal      >= 0  (got -308.50)
MISS score                      military     >= 0  (got -593)
MISS score                      accept_all   >= 0  (got -763)
ok   election                   cautious     >= 0.50  (got 1)
ok   election                   minimal      >= 0.50  (got 1)
ok   election                   military     >= 0.50  (got 0.50)
ok   election                   accept_all   >= 0.50  (got 1)
```

40 band miss(es); report-only until P1.I (balance_bands.json "enforce").

## What each policy does

- **cautious** — Hire to 14 (an emergency lateral below 12 fit, a standing order for 18 on the books), train, restraint contracts, no military hardware, take the suggested raid kit, answer the gravest two calls and keep high-trauma officers off crowd duty.
- **minimal** — No hiring, no courses, no contracts, no programs, every offer declined, cases left to lapse, one call a week.
- **military-first** — Military contracts and kit, Kettering's offers, cases cleared, hire to 16 (an emergency lateral below 12 fit), three calls a week including crowd events.
- **accept-all** — Sign the cheapest contract and program on the desk, accept every offer and answer every event, hire to 18 (a standing order for 20 on the books), let plans buy kit, three calls a week.