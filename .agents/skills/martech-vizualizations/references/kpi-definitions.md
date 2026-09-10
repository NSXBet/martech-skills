# KPI definitions by dashboard

Evidence labels per skill entry: `Documented`, `Observed SQL`, `Inferred`, `Missing definition`, `Conflicting sources`. Approval field is `Not established` everywhere unless a source records it. Datasets are referenced by the dashboard dataset hash names from the draft definitions fetched 2026-09-10.

Common conventions used below are in [business-conventions.md](business-conventions.md); table grains in [schema-and-joins.md](schema-and-joins.md). ROAS is excluded by scope.

---

## FTD by Tier - Attribution V2 (`01f1873b8f9a1f6fad3be199a6a9a9b8`)

Datasets: `6571c853` FTD by Tier (page-referenced), `5679a23e` FTD in World Cup (page-referenced), `d28e547c` FTD in World Cup by event (page-referenced), `6d1c368d` record-count QA, `d3ada300` freshness check (`max(period_ref)`), `campaign_cpa` (unused by pages).

- **total_signups** — business meaning: registrations in the period. Formula: precomputed column `total_signups` summed. Lineage: `ftd_by_tier_v2.total_signups` (no column comment). Aggregation: SUM per `period_type`,`period_ref` (widget `SUM(total_signups)`). Evidence: `Observed SQL` (column exists; derivation `Missing definition`).
- **ftd_customers** — distinct first-time depositors. Precomputed `ftd_customers`, SUM. Derivation `Missing definition` (no comments).
- **ftd_amount_total / avg_ftd_amount** — precomputed sum/avg of first-deposit amounts; derivation `Missing definition`. Live check: `Weekly` `period_ref=2026-07-06` → 40,823 FTD customers, R$ 1,625,049.77 (`Observed SQL`).
- **sports/iGaming/total GGR and NGR** — `sports_ggr_amount`, `sports_ngr_amount`, `igaming_*`, `total_*` summed. Derivation `Missing definition` upstream; GGR/NGR semantics per `customer_view_by_day` comments (GGR = stakes − winnings; NGR = GGR − restricted stakes).
- **ARPU (tier dataset `6571c853`)** — `SUM(total_ngr_amount) / SUM(ftd_customers)`, explicit zero when `SUM(ftd_customers)=0`. `Observed SQL` (named measure `ARPU`).
- **ARPU (World Cup datasets `5679a23e`/`d28e547c`)** — divides by `SUM(ftd_active_wc)` instead; zero for zero denominator. `d28e547c` also has `ARPU_` using `ftd_customers`. These differ from the tier dataset measure and from the unknown precomputed `arpu` column — keep separate records.
- **ftd_active_wc, retention, reactivation, delayed_wc** (World Cup tables) — surfaced counts; derivation `Missing definition`.
- **Filters/date window:** period types overlap (`Weekly`/`Monthly`); select one type before summing. Widget period filters select `period_ref`.
- **Attribution enrichment:** dashboard LEFT JOINs latest LTA `sign_up`/`first_time_deposit` rows (`ROW_NUMBER ... ORDER BY event_timestamp DESC`, no tie-breaker, no historical `tier_ref` predicate) — enrichment only, does not redefine tier periods.
- **campaign_cpa** (dataset `campaign_cpa`, 119 lines): joins FTD-by-campaign counts to spend by normalized campaign name + period, **omits channel** — same campaign name on two channels would multiply matches. `total_spend` COALESCEs to zero; `cpa` uses raw nullable spend (`ROUND(sp.total_spend / NULLIF(fc.ftd_customers,0),2)`). **Unused by any page** — supporting/query evidence only, not a visible KPI. There is a commented-out `roas_ngr` line (excluded by scope).
- Approval: `Not established`.

## Payback Dashboard - V1 (`01f13975d65a1872856e4f57df7a950c`)

Datasets: `0a80f426` Payback V1, `6111a571` Metrics (both page-referenced); `57825ed0` M1 retention (iGaming), `e5df4497`, `f8edceec` (supporting).

