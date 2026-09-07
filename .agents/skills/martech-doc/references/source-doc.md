# Source document this skill encodes

Extracted 2026-09-07 from `Doc - MarTech Technical Review & Approval.docx` (local; not committed to git).

## Purpose (preamble)

This document provides MarTech Specialists with the minimum information and evidence required to review and approve a proposed change, without requiring detailed Product, Data or Technical documentation.

## 9 sections

1. **Initiative Overview** — name, business/product owner, data/tech contact, go-live, risk, tech submission date.

2. **What Are We Changing?** — current state, proposed, why + Incremental Delivery Plan. Heading: "Describe the change in simple business language."

3. **Supporting Evidence** — product/business req, data spec, tech design, DQ evidence, PoC/testing, Shortcut links.

4. **MarTech Impact** — canonical surface list (Payback 1/1.1–1.4/2, LTV 1/2, Attribution 2/3, Conversion Funnel, Product Journey Optimization, Campaign Insights, Payback Insights, Data Foundation, MMM, Other) + summary.

5. **Data / System Flow** — current + proposed arrows; new integration / destination / vendor Yes/No.

6. **Data Quality Evidence** — Green/Amber/Red + Completeness / Accuracy / Consistency → Pass/Issue + evidence; known issues.

7. **What Needs MarTech Review?** — 11 fixed items assessed (use, journey, data-fit, DQ sufficiency, segmentation logic, tracking, integration, consent/preference, limitations/fallback, no additional requirements, Other).

8. **MarTech Decision** — Decision (Approved / Approved with conditions / Changes required / Further review required / Not approved), Conditions/comments, Specialist, Date.

9. **Delivery Outcome Confirmation** — date, business owner, comments. Filled after go-live, not at submission.

The skill additionally keeps an `N/A — no data flow changed` DQ status that the doc does not list.

When the .docx changes, update this extract AND the skill in the same PR, so drift between source and skill is visible.
