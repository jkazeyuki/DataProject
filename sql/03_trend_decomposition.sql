-- =====================================================================
-- Day 3 — Trend Decomposition
-- Project : ecom-da-project (BigQuery Sandbox)
-- Source  : bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*
--           (2020-11-01 → 2021-01-31)
-- Windows : prior_4w    = 2020-12-07 → 2021-01-03 (holiday peak)
--           trailing_4w = 2021-01-04 → 2021-01-31 (post-holiday)
--           baseline_3w = 2020-11-02 → 2020-11-22 (pre-Black-Friday, Q3 only)
--
-- Q0 materialises a session-grain table once; Q1–Q3 read only that table,
-- so the public dataset is scanned a single time.
-- =====================================================================


-- ---------------------------------------------------------------------
-- Q0. Session-grain table (same logic as powerbi/pbi_fact_sessions.sql)
-- One row per user_pseudo_id + ga_session_id.
-- Sandbox note: tables auto-expire after 60 days — re-run Q0 if missing.
-- ---------------------------------------------------------------------
CREATE OR REPLACE TABLE `ecom-da-project.ecom_marts.sessions` AS
WITH ev AS (
  SELECT
    PARSE_DATE('%Y%m%d', event_date) AS event_date,
    event_name,
    user_pseudo_id,
    (SELECT value.int_value FROM UNNEST(event_params) WHERE key = 'ga_session_id') AS ga_session_id,
    (SELECT value.int_value FROM UNNEST(event_params) WHERE key = 'ga_session_number') AS ga_session_number,
    device.category AS device_category,
    geo.country AS country,
    traffic_source.source AS source,
    traffic_source.medium AS medium,
    ecommerce.purchase_revenue AS purchase_revenue
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  WHERE _TABLE_SUFFIX BETWEEN '20201101' AND '20210131'
)
SELECT
  CONCAT(user_pseudo_id, '-', CAST(ga_session_id AS STRING)) AS session_key,
  user_pseudo_id,
  MIN(event_date) AS session_date,
  ANY_VALUE(device_category) AS device_category,
  ANY_VALUE(country) AS country,
  ANY_VALUE(source) AS source,
  ANY_VALUE(medium) AS medium,
  CASE ANY_VALUE(medium)
    WHEN 'organic'  THEN 'Organic Search'
    WHEN 'cpc'      THEN 'Paid Search'
    WHEN 'referral' THEN 'Referral'
    WHEN '(none)'   THEN 'Direct'
    ELSE 'Other / Unknown'
  END AS channel_group,
  IF(MIN(ga_session_number) = 1, 'New', 'Returning') AS user_type,
  COUNTIF(event_name = 'page_view') AS pageviews,
  MAX(IF(event_name = 'view_item', 1, 0)) AS has_view_item,
  MAX(IF(event_name = 'add_to_cart', 1, 0)) AS has_add_to_cart,
  MAX(IF(event_name = 'begin_checkout', 1, 0)) AS has_begin_checkout,
  MAX(IF(event_name = 'purchase', 1, 0)) AS has_purchase,
  COUNTIF(event_name = 'purchase') AS purchases,
  SUM(IF(event_name = 'purchase', IFNULL(purchase_revenue, 0), 0)) AS revenue,
  -- extra vs pbi_fact_sessions: purchase events with NULL revenue (see Q4)
  COUNTIF(event_name = 'purchase' AND purchase_revenue IS NULL) AS purchases_missing_revenue
FROM ev
WHERE ga_session_id IS NOT NULL
GROUP BY user_pseudo_id, ga_session_id;


-- ---------------------------------------------------------------------
-- Q0b. Sanity check — window totals (compare with Day 2 baseline)
-- ---------------------------------------------------------------------
SELECT
  CASE
    WHEN session_date BETWEEN '2020-12-07' AND '2021-01-03' THEN '1_prior_4w'
    WHEN session_date BETWEEN '2021-01-04' AND '2021-01-31' THEN '2_trailing_4w'
    ELSE '0_other'
  END AS period,
  COUNT(*) AS sessions,
  SUM(purchases) AS purchases,
  ROUND(SUM(revenue), 2) AS revenue,
  ROUND(SAFE_DIVIDE(SUM(revenue), COUNT(*)), 4) AS rev_per_session,
  ROUND(SAFE_DIVIDE(SUM(purchases), COUNT(*)), 5) AS conversion_rate,
  ROUND(SAFE_DIVIDE(SUM(revenue), NULLIF(SUM(purchases), 0)), 2) AS aov