- **NGR/Turnover predicted months-to-payback** — `predicted_m2payback` from model tables, surfaced as `ngr_predicted_m2payback` / `trn_predicted_m2payback`. Documented derivation (`Documented`, NGR V1 Pipeline Notion page): if payback within 12 months use actual `m2payback`; else `remaining_gap = acq_spend − gp_11`, `monthly_tail_gp = gp_11 × (growth_factor/tail_scale)` (defaults 6/100 ⇒ 6% monthly continuation), `predicted_m2payback = 12 + CEIL(remaining_gap/monthly_tail_gp)`. Verify against the current pipeline run before treating numbers as current (`Missing definition` for run-parameter drift). Never SUM months-to-payback across cohorts.
- **M0 bets / NGR / estimated GP** — `sports_bet`/`gaming_bet`/`total_bet`, `*_ngr`, `*_estimated_gp` from `cohort_*` tables, column `0` = M0. `estimated_gp` derivation: `Missing definition` (pipeline doc link not followed through to formula).
- **FTD counts** — `sports_ftd_count` = `cohort_m0_sports_bettors_distinct`, `gaming_ftd_count` = `cohort_m0_igaming_bettors_distinct`, `total_ftd_count` = `cohort_ftd_count`. Vertical counts do not partition total.
- **CPA** — `CAST(try_divide(cost_data.acq_spend, aggregated_data.total_ftd_count) AS DECIMAL(18,1)) AS cpa`; dataset comment `CPA = Investment / FTD Count` (`Observed SQL` + `Documented` Payback doc).
- **NGR margin** — `try_divide(total_ngr, total_bet) * 100`, DECIMAL(18,1); vertical margins analog. `Documented`: Margin = NGR/Turnover.
- **ARPU M0** — `try_divide(ngr, ftd_count)` DECIMAL(18,1) per vertical (`Documented` ARPU = NGR/FTD). **ATPU M0** — `try_divide(turnover, ftd_count)` (`Documented` Turnover/FTD).
- **Spend** — `acq_spend` from `ch_<channel>_vrt_all_acquisition_spend_asof_<yyyy_MM>`; blank/NULL for `Uncategorized` channels (`Documented` Cost blank for Uncategorized).
- **Channel mapping:** literal CASE on `acquisition_channel_group`+`acquisition_source` → Google/Meta/TikTok/Affiliates/Referral (RAE)/Others/Uncategorized; UNION rollup rows `'Paid media (aggregated)'`, `'All channels'` overlap channel rows — never add together. `'Do not use'` internal rows excluded by final filter.
- **Date window:** `customer_created_date < DATE_TRUNC('MONTH', CURRENT_DATE())` — current month excluded (`Observed SQL`); widgets also filter year(s). Dynamic snapshot suffix = previous calendar month (`yyyy_MM`).
- **Formatting:** several Payback/LTV widgets render USD-format; format alone does not establish units (`Conflicting sources` with BRL wording elsewhere — see review register).
- Approval: `Not established`.

## Copa — Cohort Analysis - Attribution V2 (`01f1840eef8913878e0920450105ea51`)

Datasets: `cohort_weekly` Cohort Semanal and `export_base` (page-referenced); `cohort_daily`, `cohort_monthly`, `42a3a1c6`, `export_qa_check` present but not page-referenced in this snapshot.

- **cohort_size** — fixed denominator: distinct customers with a row at `period_offset=0` per `(cohort_period, segmento)` (`Observed SQL`).
- **active_customers** — `COUNT(DISTINCT customer_id)` of rows in the offset bucket. No explicit `active_user_by_flutter`/bet predicate — presence of any activity row counts (`Observed SQL`; definition gap in review register).
- **retention_pct** — `active_customers / cohort_size × 100`, ROUND 1.
- **NGR/GGR/deposits/turnover per customer** — `SUM(amount)/cohort_size`, ROUND 2; money NULL→0 via COALESCE.
- **segmento** — `QR Code` (QR member overrides everything), else `Copa` if FTD date ≥ 2026-06-11, else `Pré-Copa`. Base/partition cutoff `date >= 2026-05-01`, `skin_id=1`; QR segment overrides the Copa date cutoff.
- **Period bins are not all calendar periods:** daily offsets 0–30; weekly `FLOOR(days/7)` 0–8; monthly `FLOOR(days/30)` 0–3. Only weekly/export are page-referenced.
- **Missing rows are absent data, not proven zero retention.** No explicit maturity/D-2 upper cap in the cohort query; the QA dataset (`export_qa_check`) applies a D-2 cap and differs.
- **Export attribution columns** (signup/FTD attr source/medium/campaign) are latest-event LTA lookups per customer — not a cohort-heatmap attribution filter.
- **QR dependency** `flutter_brazil_data_dev.qrcodecaze.qr_ftd_customers` unavailable (schema not found; live `TABLE_OR_VIEW_NOT_FOUND`) — execution blocked, not replaced.
- Approval: `Not established`.

## LTV Dashboard - V1 (`01f12372f1bf1d93a4611fe7f2e35312`)

Datasets: `6a495532`, `25493e50`, `3ff26137`, `ret_comparison`, `insights_q1q2` (page-referenced); `ret_threshold` filter-only (not a displayed KPI widget).

