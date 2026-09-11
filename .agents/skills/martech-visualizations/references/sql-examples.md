# SQL examples

Seven focused examples. Each: source, output grain, required filters, status, expected columns. All select aggregate/non-PII output only. Literal synthetic dates/keys appear only inside synthetic VALUES. Examples for unknown formulas consume precomputed columns and label the derivation unknown.

Live execution record (2026-09-10, dev warehouse `Martech SQL Warehouse Dev`, Statement Execution API, aggregate-only, bounded): the attribution rollup (Ex.1), the channel spend rollup underlying Ex.4, the Payback core (Ex.5), the LTV per-FTD query (Ex.6), and the tier/fanout/grain checks were executed live; Ex.2 ran a channel-group variant and Ex.7's offset math is synthetic-only. Where a full example below reassembles CTEs that were not part of the executed statement, it is flagged in place — treat those as `Observed SQL` composition, not as individually live-validated queries.

## 1. Attribution first-touch rollup (fixed acquisition) from `agg_daily_metrics`

Source: Attribution Dashboard dataset `5b939214`. Status: `Observed SQL`, executed live.

```sql
SELECT macro_channel, SUM(signups) AS signups, SUM(ftd_count) AS ftd_count,
       SUM(ftd_amount) AS ftd_amount, SUM(ggr_amount) AS ggr_amount, SUM(ngr_amount) AS ngr_amount
FROM gold_martech.paid_media.agg_daily_metrics
WHERE date >= DATE '2026-08-01' AND date < DATE '2026-08-08'   -- always bound the range
GROUP BY macro_channel
ORDER BY macro_channel;
```

- Live result at the 2026-08-01..07 window: one row per `macro_channel` (row count is environment state, not a query contract); Paid media ≈ 9.9k signups. Add `acquisition_channel_group`/`acquisition_source` to reproduce the dashboard's `GROUP BY ALL` shape.
- This is fixed acquisition attribution; do not present it as last-touch.

## 2. Last-touch event counts and unique customers from `true_lta...30d_win`

Source: Attribution - Last Touch dataset `cb38b652` (base CTE). Status: `Observed SQL`; channel-group variant executed live.

```sql
SELECT channel_group,
       SUM(1) AS events,
       COUNT(DISTINCT customer_user_id) AS customers
FROM silver_martech.true_lta.true_lta_events_attributed_v2_30d_win
WHERE event_date >= DATE '2026-08-03' AND event_date < DATE '2026-08-06'
  AND event_name NOT IN ('kyc_completed', 'bet_placed')
GROUP BY channel_group
ORDER BY events DESC;
```

- Caveats preserved: GA4 `customer_user_id` may be NULL (distinct customer counts undercount GA4-only journeys); GA4 and AppsFlyer rows for the same real-world action remain separate (no cross-platform dedup); recent days capped at D-2; `event_value` NULL when unavailable. No spend columns in this query — do not join spend here (fanout; use `paid_media__campaign_view_by_day` with the ROW_NUMBER allocation as in the dashboard).
- Live result (3-day window): `direct` 237,640 events / 77,953 customers; `paid social` 158,024 / 40,009; etc.
- Event-source duplicates do not become two unique customers: `COUNT(DISTINCT customer_user_id)`.

## 3. FTD tier counts at one period_type/period_ref, with latest-signup/FTD enrichment

Source: FTD by Tier dataset `6571c853`. Status: `Observed SQL`; aggregate core executed live.

```sql
WITH lta_signup AS (
  SELECT customer_user_id AS customer_id, attr_source AS signup_attr_source,
         ROW_NUMBER() OVER (PARTITION BY customer_user_id ORDER BY event_timestamp DESC) AS rn
  FROM silver_martech.true_lta.true_lta_events_attributed_v2_30d_win
  WHERE event_name = 'sign_up' AND customer_user_id IS NOT NULL
)
SELECT f.period_type, f.period_ref,
       SUM(f.total_signups) AS total_signups,
       SUM(f.ftd_customers) AS ftd_customers,
       SUM(f.ftd_amount_total) AS ftd_amount_total,
       ls.signup_attr_source
FROM flutter_brazil_data_science.data_science_sandbox.ftd_by_tier_v2 f
LEFT JOIN lta_signup ls ON f.customer_id = ls.customer_id AND ls.rn = 1
WHERE f.period_type = 'Weekly' AND f.period_ref >= DATE '2026-07-06' AND f.period_ref < DATE '2026-07-13'
GROUP BY f.period_type, f.period_ref;
```

