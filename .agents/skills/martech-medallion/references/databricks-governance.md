# Databricks governance and enforcement

Use this for Databricks designs and reviews. Check cloud, Unity Catalog availability, runtime/SQL warehouse version, table format, pipeline engine, and permissions before choosing features. Public documentation describes capabilities, not the workspace's approved policy. Source links and research date are in `sources-and-decisions.md`.

## Govern the structure before adding projects

1. Inventory the relevant catalogs, schemas, tables/views, owners, grants, lineage, pipeline definitions, and consumers. Use metadata first and bounded aggregate queries next. `information_schema` is privilege-filtered and excludes `hive_metastore`; an empty result does not prove an object or issue is absent. Record inaccessible and legacy areas.
2. Find the Data Platform-approved namespace, environment boundaries, provisioning process, ownership groups, access model, classification/retention policies, and exception register. If missing, propose a decision record and name the missing authority; do not claim the design is already company policy.
3. Use catalogs for intentional isolation/access boundaries, often environment/domain, and schemas for organization. A proposed example is `<domain>_<environment>.<layer>.<dataset>`; another can use separate catalogs when layer access boundaries justify it. These are alternatives, not Databricks-mandated names. Avoid creating a permanent catalog/schema per campaign without an ownership, access, and lifecycle rationale.
4. Use group ownership for production objects and narrowly scoped service principals for production writes. Review inherited privileges as well as direct grants. Distinguish permission to discover metadata from permission to read data. Restrict production object creation through the approved deployment/provisioning path; give sandboxes explicit owners and expiry.
5. Keep dataset definitions, classifications, consumers, retention, lineage, and readiness discoverable. Tags and comments describe governance; verify the permissions, policy, and pipeline controls that enforce it.
6. Choose managed versus external storage from ownership, external access, disaster recovery, and raw-retention requirements. Databricks generally recommends managed tables; that does not make every raw archive managed by default. Document lifecycle behavior when a table is dropped and prevent storage access from bypassing catalog controls.

## Review the actual ingestion and quality mechanisms

| Mechanism | Guidance and evidence needed |
|---|---|
| Auto Loader | Appropriate for file arrivals in object storage; not a general SaaS API client. Inspect durable checkpoint and schema locations, rescue/corrupt-record paths, schema evolution/restart policy, and observability. File-processing guarantees do not prove the upstream API extraction was complete. |
| Schema evolution | Classify additions, renames, removals, type changes, and semantic changes. Review reader compatibility and explicit promotion to Silver/Gold. Do not enable broad automatic evolution merely to make failing writes succeed. |
| Delta constraints | Use supported `NOT NULL`/`CHECK` constraints for eligible row rules. PK/FK and informational uniqueness declarations do not enforce integrity; test nulls, duplicates and orphan references separately. Do not rely on optimizer assumptions without proving them. |
| Lakeflow Spark Declarative Pipelines expectations | Choose keep/warn, drop, fail, or a quarantine design per rule. Keep/warn can produce successful output containing invalid rows. Inspect actual metrics/failures and publication behavior; row expectations do not cover cross-table reconciliation or missing deliveries. |
| Expectation failure evidence | Fail actions do not record the same pass/fail metrics as warn/drop. Capture failure artifacts and use an appropriate diagnostic/quarantine path; missing metrics are not zero violations. Verify object/flow support, including limitations for snapshot CDC. |
| CDC and snapshots | Verify source keys, sequencing, ties, late events, delete/tombstone semantics, and SCD requirements. Consider supported AUTO CDC APIs where appropriate. Partial snapshots must not be mistaken for authoritative deletions. |
| `MERGE` | Define deterministic source precedence and unique merge matches. Duplicate-match behavior varies by runtime. A merge is not a substitute for grain validation or a replay test; inspect broad `WHEN NOT MATCHED BY SOURCE` deletes carefully. |
| Change data feed and time travel | Useful for incremental processing/recovery within their retention. CDF is not a permanent history archive and does not reconstruct changes from before enablement. Verify source/archive retention and replay horizon before relying on recovery. |
| Layout and maintenance | Consider supported liquid clustering and predictive optimization using workload evidence. Liquid clustering replaces partitioning/ZORDER for that table; do not combine them blindly. Check cost and retention implications of automatic maintenance, including `VACUUM`. |
| Access, filters, masks | Protect sensitive fields at all layers, not only Gold. Check supported runtime/compute/features and test as consumer principals. A hash, tag, row filter, or mask alone does not prove that exports and downstream copies follow the approved use. |

## Turn standards into enforceable controls

The skill checks and advises. Implement enforcement in the team's deployment, orchestration, and catalog mechanisms as part of an authorized engineering task.

| Point | Enforce / verify | Failure behavior |
|---|---|---|
| Design / PR | Contract and dictionary changes, grain/layer fit, owner, namespace policy, lineage, sensitive data treatment, tests for changed semantics | Request changes with a specific missing decision or artifact |
| Deployment | Approved namespace and service identity, constrained permissions, versioned transformations, applicable migrations | Prevent unapproved production structure or privileges |
| Each pipeline run | Extraction coverage/freshness, schema changes, rule metrics, rejected data accounting, agreed metric checks | Alert owner; quarantine/fail/block publication according to rule severity |
| Promotion / consumer release | Required history, replay/backfill, reconciliation, issue closure, dictionary coverage, platform and consumer acceptance | Withhold readiness for the failing scope; retain or mark prior validated output with its as-of date |
| Scheduled operations | Coverage drift, new columns/unmapped values, duplicate/orphan growth, cost/freshness, retention/recovery and exception expiry | Open actionable remediation and reassess affected readiness |

Each rule needs an owner, execution location, frequency, threshold, evidence retention, and failure action. A checklist item or test file is not enforcement until the path actually runs and failures reach the responsible person. Separate data-dependent readiness gates from the job's execution status.

## Refactor structural debt safely

Return a per-object migration register: current object/responsibility, intended layer/namespace, consumer impact, owner, action, evidence, and status. Identify canonical datasets and redundant/project-specific copies. Prioritize incorrect business output, irrecoverable raw loss, exposure, and shared upstream defects.

Sequence the work: agree target structure → build/repair canonical data and contracts → replay/backfill → validate old/new differences at matching grain and dates → consumer compatibility/UAT → controlled cutover → monitored deprecation. Record rollback and recovery boundaries, grants/comments/lineage migration, and known unrecoverable history. Do not treat table renames as semantic remediation or drop old objects before the authorized migration and retention conditions are met.