- **LTV 12M** — cumulative GP column `11` / `M0_FTDs`; **24M** = `23` / `M0_FTDs`; **nominal 60M** = `ltv_60m_gross` / `M0_FTDs`; **NPV 60M** = `ltv_60m_npv` / `M0_FTDs` (`Observed SQL`, dataset `3ff26137`). Source `ltv_60m_npv` is a cohort NPV — dividing by `M0_FTDs` yields per-FTD, not per-user NPV.
- **Main LTV divisions are unguarded:** zero `M0_FTDs` errors under ANSI mode (live check: `100/0` → `DIVIDE_BY_ZERO`; `try_divide` → NULL). Never claim guaranteed NULL. Other datasets use NULLIF/CASE guards.
- **ROI fields** — `roi_12m/24m/60m` = GP ÷ `acq_spend` without subtracting 1. If surfaced, document this exact definition — not textbook ROI, not ROAS. Upstream `roi_12m` returns NULL when spend is zero (documented default).
- **Retention counts/rates M0–M26** — unpivoted `M<n> / M0_FTDs` (dataset `25493e50`, `ret_comparison`); counts repeat cohort denominators — never sum across offsets. Min/max via MEASURE(`Min Retention`)/`Max Retention`; year comparison pp (`avg_2026 − avg_2025` on pooled ratios, `delta_pp`); Q1/Q2 via `insights_q1q2`.
- **NPV discount:** business doc suggests 15% annual (`Documented`, LTV V1 Business Requirements) vs pipeline documented default 4% (`Documented`, LTV V1 Pipeline) — `Conflicting sources`; exponent uses `month + 1` in pipeline pseudocode while prose says "applied to all months: month" — also `Conflicting sources`. M24 proxy uses average M18 retention; baseline GP index 23 vs "M24" prose. Do not decide; see review register.
- **first retention below 15%** — filter-only dataset `ret_threshold` (`retention_rate < 0.15 AND month_number > 0`, first occurrence by ROW_NUMBER).
- Approval: `Not established`.

## Attribution Dashboard (`01f1035baf7717dcb3b699c05e18af31`)

Datasets: `5b939214` (page-referenced), `counter_metrics` (page-referenced), `b3910db5` selector.

- User-defined **fixed acquisition attribution** (registration-locked, first-touch semantics by design decision), not necessarily chronological MIN(click). Terms per user decision: Attribution Dashboard = first-touch/fixed acquisition; Attribution V2 = last-touch.
- **signups** — `SUM(signups)` by selected period/dimensions (`macro_channel`, channel group/source/medium/platform, `customer_migration_status`) (`Observed SQL`).
- **FTD count/amount** — `SUM(ftd_count)`, `SUM(ftd_amount)`; **FTB count/amount** — `SUM(ftb_real_money_count)`, `SUM(ftb_real_money_amount)`; **GGR/NGR** — `SUM(ggr_amount)`, `SUM(ngr_amount)`.
- **AVG of amount aggregates** (`Avg. FTD Amount` = `AVG(ftd_amount)` over rows) is an average of daily/source cells, **not** an average customer deposit — flag label/denominator ambiguity.
- Zero denominators: no guard expressions in dataset; counter widgets aggregate columns. Units: currency (BRL wording); no percent KPIs here.
- Approval: `Not established`.

## Attribution - Last Touch (`01f1448e2467147a977430f0b22ef212`)

Datasets: `cb38b652` unified events (page-referenced), `time_to_ftd` (page-referenced).

- **Event counts** — `SUM(event_count)` (=1 per row); **distinct customers** — `COUNT(DISTINCT customer_id)`. Base since 2026-01-01 excludes `kyc_completed` and `bet_placed`; cross-platform events remain separate (GA4 + AppsFlyer rows stay distinct — dedup only within platform via `event_unique_key`).
- **Amount SUM/AVG and named measures:**
  - `Avg Amount Per Customer` = `ROUND(SUM(amount) / NULLIF(COUNT(DISTINCT customer_id),0), 2)` — "average transaction amount per unique customer (BRL)".
  - `CPA` = `SUM(campaign_day_spend_once_event_type) / NULLIF(SUM(event_count),0)` (desc: "Full campaign-day spend divided by the number of events for the same campaign-day and event type").
  - `Spend for CPA` = `ROUND(SUM(campaign_day_spend_once_event_type), 2)` — full campaign spend counted once per campaign-day × event type.
  - `Total Spend` = `ROUND(SUM(campaign_day_spend / NULLIF(events_in_group,0)), 2)` — allocates campaign-day spend over event rows; **filters removing some event rows remove allocated spend**. Cannot be summed across event types as unique total spend.
  - `Campaign CPA` = allocated spend sum ÷ `SUM(event_count)` ("Correct at campaign… [level]" per description); not approved as a cross-filter invariant.
  - `FTD to Repeat Deposit Rate` = distinct deposit customers ÷ distinct first_time_deposit customers — **not** an explicit intersection of the same FTD cohort and subsequent depositors; its description says "% of FTD customers who made a subsequent deposit" — `Conflicting sources` with its own semantics.
  - Event amount subtotals use CASE on `event_type`; `Total FTD Amount` description says "deposit + bet placed + FTD" but the expression selects only `first_time_deposit` — description mismatch (`Observed SQL`).
