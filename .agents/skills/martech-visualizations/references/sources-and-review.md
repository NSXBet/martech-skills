# Sources, dataset inventory, and marketing review register

Research date: **2026-09-10**. Dev workspace `https://dbc-9853e30c-b7b6.cloud.databricks.com`, CLI profile `make dev/validate`.

## Source catalog

| Source | Type | Retrieved | Verification state |
|---|---|---|---|
| Dashboard definitions (8×) via `databricks lakeview get <id>` | Draft/editable definitions (SQL + widgets) | 2026-09-10 | Draft snapshots; update timestamps per dashboard below. Not verified equivalent to published revision. |
| Unity Catalog table metadata via `databricks tables get` | Column comments, types, grains | 2026-09-10 | `Observed SQL` |
| Live aggregate checks via Statement Execution API (warehouse `Martech SQL Warehouse Dev`) | Bounded SELECT aggregates only | 2026-09-10 | `Observed SQL` |
| Notion documentation (9 pages, listed below) | `Documented` — all pages report Notion verification state `unverified`; treat as documented requirements/technical docs, not marketing-approved policy | 2026-09-10 | unverified |

## Dashboard → dataset mapping and usage inventory

Usage classes: **displayed** (page-referenced widget), **filter-only**, **unused**, **QA**.

| Dashboard (clean name) | ID | Datasets (name → displayName) | Usage |
|---|---|---|---|
| FTD by Tier - Attribution V2 | `01f1873b8f9a1f6fad3be199a6a9a9b8` | 6571c853 FTD by Tier; 5679a23e FTD in World Cup; d28e547c FTD in World Cup by event; 6d1c368d Aggregate Record Count Summary; d3ada300 True LTA snapshot; campaign_cpa | displayed, displayed, displayed, QA, QA, unused (no page widget) |
| Payback Dashboard - V1 | `01f13975d65a1872856e4f57df7a950c` | 0a80f426 Payback V1; 6111a571 Metrics; 57825ed0 M1 Retention (iGaming); e5df4497 Affiliates rolling forecast; f8edceec Channel Payback rolling 2026 | displayed, displayed, supporting, supporting, supporting |
| Copa — Cohort Analysis - Attribution V2 | `01f1840eef8913878e0920450105ea51` | cohort_daily/weekly/monthly; export_base; 42a3a1c6; export_qa_check | unused in snapshot, displayed, displayed, unused, QA |
| LTV Dashboard - V1 | `01f12372f1bf1d93a4611fe7f2e35312` | 6a495532; 25493e50; 3ff26137; ret_comparison; ret_threshold; insights_q1q2 | displayed, displayed, displayed, displayed, filter-only, displayed |
| Attribution Dashboard | `01f1035baf7717dcb3b699c05e18af31` | 5b939214; b3910db5; counter_metrics | displayed, selector, displayed |
| Attribution - Last Touch | `01f1448e2467147a977430f0b22ef212` | cb38b652; time_to_ftd | displayed, displayed |
| Single Cockpit | `01f1ad0baf861db6947747291643e017` | 92510bd6; f60a6281; 4db43156; e69639b3; e69639b3_counters | selector, displayed, displayed, displayed, displayed |
| Paid Media Dashboard | `01f1035b032d18c4ae75b7e7dde613e5` | 15970278; bbfe9dce; paid_media_counters | displayed, selector, displayed |

Draft-definition update timestamps (2026-09-10 fetch): FTD by Tier 2026-09-09T09:09Z; Payback 2026-09-10T11:50Z; Copa 2026-07-23T14:26Z; LTV 2026-09-10T11:48Z; Attribution Dashboard 2026-09-10T11:57Z; Last Touch 2026-09-10T11:51Z; Single Cockpit 2026-09-10T11:50Z; Paid Media 2026-09-10T11:52Z.

## Notion pages fetched (all unverified)

| Page | URL | Last edited |
|---|---|---|
| Payback V1 - Dashboard Documentation | https://app.notion.com/p/325eb847f78c80b1a187fd2ae6143ccc | 2026-04-06 |
| Attribution v2 - True Last Click | https://app.notion.com/p/2ceeb847f78c80008ec6ee6d4ff559b1 | 2026-08-25 |
| Payback & LTV Catalog & Schema Architecture | https://app.notion.com/p/33eeb847f78c80d9801ce63f27452088 | 2026-04-15 |
| LTV V1 Pipeline | https://app.notion.com/p/343eb847f78c80e2a952d02af4901c1a | 2026-04-15 |
| LTV V1 Business Requirements | https://app.notion.com/p/32feb847f78c80e0a296c21092f853a1 | 2026-04-15 |
| Single Cockpit | https://app.notion.com/p/311eb847f78c80698a2dee48575368a8 | 2026-07-01 |
| Payback Model V1 - Pipeline Documentation | https://app.notion.com/p/325eb847f78c8035a19ac32084611b28 | 2026-03-16 |
| NGR V1 Pipeline | https://app.notion.com/p/325eb847f78c8094a834c34fb8d35445 | 2026-03-16 |
| Turnover V1 Pipeline | https://app.notion.com/p/325eb847f78c80e09858e69a284a3474 | 2026-03-16 |

All fetched pages report Notion verification state `unverified` — documented requirements/technical documentation, not marketing-approved policy.