- Grain: one row per period×tier×source combination (aggregate before joining enrichment if you need counts). Live check at `Weekly/2026-07-06`: 50,094 signups, 40,823 FTD customers, R$ 1,625,049.77.
- Missing upstream semantics: tier thresholds, `tier_ref`/time policy, stage classifications, and `arpu` derivation are `Missing definition` — this example reproduces the dashboard join, it does not invent tier rules. Note the timestamp tie (no secondary ordering) and that attribution is not constrained to the historical `tier_ref`.

## 4. Shared Paid Media / Cockpit channel-period acquisition + spend join

Source: Paid Media datasets `15970278`/`paid_media_counters`; Cockpit `f60a6281`. Status: `Observed SQL`; channel spend rollup executed live. The customer_view CTE expression and the ratio aliases reproduce the dashboard SQL but the exact combined query below was authored after the live run — validate joins in your environment before relying on the ratios.

```sql
WITH customer_view AS (
  SELECT date, acquisition_source,
         COUNT(DISTINCT CASE WHEN DATE(customer_created_at) = date THEN customer_id END) AS sign_ups,
         COUNT(DISTINCT CASE WHEN ftd = 'yes' THEN customer_id END) AS ftds,
         SUM(CASE WHEN ftd = 'yes' THEN ftd_amount ELSE 0 END) AS ftd_deposits
  FROM gold_dimensional_model.aggs.customer_view_by_day
  WHERE skin_id = 1 AND flag_migrated_mrjack = 0
  GROUP BY date, acquisition_source
),
channel_view AS (
  SELECT date, channel, SUM(spend) AS spend, SUM(clicks) AS clicks
  FROM gold_martech.paid_media.paid_media__channel_view_by_day
  WHERE date >= DATE '2026-08-03' AND date < DATE '2026-08-05'
  GROUP BY date, channel
)
SELECT c.date, c.channel, c.spend, c.clicks,
       COALESCE(cv.sign_ups, 0) AS sign_ups,
       COALESCE(cv.ftds, 0) AS ftds,
       -- dataset-level ratio-of-sums (NOT the AVG-based counter widgets):
       try_divide(c.spend, COALESCE(cv.sign_ups, 0)) AS cost_per_signup,
       try_divide(c.spend, COALESCE(cv.ftds, 0))     AS cost_per_ftd
FROM channel_view c
LEFT JOIN customer_view cv
  ON TO_DATE(c.date) = TO_DATE(cv.date)
  AND LOWER(CASE WHEN LOWER(c.channel) = 'dv_360' THEN 'dv360'
                 WHEN LOWER(c.channel) = 'tiktok_ads' THEN 'tiktok'
                 ELSE c.channel END) = LOWER(cv.acquisition_source)
ORDER BY c.date, c.spend DESC;
```

- Preserves dashboard filters/mappings (`skin_id=1`, `flag_migrated_mrjack=0`, `dv_360→dv360`, `tiktok_ads→tiktok`, case-insensitive match). Separate `cost_per_signup` and `cost_per_ftd` aliases expose the Paid Media (spend/signups) vs Cockpit (spend/FTDs) CPA difference.
- Label: this is the **dataset-level** calculation. Counter widgets that `AVG(CPC)`/`AVG(CPA)` over daily×channel rows produce different numbers (mean-of-ratios). See test 1.
- Fanout note: same campaign name on two media channels would multiply campaign-level joins (campaign_cpa omits the channel key) — check `COUNT(DISTINCT channel) GROUP BY campaign_name` before campaign claims. Live check 2026-08-03..07: no campaign appeared on 2+ channels, but this is not guaranteed.

## 5. Payback single-channel single-snapshot predicted metrics + separately sourced M0 ratios

