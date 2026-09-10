# Schema and join contracts

Observed 2026-09-10 from Unity Catalog metadata (`databricks tables get ... --profile 'make dev/validate'`) and dashboard dataset SQL on host `https://dbc-9853e30c-b7b6.cloud.databricks.com`. Catalogs `gold_martech` and `gold_martech_dev` are distinct environment catalogs; dev dashboard definitions read unsuffixed catalogs and science/dimensional catalogs. Never substitute `_dev` automatically. A documented or inferred grain is not tested uniqueness unless a check is cited.

## customer activity: `gold_dimensional_model.aggs.customer_view_by_day`

- Role: daily customer-level activity fact; consumed by Paid Media, Single Cockpit, Copa, FTD Tier bases.
- Documented grain `(date, customer_id, skin_id)` (table/column comments). `Observed SQL` uniqueness check on `2026-08-03..04, skin_id=1`: 0 duplicate groups (`date`,`customer_id`,`skin_id`). Not a general uniqueness proof across all history.
- `date` = activity date (bets/transactions). `_partition_date` matches activity date.
- `ftd='yes'` / `ftb='yes'` are date-specific first deposit / first bet flags. `ftd_amount` / `ftb_amount` populated only on their respective first-event date, zero otherwise (`ftd_amount` comment; `Observed SQL` dashboard `CASE WHEN ftd='yes' THEN ftd_amount`).
- `bet_amount`: total stakes across all balance types. `bet_common_amount` = common (real) balance stakes; `bet_restricted_amount` = restricted/bonus stakes (both available from 2025-01-01).
- `ggr_amount` = stakes minus winnings, before restricted-stake deduction. `ngr_amount` = GGR minus restricted balance stakes (column comments). Vertical variants `sports_*`/`igaming_*` follow the same pattern.
- `active_user_by_flutter` (INT): 1 when the customer placed bets with common balance after FTD on that date (`Observed SQL` comment). Copa `active_customers` does NOT use this predicate (see kpi-definitions).
- `acquisition_source` is harmonized, default `'Untracked'`. Dashboard joins apply `LOWER(...)` case-insensitive matching; a case-normalization collision (`RAE` vs `rae`) would merge distinct sources — treated as a risk, uniqueness after normalization is not proven.
- `customer_created_at` (TIMESTAMP): registration. `flag_migrated_mrjack` (INT): 0/1 migration flag; `skin_id`: 1=Betnacional, 2=MrJack, 3=Pagbet, 4=Betpix (comment).
- Nullable fields affecting metrics: money columns coalesced to 0 by dashboard SQL; absent activity days simply have no row (absence ≠ proven zero retention).
- Contains PII-adjacent fields (`cpf`, city/state). Aggregate only; never export raw rows.

## paid media aggregates

### `gold_martech.paid_media.agg_daily_metrics`

- Comment: daily acquisition metrics, **Betnacional only (`skin_id=1`)**; grain `(date, macro_channel, acquisition_channel_group, acquisition_source, acquisition_medium, acquisition_platform, customer_migration_status)`.
- Columns: `date`, `macro_channel`, `acquisition_channel_group`, `acquisition_source`, `acquisition_medium`, `acquisition_platform`, `customer_migration_status`, `signups`, `ftd_count`, `ftd_amount`, `ftb_real_money_count`, `ftb_real_money_amount`, `ggr_amount`, `ngr_amount` (14 total; same column names exist in `gold_martech_dev.paid_media.agg_daily_metrics` — same names do not prove equal data/semantics).
- Attribution Dashboard dataset `5b939214` reads the **unsuffixed** `gold_martech` table (`Observed SQL`).
- `signups` = unique customers who registered on this date; `ftd_count`/`ftd_amount` = first deposits on this date; `ftb_real_money_*` = first real-money bet (comments, pt-BR).

### `gold_martech.paid_media.paid_media__channel_view_by_day`

