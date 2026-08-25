# Compliant example — filled doc in the target shape

Every claim below is consistent with the template + checklist. Generate output in this shape.

```markdown
# Affiliates Payback Window Change
Section 1 — Initiative Overview

| Field | Answer |
|---|---|
| Initiative name | Affiliates Payback window change |
| Business / Product owner | MarTech Lead |
| Data / Tech contact | Data Platform team |
| Target go-live | 2026-09-15 |
| Risk level | Medium |

## 2. What Are We Changing?

**Current:** payback realization window for affiliates is 90 days.
**Proposed:** widen it to 120 days to capture igaming tail revenue.
**Why:** affiliate payback reads short compared with the longer-tail verticals.

### Incremental Delivery Plan

| Step | Answer |
|---|---|
| Smallest production release | extend window in the staging model |
| Target first production release | dev release 2026-09-15 |
| Customer/business outcome unlocked | affiliate payback aligned with verticals |
| How we'll know it worked | affiliate median payback day moves ±7 days |
| What comes next | tune back to median within the window |

## 3. MarTech Impact

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

## 4. Data / System Flow

**Current:** `gold_dimensional_model.facts.transactions → staging model → Lakeview`
**Proposed:** `gold_dimensional_model.facts.transactions → staging model (120d) → Lakeview`

| Flag | Answer |
|---|---|
| New integration | No |
| New destination | No |
| New vendor | No |

## 5. Data Quality Evidence

**Status:** Amber — test-user exclusion pending validation (see Known issues).

| Check | Result | Evidence |
|---|---|---|
| Completeness | Pass | 99.1% of affiliate FTDs have transactions (excl. test users) |
| Accuracy | Pass | reconciled vs finance GP for July cohort |
| Consistency | Pass | no duplicate FTD rows in staging |

**Known issues:** `is_test` flag is Betnacional-only, so cross-brand exclusion uses the QA account list; not yet confirmed for affiliates.

## 6. What Needs MarTech Review?

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

## 7. Supporting Evidence

- Technical design: (link)
- Data Quality evidence: (link)
- Shortcut Epic / Story: (link)

## 8. MarTech Decision

| Field | Answer |
|---|---|
| Decision | `TBD — reviewer to complete` |
| Conditions / comments | `TBD — reviewer to complete` |
| MarTech Specialist | `TBD — reviewer to complete` |
| Date | `TBD — reviewer to complete` |
```

All 8 sections, all fixed rows, exact titles, on-vocabulary answers, Section 8 untouched for the human.