Source: Payback Dashboard - V1 datasets `0a80f426`/`6111a571`. Status: `Observed SQL` + `Documented` derivation; core executed live.

```sql
SELECT customer_created_date,          -- FTD cohort month (despite the name)
       acq_spend, gp_11,
       predicted_m2payback
FROM gold_martech.payback_v1_channels_ngr.ch_google_vrt_all_pred_metrics_for_all_curve_rolling_asof_2026_08
WHERE customer_created_date < DATE_FORMAT(DATE_TRUNC('MONTH', CURRENT_DATE()), 'yyyy-MM')  -- dashboard excludes current month; column is STRING 'YYYY-MM', compare as string
ORDER BY customer_created_date DESC
LIMIT 6;
```

- Bind exactly one model (`ngr` or `turnover`), one channel, one snapshot (`_asof_2026_08` for a September run). Live result: cohorts 2026-04..2026-08 with `predicted_m2payback` 14–25 months.
- M0 ratios are computed separately from `silver_martech.payback_v1_channels_core.cohort_*` on `(customer_created_date, acquisition_channel_group, acquisition_source)` (column `0` = M0): e.g. margin = `try_divide(total_ngr, total_bet)*100`, ARPU = `try_divide(total_ngr, total_ftd_count)`, ATPU = `try_divide(total_bet, total_ftd_count)`. Join model outputs to cohort data by cohort + mapped channel; never SUM `predicted_m2payback` across cohorts.
- Upstream derivation of `predicted_m2payback` is documented in the NGR V1 Pipeline page (tail model, defaults 6/100); treat the dashboard value as precomputed input of that pipeline.

## 6. LTV one-model one-channel one-snapshot per-FTD 12/24/60M and NPV

Source: LTV Dashboard - V1 dataset `3ff26137`. Status: `Observed SQL`; executed live.

```sql
SELECT r.cohort, r.M0_FTDs,
       g.`11` / r.M0_FTDs                       AS ltv_12m,
       g.`23` / r.M0_FTDs                       AS ltv_24m,
       l.ltv_60m_gross / r.M0_FTDs              AS ltv_60m_nominal,
       l.ltv_60m_npv   / r.M0_FTDs              AS ltv_60m_npv_per_ftd
FROM silver_martech.ltv_v1_channels_core.cohort_retention_ch_google_as_of_2026_08 r
JOIN silver_martech.ltv_v1_channels_ngr.ch_google_gp_24m_for_all_curve_rolling_asof_2026_08 g
  ON r.cohort = g.customer_created_date
JOIN silver_martech.ltv_v1_channels_ngr.ch_google_gp_ltv_60m_npv_asof_2026_08 l
  ON r.cohort = l.cohort
WHERE r.cohort = '2026-02';
```

- Raw source formulas (unguarded `/`) preserved as in the dashboard definition. **Proposed safety variant** — NOT existing behavior; returns NULL instead of erroring:

```sql
-- Proposed safety guard: NOT existing dashboard behavior; returns NULL on zero FTDs
try_divide(g.`11`, NULLIF(r.M0_FTDs, 0))
```

- Live result (cohort 2026-02, Google, snapshot 2026_08): M0_FTDs=36,142 → ltv_12m=278.11, ltv_24m=559.61, 60M nominal=1,361.72, NPV=1,241.07. Source `ltv_60m_npv` is a cohort NPV; dividing by `M0_FTDs` gives per-FTD, not per-user NPV. NGR and Turnover stay separate (`model_type`). Discount-rate conflict (15% suggested vs 4% default) is reported, not resolved here.

## 7. Copa weekly cohort (live execution blocked by missing QR dependency)

Source: Copa dataset `cohort_weekly`. Status: `Observed SQL`; **live execution blocked** — `flutter_brazil_data_dev.qrcodecaze.qr_ftd_customers` not found (schema absent from metadata; live `TABLE_OR_VIEW_NOT_FOUND`). Do not replace the QR table with an empty result in a supposedly equivalent live query.