FROM `ecom-da-project.ecom_marts.sessions`
GROUP BY period
ORDER BY period;


-- ---------------------------------------------------------------------
-- Q1. Weekly trends by channel / device / user_type (§3.1–3.3)
-- Long format: one row per (dimension, segment, week).
-- Note: week of 2020-10-26 is partial (Nov 1 only) and is excluded.
-- ---------------------------------------------------------------------
WITH long AS (
  SELECT
    DATE_TRUNC(s.session_date, WEEK(MONDAY)) AS week,
    d.dimension,
    d.segment,
    s.purchases,
    s.revenue
  FROM `ecom-da-project.ecom_marts.sessions` AS s,
  UNNEST([
    STRUCT('channel' AS dimension, s.channel_group AS segment),
    STRUCT('device', s.device_category),
    STRUCT('user_type', s.user_type)
  ]) AS d
  WHERE s.session_date >= '2020-11-02'
),
weekly AS (
  SELECT
    dimension,
    segment,
    week,
    COUNT(*) AS sessions,
    SUM(purchases) AS purchases,
    SUM(revenue) AS revenue
  FROM long
  GROUP BY dimension, segment, week
)
SELECT
  dimension,
  segment,
  week,
  sessions,
  ROUND(revenue, 0) AS revenue,
  ROUND(SAFE_DIVIDE(revenue, sessions), 3) AS rev_per_session,
  ROUND(SAFE_DIVIDE(purchases, sessions), 4) AS conversion_rate,
  ROUND(SAFE_DIVIDE(revenue, NULLIF(purchases, 0)), 1) AS aov,
  ROUND(SAFE_DIVIDE(
    SAFE_DIVIDE(revenue, sessions)
      - LAG(SAFE_DIVIDE(revenue, sessions)) OVER w,
    LAG(SAFE_DIVIDE(revenue, sessions)) OVER w), 3) AS rps_wow_pct_change
FROM weekly
WINDOW w AS (PARTITION BY dimension, segment ORDER BY week)
ORDER BY dimension, segment, week;


