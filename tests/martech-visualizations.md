# MarTech Visualizations behavioral evaluations

Maintainer scenarios for evaluating the skill after substantive edits. Synthetic inputs, not company data or production findings. Run each in a fresh agent context with the skill and its relevant references, read-only, without live services. Assess decisions and evidence discipline, not exact wording or heading matches. Do not provide the expected behavior to the evaluating agent until after its response.

## 1. CPA and weighting

Prompt:

> Two days of paid media for one channel: Day 1 spend=100, clicks=10, signups=10, FTDs=2. Day 2 spend=100, clicks=100, signups=20, FTDs=8. What is the CPC, the CPA by signups, and the CPA by FTDs — and why do dashboard counter widgets sometimes disagree with the table?

Expected behavior:

- Dataset CPC = 200/110 ≈ 1.82; AVG daily CPC = (10+1)/2 = 5.5; signup CPA = 200/30 ≈ 6.67; FTD CPA = 200/10 = 20.
- Names the denominators, distinguishes dataset-level ratio-of-sums from counter AVG (mean-of-ratios) behavior, cites Paid Media vs Cockpit CPA sources, does not silently equate the two layers.

## 2. Attribution and grain

Prompt:

> A user registers via SEO organic search, then deposits after clicking a Meta ad. In our attribution dashboards, how do we count this user, and what happens to unique customer counts if the same customer has events attributed to two sources? Also, a colleague says campaign_cpa can be summed across channels since campaign names are unique — react.

Expected behavior:

- Distinguishes fixed acquisition source (registration-locked, Attribution Dashboard) from event-specific attribution (last-touch, LTA table); the deposit event may attribute to Meta while the acquisition source stays the registration source.
- Event-source duplicates do not become two unique customers (COUNT(DISTINCT customer_id)).
- Flags campaign_cpa fanout: join matches normalized campaign name + period, omits channel — same campaign on two media channels multiplies matches; warns instead of asserting one-to-one. Does not invent a seven-day precedence rule.

## 3. LTV and zero/maturity

Prompt:

> Cohort A has 1000 FTDs and M1=100 actives; cohort B has 100 FTDs and M1=20. What is M1 retention, and what happens for a zero-FTD cohort row? Also, cumulative GP at month 11 is 1200 for a cohort with 10 FTDs — what is LTV 12M? There are two discount rates mentioned in our docs, 15% and 4% — which do I use?

Expected behavior:

- Unweighted average rate = 15% vs pooled 120/1100 ≈ 10.9% — names both, flags ratio-of-sums vs mean-of-ratios.
- Zero-FTD row: guarded formula → NULL; existing unguarded division errors under ANSI mode (not guaranteed NULL).
- Flags the 15% (business requirements) vs 4% (pipeline default) discount conflict as `Conflicting sources` and does not pick a winner.
- Immature periods are missing/unknown, not zero.
- GP cumulative `11`=1200, FTDs=10 → per-FTD 12M = 120, not 1200 (column 11 is cumulative, do not sum M0–M11 rows again).

## 4. Copa/tier/source discipline

Prompt:

> For the Copa cohort dashboard: a customer FTDs on June 10, another on June 11; one is a QR-code customer. When do weekly/monthly offsets land for activity at FTD+7 and FTD+30? A stakeholder asks what the tier thresholds are for ftd_by_tier_v2 and wants us to substitute the missing QR table with a zero-member table so the query runs. Also someone asks for the ROAS breakdown by segment.

Expected behavior:

- QR membership precedence retained (QR Code overrides date-based Pré-Copa/Copa boundary); otherwise June 11 (≥ 2026-06-11) is Copa, June 10 is Pré-Copa.
- FTD+7 → weekly offset 1; FTD+30 → monthly offset 1 (FLOOR bins, not calendar periods).
- Tier thresholds absent from supplied sources → `Missing definition` review item; no invented thresholds; does not import unrelated Value Tier models.
- Missing QR table is never replaced with an empty/zero-member table; dependency reported unavailable.
- A request containing ROAS leaves it excluded.
- Uses clean dashboard names without clone suffixes and cites source-backed rules.


## Validation record

Dated results of actually running the scenarios above.

| Date | Evaluator | Scope | Result |
|---|---|---|---|
| 2026-09-10 | Authoring run — structural checks only | Validator `OK — 3 skill(s) valid`; `bash -n` green; links checked; live execution record for SQL examples in `references/sql-examples.md` and `references/sources-and-review.md` | Structural only |
| 2026-09-11 | Four fresh-context task agents (one per scenario), read-only, no live services, skill at `.agents/skills/martech-visualizations/` | Scenarios 1–4 | All four passed. Maintainer assessed each of the four fresh responses against the expected behaviors above and found no mismatches. Scenario 1: correct dataset/AVG layer split (1.82 vs 5.5; 6.67 vs 7.5; 20 vs 31.25) with Paid Media/Cockpit CPA conflict flagged. Scenario 2: families kept separate, distinct-customer dedup correct, campaign_cpa fanout refused. Scenario 3: 10%/20% per cohort vs pooled 10.9%, zero-FTD = ANSI error not NULL, 15%/4% left unresolved, LTV 12M = 120. Scenario 4: QR precedence + all four segment outcomes, FTD+7→weekly 1, FTD+30→weekly 4/monthly 1, tier thresholds `Missing definition`, QR substitution refused, ROAS excluded |

Scenario runs are synthetic: no company data, no live dashboards, no customer rows are involved. Record each run's date, evaluator, and which expected behaviors failed before extending this table.