```sql
-- As-authored dashboard logic (simplified), with the explicit QR dependency:
WITH base AS (
  SELECT cvbd.date, cvbd.customer_id, cvbd.ftd,
         COALESCE(cvbd.ngr_amount, 0) AS ngr_amount,
         CASE WHEN qr.customer_id IS NOT NULL THEN 1 ELSE 0 END AS ftd_qr_code
  FROM gold_dimensional_model.aggs.customer_view_by_day cvbd
  LEFT JOIN (SELECT DISTINCT customer_id
             FROM flutter_brazil_data_dev.qrcodecaze.qr_ftd_customers) qr
    ON cvbd.customer_id = qr.customer_id
  WHERE cvbd.date >= DATE '2026-05-01'
    AND cvbd._partition_date >= DATE '2026-05-01'
    AND cvbd.skin_id = 1
),
ftd_dates AS (
  SELECT customer_id, date AS ftd_date, ftd_qr_code,
         DATE_TRUNC('week', date) AS cohort_period,
         CASE WHEN ftd_qr_code = 1 THEN 'QR Code'
              WHEN date >= DATE '2026-06-11' THEN 'Copa'
              ELSE 'Pré-Copa' END AS segmento
  FROM base WHERE ftd = 'yes'
),
activity AS (
  SELECT fd.cohort_period, fd.segmento,
         CAST(FLOOR(DATEDIFF(b.date, fd.ftd_date) / 7) AS INT) AS period_offset,
         b.customer_id, b.ngr_amount
  FROM base b INNER JOIN ftd_dates fd ON b.customer_id = fd.customer_id
  WHERE b.date >= fd.ftd_date
    AND CAST(FLOOR(DATEDIFF(b.date, fd.ftd_date) / 7) AS INT) <= 8
)
SELECT a.cohort_period, a.period_offset, a.segmento, cs.cohort_size,
       COUNT(DISTINCT a.customer_id) AS active_customers,
       ROUND(COUNT(DISTINCT a.customer_id) * 100.0 / cs.cohort_size, 1) AS retention_pct,
       ROUND(COALESCE(SUM(a.ngr_amount), 0) / cs.cohort_size, 2) AS ngr_per_customer
FROM activity a
JOIN (SELECT cohort_period, segmento, COUNT(DISTINCT customer_id) AS cohort_size
      FROM activity WHERE period_offset = 0
      GROUP BY cohort_period, segmento) cs
  ON a.cohort_period = cs.cohort_period AND a.segmento = cs.segmento
GROUP BY a.cohort_period, a.period_offset, a.segmento, cs.cohort_size
ORDER BY a.cohort_period, a.period_offset;
```

Synthetic CTE variant proving rolling offsets + fixed denominator (no real rows, no QR dependency):

```sql
-- SYNTHETIC proof only: not a live equivalent of the Copa dataset
WITH act AS (
  SELECT * FROM VALUES
    ('2026-06-08', 1, '2026-06-08', 0, 100.0),   -- FTD day (offset 0)
    ('2026-06-15', 1, '2026-06-08', 1,  50.0),   -- FTD+7  -> weekly offset 1
    ('2026-07-08', 1, '2026-06-08', 30,  50.0)   -- FTD+30 -> monthly offset 1
  AS t(date, customer_id, ftd_date, days_since_ftd, ngr)
),
cohort_sizes AS (
  SELECT COUNT(DISTINCT customer_id) AS cohort_size FROM act WHERE days_since_ftd = 0
)
SELECT CAST(FLOOR(days_since_ftd / 7) AS INT) AS weekly_offset,
       CAST(FLOOR(days_since_ftd / 30) AS INT) AS monthly_offset,
       COUNT(DISTINCT customer_id) AS active_customers,
       c.cohort_size,
       ROUND(COUNT(DISTINCT customer_id) * 100.0 / c.cohort_size, 1) AS retention_pct,
       ROUND(SUM(ngr) / c.cohort_size, 2) AS ngr_per_customer
FROM act, cohort_sizes c
GROUP BY 1, 2, c.cohort_size
ORDER BY 1;
-- Expected: offset (0,0): size 1, 100%; (1,0) weekly 1; (4,1) weekly 4 / monthly 1; monthly offset only 0..3.
```

- Missing QR table must not be replaced with an empty result in live queries; report the dependency as unavailable.