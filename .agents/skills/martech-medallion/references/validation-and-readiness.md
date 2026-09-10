# Validation and readiness

For delivery reviews, track the requirements actually supplied: accurate labels, issue closure, validation reports, layer refactoring, dictionaries, catalog governance review, and standards enforcement where applicable. If the current review materials refer to earlier issues whose register is unavailable, request it or mark that coverage unknown. Do not invent missing historical feedback when the current materials provide it or no earlier issues are referenced.

## Review depth and scope

Record dataset versions/code revision, environment, sources, brands/accounts, period, metrics/consumer, evidence as-of date, and visibility limits.

- **Design review:** proposed behavior assessed; no runtime correctness claim.
- **Quick review:** metadata and selected samples/windows; findings establish a lower bound, not complete coverage.
- **Scoped validation:** named checks executed on explicit data/windows; state sample sizes and exclusions.
- **Deep review:** documented inventory plus risk-based historical, semantic, operational, and governance checks across the agreed scope. Report residual blind spots; the name alone gives no assurance.

A recent passing sample cannot certify older periods or other brands. A changed transformation, backfill, definition, or source extract can invalidate earlier evidence. Rerun affected checks on the new version and downstream dependencies.

## Readiness labels

Use these in the assessment, or map to the team's approved labels with the same meaning. Keep execution/delivery status separate from data readiness. These labels are this skill's proposed convention, not native Databricks certification states.

| Label | Meaning |
|---|---|
| **Not assessed** | Required evidence is absent or checks have not run; no readiness claim |
| **In progress** | Implementation or validation is underway; incomplete evidence prevents acceptance |
| **Blocked** | Known critical defect, required acceptance refusal/missing decision, or material quality/history/structural/eligibility gap prevents the intended use |
| **Ready with conditions** | Required checks for an explicitly limited use passed; only noncritical, bounded conditions remain with named owner, due date, impact, and recorded authorized acceptance |
| **Ready** | Required checks for the stated version, period, brands and use passed; known review issues closed with evidence; applicable dictionary, governance, operational and consumer acceptance complete |

If nothing is known to fail but runtime evidence is missing, use Not assessed/In progress, not Ready. A known material failure takes precedence over unknown checks and makes the affected use Blocked. Suggest Ready with conditions only where acceptance is actually recorded; otherwise state what decision is pending. Known critical correctness, eligibility/privacy, required-history, or mandatory governance failures are not conditional readiness.

One dataset can have different readiness for reporting and activation. A blocked input blocks only outputs that depend on the failing property/population; prove isolation before allowing a narrower release. Never silently redefine the release scope to achieve a positive label.

## Evidence package

### 1. Inventory / layer review

| Dataset and version | Declared / actual layer | Row grain | Owner | Required / observed history | Checks executed / planned | Layer fit and readiness | Evidence / gaps |
|---|---|---|---|---|---|---|---|

Include every in-scope table/view and material upstream dependency. Classify migration needs per object: retain, document, repair, move/refactor, consolidate, or deprecate. Do not infer required transformations solely from names.

### 2. Finding and feedback closure register

| ID / feedback item | Dataset / consumer | Severity and impact | Observed or reported evidence | Fix / decision | Owner | Closure test and evidence | State |
|---|---|---|---|---|---|---|---|

States: Open, Implemented—not verified, Verified closed, or Accepted noncritical exception. An exception does not erase the finding; record approver, scope, reason, compensating control, expiry, and follow-up. Missing owner is a gap, not a name to invent.

Use **Blocker** for conditions that prevent the intended use, **Concern** for bounded issues needing resolution/acceptance, and **Improvement** for optional work. Explain severity using the affected outcome. Report incomplete review coverage separately from observed defects. A proposed fix, a commit, or a clean job is not closure: rerun the specified test, include historical repair and affected downstream checks, and link the result.

Keep one row for each supplied feedback requirement. Common categories are status correction, previously raised issues, DQ reports, per-table architecture review/refactoring, dictionaries, Data Platform catalog review, and standards/enforcement. These categories help map the current request; they do not establish that every engagement has unresolved work in each category. Link detailed findings without duplicating their text.

### 3. Data quality report

| Rule ID / invariant | Dataset/version and population/window | Method / query artifact | Threshold and basis | Observed result, numerator / denominator | Result | Run ID / as-of / evidence | Owner / action |
|---|---|---|---|---|---|---|---|

