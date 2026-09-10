# Dataset contracts and data dictionaries

Use a maintained contract per dataset, covering every in-scope layer. A contract records intended behavior; validation evidence establishes whether that behavior exists. Populate from inspected metadata and agreed definitions. Mark missing facts `Unknown — <evidence or decision needed>`; generated descriptions require owner review.

## Dataset contract

| Field | Required content |
|---|---|
| Identity | Fully qualified object, environment, object type, logical layer, purpose, version, current readiness |
| Accountability | Engineering owner, business/Data PM owner, governing group, support route |
| Scope | Sources/entities, brands/accounts, consumers and permitted uses, exclusions |
| Grain and identity | Meaning of one row, composite key, ID namespace, uniqueness and relationship semantics |
| Lineage | Upstream objects/source extracts, transformation code revision, downstream products/destinations |
| Time | Event/update/ingestion timestamps, reporting date and timezone, freshness SLA, finality/revision window |
| History | Required and available ranges by source/brand, gaps, snapshot/CDC/SCD model, backfill/replay procedure |
| Semantics | Taxonomy version, currency/rate/rounding policy, metric definitions, identity and test-user rules |
| Change contract | Compatible/incompatible changes, notification/consumer migration, deprecation, rollback |
| Quality | Named rules, scope, threshold and approving owner, action on failure, evidence/report location |
| Governance | Classification, access groups, purpose/consent where relevant, retention, deletion propagation |
| Operations | Job/pipeline, schedule, checkpoint/state location reference, alert owner, recovery and runbook |
| Acceptance | Data PM, Data Platform and consumer decisions where applicable; dates and evidence links |

Do not paste secrets, raw customer examples, real export identifiers, or credentials into contracts. Link governed evidence locations. Raw pointers need a retention/access contract of their own.

## Column dictionary

Document every exposed field, including technical audit fields. Reuse canonical definitions by reference while recording layer-specific transformations and lineage.

| Column/path | Meaning | Type / nullable | Grain/key role | Source / transformation | Unit / timezone / allowed values | Quality rule | Sensitivity |
|---|---|---|---|---|---|---|---|
| `report_date` (synthetic example) | Day as reported by the advertising account | DATE / no | Part of daily performance key | Source report date, retained as a date | Account reporting timezone, named in contract | Required; coverage by account/day | Internal |
| `spend_reporting` (synthetic example) | Spend converted under the agreed rate policy | DECIMAL with agreed precision / conditional | Measure; additive only at declared grain | Original spend × governed rate | Reporting currency; rate direction/date documented | Rate coverage, reconciliation, rounding tolerance | Internal |

For nested raw payloads, document the envelope, source schema/version reference, rescued/corrupt payload fields, and any extracted columns; do not invent a stable exhaustive schema for an unbounded source payload. Add precise dictionary entries as fields become contracted in Silver or Gold.

## Keeping dictionaries useful

- Compare the dictionary to actual schema: missing/extra columns, names, types, nullability, units, deprecated fields, and ownership. Counts alone do not establish semantic accuracy.
- Publish approved table/column descriptions through the team's catalog documentation mechanism and keep definitions with transformation changes. A generated Unity Catalog comment is documentation, not validation or certification.
- Link contracts, dictionary, lineage, DQ evidence, and runbook through the dataset entry. Track `documented columns / exposed columns` plus unresolved definitions per dataset; do not hide one undocumented dataset inside an overall average.
- During a readiness review, missing semantics for keys, metrics, eligibility, time/currency, or history block the affected use. Record other gaps explicitly; accept conditional documentation work only under a recorded scoped decision using the readiness rules.
