---
name: martech-visualizations
description: "Use when interpreting NSX marketing dashboards (FTD by Tier, Payback, Copa Cohort Analysis, LTV, Attribution, Attribution Last Touch, Single Cockpit, Paid Media), writing or reviewing marketing SQL, or explaining KPIs like FTD, cohort retention, CPA, ARPU, payback, or LTV from these dashboards' Databricks tables. Supplies sourced schema/join contracts, exact KPI formulas, business conventions, and sourced SQL examples. Not for chart styling, medallion pipeline architecture, or MarTech approval documents."
---

# MarTech Vizualizations (dashboards knowledge)

Evidence-backed interpretation of the eight NSX MarTech dashboards in the dev
Databricks workspace. Before generating or changing marketing SQL, read the
relevant KPI contract in [references/kpi-definitions.md](references/kpi-definitions.md)
and the table grain in [references/schema-and-joins.md](references/schema-and-joins.md).

## Scope guard

ROAS is out of scope: no definitions, examples, or review findings. If a
request asks for ROAS, state it is excluded pending a marketing-approved
definition.

## Dashboards covered

| Dashboard | Dashboard ID |
|---|---|
| FTD by Tier - Attribution V2 | `01f1873b8f9a1f6fad3be199a6a9a9b8` |
| Payback Dashboard - V1 | `01f13975d65a1872856e4f57df7a950c` |
| Copa — Cohort Analysis - Attribution V2 | `01f1840eef8913878e0920450105ea51` |
| LTV Dashboard - V1 | `01f12372f1bf1d93a4611fe7f2e35312` |
| Attribution Dashboard | `01f1035baf7717dcb3b699c05e18af31` |
| Attribution - Last Touch | `01f1448e2467147a977430f0b22ef212` |
| Single Cockpit | `01f1ad0baf861db6947747291643e017` |
| Paid Media Dashboard | `01f1035b032d18c4ae75b7e7dde613e5` |

URLs: `https://dbc-9853e30c-b7b6.cloud.databricks.com/dashboardsv3/<id>/published`.
Definitions fetched with `databricks lakeview get <id> --profile 'make dev/validate' --output json` (draft definitions — dated provenance in [references/sources-and-review.md](references/sources-and-review.md); not verified equivalent to the published revision).

## Evidence statuses

Use exactly these labels in answers:

- `Documented` — Notion business/technical documentation (all fetched pages were Notion-unverified; cite page + section).
- `Observed SQL` — dashboard dataset SQL or Unity Catalog table/column comment read directly.
- `Inferred` — interpretation; label it as such, never as source fact.
- `Missing definition` — formula/owner decision not found upstream; record precisely what is missing.
- `Conflicting sources` — sources disagree; report both, decide nothing.

Approval is a separate field: `Not established` unless a source explicitly records approval. A source mismatch never authorizes a dashboard fix — report it. Unknown value/unit/filter is a finding, never zero or a default.

## Routing

| Need | Read |
|---|---|
| Table grain, join keys, cardinality, join direction | [references/schema-and-joins.md](references/schema-and-joins.md) |
| Exact KPI formula, lineage, filters, NULL/zero handling | [references/kpi-definitions.md](references/kpi-definitions.md) |
| Attribution family, channel normalization, cohort vs reporting date, ratio-of-sums vs mean-of-ratios | [references/business-conventions.md](references/business-conventions.md) |
| Ready-to-adapt SELECT/WITH examples | [references/sql-examples.md](references/sql-examples.md) |
| Source dates, dataset inventory, open marketing/data-platform review items | [references/sources-and-review.md](references/sources-and-review.md) |

Reference other installed skills (e.g. `martech-medallion`, `martech-doc`) only as optional pointers; this skill has no runtime dependency on them.

## Working rules

- Quote the actual SQL identifiers and the Portuguese business labels (`Pré-Copa`, `Copa`, `QR Code`, `segmento`) as they appear.
- Dataset-level ratios (e.g. `SUM(spend)/SUM(signups)`) and counter widgets that `AVG` the per-row ratio column are different numbers. Name which layer you are using.
- Precomputed columns (Payback `predicted_m2payback`, LTV `ltv_60m_npv`, tier `arpu`) are consumed, not recomputed: label their derivation as `Missing definition` unless a cited pipeline document defines it.
- Period types overlap (`weekly`/`Monthly` tier rows; daily+weekly+monthly UNION rows in Paid Media). Select one type before summing.
- Missing/NULL is a finding. Do not replace an unavailable dependency (e.g. the QR table) with an empty result.
- Counts/ratios in LTV unpivoted M0–M26 rows repeat cohort denominators — never sum across month offsets.
- Payback "All channels"/"Paid media (aggregated)" rollup rows overlap channel rows; never add them together.