Rule results: **Pass**, **Fail**, **Not run**, **Inconclusive**, or **Not applicable — reason**. Report query errors, permission gaps, empty denominators, missing baselines, or missing metrics as Inconclusive/Not run as appropriate, not Pass. Preserve the actual query/code reference, parameters, input versions/as-of state, measured counts, and execution time so someone else can reproduce the result. Protect sensitive samples and link access-controlled evidence.

For whole-scope readiness, show completeness of the checks as well as their results: datasets assessed/in scope, periods tested/required, brands/accounts covered/required, and rules executed/required. State omissions even when all executed checks pass. Do not manufacture a composite quality score.

## Minimum check families (select applicable rules)

| Family | Required reasoning and evidence |
|---|---|
| Extraction | Expected versus completed requests/pages/windows/accounts; counts at extraction and landing; zero-activity proof, partial responses and failures |
| Historical completeness | Calendar × source × account/brand coverage for the required interval; missing and partial days, start/end, gaps, source availability and backfill ledger |
| Schema and semantic correctness | Actual types/nullability/schema vs contract, required fields, rescued/corrupt records, units/date semantics, schema change impact |
| Keys and relationships | Null key components, duplicate groups and excess rows at the full grain, orphan rates, namespace collisions, deterministic deduplication and valid SCD intervals |
| Taxonomy / normalization | Unmapped counts/rates and distribution by source/brand/date, rate coverage and conversion lineage, reporting timezone agreement |
| Data disposition | Accepted, quarantined, deliberately filtered, duplicate-delivery/business duplicate handling; explain transformations that change grain |
| Metric reconciliation | Counts and measures at aligned source/account/date/grain, currency/timezone and as-of; account for revisions, attribution windows and exclusions |
| MarTech semantics | Cross-brand test exclusions, cohort anchors, identity match quality, attribution/metric definitions, join fanout and measure conservation |
| Recovery / change | Duplicate delivery, same-window replay, late update, source deletion, schema drift, backfill and recovery; compare expected stable keys/counts/measures |
| Consumer / operations | Freshness and finality, failure alerts/ownership, representative performance/cost, destination eligibility/schema/acknowledgements and UAT |
| Governance / documentation | Approved namespace/groups/grants, classification/retention/lineage, contract and column dictionary coverage, applicable recorded acceptance |

Validate both agreed full-history aggregates and deeper risk-based slices (onboarding dates, outages, late corrections, schema changes, brand boundaries, daylight-saving transitions, and backfills). Full-history min/max dates do not detect internal holes, and random row samples do not validate all periods. Source limitations become explicit contract gaps or accepted scope decisions; downstream reconstruction must not invent missing facts.

## Reconciliation rules

Name the source of truth, extract/as-of time, exact scope, record/metric grain, units, reporting timezone, attribution/reporting window, and revision lag. Compare equivalent states. Reconcile each source/account/brand/date before roll-up to prevent positive and negative discrepancies cancelling.

Report `absolute_difference = abs(actual - expected)`. For a nonzero expected value, use `relative_difference = absolute_difference / abs(expected)` and state whether displayed as a fraction or percent. If expected is zero, report the absolute difference and apply an explicitly agreed zero-baseline rule. If either value or the reference population is unavailable, return Inconclusive. An absent row is not an observed zero.

Tolerance requires an owner and rationale; it can depend on metric, volume, maturity window and source behavior. The snapshot's ±1% is illustrative, not a default. Totals alone do not prove dimension-level correctness, row coverage, or valid population membership.

## Completion gate

Before calling the requested scope Ready, establish:

1. Labels reflect evidence and limitations; all supplied issues are accounted for, with closure tests passed and historical/downstream impact resolved.
2. Layer review covers every in-scope object; required refactors are validated against the consumer contract.
3. Required DQ checks have reproducible passing results for the intended history and population; untested areas are declared.
4. Contracts and dictionaries cover the datasets and current schemas; key semantic gaps are resolved.
5. Applicable catalog governance changes/review have recorded acceptance from Data Platform or the designated authority under approved local policy; scoped exceptions are explicit. Reuse existing acceptance that covers the current scope/version. Seek a new decision only for changed or unresolved scope that requires it. Do not invent approval or treat the skill as the approving body.
6. Standards have actual enforcement points, owners, failure actions, and run evidence; recovery/monitoring and consumer acceptance are in place.

If only a quick review was done, say that readiness for unexamined scope remains unestablished and list the next checks. Corrected known defects cannot justify claiming a thorough review occurred.