-- ---------------------------------------------------------------------
-- Q2. Mix / rate decomposition of Δ revenue-per-session (§3.4)
--
-- Total RPS = Σ_s share_s × rps_s, so within each dimension:
--   ΔRPS = Σ_s [ (share_t − share_p) × rps_p ]   -- mix effect
--        + Σ_s [ share_t × (rps_t − rps_p) ]     -- rate effect
-- This identity is exact (no residual).
--
-- mix_effect_centered = (share_t − share_p) × (rps_p − RPS_p_total) gives
-- the same dimension total (Σ Δshare = 0) but is easier to read per
-- segment: shifting share toward a below-average segment is negative.
-- (It is shown for reading only; the % columns use the spec's mix_effect.)
--
-- rev_contrib_pct is the guide's simple contribution:
--   Δ revenue(segment) ÷ Δ revenue(total).
--
-- Sensitivity: set trailing_end = '2021-01-25' to drop the Jan 26–31
-- revenue-tracking gap (see Q4).
-- ---------------------------------------------------------------------
WITH params AS (
  SELECT DATE '2021-01-31' AS trailing_end
),
long AS (
  SELECT
    IF(s.session_date BETWEEN '2020-12-07' AND '2021-01-03', 'p', 't') AS win,
    d.dimension,
    d.segment,
    s.revenue
  FROM `ecom-da-project.ecom_marts.sessions` AS s,
  UNNEST([
    STRUCT('channel' AS dimension, s.channel_group AS segment),
    STRUCT('device', s.device_category),
    STRUCT('user_type', s.user_type)
  ]) AS d
  CROSS JOIN params
  WHERE s.session_date BETWEEN '2020-12-07' AND params.trailing_end
),
seg AS (
  SELECT
    dimension,
    segment,
    COUNTIF(win = 'p') AS sess_p,
    COUNTIF(win = 't') AS sess_t,
    SUM(IF(win = 'p', revenue, 0)) AS rev_p,
    SUM(IF(win = 't', revenue, 0)) AS rev_t
  FROM long
  GROUP BY dimension, segment
),
tot AS (
  SELECT
    dimension,
    SUM(sess_p) AS tsess_p,
    SUM(sess_t) AS tsess_t,
    SUM(rev_p) AS trev_p,
    SUM(rev_t) AS trev_t
  FROM seg
  GROUP BY dimension
),
calc AS (
  SELECT
    seg.*,
    sess_p / tsess_p AS share_p,
    sess_t / tsess_t AS share_t,
    SAFE_DIVIDE(rev_p, sess_p) AS rps_p,
    SAFE_DIVIDE(rev_t, sess_t) AS rps_t,
    trev_p / tsess_p AS total_rps_p,
    trev_t / tsess_t AS total_rps_t,
    trev_t - trev_p AS total_drev
  FROM seg JOIN tot USING (dimension)
),
eff AS (
  SELECT
    *,
    (share_t - share_p) * rps_p AS mix_effect,
    (share_t - share_p) * (rps_p - total_rps_p) AS mix_effect_centered,
    share_t * (rps_t - rps_p) AS rate_effect,
    total_rps_t - total_rps_p AS total_drps
  FROM calc
)
SELECT
  dimension,
  segment,
  sess_p,
  sess_t,
  ROUND(share_p, 4) AS share_p,
  ROUND(share_t, 4) AS share_t,
  ROUND(rps_p, 3) AS rps_p,
  ROUND(rps_t, 3) AS rps_t,
  ROUND(mix_effect, 4) AS mix_effect,
  ROUND(mix_effect_centered, 4) AS mix_effect_centered,
  ROUND(rate_effect, 4) AS rate_effect,
  ROUND(mix_effect + rate_effect, 4) AS total_effect,
  ROUND(total_drps, 4) AS total_drps,
  ROUND(SAFE_DIVIDE(mix_effect, total_drps), 3) AS mix_pct_of_drps,
  ROUND(SAFE_DIVIDE(rate_effect, total_drps), 3) AS rate_pct_of_drps,
  ROUND(SAFE_DIVIDE(mix_effect + rate_effect, total_drps), 3) AS seg_pct_of_drps,
  ROUND(rev_t - rev_p, 0) AS drev,
  ROUND(SAFE_DIVIDE(rev_t - rev_p, total_drev), 3) AS rev_contrib_pct
FROM eff
ORDER BY dimension, rate_effect;

-- Check: per dimension, Σ(mix + rate) must equal total_drps exactly.
--   SELECT dimension, SUM(total_effect), ANY_VALUE(total_drps) FROM (<Q2>) GROUP BY 1;


-- ---------------------------------------------------------------------
-- Q2b. Drill-down on the #1 driver: user_type rate = CR × AOV by window
-- ---------------------------------------------------------------------
SELECT
  user_type,
  IF(session_date <= '2021-01-03', '1_prior_4w', '2_trailing_4w') AS period,
  COUNT(*) AS sessions,
  SUM(purchases) AS purchases,
  ROUND(SAFE_DIVIDE(SUM(revenue), COUNT(*)), 3) AS rev_per_session,
  ROUND(SAFE_DIVIDE(SUM(purchases), COUNT(*)), 4) AS conversion_rate,
  ROUND(SAFE_DIVIDE(SUM(revenue), NULLIF(SUM(purchases), 0)), 1) AS aov
FROM `ecom-da-project.ecom_marts.sessions`
WHERE session_date BETWEEN '2020-12-07' AND '2021-01-31'
GROUP BY user_type, period
ORDER BY user_type, period;


-- ---------------------------------------------------------------------
-- Q3. Seasonal vs structural split
-- Assumption (one year of data only): the pre-Black-Friday 3 weeks are
-- the "normal" level. Seasonal part of the drop = prior → baseline;
-- structural part = how far trailing falls below baseline (0 if not).
-- Defined so seasonal + structural = prior − trailing:
--   seasonal   = max(prior − max(trailing, baseline), 0)
--   structural = (prior − trailing) − seasonal
-- ---------------------------------------------------------------------
WITH per AS (
  SELECT
    CASE
      WHEN session_date BETWEEN '2020-11-02' AND '2020-11-22' THEN 'baseline'
      WHEN session_date BETWEEN '2020-12-07' AND '2021-01-03' THEN 'prior'
      WHEN session_date BETWEEN '2021-01-04' AND '2021-01-31' THEN 'trailing'
    END AS period,
    COUNT(*) AS sessions,
    SUM(purchases) AS purchases,
    SUM(revenue) AS revenue
  FROM `ecom-da-project.ecom_marts.sessions`
  GROUP BY period
  HAVING period IS NOT NULL
),
m AS (
  SELECT 'rev_per_session' AS metric, period, SAFE_DIVIDE(revenue, sessions) AS v FROM per
  UNION ALL
  SELECT 'conversion_rate', period, SAFE_DIVIDE(purchases, sessions) FROM per
  UNION ALL
  SELECT 'aov', period, SAFE_DIVIDE(revenue, NULLIF(purchases, 0)) FROM per
),
p AS (
  SELECT
    metric,
    MAX(IF(period = 'baseline', v, NULL)) AS baseline,
    MAX(IF(period = 'prior', v, NULL)) AS prior,
    MAX(IF(period = 'trailing', v, NULL)) AS trailing
  FROM m
  GROUP BY metric
)
SELECT
  metric,
  ROUND(baseline, 5) AS baseline,
  ROUND(prior, 5) AS prior,
  ROUND(trailing, 5) AS trailing,
  ROUND(trailing - prior, 5) AS total_change,
  ROUND(seasonal, 5) AS seasonal_drop,
  ROUND((prior - trailing) - seasonal, 5) AS structural_drop,
  ROUND(SAFE_DIVIDE(seasonal, prior - trailing), 3) AS seasonal_share,
  ROUND(SAFE_DIVIDE((prior - trailing) - seasonal, prior - trailing), 3) AS structural_share
FROM (
  SELECT *, GREATEST(prior - GREATEST(trailing, baseline), 0) AS seasonal
  FROM p
)
ORDER BY metric;


-- ---------------------------------------------------------------------
-- Q4. Data-quality check: purchase revenue completeness by week
-- From 2021-01-26 most purchase events carry NULL purchase_revenue, so
-- revenue (and AOV, RPS) in the last week is understated. Conversion
-- rate is unaffected because it counts purchase events, not revenue.
-- ---------------------------------------------------------------------
SELECT
  DATE_TRUNC(session_date, WEEK(MONDAY)) AS week,
  SUM(purchases) AS purchases,
  SUM(purchases_missing_revenue) AS purchases_missing_revenue,
  ROUND(SAFE_DIVIDE(SUM(purchases_missing_revenue), SUM(purchases)), 3) AS pct_missing_revenue,
  ROUND(SAFE_DIVIDE(SUM(revenue), SUM(purchases) - SUM(purchases_missing_revenue)), 1) AS aov_known_revenue
FROM `ecom-da-project.ecom_marts.sessions`
WHERE session_date >= '2020-11-02'
GROUP BY week
ORDER BY week;


-- ---------------------------------------------------------------------
-- Q4b. Headline robustness: prior_4w vs trailing excluding Jan 26–31
-- ---------------------------------------------------------------------
SELECT
  IF(session_date <= '2021-01-03', '1_prior_4w', '2_trailing_jan04_25') AS period,
  COUNT(*) AS sessions,
  SUM(purchases) AS purchases,
  ROUND(SUM(revenue), 0) AS revenue,
  ROUND(SAFE_DIVIDE(SUM(revenue), COUNT(*)), 4) AS rev_per_session,
  ROUND(SAFE_DIVIDE(SUM(purchases), COUNT(*)), 5) AS conversion_rate,
  ROUND(SAFE_DIVIDE(SUM(revenue), NULLIF(SUM(purchases), 0)), 2) AS aov
FROM `ecom-da-project.ecom_marts.sessions`
WHERE session_date BETWEEN '2020-12-07' AND '2021-01-25'
GROUP BY period
ORDER BY period;