## Live execution record (2026-09-10, aggregate-only, warehouse `Martech SQL Warehouse Dev`)

- Executed live: attribution rollup (`agg_daily_metrics`), channel spend rollup (`paid_media__channel_view_by_day`), last-touch channel-group counts, time-to-FTD aggregates, tier weekly counts (`period_type='Weekly'`, 2026-07-06), LTV per-FTD example (cohort 2026-02 Google), Payback `predicted_m2payback` example (Google 2026_08), grain check (`customer_view_by_day` 0 duplicate groups), campaign multi-channel fanout check (0 in window), case-collision check (0), zero-division behavior (`/` → error, `try_divide` → NULL), dynamic tables `2026_08` present, QR table **missing** (`TABLE_OR_VIEW_NOT_FOUND`).
- Blocked: any query touching `flutter_brazil_data_dev.qrcodecaze.qr_ftd_customers` (Copa live examples).
- Synthetic-only: Copa offset math proof (in sql-examples.md).
- Not checked: production/published dashboard revisions (draft definitions cited instead), no reconciliation against rendered screens.

## Marketing review register (all `Open`; decision requested from Marketing Analytics; Data Platform for schema/access rows)

| # | Issue | Conflicting/missing claims | Affected KPI/dashboard | Citations |
|---|---|---|---|---|
| 1 | CPA meaning split | Paid Media CPA = spend/signups vs Cockpit CPA = spend/FTDs (plus separate `cost_per_signup`); counter widgets AVG per-row ratios vs dataset ratio-of-sums | CPA, CPC, CTR, CPM, conversion_rate | Paid Media `15970278`/`paid_media_counters`; Cockpit `f60a6281`/`4db43156` |
| 2 | LTV discount rate | Business doc suggests 15% annual vs pipeline documented default 4% | LTV 60M NPV | LTV V1 Business Requirements; LTV V1 Pipeline |
| 3 | LTV NPV exponent & proxies | Pipeline pseudocode uses `(month + 1)` exponent vs prose "applied to all months: month"; M24 projection uses average M18 retention as proxy; baseline GP index 23 vs M24 prose | LTV 60M NPV | LTV V1 Pipeline, NPV Discounting section |
| 4 | Retention widget off-by-one/labels | counter_m3 filters `month_number IN (2)`; counter_m12 filters 11; `f97265c6` filters 17 with M18 title and Weighted M12 display name — calendar labeling intent undecided | Cohort Retention Rates | LTV dataset `25493e50` widget specs |
| 5 | Currency formatting | USD-style widget formatting in some Payback/LTV widgets vs BRL wording elsewhere; format does not establish units | Payback/LTV money KPIs | dashboard widget `format` specs vs docs wording |
| 6 | Attribution model versions | Registration-locked vs event-specific attribution; 7-day roadmap example vs 30-day GA4 table variant; unresolved source hierarchy/orphan fallback | Attribution family | Attribution v2 - True Last Click doc; `true_lta...30d_win` table comment |
| 7 | Tier upstream grain/formula | Tier thresholds, snapshot rules, stage classifications absent; latest attribution joined without historical `period_ref`/`tier_ref` predicate; timestamp ties unresolved (no secondary ORDER BY) | FTD Tier KPIs | `ftd_by_tier_v2` metadata (no comments); datasets `6571c853`/`5679a23e`/`d28e547c` |
| 8 | Copa retention definition | `active_customers` = any row present (no `active_user_by_flutter`/bet predicate); rolling month offsets (FLOOR/30); incomplete-period handling; QR schema unavailable; QA D-2 query differs from cohort query | Copa cohort KPIs | Copa datasets `cohort_weekly`, `export_qa_check` |
| 9 | Campaign CPA channel gap | campaign_cpa joins normalized campaign name + period, omits channel — can multiply matches; dataset unused by pages (supporting evidence, not active KPI failure) | campaign_cpa (unused) | FTD Tier dataset `campaign_cpa` |
| 10 | Cockpit CM360 roadmap vs actual | CM360 path-to-conversion/deduplicated CPA is roadmap vision; actual datasets are acquisition/media joins; obsolete catalog names in old docs/comments vs live metadata | Single Cockpit | Single Cockpit doc; live catalog listing (no Payback/LTV model schemas in `gold_martech_dev`) |
| 11 | `FTD to Repeat Deposit Rate` semantics | Expression = distinct deposit customers ÷ distinct FTD customers, not explicit same-cohort intersection; description claims "% of FTD customers who made a subsequent deposit" | Last Touch | dataset `cb38b652` measure definitions |
| 12 | `Total FTD Amount` description mismatch | Description mentions deposit + bet + FTD; expression sums only `first_time_deposit` amounts | Last Touch | dataset `cb38b652` measure definitions |

ROAS is excluded from this register entirely.

## Known absences (recorded, not filled)

- `flutter_brazil_data_dev.qrcodecaze.qr_ftd_customers`: schema not found in metadata access; live SELECT fails. QR segmentation dependency active in Copa datasets but unavailable.
- No Payback/LTV model-schema counterparts in `gold_martech_dev` beyond `gold_martech_dev.paid_media.agg_daily_metrics`.
- `ftd_by_tier_v2`/world-cup tables: no table/column comments; upstream definitions not read.
- `gold_martech_dev.paid_media.agg_daily_metrics` shares column names with `gold_martech` — same columns do not prove equal data/semantics.