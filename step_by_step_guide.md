# Step-by-Step Walkthrough — E-Commerce DA Project


[[project]]
**Audience:** the analyst executing the project in `project.md`.
**How to use this file:** Read `project.md` first to understand *what* you are producing each day and *why*. This file tells you exactly *how* — every click, every query, every common mistake.

> If anything in this guide ever conflicts with `project.md`, the brief wins. This is the runbook.

---

## Progress tracker

**Project window:** 2 weeks · May 28 – Jun 11, 2026 (Day 0 setup + 10 working days)  
**Last updated:** Jun 5, 2026

### Velocity snapshot

| Metric                      | Value                                                           |
| --------------------------- | --------------------------------------------------------------- |
| Content days complete       | **2 / 10** (Days 1–2)                                           |
| Setup (Day 0)               | Done                                                            |
| Working days elapsed        | 6 (Thu May 28 → Thu Jun 4)                                      |
| Pace                        | ~0.33 project days / working day (target: **1.0**)              |
| Working days left in window | 5 (Fri Jun 5 → Thu Jun 11)                                      |
| Project days remaining      | 8 (Days 3–10)                                                   |
| Status                      | **Behind** — need ~1.6 project days/day, or extend the deadline |

<progress value="2" max="10" title="2 of 10 content days complete"></progress>  
*20% of content days done (Day 0 not counted above).*

### Daily log

Update this row each evening. One line per calendar day — even if you only made partial progress.

| Date      | Day     | Project | Status      | Notes                                                         |
| --------- | ------- | ------- | ----------- | ------------------------------------------------------------- |
| May 28    | Thu     | Day 0   | Done        | Setup complete — BQ sandbox, first query, repo, Colab, Looker |
| May 29    | Fri     | Day 1   | Started     | Began data onboarding                                         |
| May 30–31 | Sat–Sun | —       | —           | Weekend                                                       |
| Jun 1     | Mon     | Day 1   | Blocked     | Stuck on **1.2** — learning how to run queries in BigQuery UI |
| Jun 2     | Tue     | Day 1   | In progress | Completed **1.4** (UNNEST worked examples)                    |
| Jun 3     | Wed     | Day 1   | Done        | Finished Day 1 — `data_dictionary.md`, profiling SQL          |
| Jun 4     | Thu     | Day 2   | Done        | KPI tree, `metric_definitions.md`, `baseline_metrics.sql`     |
| Jun 5     | Fri     | Day 3   | —           | *Today*                                                       |
|           |         |         |             |                                                               |

### Deliverable checklist

Check off when the day's **Done when** criteria are met (see each day section below).

| Day | Key deliverable | Status |
|-----|-----------------|--------|
| 0 | BQ + repo + Colab + Looker working | Done |
| 1 | `docs/data_dictionary.md` + `sql/01_data_profiling.sql` | Done |
| 2 | `docs/metric_definitions.md` + `sql/02_baseline_metrics.sql` | Done |
| 3 | `docs/findings_memo.md` + `sql/03_trend_decomposition.sql` | — |
| 4 | `sql/04_funnel_analysis.sql` + funnel chart | — |
| 5 | `python/segmentation.ipynb` | — |
| 6 | `dashboard/wireframe.png` + Power BI data model ([Power BI track](powerbi/README.md)) | — |
| 7 | Power BI dashboard (`.pbix`) + screenshots | — |
| 8 | `docs/experiment_brief.md` | — |
| 9 | `presentation/final_deck.pdf` | — |
| 10 | Mock presentation + final repo package | — |

### How to keep this honest on GitHub Pages