- **Time to FTD** (`time_to_ftd`): earliest signup since 2025-01-01; earliest ranked FTD since 2026-01-01 (`ROW_NUMBER` by `event_timestamp, source_platform`); INNER JOIN with `signup_time < ftd_time` and `≤720` hours cap. Averages therefore exclude equal-timestamp, missing-signup and >30-day cases (`Observed SQL` + on-page note). `hours_to_ftd` = ROUND(diff/3600, 1); `days_to_ftd` = ROUND(diff/86400, 2); widgets `AVG(hours_to_ftd)`, `APPROX_PERCENTILE(hours_to_ftd, 0.5)` for median.
- ROAS-named measures exist in this dashboard's dataset (`ROAS - Deposits/Sign-Up/FTD`) — **excluded from scope**; they are not reproduced here.
- Approval: `Not established`.

## Single Cockpit (`01f1ad0baf861db6947747291643e017`)

Datasets: `92510bd6` selector, `f60a6281` V2 pre-aggregated (page-referenced), `4db43156` V2 counters (page-referenced), `e69639b3` + `e69639b3_counters` affiliates/referrals (page-referenced).

- **Signups** — count by registration date (`COUNT(DISTINCT CASE WHEN DATE(customer_created_at)=date THEN customer_id END)`); **FTD/FTB** — by event-date flags `ftd='yes'`/`ftb='yes'`; **amounts** — sum first-event amounts. Filters: `skin_id=1`, `flag_migrated_mrjack=0` (`Observed SQL`).
- **Cost/clicks/impressions/video** from `paid_media__channel_view_by_day`.
- **CPA = spend/FTDs** (`TRY_DIVIDE(Cost, NULLIF(ftds,0))`); **separate `cost_per_signup` = spend/signups**. **CPC** = cost/clicks; **CTR** = clicks/impressions×100; **CPM** = cost/impressions×1000; **conversion_rate** = FTDs/signups×100 — not same-cohort conversion; can exceed 100%.
- Dataset ratios use period totals and `try_divide`; counter widgets `AVG` the per-row ratio column (e.g. `AVG(CPC)`, `AVG(CTR)`, `AVG(conversion_rate)`) — document both layers; they differ (ratio-of-sums vs mean-of-ratios).
- **Affiliate/referral datasets** select `acquisition_source IN ('myaffiliates','RAE')` with no paid-media spend join (`Observed SQL`).
- Cockpit `spend`/`clicks` are CAST DECIMAL(18,1); ratios DECIMAL(18,4).
- Approval: `Not established`.

## Paid Media Dashboard (`01f1035b032d18c4ae75b7e7dde613e5`)

Datasets: `15970278` Paid Media (page-referenced), `bbfe9dce` selector, `paid_media_counters` (page-referenced).

- Same customer/channel join as Cockpit; **CPA = spend/signups** (`try_divide(SUM(spend), SUM(sign_ups))`) — differs from Cockpit's CPA = spend/FTDs (`Conflicting sources` across dashboards using the same label; review register).
- CPC = `try_divide(SUM(spend), SUM(clicks))`.
- Channel-driven LEFT JOIN retains spend rows, fills unmatched acquisition counts/amounts with zero, excludes acquisition-only sources.
- Counter widgets `AVG(CPC)`, `AVG(CPA)` over daily×channel rows — mean-of-ratios layer.
- Approval: `Not established`.

---

## Explicitly out of KPI inventory

- Infrastructure counters, associative-filter plumbing (`COUNT_IF(associative_filter_predicate_group)`), raw row-count QA datasets (`6d1c368d`, `42a3a1c6`, `d3ada300`), unused exploratory fields, roadmap-only CM360 metrics (Single Cockpit doc vision).
- `campaign_cpa` (FTD Tier): unused dataset — documented above only as supporting evidence.
- `ret_threshold`: filter-only.
- ROAS: excluded entirely (no formulas, no recommendations, no unresolved-definition work).