# Trend Decomposition — Findings Memo
**Window:** Trailing 4w (Jan 4–31, 2021) vs Prior 4w (Dec 7, 2020–Jan 3, 2021)
**Source:** `sql/03_trend_decomposition.sql` (Q0–Q4) on `ecom-da-project.ecom_marts.sessions`

## Headline
Revenue/session declined **57.0%** ($1.152 → $0.495) in the trailing window vs the prior window.
Sessions were nearly flat (114,667 → 110,556, −3.6%), so the drop is a **monetisation** problem,
not a traffic problem: conversion rate fell **38.9%** (1.72% → 1.05%) and AOV fell **29.7%** ($66.98 → $47.11).

> **Data-quality caveat:** from Jan 26 most purchase events have NULL `purchase_revenue`
> (71% of purchases in the week of Jan 25 vs 2–11% in earlier weeks, Q4). Excluding Jan 26–31,
> the drop is still **−48.2%** RPS ($0.596), **−41.7%** CR and **−11.2%** AOV (Q4b). CR is unaffected
> by the gap, so the conversion collapse is real; part of the AOV fall is a tracking artefact.

## Decomposition
Total ΔRPS = −$0.657 per session, split into mix `(shareₜ − shareₚ) × rpsₚ` and rate `shareₜ × (rpsₜ − rpsₚ)` (Q2; sums exactly to ΔRPS).

| Dimension | #1 segment | Share of ΔRPS | of which rate / mix | Simple Δrevenue share |
|---|---|---|---|---|
| **New vs returning** | **Returning** | **77.4%** | 74.5% / 2.9% | 77.0% |
| Device | Desktop | 66.7% | 66.1% / 0.6% | 66.4% |
| Channel | Organic Search | 27.9% | 28.3% / −0.5% | 27.9% |

- **Mix effects are negligible in every dimension** (≤3% of ΔRPS): channel, device and user-type shares barely moved
  (e.g. returning 24.9% → 24.3% of sessions). The drop is a **rate** problem inside segments.
- By channel the drop is spread almost evenly (Organic 28%, Direct 26%, Other 24%, Referral 21%, Paid 2%), so
  **channel does not explain the drop**; every channel's RPS fell 44–62%.
- Device mirrors session share (desktop 58% of sessions → 67% of drop), so it is only mildly concentrated.
- With the Jan 26–31 gap removed, Returning still explains 80.7% of ΔRPS (73.2% rate) — the ranking is robust.

## Caveat: seasonality
We have only one year of data, so "seasonal" is an **assumption**: we treat the pre-Black-Friday
weeks (Nov 2–22) as the normal level (Q3). Baseline RPS was $1.139, almost the same as the prior
window ($1.152), so only **~2%** of the RPS drop is "returning to baseline"; the remaining **~98%** is
trailing falling *below* baseline (CR: 9% seasonal / 91% structural; AOV: 0% / 100%).
Read this with care: the weekly series (Q1) shows the weakest weeks are Dec 21–Jan 11, and returning-user
RPS in the week of Jan 18 ($2.48) was back inside its November range ($1.88–$2.57). So a large part of the
"structural" share may be an extended post-holiday lull plus the late-January tracking gap, not a lasting break.
Another year of data would be needed to separate the two properly.

## Top finding
**Observation:** The revenue/session drop is concentrated in **returning users**, and it is a **rate** effect, not mix.
**Evidence:** Returning users are ~25% of sessions in both windows but account for 77.4% of the ΔRPS (74.5 pts rate,
2.9 pts mix). Their RPS fell from $3.30 to $1.29 (−61%) because conversion rate dropped from 4.66% to 2.70%
(purchases 1,328 → 725) and AOV from $70.9 to $47.6 (Q2b). New users' RPS fell from $0.44 to $0.24 but they
contribute only 22.6% of ΔRPS.
**Implication:** The holiday window was carried by repeat buyers (December gift purchases). When they stop buying
in January, revenue/session collapses even though traffic and channel mix are stable. Acquisition spend or channel
re-allocation will not fix this; the lever is getting returning users to purchase again (retention / re-engagement)
— and fixing the revenue tracking gap from Jan 26 so we measure it correctly.

## Next steps for Day 4
Funnel-decompose **returning users** (view_item → add_to_cart → begin_checkout → purchase), prior vs trailing,
split by device (desktop first), to find the step where their conversion fell from 4.66% to 2.70%.
Exclude or flag Jan 26–31 for any revenue-based metric.