**Live dashboard:** [webswift-engineering.github.io/DataProject](https://webswift-engineering.github.io/DataProject/)

1. **Update `docs/progress.json` each evening** — the dashboard reads this file. Keep the tables above in sync (or treat JSON as source of truth and copy numbers here weekly).
2. **Push to `main`.** GitHub Pages redeploys in ~1 minute.
3. **Pair with daily commits** — messages like `Day 3: trend decomposition memo` give you a free [commit activity chart](https://github.com/webswift-engineering/DataProject/graph/commit-activity).

**Rule of thumb for a 2-week sprint:** if pace drops below 1 project day per working day for more than two days in a row, message your project lead with the blocker — same as ground rule #2 in `project.md`.

---

## Conventions used in this guide

- **`Click → ...`** means a literal UI action. Follow it exactly.
- **Code blocks** are copy-paste-ready. SQL runs in BigQuery; Python runs in Google Colab.
- **"Done when:"** at the end of each step is your self-check.
- **Common mistakes** are real ones I have watched juniors make. Read them before you start the step, not after.

---

## Day 0 — Setup (do this BEFORE Day 1)

Goal: by the end of Day 0 you can run a query against the GA4 sample dataset, push code to your repo, and open Looker Studio. About **2–3 hours** total.

### 0.1 Get a Google account (5 min)

If you already have a personal Gmail, you can use it. If not, create one at https://accounts.google.com/signup. **Do not use a school/work account that's locked down by an admin** — it will block BigQuery Sandbox.

### 0.2 Create a Google Cloud project (10 min)

1. Open https://console.cloud.google.com in a browser. Sign in with the account from 0.1.
2. Accept the terms of service. Pick your country.
3. At the top of the page, `Click → "Select a project" → "NEW PROJECT"`.
4. Project name: `ecom-da-project` (or anything memorable). Click **Create**.
5. Wait ~30 seconds. The project is now selected at the top of the page.

**Common mistake:** If Google asks for a credit card, you accidentally tried to enable billing. Close that dialog — you do not need billing for this project.

### 0.3 Enable BigQuery Sandbox (5 min)

Check the well known free dataset
<img width="2447" height="1292" alt="image" src="https://github.com/user-attachments/assets/72b54d3f-2cfd-4f93-a0e4-691af1eb9f58" />



1. In the left nav, `Click → BigQuery`. (If you don't see it, type "BigQuery" in the top search bar and click the result.)
2. The first time you open it, BigQuery activates the Sandbox automatically. You'll see a yellow banner at the top that says "Sandbox" — that's good.
3. **You are now free to query up to 1 TB/month at no cost.**

**Done when:** You see the BigQuery Studio interface with a yellow "Sandbox" banner at the top.

### 0.4 Pin the public dataset (3 min)
Select the target dataset
https://console.cloud.google.com/bigquery?ws=!1m4!1m3!3m2!1sbigquery-public-data!2sga4_obfuscated_sample_ecommerce
<img width="2560" height="1305" alt="image" src="https://github.com/user-attachments/assets/f94f664c-da30-4902-abef-d085f8c05731" />
The dataset name `bigquery-public-data.ga4_obfuscated_sample_ecommerce` looks intimidating. It just means: *project = `bigquery-public-data`, dataset = `ga4_obfuscated_sample_ecommerce`*. Public datasets live in the shared `bigquery-public-data` project that Google maintains. To make it visible in your sidebar:


<img width="2560" height="1305" alt="image" src="https://github.com/user-attachments/assets/3cc7024c-230e-4646-8a15-7ddb0b797094" />

1. In the BigQuery Explorer pane (left side), `Click → "+ ADD" → "Star a project by name"`.
2. Type `bigquery-public-data` exactly. Click **STAR**.
3. Expand the new `bigquery-public-data` entry in the sidebar.
4. Scroll down (it's alphabetical, hundreds of datasets) until you find `ga4_obfuscated_sample_ecommerce`. Click it to expand.
5. You'll see ~92 tables: `events_20201101`, `events_20201102`, ..., `events_20210131`. **One table per day.**

### 0.5 Run your first query (5 min)

1. `Click → "+ COMPOSE NEW QUERY"` (top of page).
2. Paste this exactly:

```sql
SELECT
  COUNT(*) AS event_count,
  COUNT(DISTINCT user_pseudo_id) AS user_count,
  COUNT(DISTINCT event_date) AS day_count,
  MIN(event_date) AS first_day,
  MAX(event_date) AS last_day
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`;
```

3. Look at the top-right corner: it should say "This query will process **~3 GB** when run." That's well under your 1 TB/month limit.
4. `Click → RUN`.
5. After 5–15 seconds you should see ~4–5M events across ~270k users across 92 days.

**You are now officially querying real GA4 data.**

**Common mistakes:**
- *Forgetting backticks around the table name.* The table contains dots and a `*` wildcard — backticks are required.
- *Removing the `_*` wildcard.* Without it, BigQuery only queries one specific day.
- *Accidentally querying without the wildcard suffix.* Always use `events_*` unless you intentionally want a single day.

### 0.6 Set up your repo (15 min)

You will commit work daily. Pick **one** of these:

**Option A — GitHub (recommended for your portfolio):**
1. Go to https://github.com and create a free account if you don't have one.
2. Click **New repository** → name it `ecom-da-project` → Public → Add README → Create.
3. On your laptop, install Git from https://git-scm.com/downloads.
4. In a terminal: `git clone https://github.com/YOUR_USERNAME/ecom-da-project.git`
5. `cd ecom-da-project` and create the folder structure exactly as in `project.md` Section 5.

**Option B — Google Drive (faster, but no portfolio value):**
1. Create a folder `ecom-da-project` in your Drive.
2. Recreate the same subfolder structure inside it.

Confirm with your project lead which they prefer. **GitHub is strongly recommended** — this project is meant to be portfolio-ready.

### 0.7 Open Google Colab (3 min)

You will need this for Day 5 (segmentation) and Day 8 (sample-size calc).

1. Go to https://colab.research.google.com.
2. Sign in with the same Google account.
3. `Click → "New notebook"`. A blank Python notebook opens. Close it for now.

### 0.8 Open Looker Studio (3 min)

You will need this for Days 6 & 7.

1. Go to https://lookerstudio.google.com.
2. Sign in. Accept terms.
3. `Click → "Create" → "Report"` to verify it loads. Close without saving.

### 0.9 Sanity-check Day 0 is complete

- [x] You can run the query in 0.5 and see results.
- [x] You can `git push` an empty README to your repo (or save a file to your Drive folder).
- [x] You can open Colab and Looker Studio and see their main UIs.

If all three boxes are checked, you are ready for Day 1. **Message your project lead with a screenshot of the Day 0.5 query result** — that's your "I have access" confirmation.

---

## Day 1 — Data Onboarding & Schema Mastery

Goal: produce `data_dictionary.md` covering 17 fields, with at least 3 documented data-quality findings.

### 1.1 Read the schema docs while you have your coffee (15 min)

Skim — do not memorize — these two pages:
- GA4 BigQuery Export Schema: https://support.google.com/analytics/answer/7029846
- Sample dataset description (covers the obfuscation caveats): https://developers.google.com/analytics/bigquery/web-ecommerce-demo-dataset

You're scanning for: what's a top-level field vs. a nested field, what's `event_params`, what's `items`, and the date range (Nov 2020 – Jan 2021).

### 1.2 Get comfortable with the BigQuery UI (10 min)

In BigQuery, click on `events_20210131` (the last table). On the right pane you'll see three tabs:
- **SCHEMA** — shows every field. Notice the icons: `RECORD` = nested, `REPEATED` = an array. You need both UNNEST tricks below.
- **DETAILS** — shows row count and table size.
- **PREVIEW** — shows the first ~50 rows. **Use this constantly** to sanity-check what fields actually contain.

### 1.3 Date-range coverage and event mix (15 min)

Run these two queries one at a time. Save them in `sql/01_data_profiling.sql` in your repo.

```sql
-- Q1: row count, user count, date coverage
SELECT
  COUNT(*) AS rows,
  COUNT(DISTINCT user_pseudo_id) AS users,
  COUNT(DISTINCT event_date) AS days,
  MIN(event_date) AS first_day,
  MAX(event_date) AS last_day
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`;
```

```sql
-- Q2: event type distribution
SELECT
  event_name,
  COUNT(*) AS event_count,
  COUNT(DISTINCT user_pseudo_id) AS user_count,
  ROUND(COUNT(*) / SUM(COUNT(*)) OVER () * 100, 2) AS pct_of_events
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
GROUP BY event_name
ORDER BY event_count DESC;
```

Write down which event names you see and roughly what fraction each is. You should spot all the funnel events you'll need later: `session_start`, `view_item`, `add_to_cart`, `begin_checkout`, `purchase`.

### 1.4 Learn UNNEST with a worked example (30 min)

`event_params` is a **REPEATED RECORD** — basically an array of `(key, value)` pairs attached to each event. To pull a specific param out, you `UNNEST` and filter by key.

```sql
-- Get ga_session_id and page_location for the first 100 events
SELECT
  event_date,
  event_name,
  user_pseudo_id,
  (SELECT value.int_value FROM UNNEST(event_params) WHERE key = 'ga_session_id') AS session_id,
  (SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'page_location') AS page_url
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_20210131`
LIMIT 100;
```

Why the subquery pattern with `(SELECT ... FROM UNNEST(...) WHERE key = ...)`? It pulls out exactly one param per event, so the row count stays the same. The naive `FROM events, UNNEST(event_params)` will multiply your rows by the number of params per event — usually a bug.

Try it on `items` too:

```sql
-- Items unnested (one row per item per event)
SELECT
  event_date,
  event_name,
  user_pseudo_id,
  item.item_id,
  item.item_name,
  item.item_category,
  item.price,
  item.quantity
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_20210131`,
  UNNEST(items) AS item
WHERE event_name IN ('view_item', 'add_to_cart', 'purchase')
LIMIT 100;
```

**Common mistake:** Forgetting that `items` UNNEST multiplies rows. If you `SUM(item.price * item.quantity)` after unnesting, you're summing per-line-item — that's correct for revenue. But if you `COUNT(*)` you're now counting line-items, not events. Keep this in your head.

### 1.5 Null/completeness audit (20 min)

```sql
-- For each of your 17 fields, what fraction is NULL or empty?
SELECT
  COUNTIF(event_date IS NULL) / COUNT(*) AS pct_null_event_date,
  COUNTIF(user_pseudo_id IS NULL) / COUNT(*) AS pct_null_user,
  COUNTIF(device.category IS NULL OR device.category = '') / COUNT(*) AS pct_null_device,
  COUNTIF(geo.country IS NULL OR geo.country = '') / COUNT(*) AS pct_null_country,
  COUNTIF(traffic_source.source IS NULL OR traffic_source.source = '') / COUNT(*) AS pct_null_source,
  COUNTIF(traffic_source.medium IS NULL OR traffic_source.medium = '') / COUNT(*) AS pct_null_medium
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`;
```

You will find `traffic_source` and `geo` are mostly populated, but watch for `(direct) / (none)` and `(not set)` strings — those are GA4's "I don't know" placeholders, not real values.

### 1.6 Find your 3 data-quality oddities (30 min)

Try these. Each one will probably surface something:

```sql
-- A. Do purchase events have non-zero revenue?
SELECT
  COUNTIF(ecommerce.purchase_revenue IS NULL OR ecommerce.purchase_revenue = 0) AS zero_or_null_revenue,
  COUNTIF(ecommerce.purchase_revenue > 0) AS valid_revenue,
  COUNT(*) AS total_purchases
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
WHERE event_name = 'purchase';
```

```sql
-- B. Do users have session_start events? (Some won't.)
SELECT
  user_pseudo_id,
  COUNTIF(event_name = 'session_start') AS session_starts,
  COUNT(*) AS total_events
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
GROUP BY user_pseudo_id
HAVING session_starts = 0
LIMIT 10;
```

```sql
-- C. Does purchase_revenue ≈ SUM(items.price * items.quantity)?
WITH purchases AS (
  SELECT
    (SELECT value.int_value FROM UNNEST(event_params) WHERE key = 'ga_session_id') AS session_id,
    user_pseudo_id,
    event_timestamp,
    ecommerce.purchase_revenue AS reported_revenue,
    (SELECT SUM(item.price * item.quantity) FROM UNNEST(items) AS item) AS computed_revenue
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  WHERE event_name = 'purchase'
)
SELECT
  COUNTIF(ABS(reported_revenue - computed_revenue) > 0.01) AS mismatched,
  COUNT(*) AS total
FROM purchases;
```

Document at least 3 of these findings in your data dictionary. **This is a feature, not a bug** — real data is messy, and your future client will respect that you noticed.

### 1.7 Write `data_dictionary.md` (45 min)

Use this template, one row per field:

```markdown
| Field | Type | Description | Sample value | Quality notes |
|-------|------|-------------|--------------|---------------|
| event_date | STRING (YYYYMMDD) | Date the event was logged | "20210115" | 0% null. Stored as string, cast to DATE for arithmetic. |
| user_pseudo_id | STRING | Pseudonymous user ID, stable across sessions | "1234567.8901234" | 0% null. Use this, not user_id (mostly empty). |
| ... | | | | |
```

Cover all 17 fields named in `project.md` Day 1. At the bottom add a **"Data Quality" section** with the 3+ findings from 1.6.

### 1.8 Commit and confirm

```bash
git add sql/01_data_profiling.sql docs/data_dictionary.md
git commit -m "Day 1: data profiling and dictionary"
git push
```

**Done when:**
- [ ] `sql/01_data_profiling.sql` runs end-to-end without errors
- [ ] `docs/data_dictionary.md` has 17 fields documented
- [ ] You have ≥3 data-quality findings written down
- [ ] Standup-ready: you can answer "what does this dataset contain?" in 60 seconds

---

## Day 2 — Metric Framework

Goal: a one-page KPI tree + `metric_definitions.md` + `baseline_metrics.sql` that computes every metric for trailing-4-weeks vs prior-4-weeks.

### 2.1 Draw the KPI tree (45 min)

Open a blank sheet of paper or a Figma file. Draw it like this:

```
                          Total Revenue
                                |
              ┌─────────────────┴─────────────────┐
          Sessions                    Revenue per Session
              |                                |
   ┌──────────┴──────────┐          ┌──────────┴──────────┐
 Users                 Sessions      Conversion Rate         AOV
                       per User      (Purchasers/Sessions)   (Revenue/Purchase)
```

You will further decompose `Conversion Rate` by funnel step on Day 4. For now, this 7-node tree is your one-pager.

### 2.2 Build a session-level CTE you can reuse (30 min)

Almost every metric below is "per session." Build this CTE once, then reuse it:

```sql
-- sessions: one row per (user, session_id)
WITH sessions AS (
  SELECT
    user_pseudo_id,
    (SELECT value.int_value FROM UNNEST(event_params) WHERE key = 'ga_session_id') AS session_id,
    MIN(PARSE_DATE('%Y%m%d', event_date)) AS session_date,
    MAX(traffic_source.medium) AS medium,
    MAX(traffic_source.source) AS source,
    MAX(device.category) AS device_category,
    COUNTIF(event_name = 'view_item') AS views,
    COUNTIF(event_name = 'add_to_cart') AS adds,
    COUNTIF(event_name = 'begin_checkout') AS checkouts,
    COUNTIF(event_name = 'purchase') AS purchases,
    SUM(IF(event_name = 'purchase', ecommerce.purchase_revenue, 0)) AS revenue
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  GROUP BY user_pseudo_id, session_id
)
SELECT * FROM sessions LIMIT 10;
```

Run it and eyeball the result — does it look right?

### 2.3 Daily and weekly metrics (45 min)

```sql
-- Daily KPI table
WITH sessions AS (
  -- ... same CTE as above ...
)
SELECT
  session_date,
  COUNT(*) AS sessions,
  COUNT(DISTINCT user_pseudo_id) AS users,
  SUM(purchases) AS purchase_events,
  SUM(revenue) AS revenue,
  SAFE_DIVIDE(SUM(revenue), COUNT(*)) AS revenue_per_session,
  SAFE_DIVIDE(SUM(purchases), COUNT(*)) AS conversion_rate,
  SAFE_DIVIDE(SUM(revenue), NULLIF(SUM(purchases), 0)) AS aov
FROM sessions
GROUP BY session_date
ORDER BY session_date;
```

For weekly grain, replace `session_date` with `DATE_TRUNC(session_date, WEEK(MONDAY)) AS week_start`.

**Save both as `sql/02_baseline_metrics.sql`.**

### 2.4 The trailing-4 vs prior-4 comparison (30 min)

```sql
WITH sessions AS ( /* ... */ ),
windowed AS (
  SELECT
    CASE
      WHEN session_date BETWEEN '2021-01-04' AND '2021-01-31' THEN 'trailing_4w'
      WHEN session_date BETWEEN '2020-12-07' AND '2021-01-03' THEN 'prior_4w'
      ELSE NULL
    END AS window,
    *
  FROM sessions
)
SELECT
  window,
  COUNT(*) AS sessions,
  SUM(revenue) AS revenue,
  SAFE_DIVIDE(SUM(revenue), COUNT(*)) AS revenue_per_session,
  SAFE_DIVIDE(SUM(purchases), COUNT(*)) AS conversion_rate,
  SAFE_DIVIDE(SUM(revenue), NULLIF(SUM(purchases), 0)) AS aov
FROM windowed
WHERE window IS NOT NULL
GROUP BY window;
```

In your memo, compute `(trailing - prior) / prior` for each metric to get the % change.

**Common mistake:** Picking 4-week windows that straddle Christmas and New Year unevenly. The dates above split it cleanly: prior_4w = Dec 7 → Jan 3 (heavy holiday), trailing_4w = Jan 4 → Jan 31 (post-holiday). That's what you want for a post-holiday-drop story.

### 2.5 Write `metric_definitions.md` (30 min)

For each of the ~7 metrics in your KPI tree, document:

```markdown
### Revenue per Session
- **Formula:** SUM(ecommerce.purchase_revenue) / COUNT(DISTINCT session_id)
- **Granularity available:** daily, weekly, by channel, by device
- **Why it matters:** Top-line health metric. Decomposes into conversion_rate × AOV.
- **Limitations:** Sessions are derived from `ga_session_id` event_param — may double-count users who clear cookies.
- **Owner (in this project):** the analyst (you).
```

**Done when:**
- [ ] KPI tree drawn (image saved to repo)
- [ ] `sql/02_baseline_metrics.sql` produces both daily/weekly and the 4w-vs-4w comparison
- [ ] `docs/metric_definitions.md` covers every metric in your tree
- [ ] Committed and pushed

---

## Day 3 — Trend Decomposition

Goal: a 1-page memo identifying which dimension (channel, device, or new-vs-returning) explains the most of the post-holiday revenue/session drop, with numbers.

### 3.1 Trend revenue/session by channel (45 min)

```sql
WITH sessions AS ( /* same CTE as Day 2 */ ),
weekly AS (
  SELECT
    DATE_TRUNC(session_date, WEEK(MONDAY)) AS week,
    medium,
    COUNT(*) AS sessions,
    SUM(revenue) AS revenue
  FROM sessions
  GROUP BY week, medium
)
SELECT
  week,
  medium,
  sessions,
  revenue,
  SAFE_DIVIDE(revenue, sessions) AS rev_per_session,
  LAG(SAFE_DIVIDE(revenue, sessions)) OVER (PARTITION BY medium ORDER BY week) AS prev_rev_per_session,
  SAFE_DIVIDE(revenue, sessions) -
    LAG(SAFE_DIVIDE(revenue, sessions)) OVER (PARTITION BY medium ORDER BY week) AS wow_change
FROM weekly
ORDER BY medium, week;
```

You're looking for: which `medium` shows the biggest WoW collapse around Jan 4? Which is stable? Note that "(direct) / (none)" and "organic" usually behave very differently from "cpc" / paid.

### 3.2 Trend by device (20 min)

Repeat 3.1 but `GROUP BY week, device_category`. Compare desktop vs mobile vs tablet revenue/session trajectories.

### 3.3 Trend by new vs returning user (30 min)

```sql
WITH first_seen AS (
  SELECT
    user_pseudo_id,
    MIN(PARSE_DATE('%Y%m%d', event_date)) AS first_date
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  GROUP BY user_pseudo_id
),
sessions AS ( /* same CTE as Day 2 */ ),
labeled AS (
  SELECT
    s.*,
    IF(s.session_date = f.first_date, 'new', 'returning') AS user_type
  FROM sessions s
  JOIN first_seen f USING (user_pseudo_id)
)
SELECT
  DATE_TRUNC(session_date, WEEK(MONDAY)) AS week,
  user_type,
  COUNT(*) AS sessions,
  SUM(revenue) AS revenue,
  SAFE_DIVIDE(SUM(revenue), COUNT(*)) AS rev_per_session
FROM labeled
GROUP BY week, user_type
ORDER BY week, user_type;
```

### 3.4 Quantify "how much of the drop" (30 min)

For each dimension, compute the contribution to the total drop:

```
Δ Revenue (segment) = (trailing_4w sessions × trailing_4w rev/session) − (prior_4w sessions × prior_4w rev/session)
Contribution % = Δ Revenue (segment) ÷ Δ Revenue (total)
```

Run this in a spreadsheet or one final SQL query. The dimension that explains the **largest single share** is your headline.

### 3.5 Write `findings_memo.md` (45 min)

Strictly one page. Use this skeleton:

```markdown
# Trend Decomposition — Findings Memo
**Window:** Trailing 4w (Jan 4–31) vs Prior 4w (Dec 7–Jan 3)

## Headline
Revenue/session declined **X%** in the trailing window vs the prior window.

## Decomposition
- By **channel**: [most-impacted channel] explains [Y%] of the absolute drop
- By **device**: [most-impacted device] explains [Z%] of the drop
- By **new vs returning**: [user type] explains [W%] of the drop

## Caveat: seasonality
The prior window includes peak holiday demand. We estimate that ~[N]% of the
absolute drop is consistent with normal post-holiday seasonality (basis: AOV
returned to pre-Black-Friday levels by Jan 11). The remaining ~[100-N]% is
the structural component this memo focuses on.

## Top finding
[One paragraph: Observation → Evidence → Implication]

## Next steps for Day 4
We'll funnel-decompose the segment identified above to find the exact step
where users are dropping.
```

**Save the SQL as `sql/03_trend_decomposition.sql`.**

**Done when:**
- [ ] Three trend queries run, all three results look sane
- [ ] You can name the #1 dimension that explains the drop
- [ ] You separated seasonal vs structural components in the memo
- [ ] Memo fits on one page

---

## Day 4 — Funnel Analysis

Goal: a step-by-step funnel table with overall + by-device + by-channel cuts, and an annotated chart highlighting the single biggest drop-off.

### 4.1 Build the funnel CTE (45 min)

The clean way: one CTE per step, then `LEFT JOIN` them so each user appears once with the timestamps of every step they reached.

```sql
WITH all_users AS (
  SELECT DISTINCT user_pseudo_id
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
),
session_starts AS (
  SELECT user_pseudo_id, MIN(event_timestamp) AS ts
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  WHERE event_name = 'session_start'
  GROUP BY user_pseudo_id
),
view_items AS (
  SELECT user_pseudo_id, MIN(event_timestamp) AS ts
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  WHERE event_name = 'view_item'
  GROUP BY user_pseudo_id
),
add_to_carts AS (
  SELECT user_pseudo_id, MIN(event_timestamp) AS ts
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  WHERE event_name = 'add_to_cart'
  GROUP BY user_pseudo_id
),
begin_checkouts AS (
  SELECT user_pseudo_id, MIN(event_timestamp) AS ts
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  WHERE event_name = 'begin_checkout'
  GROUP BY user_pseudo_id
),
purchases AS (
  SELECT user_pseudo_id, MIN(event_timestamp) AS ts
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  WHERE event_name = 'purchase'
  GROUP BY user_pseudo_id
)
SELECT
  COUNT(DISTINCT a.user_pseudo_id) AS step_0_all_users,
  COUNT(DISTINCT s.user_pseudo_id) AS step_1_session_start,
  COUNT(DISTINCT v.user_pseudo_id) AS step_2_view_item,
  COUNT(DISTINCT c.user_pseudo_id) AS step_3_add_to_cart,
  COUNT(DISTINCT b.user_pseudo_id) AS step_4_begin_checkout,
  COUNT(DISTINCT p.user_pseudo_id) AS step_5_purchase
FROM all_users a
LEFT JOIN session_starts s USING (user_pseudo_id)
LEFT JOIN view_items v USING (user_pseudo_id)
LEFT JOIN add_to_carts c USING (user_pseudo_id)
LEFT JOIN begin_checkouts b USING (user_pseudo_id)
LEFT JOIN purchases p USING (user_pseudo_id);
```

This gives you the user counts at each step. Compute step-to-step rates in a spreadsheet:
`step_2 / step_1`, `step_3 / step_2`, `step_4 / step_3`, `step_5 / step_4`.

**Common mistake:** Not enforcing time order. The version above is loose (first-ever timestamp of each event, regardless of order) — it will overcount because some users add to cart from a saved-cart link without viewing the product page in this session. For Day 4 that's fine; if you want strict funnel, add `WHERE c.ts > v.ts` etc. between the joins.

### 4.2 Cut by device (30 min)

Add `device.category` to each CTE, group by it. Or simpler: pre-aggregate at the user-level then group.

```sql
WITH user_device AS (
  SELECT user_pseudo_id, ANY_VALUE(device.category) AS device_category
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  GROUP BY user_pseudo_id
)
-- then join the funnel CTEs from 4.1, group by device_category
```

### 4.3 Cut by channel (30 min)

Same pattern, but `traffic_source.medium` (not `session_traffic_source_last_click` — that's empty for this dataset).

### 4.4 Identify the single biggest drop-off (15 min)

Compute step-to-step retention rate for **mobile** and **desktop** separately. The biggest **gap between segments** at the same step is your insight. Example: "Mobile users drop 71% at begin_checkout → purchase, vs 54% on desktop. That single step explains $X of the structural decline."

### 4.5 Annotated chart (30 min)

Build the chart in Looker Studio (preview of Day 7) or Google Sheets:
- Horizontal bars, one per step, labeled with both count and % retained
- Two overlays: mobile vs desktop
- Annotate the biggest mobile-vs-desktop gap

**Save SQL as `sql/04_funnel_analysis.sql`. Save chart image to `docs/funnel_chart.png`.**

**Done when:**
- [ ] Funnel SQL runs and produces 5 step counts
- [ ] You have device + channel cuts
- [ ] You can name the single biggest drop-off and your hypothesis for it
- [ ] Chart saved

---

## Day 5 — Customer Segmentation

Goal: `segmentation.ipynb` with 3–5 named segments, each profiled with size, revenue share, defining behaviors, and a recommended action.

### 5.1 Set up Colab + connect to BigQuery (20 min)

1. Open https://colab.research.google.com → New notebook → name it `segmentation.ipynb`.
2. First cell:

```python
from google.colab import auth
auth.authenticate_user()
print("Auth complete.")
```

Run it. A browser popup asks you to grant access — accept with the same Google account you used for BigQuery.

3. Second cell — install and import:

```python
!pip install -q pandas-gbq scikit-learn matplotlib seaborn
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from sklearn.cluster import KMeans
from sklearn.preprocessing import StandardScaler
```

4. Third cell — set your project:

```python
PROJECT_ID = "ecom-da-project"  # the project you created in Day 0.2
```

### 5.2 Pull user-level aggregates from BigQuery (30 min)

```python
query = """
WITH events AS (
  SELECT
    user_pseudo_id,
    PARSE_DATE('%Y%m%d', event_date) AS event_date,
    event_name,
    device.category AS device,
    traffic_source.medium AS medium,
    ecommerce.purchase_revenue AS purchase_revenue,
    (SELECT value.int_value FROM UNNEST(event_params) WHERE key = 'ga_session_id') AS session_id
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
)
SELECT
  user_pseudo_id,
  COUNT(DISTINCT session_id) AS sessions,
  COUNT(*) AS total_events,
  COUNTIF(event_name = 'view_item') AS views,
  COUNTIF(event_name = 'add_to_cart') AS adds,
  COUNTIF(event_name = 'begin_checkout') AS checkouts,
  COUNTIF(event_name = 'purchase') AS purchases,
  COALESCE(SUM(purchase_revenue), 0) AS total_revenue,
  DATE_DIFF(DATE '2021-01-31', MAX(event_date), DAY) AS recency_days,
  ANY_VALUE(device) AS device,
  ANY_VALUE(medium) AS medium
FROM events
GROUP BY user_pseudo_id
"""

users = pd.read_gbq(query, project_id=PROJECT_ID, dialect='standard')
print(users.shape)
users.head()
```

You should get ~270k rows.

### 5.3 Bucketed RFM (45 min)

Standard RFM quintiles do not work in a 92-day window. Use the explicit buckets from `project.md` Day 5.

```python
def recency_bucket(d):
    if d <= 7:   return 5
    if d <= 21:  return 4
    if d <= 45:  return 3
    if d <= 75:  return 2
    return 1

def frequency_bucket(s):
    if s == 1: return 1
    if s == 2: return 2
    return 3

users['R'] = users['recency_days'].apply(recency_bucket)
users['F'] = users['sessions'].apply(frequency_bucket)

# Monetary: quintiles among purchasers only
purchasers = users[users['total_revenue'] > 0].copy()
purchasers['M'] = pd.qcut(purchasers['total_revenue'], 5, labels=[1,2,3,4,5])
users = users.merge(purchasers[['user_pseudo_id', 'M']], on='user_pseudo_id', how='left')
users['M'] = users['M'].fillna(0).astype(int)  # 0 = non-purchaser

users['rfm_score'] = users['R'].astype(str) + users['F'].astype(str) + users['M'].astype(str)
users[['R','F','M','rfm_score']].head()
```

### 5.4 Alternative: K-means clustering (45 min)

K-means is often cleaner on this dataset. Try it and compare.

```python
features = ['sessions', 'views', 'adds', 'checkouts', 'purchases', 'total_revenue']
X = users[features].fillna(0)
X_scaled = StandardScaler().fit_transform(X)

# Elbow plot to pick k
inertias = []
for k in range(2, 9):
    km = KMeans(n_clusters=k, random_state=42, n_init=10).fit(X_scaled)
    inertias.append(km.inertia_)
plt.plot(range(2,9), inertias, marker='o')
plt.xlabel('k'); plt.ylabel('inertia'); plt.title('Elbow plot')
plt.show()

# Pick k from elbow (usually 4 here)
K = 4
users['cluster'] = KMeans(n_clusters=K, random_state=42, n_init=10).fit_predict(X_scaled)
```

### 5.5 Profile and name your segments (45 min)

```python
profile = users.groupby('cluster').agg(
    size=('user_pseudo_id', 'count'),
    avg_sessions=('sessions', 'mean'),
    avg_purchases=('purchases', 'mean'),
    avg_revenue=('total_revenue', 'mean'),
    total_revenue=('total_revenue', 'sum'),
).round(2)
profile['size_pct'] = (profile['size'] / profile['size'].sum() * 100).round(1)
profile['revenue_pct'] = (profile['total_revenue'] / profile['total_revenue'].sum() * 100).round(1)
profile
```

For each cluster, write a sentence: "Cluster N: X% of users, Y% of revenue, defining behavior is Z." Then **give each one a memorable name**. Ban "Cluster 0/1/2/3" from your final notebook.

Example (substitute real numbers from your output):
- **High-Value Loyalists** — 4% of users, 38% of revenue. Multiple purchases, high AOV.
- **Cart Abandoners** — 18% of users, 6% of revenue. Add to cart frequently, rarely purchase.
- **Browse-Only Window Shoppers** — 60% of users, <1% of revenue. View items, never engage further.
- **One-and-Done Buyers** — 18% of users, 55% of revenue. Single high-value purchase, never returned.

For each, write one specific action a marketing team could take.

**Done when:**
- [ ] Notebook runs end-to-end with `Restart and run all`
- [ ] 3–5 named segments with size %, revenue %, and a recommended action each
- [ ] Markdown cells between code cells explain *what* and *why*, not just *how*
- [ ] Committed to repo

---

## Day 6 — Dashboard Architecture & Data Layer

> **Power BI track:** follow [`powerbi/README.md`](powerbi/README.md) for Days 6–7 instead of the Looker Studio steps below. §6.1 (wireframe) still applies.

Goal: a wireframe sketch + 2–3 BigQuery views ready for Looker Studio.

### 6.1 Sketch the wireframe (45 min)

Hand-drawn on paper is fine. Or use Figma (free at https://figma.com — sign up, "New design file"). Layout:

```
┌─────────────────────────────────────────────────────────────────┐
│  Filters: [Date range] [Device] [Channel]                        │
├─────────────────────────────────────────────────────────────────┤
│  KPI 1     │  KPI 2     │  KPI 3     │  KPI 4                    │
│  Revenue   │  Sessions  │  CR%       │  AOV                      │
│  $X.XM     │  X.XM      │  X.X%      │  $XX                      │
│  ↑/↓ vs    │  ↑/↓ vs    │  ↑/↓ vs    │  ↑/↓ vs                   │
│  prior 4w  │  prior 4w  │  prior 4w  │  prior 4w                 │
├─────────────────────────────────────────────────────────────────┤
│  Revenue trend (line chart, weekly, channel overlay)             │
│                                                                  │
├─────────────────────────────────────────────────────────────────┤
│  Funnel chart                  │   Segment performance table     │
│  (5 horizontal bars)           │   (segment × revenue × CR)      │
└─────────────────────────────────────────────────────────────────┘
```

Save as `dashboard/wireframe.png`.

### 6.2 Create your own dataset for views (10 min)

You cannot create views inside `bigquery-public-data` — it's read-only. Create your own dataset:

1. In BigQuery Explorer, click your project (`ecom-da-project`) → three-dot menu → **Create dataset**.
2. Dataset ID: `ecom_marts`. Location: `US` (must match the public dataset's location). Click Create.

### 6.3 Build view 1 — daily KPIs (30 min)

```sql
CREATE OR REPLACE VIEW `ecom-da-project.ecom_marts.v_daily_kpis` AS
WITH sessions AS (
  SELECT
    user_pseudo_id,
    (SELECT value.int_value FROM UNNEST(event_params) WHERE key = 'ga_session_id') AS session_id,
    PARSE_DATE('%Y%m%d', event_date) AS session_date,
    MAX(traffic_source.medium) AS medium,
    MAX(device.category) AS device_category,
    COUNTIF(event_name = 'purchase') AS purchases,
    SUM(IF(event_name = 'purchase', ecommerce.purchase_revenue, 0)) AS revenue
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  GROUP BY user_pseudo_id, session_id, session_date
)
SELECT
  session_date,
  device_category,
  medium,
  COUNT(*) AS sessions,
  COUNT(DISTINCT user_pseudo_id) AS users,
  SUM(purchases) AS purchase_events,
  SUM(revenue) AS revenue,
  SAFE_DIVIDE(SUM(revenue), COUNT(*)) AS rev_per_session,
  SAFE_DIVIDE(SUM(purchases), COUNT(*)) AS conversion_rate,
  SAFE_DIVIDE(SUM(revenue), NULLIF(SUM(purchases), 0)) AS aov
FROM sessions
GROUP BY session_date, device_category, medium;
```

**Important — Sandbox warning:** This view will auto-expire in 60 days. If you need it permanent, click "Upgrade" in BigQuery to enable billing — the free tier (1 TB queries/month) keeps the project at $0.

### 6.4 Build view 2 — funnel by segment (30 min)

```sql
CREATE OR REPLACE VIEW `ecom-da-project.ecom_marts.v_funnel_by_segment` AS
WITH ev AS (
  SELECT
    user_pseudo_id,
    PARSE_DATE('%Y%m%d', event_date) AS event_date,
    event_name,
    device.category AS device_category,
    traffic_source.medium AS medium
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
)
SELECT
  device_category,
  medium,
  COUNT(DISTINCT user_pseudo_id) AS step_0_users,
  COUNT(DISTINCT IF(event_name = 'session_start', user_pseudo_id, NULL)) AS step_1_session_start,
  COUNT(DISTINCT IF(event_name = 'view_item', user_pseudo_id, NULL)) AS step_2_view_item,
  COUNT(DISTINCT IF(event_name = 'add_to_cart', user_pseudo_id, NULL)) AS step_3_add_to_cart,
  COUNT(DISTINCT IF(event_name = 'begin_checkout', user_pseudo_id, NULL)) AS step_4_begin_checkout,
  COUNT(DISTINCT IF(event_name = 'purchase', user_pseudo_id, NULL)) AS step_5_purchase
FROM ev
GROUP BY device_category, medium;
```

### 6.5 Connect Looker Studio to your view (15 min)

1. https://lookerstudio.google.com → **Create** → **Report**.
2. **Add data** → **BigQuery** (you may need to authorize).
3. Pick your project → `ecom_marts` → `v_daily_kpis` → **Add**.
4. A blank report opens with a default table. Drop in a quick line chart of `session_date` vs `revenue` to confirm data flows. **Done.**

**Save view SQL as `sql/05_dashboard_views.sql`.**

**Done when:**
- [ ] Wireframe image in `dashboard/wireframe.png`
- [ ] Both views created in your `ecom_marts` dataset
- [ ] Looker Studio shows real data from `v_daily_kpis`

---

## Day 7 — Dashboard Build

Goal: a polished, single-page Looker Studio dashboard at the URL you'll share with stakeholders.

### 7.1 Set up the page (15 min)

In your Looker Studio report:
- **File → Page setup**: Letter, Landscape.
- **Theme and layout** (right pane): pick a clean theme. "Simple" or "Constellation" works.
- Add three filter controls at the top: date range, drop-down for `device_category`, drop-down for `medium`.

### 7.2 Build the four KPI scorecards (30 min)

For each KPI (revenue, sessions, conversion rate, AOV):
1. **Insert → Scorecard**.
2. Data source: `v_daily_kpis`.
3. Metric: pick the field. For derived ones (rev/session, CR, AOV), use **Calculated field**: `Add a field → Custom formula`. Example for rev/session: `SUM(revenue) / SUM(sessions)`.
4. **Comparison date range**: "Previous period". This adds the ↑/↓ vs prior arrow automatically.
5. Format: large number, currency or percent as appropriate.

### 7.3 Revenue trend with channel overlay (20 min)

1. **Insert → Time series chart**.
2. Dimension: `session_date`.
3. Breakdown dimension: `medium`.
4. Metric: revenue (or rev/session).
5. Style → Series: pick a sequential palette (e.g. https://colorbrewer2.org → Sequential → 6-class Blues).

### 7.4 Funnel chart (20 min)

Looker Studio has no native funnel chart. Use a **horizontal bar chart**:
1. Connect a second data source: `v_funnel_by_segment`.
2. Bar chart: dimension = "step name", metric = "users".
3. To get one row per step, you'll need to unpivot in a calculated field, or build a small intermediate view that already has `(step, users)` rows.

Easier option: build a 6-row intermediate view:

```sql
CREATE OR REPLACE VIEW `ecom-da-project.ecom_marts.v_funnel_steps` AS
WITH base AS ( SELECT * FROM `ecom-da-project.ecom_marts.v_funnel_by_segment` )
SELECT 'step_1_session_start' AS step, 1 AS step_order, SUM(step_1_session_start) AS users, device_category, medium FROM base GROUP BY device_category, medium
UNION ALL
SELECT 'step_2_view_item', 2, SUM(step_2_view_item), device_category, medium FROM base GROUP BY device_category, medium
-- ... repeat for steps 3, 4, 5
;
```

Then point Looker Studio at `v_funnel_steps`.

### 7.5 Segment performance table (15 min)

If you used K-means in Day 5, export your labelled users to BigQuery and join. If that's too much for one day, just use a static segment from the funnel cuts (e.g. device × channel).

### 7.6 Polish (45 min)

- Apply consistent fonts (one family, one weight per role)
- Align all blocks on a 12-column grid (View → Show grid)
- Color rule: gray for "context" charts, accent color (one!) for "headline" numbers
- Add a title block: project name, your name, "Data: GA4 obfuscated sample, 2020-11-01 → 2021-01-31"

### 7.7 Share

**File → Share → "Anyone with the link can view" → Copy link.** Paste in `dashboard/looker_studio_link.md`.

**Done when:**
- [ ] All 4 scorecards + trend + funnel + segment-table render with real data
- [ ] Filters at the top filter all charts
- [ ] You can pass the "5-second test" with a colleague
- [ ] Public link saved to repo

---

## Day 8 — Experiment Design

Goal: a 1-page experiment brief tied to your strongest insight, with a defensible sample-size calculation.

### 8.1 Pick the insight (20 min)

Look at your Day 4 funnel. Pick the **single biggest device-vs-device or channel-vs-channel gap**. Example: "Mobile users drop from begin_checkout → purchase at 71%, vs 54% on desktop."

Translate it to a testable action: "Simplify the mobile checkout flow (remove guest-checkout friction) → expect mobile checkout completion to improve by 5–10% relative."

If you cannot translate your insight to a concrete UX or marketing action, pick a different one.

### 8.2 Pull the baseline number from Day 4 (10 min)

This is non-negotiable: do not invent a baseline. Re-run your Day 4 funnel SQL filtered to mobile and read the exact step-to-step rate.

```sql
-- example: mobile begin_checkout → purchase rate
SELECT
  COUNT(DISTINCT IF(event_name = 'begin_checkout', user_pseudo_id, NULL)) AS bc_users,
  COUNT(DISTINCT IF(event_name = 'purchase', user_pseudo_id, NULL)) AS p_users,
  SAFE_DIVIDE(
    COUNT(DISTINCT IF(event_name = 'purchase', user_pseudo_id, NULL)),
    COUNT(DISTINCT IF(event_name = 'begin_checkout', user_pseudo_id, NULL))
  ) AS bc_to_purchase_rate
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
WHERE device.category = 'mobile';
```

Write down the actual number. That is your baseline conversion rate.

### 8.3 Pick a defensible MDE (10 min)

Minimum Detectable Effect (relative): typical e-commerce experiments aim for **5–10% relative**. Smaller MDE = bigger sample needed = longer test.

Decide one. Justify in one sentence: "We targeted 8% relative MDE because anything smaller would not justify the engineering effort, per a quick conversation with the PM."

### 8.4 Compute sample size (20 min)

**Option A — Evan Miller's calculator** (https://www.evanmiller.org/ab-testing/sample-size.html):
1. Baseline conversion rate: enter your number from 8.2 (e.g. 38.2)
2. Minimum Detectable Effect: enter your relative MDE, mode = Relative (e.g. 8)
3. Statistical power: 80%
4. Significance: 5%
5. Read off "Sample size per variation" — that's how many users per arm.

**Option B — statsmodels in Colab:**

```python
from statsmodels.stats.power import NormalIndPower
from statsmodels.stats.proportion import proportion_effectsize

baseline = 0.382  # from 8.2
mde_rel = 0.08
treated = baseline * (1 + mde_rel)

es = proportion_effectsize(baseline, treated)
n = NormalIndPower().solve_power(effect_size=es, alpha=0.05, power=0.8, alternative='two-sided')
print(f"Sample per arm: {int(n)}")
```

### 8.5 Estimate duration (10 min)

```
duration_days = (sample_size_per_arm × 2) ÷ (eligible daily traffic from Day 1)
```

For mobile checkout: pull the average daily count of mobile `begin_checkout` users from your Day 1 profiling. Divide.

### 8.6 Write `experiment_brief.md` (45 min)

```markdown
# Experiment Brief: Simplify Mobile Checkout

**Owner:** [your name]   |   **Status:** Draft   |   **Date:** [today]

## Hypothesis
If we [remove guest-checkout friction on mobile], then [mobile checkout-to-purchase rate]
will improve by [8% relative], because [evidence: mobile drops 17pp more than desktop at this step].

## Metrics
- **Primary:** mobile checkout-to-purchase rate (binary, per user-session)
- **Secondary:** mobile AOV, overall mobile revenue
- **Guardrails:** desktop conversion rate (no harm), refund rate (no harm)

## Variants
- **Control:** current mobile checkout flow
- **Treatment:** [specific UX change]

## Statistics
- **Baseline:** 38.2% (from Day 4 funnel, mobile, full dataset window)
- **MDE:** 8% relative (justification: smallest improvement that justifies eng cost)
- **Power / Significance:** 80% / 5%, two-sided
- **Sample per arm:** N (computed in 8.4)
- **Eligible daily traffic:** ~M mobile checkout users/day (from Day 1)
- **Estimated duration:** D days

## Expected revenue impact
If successful at the MDE, annualized revenue uplift = **$X – $Y**
- Assumptions: traffic level holds, MDE achieved, no cannibalization
- Sensitivity: every 1pp shortfall in lift = ~$Z lost upside
- Reasons this could be wrong: [obfuscated data, holiday-skewed baseline, ...]
```

**Done when:**
- [ ] Brief fits on one page
- [ ] Baseline pulled from real Day 4 numbers (no invented numbers)
- [ ] Sample size and duration computed
- [ ] Range estimate for revenue impact, not a single number

---

## Day 9 — Executive Presentation

Goal: a 10-slide deck with insight-led headlines.

### 9.1 Open Google Slides (5 min)

https://slides.google.com → Blank → name it `Final_Deck_[your_name]`.

### 9.2 Use one rule for every slide title (the most important thing today)

Every title is a **complete sentence stating the insight**. Not a topic.

| Bad | Good |
|---|---|
| "Traffic Source Analysis" | "Paid Social grew 40% but converts at 1/7 the rate of organic" |
| "Funnel Performance" | "Mobile checkout abandonment is 17pp worse than desktop" |
| "Customer Segments" | "60% of users browse but never purchase — they're our biggest growth lever" |

If you cannot write the title as a sentence with a verb, **you don't have an insight yet** — go back and figure out what your data is telling you.

### 9.3 Slide-by-slide structure (90 min)

| # | Title (insight statement) | Body |
|---|---|---|
| 1 | Title slide — project name, your name, dates | Logo, dataset citation |
| 2 | "[3 insights in 3 bullets — the entire deck in 60 seconds]" | TL;DR |
| 3 | "Revenue/session declined X% post-holiday" | Trend chart from Day 2 |
| 4 | "[Top dimension] explains Y% of the structural decline" | Decomposition chart from Day 3 |
| 5 | "Mobile checkout drops at Zpp worse than desktop" | Funnel chart from Day 4 |
| 6 | "Three high-value segments capture W% of revenue" | Segment table from Day 5 |
| 7 | "[Specific segment] is the biggest growth opportunity because…" | Segment deep-dive |
| 8 | "We recommend testing [X] — expecting [Y%] lift" | Experiment brief one-pager |
| 9 | "If adopted, expected annual impact is $A–$B" | Range, assumptions, sensitivity, "reasons it could be wrong" |
| 10 | "Next steps + what we'd do with 2 more weeks" | Honest list of open questions |

### 9.4 Visual rules (30 min)

- One headline color (e.g. orange) used **only** for the number that proves the insight on each slide. Everything else gray.
- Charts: remove gridlines, axis chartjunk, legends if a label can replace them. Steal from https://hbr.org/2014/06/the-three-elements-of-successful-data-visualizations.
- Font: one family, two sizes max (title + body).
- Slide footer with page number and dataset citation.

### 9.5 Export and commit

File → Download → PDF. Save as `presentation/final_deck.pdf` in your repo.

**Done when:**
- [ ] 10 slides, no more
- [ ] Every title is a complete sentence stating an insight
- [ ] Slide 9 includes a range, assumptions, sensitivity, and "reasons it could be wrong"
- [ ] PDF in repo

---

## Day 10 — Mock Presentation & Final Polish

Goal: deliver a 15-minute presentation, handle Q&A, revise, submit.

### 10.1 Practice the deck out loud (60 min)

- **Time yourself.** Aim for 12 minutes of content + 3 of buffer = 15 total.
- Practice the **first 60 seconds** five times. That's where you set the frame.
- Practice the **transition between slides** — those are usually where juniors stumble ("uh, so, on this slide we have…"). Better: "That tells us *what* happened. Now let me show you *why*."

### 10.2 Pre-build answers to the four standard questions (60 min)

Write 1–2 paragraph answers to each, reference your charts:

1. **"How confident are you in this root cause?"**
   - Acknowledge limits explicitly: 92-day window, obfuscated data, dimension correlation ≠ causation. State your confidence level (e.g. "70% — here's what would push it to 90%").
2. **"What's the downside risk of your recommendation?"**
   - Name the failure mode: "If the mobile change confuses returning users, we could *lose* X% on the desktop guardrail. We'd catch this in the first week of the experiment."
3. **"What would you do with 2 more weeks?"**
   - Be specific: "Validate the holiday seasonality assumption with prior-year data, build a cohort retention view, run a regression of revenue/session on N covariates."
4. **"How did you handle data quality issues?"**
   - Reference the 3 oddities you found in Day 1's data dictionary. Show you noticed.

### 10.3 Mock presentation (15 min + Q&A)

Run it with your project lead. Ask them to challenge you with the four questions plus 2 unscripted ones.

### 10.4 Revise based on feedback (60–90 min)

The most common feedback: trim slide 4 or 5 (juniors usually over-explain the diagnosis), strengthen slide 9 (the impact number), tighten transitions.

### 10.5 Final package check

```
project/
├── README.md                   ← write this last; explain how to navigate
├── sql/
│   ├── 01_data_profiling.sql
│   ├── 02_baseline_metrics.sql
│   ├── 03_trend_decomposition.sql
│   ├── 04_funnel_analysis.sql
│   └── 05_dashboard_views.sql
├── python/
│   └── segmentation.ipynb
├── docs/
│   ├── data_dictionary.md
│   ├── metric_definitions.md
│   ├── findings_memo.md
│   └── experiment_brief.md
├── dashboard/
│   ├── wireframe.png
│   └── looker_studio_link.md
└── presentation/
    └── final_deck.pdf
```

### 10.6 Final commit

```bash
git add .
git commit -m "Day 10: final deliverable package"
git push
```

**Done when:**
- [ ] Mock presentation delivered, feedback received
- [ ] Deck revised
- [ ] Repo structure matches the brief exactly
- [ ] README.md written (explain how a reviewer should navigate the repo)
- [ ] Submitted to project lead

---

## Closing notes

A few rules of thumb for the whole project:

1. **Commit at the end of every day.** Even if you're not done — push WIP.
2. **Stuck for >2 hours?** Stop, write a 3-bullet message describing what you tried and what's blocking you, send it to your project lead. That's not weakness, that's professionalism.
3. **Quality > quantity.** 3 sharp insights beat 10 shallow ones — both for the project and for any interview that comes after.
4. **Write things down.** Every decision you make today (e.g. "I bucketed recency at 0–7, 8–21…") will be a question on Day 10. Future-you will thank past-you for the breadcrumbs.

Good luck.
