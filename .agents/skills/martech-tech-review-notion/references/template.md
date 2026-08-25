# Template — MarTech Technical Review & Approval

Exact 8-section structure. Sections are never deleted; undecided fields become `TBD — <what's missing>`, genuinely-not-applying fields become `Not applicable — <reason>`.

## 1. Initiative Overview

| Field | Answer |
|---|---|
| Initiative name | |
| Business / Product owner | |
| Data / Tech contact | |
| Target go-live date | (ISO 8601 `YYYY-MM-DD`) |
| Risk level (Low / Medium / High) | |

## 2. What Are We Changing?

**Current state:**

**Proposed change:**

**Why is this needed:** (business/customer outcome)

### Incremental Delivery Plan

| Step | Answer |
|---|---|
| What is the smallest production release? | |
| Target first production release | |
| Customer/business outcome unlocked | |
| How we'll know it worked | |
| What comes next | |

## 3. MarTech Impact

- [ ] Payback v1
- [ ] Payback v1.1
- [ ] Payback v1.2
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
- [ ] Other: ______

**Impact summary:** (short explanation)

## 4. Data / System Flow

**Current:** `[Source] → [System] → [Marketing Platform]`

**Proposed:** `[Source] → [System] → [New / Changed Step] → [Marketing Platform]`

| Flag | Answer |
|---|---|
| New integration | Yes / No |
| New destination | Yes / No |
| New vendor | Yes / No |

## 5. Data Quality Evidence

**Status:** Green / Amber / Red / N/A — no data flow changed (N/A unavailable if any §4 flag is Yes; `TBD` counts as Red)

| Check | Result | Evidence |
|---|---|---|
| Completeness | Pass / Issue | e.g. 98.7% populated |
| Accuracy | Pass / Issue | validation method |
| Consistency | Pass / Issue | result |

**Known Data Quality Issues:**

## 6. What Needs MarTech Review?

Answer every fixed item: **OK / Issue / N/A** + note.

| Item | Answer | Note |
|---|---|---|
| Proposed marketing use appropriate | | |
| Customer journey / experience acceptable | | |
| Data used is appropriate for the purpose | | |
| DQ evidence sufficient | | |
| Segmentation / personalisation logic acceptable | | |
| Tracking / measurement acceptable | | |
| Integration impact acceptable | | |
| Consent / preference implications considered | | |
| Known limitations and fallback acceptable | | |
| No additional MarTech requirements identified | | |
| Other: ______ | | |

## 7. Supporting Evidence

Only links a reviewer needs to open (or `Not applicable`):

- Product / Business requirement:
- Data specification:
- Technical design:
- Data Quality evidence:
- PoC / testing:
- Shortcut Epic / Story:

## 8. MarTech Decision

**Reviewer-side only. Never fill for the human.**

| Field | Answer |
|---|---|
| Decision (Approved / Approved with conditions / Changes required / Further review required / Not approved) | `TBD — reviewer to complete` |
| Conditions / comments | `TBD — reviewer to complete` |
| MarTech Specialist | `TBD — reviewer to complete` |
| Date | `TBD — reviewer to complete` |
