# Compliant example — filled doc in the target shape

Every claim below is consistent with the template + checklist. Generate output in this shape.

```markdown
# Affiliates Payback Window Change

This document provides MarTech Specialists with the minimum information and evidence required to review and approve a proposed change, without requiring detailed Product, Data or Technical documentation.

## 1. Initiative Overview

| Field | Answer |
|---|---|
| Initiative name | Affiliates Payback window change |
| Business / Product owner | MarTech Lead |
| Data / Tech contact | Data Platform team |
| Target go-live | 2026-09-15 |
| Risk level | Medium |
| Tech submission date | 2026-09-07 |

## 2. What Are We Changing?

**Current:** when we calculate how quickly an affiliate's players pay back their acquisition cost, we only count revenue from their first 90 days.

**Proposed:** extend that counting period to 120 days, so the payback measure reflects more of the revenue those players actually generate.

**Why:** igaming players keep generating revenue well past 90 days, so affiliate payback currently reads worse than it is. With the longer window, affiliate performance can be compared fairly with the other verticals.

### Incremental Delivery Plan

| Step | Answer |
|---|---|
| Smallest production release | extend window in the staging model |
| Target first production release | dev release 2026-09-15 |
| Customer/business outcome unlocked | affiliate payback aligned with verticals |
| How we'll know it worked | affiliate median payback day moves ±7 days |
| What comes next | tune back to median within the window |

## 3. Supporting Evidence

- Technical design: (link)
- Data Quality evidence: (link)
- Shortcut Epic / Story: (link)

## 4. MarTech Impact

- [ ] Payback v1
- [ ] Payback v1.1
- [x] Payback v1.2
- [ ] Payback v1.3
- [ ] Payback v1.4
- [ ] Payback v2
- [ ] LTV v1
- [ ] LTV v2
- [ ] Attribution v2 (True Last Click)
- [ ] Attribution v3 (Data Driven)
- [ ] Conversion Funnel
- [ ] Product Journey Optimization
- [ ] Campaign Insights
- [ ] Payback Insights
- [ ] Data Foundation
- [ ] MMM
- [ ] Other

**Impact summary:** affiliate payback reads longer under the same window across other verticals.

## 5. Data / System Flow

**Current:** `gold_dimensional_model.facts.transactions → staging model → Lakeview`
**Proposed:** `gold_dimensional_model.facts.transactions → staging model (120d) → Lakeview`

| Flag | Answer |
|---|---|
| New integration | No |
| New destination | No |
| New vendor | No |

## 6. Data Quality Evidence

**Status:** Amber — test-user exclusion pending validation (see Known issues).

| Check | Result | Evidence |
|---|---|---|
| Completeness | Pass | 99.1% of affiliate FTDs have transactions (excl. test users) |
| Accuracy | Pass | reconciled vs finance GP for July cohort |
| Consistency | Pass | no duplicate FTD rows in staging |

**Known issues:** `is_test` flag is Betnacional-only, so cross-brand exclusion uses the QA account list; not yet confirmed for affiliates.

## 7. What Needs MarTech Review?

| Item | Answer | Note |
|---|---|---|
| Proposed marketing use appropriate | OK | window change only |
| Customer journey / experience acceptable | OK | no UX change |
| Data used is appropriate for the purpose | OK | same source |
| DQ evidence sufficient | OK | |
| Segmentation / personalisation logic acceptable | N/A | no segmentation changed |
| Tracking / measurement acceptable | OK | |
| Integration impact acceptable | OK | |
| Consent / preference implications considered | OK | only aggregated payback metrics used |
| Known limitations and fallback acceptable | OK | |
| No additional MarTech requirements identified | OK | |
| Other: none | OK | |

## 8. MarTech Decision

| Field | Answer |
|---|---|
| Decision | `TBD — reviewer to complete` |
| Conditions / comments | `TBD — reviewer to complete` |
| MarTech Specialist | `TBD — reviewer to complete` |
| Date | `TBD — reviewer to complete` |

## 9. Delivery Outcome Confirmation

Filled after go-live, not at submission.

| Field | Answer |
|---|---|
| Date | |
| Business Owner | |
| Comments | |
```

All 9 sections, all fixed rows, exact titles, on-vocabulary answers, Section 8 untouched for the human, Section 9 empty for the business owner.
