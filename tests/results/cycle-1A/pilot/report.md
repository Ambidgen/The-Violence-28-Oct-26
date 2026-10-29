# Run-layer balance — 2 seed(s) × 4 policy(ies), 40 weeks

8 run(s), 4001 s wall clock, 4.7.2-stable (official).

| metric | cautious | minimal | military-first | accept-all |
|---|---|---|---|---|
| lowest fit officers | 6.50 [5–8] | 8 [6–10] | 6.50 [5–8] | 2 [0–4] |
| weeks under 12 fit | 20 [13–27] | 7.50 [4–11] | 23 [22–24] | 28.50 [25–32] |
| weeks below $0 | 3 [1–5] | 0 [0–0] | 4.50 [4–5] | 13 [1–25] |
| weeks below $0 (1-12) | 1 [1–1] | 0 [0–0] | 1.50 [1–2] | 2.50 [1–4] |
| account at week 40 | 4749.50 [1219–8280] | 414598 [389374–439822] | -7094.50 [-28165–13976] | -53934 [-117318–9451] |
| lowest account | -12748 [-23013–-2483] | 40386 [40216–40556] | -19395.50 [-28165–-10626] | -156073 [-302666–-9479] |
| highest account | 27086.50 [22810–31363] | 416821 [393820–439822] | 16869 [16029–17709] | 25851.50 [25262–26441] |
| situations unattended | 61 [55–67] | 87.50 [83–92] | 53 [53–53] | 55.50 [49–62] |
| officers killed | 22 [19–25] | 10 [8–12] | 13.50 [12–15] | 24.50 [20–29] |
| killed per operation | 0.33 [0.27–0.38] | 0.25 [0.20–0.30] | 0.18 [0.15–0.21] | 0.33 [0.29–0.38] |
| civilians killed | 3.50 [1–6] | 4 [2–6] | 3.50 [2–5] | 20.50 [8–33] |
| findings | 69.50 [49–90] | 37 [36–38] | 52.50 [48–57] | 119 [99–139] |
| allies lost at the end | 3 [3–3] | 2 [2–2] | 3.50 [3–4] | 4 [4–4] |
| allies won back | 0 [0–0] | 0 [0–0] | 0 [0–0] | 0 [0–0] |
| run score | -610.50 [-738–-483] | -492 [-612–-372] | -456.50 [-517–-396] | -1566 [-2110–-1022] |
| chief kept | 2/2 | 1/2 | 2/2 | 1/2 |

## Gate 1 bands — report-only

```
MISS roster-floor               cautious     >= 10  (got 5)
MISS roster-floor               minimal      >= 10  (got 6)
MISS roster-floor               military     >= 10  (got 5)
MISS roster-floor               accept_all   >= 10  (got 0)
MISS roster-weeks               cautious     <= 8  (got 27)
MISS roster-weeks               minimal      <= 8  (got 11)
MISS roster-weeks               military     <= 8  (got 24)
MISS roster-weeks               accept_all   <= 8  (got 32)
ok   money-deficit              cautious     <= 8  (got 5)
ok   money-deficit              minimal      <= 8  (got 0)
ok   money-deficit              military     <= 8  (got 5)
MISS money-deficit              accept_all   <= 8  (got 25)
ok   money-debt                 cautious     >= -75000  (got -23013)
ok   money-debt                 minimal      >= -75000  (got 40216)
ok   money-debt                 military     >= -75000  (got -28165)
MISS money-debt                 accept_all   >= -75000  (got -302666)
ok   money-end                  cautious     >= 0  (got 4749.50)
ok   money-end                  minimal      >= 0  (got 414598)
MISS money-end                  military     >= 0  (got -7094.50)
MISS money-end                  accept_all   >= 0  (got -53934)
MISS coverage                   cautious     <= 48  (got 61)
MISS coverage                   minimal      <= 48  (got 87.50)
MISS coverage                   military     <= 48  (got 53)
MISS coverage                   accept_all   <= 48  (got 55.50)
MISS deaths                     cautious     <= 8  (got 22)
MISS deaths                     minimal      <= 8  (got 10)
MISS deaths                     military     <= 8  (got 13.50)
MISS deaths                     accept_all   <= 8  (got 24.50)
MISS lethality                  cautious     <= 0.15  (got 0.38)
MISS lethality                  minimal      <= 0.15  (got 0.30)
MISS lethality                  military     <= 0.15  (got 0.21)
MISS lethality                  accept_all   <= 0.15  (got 0.38)
ok   civilians                  cautious     <= 6  (got 3.50)
ok   civilians                  minimal      <= 6  (got 4)
ok   civilians                  military     <= 6  (got 3.50)
MISS civilians                  accept_all   <= 6  (got 20.50)
MISS allies-held                cautious     <= 2  (got 3)
ok   allies-held                minimal      <= 2  (got 2)
MISS allies-held                military     <= 2  (got 3.50)
MISS allies-held                accept_all   <= 2  (got 4)
MISS ally-recovery              cautious     >= 0.25  (got 0)
MISS ally-recovery              minimal      >= 0.25  (got 0)
MISS ally-recovery              military     >= 0.25  (got 0)
MISS ally-recovery              accept_all   >= 0.25  (got 0)
MISS score                      cautious     >= 0  (got -610.50)
MISS score                      minimal      >= 0  (got -492)
MISS score                      military     >= 0  (got -456.50)
MISS score                      accept_all   >= 0  (got -1566)
ok   election                   cautious     >= 0.50  (got 1)
ok   election                   minimal      >= 0.50  (got 0.50)
ok   election                   military     >= 0.50  (got 1)
ok   election                   accept_all   >= 0.50  (got 0.50)
```

36 band miss(es); report-only until P1.I (balance_bands.json "enforce").

## What each policy does

- **cautious** — Hire to 14, train, restraint contracts, no military hardware, answer the gravest two calls and keep high-trauma officers off crowd duty.
- **minimal** — No hiring, no courses, no contracts, no programs, every offer declined, cases left to lapse, one call a week.
- **military-first** — Military contracts and kit, Kettering's offers, cases cleared, hire to 16, three calls a week including crowd events.
- **accept-all** — Sign the cheapest contract and program on the desk, accept every offer and answer every event, hire to 18, let plans buy kit, three calls a week.