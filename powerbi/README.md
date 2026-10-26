# Power BI Track — E-Commerce Revenue Diagnostic

**Decision:** don't start a new project. Keep the GA4 revenue-diagnostic project (Days 1–2 already done)
and build the dashboard (Days 6–7) in **Power BI Desktop instead of Looker Studio**.

Why this beats a fresh Kaggle-style Power BI project:

| | This project (Power BI track) | Typical "Superstore sales dashboard" |
|---|---|---|
| Data | Real GA4 event data, nested JSON, ~4M events | Clean, pre-flattened CSV |
| Skills shown | SQL (BigQuery) → data modelling → DAX → Python segmentation → exec deck | Drag-and-drop visuals |
| Story | Answers a business question: *why did revenue/session fall in January?* | "Here are some charts" |
| Interview value | Every chart traces back to a finding you can defend | Hiring managers have seen it 1,000 times |

Power BI keywords this covers (match them to the job description): **Power Query, star schema,
relationships, DAX (CALCULATE, time intelligence, SWITCH), date table, KPI cards, funnel, drill-through,
slicers/sync slicers, bookmarks, conditional formatting, RLS (stretch).**

---

## Files

| File | What it is |
|---|---|
| [`pbi_fact_sessions.sql`](pbi_fact_sessions.sql) | BigQuery table: one row per session — the fact table Power BI imports |
| [`measures.dax`](measures.dax) | Date table, funnel table, all DAX measures (KPIs, T4W vs P4W, funnel, segment share) |
| `ecom_revenue_diagnostic.pbix` | *(you create this)* The report file |
| `screenshots/` | *(you create this)* One PNG per report page — recruiters look at these, not the .pbix |

---

## Data model (star schema)

```
            'Date'                     user_segments  (Day 5 Colab output)
          [Date] 1                    [user_pseudo_id] 1
              │                              │
              * session_date                 * user_pseudo_id
         ┌────────────────────────────────────────┐
         │            fact_sessions               │
         │ session_key, device_category, country, │
         │ channel_group, user_type, has_* flags, │
         │ purchases, revenue                     │
         └────────────────────────────────────────┘

   'Funnel Steps'  (disconnected — used only by the funnel measure)
```

Single-direction filters, one fact table. Say "star schema" in the interview and be able to draw this.

---

## Day 6 (Power BI) — Data layer & model

Prereq: **Power BI Desktop** (free, Windows only — Microsoft Store). On a Mac, use a Windows VM or a
lab PC; the free web version cannot author models.

1. **BigQuery:** run [`pbi_fact_sessions.sql`](pbi_fact_sessions.sql). Confirm the row count and total
   revenue match your Day 2 baseline. Save the wireframe from guide §6.1 as `dashboard/wireframe.png`.
2. **Connect:** Power BI Desktop → *Get data* → **Google BigQuery** → sign in with the same Google
   account → `ecom-da-project` → `ecom_marts` → `pbi_fact_sessions` → **Transform data**.
   - Fallback if the connector won't authorise: in BigQuery, *Save results → Google Drive (CSV)*,
     download, then *Get data → Text/CSV*.
3. **Power Query:** rename the query to `fact_sessions`; set types (`session_date` = Date,
   `revenue` = Fixed decimal, `has_*` = Whole number); *Close & Apply*.
4. **Model:** create `Date` and `Funnel Steps` from [`measures.dax`](measures.dax); mark `Date` as the
   date table; create the relationships shown above (Model view). Create an empty `_Measures` table
   (*Enter data*) and add every measure there.
5. **Validate:** a card with `[Revenue per Session T4W]` and `[Revenue per Session P4W]` must match
   the numbers in your `metric_definitions.md` / `baseline_metrics.sql`. If not, fix before building visuals.

**Done when:** model view matches the diagram, measures return the same numbers as your SQL.

## Day 7 (Power BI) — Report build

Three pages, 16:9, one accent colour.

**Page 1 — Executive overview**
- Slicers: Date range, Device, Channel (*View → Sync slicers* so they apply to every page)
- 4 KPI cards: Revenue, Sessions, Conversion Rate, Revenue per Session — each with its Δ% vs prior 4
  weeks, coloured by `[KPI Δ Colour]`
- Line chart: `[Revenue per Session]` by `'Date'[Week Start]`, legend = `channel_group`
- Text box with the **one-sentence headline** from your Day 3 findings memo

**Page 2 — Funnel**
- Funnel visual: `'Funnel Steps'[Step]` × `[Funnel Sessions]` (sort by Step Order)
- Clustered bar: `[Conversion Rate]` by `device_category`, and by `user_type`
- Card or annotation pointing at the biggest drop-off (`[Step-to-Step Drop %]`) — this is the Day 4 finding

**Page 3 — Customer segments**
- Matrix: rows = `user_segments[segment]`; values = Users, Revenue, `[Revenue Share %]`, Conversion Rate, AOV
- **Drill-through** page "Segment detail" (drill-through field = segment) with the trend + funnel for one segment
- Tooltip page showing the mini-funnel when hovering a bar

**Polish:** consistent fonts, align to grid, titles as findings ("Mobile converts at half the desktop
rate") not labels ("CR by device"), data source footnote, a **bookmark** button to reset filters.

**Stretch (good interview talking points):** Row-level security role per `channel_group`
(*Modeling → Manage roles*); a field parameter to switch the trend chart between Revenue / Sessions / CR.

**Done when:** all pages render with slicers working; screenshots saved in `powerbi/screenshots/`;
`.pbix` committed (or linked if > 100 MB).

### Sharing it
*Publish to web* and the Power BI Service need a **work/school account** — a Gmail address can't sign in.
So for a portfolio: commit the `.pbix` + page screenshots, and embed the screenshots (or a 30-second GIF
of you clicking through) at the top of the repo README. That's what recruiters actually open.

---

## Resume bullets (fill in the brackets with YOUR numbers once you have them)

> **E-Commerce Revenue Diagnostic** — SQL (BigQuery), Python, Power BI
> - Analyzed [~4M] GA4 events / [X] sessions from the Google Merchandise Store in BigQuery (UNNEST of
>   nested event data) to explain a [X]% post-holiday drop in revenue per session.
> - Built a star-schema Power BI model with [N] DAX measures (time-intelligence trailing-4-week
>   comparisons, funnel and segment metrics) and a 3-page interactive dashboard with drill-through.
> - Identified [biggest funnel drop-off, e.g. "add-to-cart → checkout on mobile, [X]% abandonment"] and
>   [N] customer segments via RFM/K-means; [top segment] drove [X]% of revenue from [Y]% of users.
> - Proposed an A/B test (MDE [X]%, [N] sessions/arm) and presented recommendations in an executive deck.

Never put a number on the resume you can't reproduce from the repo.
