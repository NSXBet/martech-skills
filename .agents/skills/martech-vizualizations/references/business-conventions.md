# Business conventions and marketing decisions

Reusable rules with citations. Do not manufacture policies not listed here: no timezone/currency conversion, no test-user exclusion, no tie-breaker, no tier threshold, no source waterfall, no NULL policy beyond what is cited.

## Attribution family

- Two attribution families are in use and must not be mixed:
  - **Fixed acquisition attribution** (Attribution Dashboard; `agg_daily_metrics` acquisition fields): assigned at acquisition/registration and stays with the customer. The dashboard is user-designated first-touch/registration-locked; do not re-derive it as chronological `MIN(click)` (`Documented` + user decision).
  - **Event-specific last touch** (`true_lta_events_attributed_v2_30d_win`; Attribution - Last Touch, Copa/FTD-Tier enrichment): each event carries the attributed session's source (`Observed SQL` table comment). GA4 web-only, 30-day prior-session last-click non-direct variant; AppsFlyer unchanged (`Documented` table comment).
- Registration-locked vs event-specific attribution, the 7-day roadmap example vs the 30-day GA4 table variant, and the unresolved source hierarchy/orphan fallback are separate concerns — see review register in [sources-and-review.md](sources-and-review.md). Different versioned models are not by themselves a contradiction.
- RAF (`raf`) is refer-a-friend, its own group, distinct from `referral` (third-party site traffic) (`Observed SQL` column comment). `RAE` (referral program label in Cockpit/Payback) and `myaffiliates` are acquisition_source values (`Observed SQL` filters).

## Customer / event / cohort distinctions

- Signups count by registration date; FTD/FTB count by their event-date flags; first-event amounts are summed on their own date (Paid Media/Cockpit pattern) (`Observed SQL`).
- `customer_created_date` in Payback/LTV tables means the **FTD cohort** month despite its name (`Documented` Payback V1 Dashboard Documentation). Copa cohorts key on the FTD date.
- A customer is one entity across platforms but events are not cross-platform deduped in the LTA table (`Observed SQL`).
- Report dates are platform reporting dates from each channel's paid-media model; cohort dates are customer FTD months. Source reporting date vs cohort date differs in Payback spend vs model tables.

## Source-specific channel normalization

- `dv_360 → dv360`, `tiktok_ads → tiktok` (media channel → acquisition source direction); reverse in Last Touch. Apply exactly where observed, lowercase both sides (`Observed SQL`).
- Case-insensitive matching on `acquisition_source` can collide differently-cased variants; warn rather than assume normalized uniqueness (`Observed SQL` pattern; no collision found in a sampled window).
- Cockpit/Paid Media `macro_channel` values come from `agg_daily_metrics` (`Paid media`, `Referrals Program`, `Affiliates` per pt-BR comment).

## Observed brand / migration / test-user filters

- Dashboards filter `skin_id=1` (Betnacional) and `flag_migrated_mrjack=0` where used (`Observed SQL`). `agg_daily_metrics` documents skin_id=1 scope.
- No test-user exclusion filter is applied in the inspected dashboard SQL — record this as an observed absence; any inherited exclusion is unverified unless traced (`martech-doc` lists test-user exclusion as a historical check, not a current fact).
- Missing provider video metrics are NULL for channels that do not report video — not necessarily zero (`Observed SQL` comment).

## Dates, periods, cohorts

- Reporting date (ad platform) vs cohort date (customer FTD month vs FTD day) must not be conflated; Payback/LTV dynamic snapshot suffix is the previous calendar month `yyyy_MM` (`Observed SQL`).
- Period types overlap (tier `Weekly`/`Monthly`; Paid Media daily/weekly/monthly UNION rows; Copa daily/weekly/monthly bins). Select one type before summing.
- Copa weekly/monthly offsets are FLOOR(days/7), FLOOR(days/30) — rolling bins, not calendar periods.
- LTV snapshot suffix = previous calendar month; data modes cap history at D-2 for the LTA table.

## Money, currency, ratios

- Currency formatting vs verified units: several Payback/LTV widgets show USD-style formatting while docs/wording say BRL; format alone does not establish units (`Observed SQL` widget formats vs `Documented` wording) — flag, don't convert.
- Ratio-of-sums vs mean-of-ratios: dataset ratios compute totals-then-divide; counter widgets frequently AVG the per-row ratio column. Always name the layer (see test 1).
- Zero-denominator handling differs per dashboard: `try_divide` (Payback/Cockpit/Paid Media), `NULLIF` (Last Touch, LTV side datasets), unguarded `/` (main LTV divisions — ANSI error on zero, verified live). Never claim guaranteed NULL for unguarded division.