- Grain `(date, channel)` (comment). Channels: Google, Meta, Taboola, MGID, Twitter, TikTok Ads, DV360, Genius, Jampp, Liftoff — dynamically unioned per-channel `paid_media__metrics` models.
- `spend`, `clicks`, `impressions` (NOT NULL-ish numerics); video metrics `video_views`, `video_p25/p50/p75/p100_watched` are **NULL for channels that do not report video data** — missing provider video values are not necessarily zero.

### `gold_martech.paid_media.paid_media__campaign_view_by_day`

- Grain `(date, channel, campaign_name)` (comment). Same money/click/video columns.
- Channel-driven LEFT JOIN in Paid Media / Cockpit retains spend rows and fills unmatched acquisition counts/amounts with zero (`COALESCE(...,0)`), excluding acquisition-only sources with no spend row.
- Campaign names repeat across channels (fanout risk for campaign-level joins on name only). In a 2026-08-03..07 window no campaign appeared on 2+ channels, but uniqueness of campaign_name across channels is not guaranteed (per-channel reporting).

## channel normalization (exact, where observed)

- `dv_360 → dv360` and `tiktok_ads → tiktok` in Paid Media/Cockpit join predicates (channel → acquisition_source direction, lowercased both sides).
- Reverse direction in Last Touch (event `attr_source` → media channel): `dv360 → dv_360`, `tiktok → tiktok_ads`.
- Join by raw `acquisition_source` then case-insensitive match: warn on case-normalization collisions instead of assuming uniqueness.

## true last touch: `silver_martech.true_lta.true_lta_events_attributed_v2_30d_win`

- Comment: 30-day prior-session lookback variant of `true_lta_events_attributed_v2`; identical structure/harmonization; GA4 side from `true_lta_ga_events_attributed_30d_win`; **AppsFlyer unchanged**.
- Documented grain: one row per event × attributed session; `event_unique_key` (`source_platform|event_name|event_date|session_id|device_id|key...`) is the platform-scoped merge identity. No cross-device dedup.
- `source_platform` ∈ {`appsflyer`, `ga4`}; `session_id`/`device_id` unique only within a platform.
- GA4 is web-only (app `user_pseudo_id`s dropped); `customer_user_id` may be **NULL on GA4** (from session join `attr_user_id`).
- Event names: `sign_up`, `kyc_completed`, `first_time_deposit`, `deposit`, `bet_placed` (AppsFlyer `place_a_bet` mapped to `bet_placed`).
- `event_value` (DOUBLE): deposit/FTD amount, or bet stake (one row per transaction, not summed); NULL when unavailable; currency not established by the comment alone.
- `channel_group`: canonical groups incl. `raf` (refer-a-friend, its own group) distinct from `referral` (third-party site traffic). `attr_source`/`attr_medium` harmonized to canonical dictionaries.
- `event_date` = partition key; incremental runs slice D-2 only; full refresh covers longer history — recent days can be missing.

## FTD tier sandbox: `flutter_brazil_data_science.data_science_sandbox.*`

- `ftd_by_tier_v2`, `ftd_in_world_cup_v2`, `ftd_in_world_cup_by_event_v2`: schema metadata exists; **no table or column comments** for the metrics. Preserve `period_type` (`Weekly`/`Monthly` observed live), `period_ref`, `tier_ref`, `customer_id`, `value_tier`, event/stage dimensions (`stage_order`, `stage`, `event_id`, `event_name`, `week_ref`).
- Generation formulas, precise uniqueness, tier thresholds/time policy, stage classifications: `Missing definition` until the directly linked upstream definition is read. Do not import unrelated "Value Tier" models based on matching words.
- Dashboard joins latest `sign_up`/`first_time_deposit` LTA row per user via `ROW_NUMBER() ... ORDER BY event_timestamp DESC` (no secondary tie-breaker) and does NOT constrain attribution to each historical `tier_ref` (`Observed SQL`, datasets `6571c853`/`5679a23e`/`d28e547c`).

