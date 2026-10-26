-- Power BI data layer: one row per session.
-- Run in BigQuery (replaces sql/05_dashboard_views.sql for the Power BI track).
-- Materialised as a TABLE, not a VIEW, so Power BI refreshes don't re-scan the public dataset.
-- Sandbox note: tables in a Sandbox project auto-expire after 60 days.

CREATE OR REPLACE TABLE `ecom-da-project.ecom_marts.pbi_fact_sessions` AS
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
  SUM(IF(event_name = 'purchase', IFNULL(purchase_revenue, 0), 0)) AS revenue
FROM ev
WHERE ga_session_id IS NOT NULL
GROUP BY user_pseudo_id, ga_session_id;

-- Sanity check: total sessions and revenue should match your Day 2 baseline numbers.
-- SELECT COUNT(*) AS sessions, SUM(revenue) AS revenue
-- FROM `ecom-da-project.ecom_marts.pbi_fact_sessions`;