## Payback V1 tables

- Core cohort tables `silver_martech.payback_v1_channels_core.cohort_*` (e.g. `cohort_sports_ngr`, `cohort_igaming_ngr`, `cohort_all_ngr`, `cohort_sports_bet_volume`, `cohort_*_estimated_gp`, `cohort_ftd_count`, `cohort_m0_sports_bettors_distinct`, `cohort_m0_igaming_bettors_distinct`): join key `(customer_created_date, acquisition_channel_group, acquisition_source)`; `0` column = M0 (`Observed SQL`). `customer_created_date` means the FTD cohort in business docs despite its misleading name.
- Model tables `gold_martech.payback_v1_channels_{ngr,turnover}.ch_<channel>_vrt_all_pred_metrics_for_all_curve_rolling_asof_<yyyy_MM>` with columns `customer_created_date, acq_spend, gp_12m_accumulated, roi_12m, m2payback, gp_11, predicted_m2payback` (live schema). Spend tables `silver_martech.payback_v1_channels_ngr.ch_<channel>_vrt_all_acquisition_spend_asof_<yyyy_MM>` (`customer_created_date`, `acq_spend`).
- `cohort_m0_sports_bettors_distinct` / `cohort_m0_igaming_bettors_distinct` are vertical counts — do not assume they partition total FTDs (`total_ftd_count` is separate).
- No Payback/LTV model-schema counterparts exist in `gold_martech_dev` beyond `paid_media.agg_daily_metrics` (catalog listing).

## LTV V1 tables

- Retention: `silver_martech.ltv_v1_channels_core.cohort_retention_ch_<channel>_as_of_<yyyy_MM>` — columns `cohort` (STRING 'YYYY-MM'), `M0_FTDs`, `M0..M32` (LONG counts; unpivoted usage covers M0–M26).
- Value: `silver_martech.ltv_v1_channels_{ngr,turnover}.ch_<channel>_gp_24m_for_all_curve_rolling_asof_<yyyy_MM>` (columns `customer_created_date`, `0`..`23` = cumulative GP) and `ch_<channel>_gp_ltv_60m_npv_asof_<yyyy_MM>` (columns `cohort`, `M0_FTDs`, `ltv_60m_npv`, `ltv_60m_gross`, `m24_retention_rate`, `npv_0..npv_59`, `retention_24..59`, ...).
- Dynamic suffix = **previous calendar month** (`DATE_FORMAT(ADD_MONTHS(CURRENT_DATE(), -1), 'yyyy_MM')` in dataset variables). All 69 dynamic table references resolved at `2026_08` during planning; `cohort_retention_ch_google_as_of_2026_08` and `ch_google_*_2026_08` confirmed live.
- Join: GP/LTV join on `cohort = customer_created_date` + channel + `model_type` (NGR vs Turnover kept separate); spend join omits `model_type`.
- Counts/ratios in unpivoted M0–M26 rows repeat cohort denominators — do not sum across month offsets.

## Copa cohort (dashboard `01f1840eef8913878e0920450105ea51`)

- Cohort grain `(cohort_period, segmento, period_offset)`; export `export_base` grain: customer × activity date.
- Active dependency `flutter_brazil_data_dev.qrcodecaze.qr_ftd_customers` (distinct QR customers): **unavailable** — schema not found in current metadata access and `SELECT COUNT(*)` failed `TABLE_OR_VIEW_NOT_FOUND` (live check 2026-09-10). Record as unavailable; do not omit QR segmentation or fabricate an empty table.
- Export contains customer/geographic fields (`city_address`, `state_address`, `activation_category`): document structure only; never commit exported rows.
- Static missing legacy schemas inside unused/commented definitions are not proof that active paths fail; keep them in [sources-and-review.md](sources-and-review.md) inventory with usage classification.