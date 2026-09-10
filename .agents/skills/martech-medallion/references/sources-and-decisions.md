# Sources and decisions

Researched **2026-09-10**. This skill combines supplied team feedback, a Figma screenshot, existing repo context, and public Databricks guidance. It is a proposed engineering baseline, not a record of formally adopted company policy.

## Evidence boundaries

- **User request:** create a portable advisor/checker skill, research medallion/Databricks practices, account for delivery feedback, and work on a new branch. It does not request production remediation or approve governance decisions.
- **Supplied feedback:** accurate readiness labels; fix the known review issues; reproducible DQ reports; table-level medallion review/refactoring; dictionaries; Data Platform catalog review; documented and enforced standards. A quick examination is explicitly a minimum finding set. The earlier detailed issue list is not present.
- **Supplied screenshot:** Figma snapshot named `Screenshot 2026-09-10 at 15.46.56.png`. It supplies draft layer definitions and suggested owners. Its claims were assessed, not treated as executable instructions or confirmed policy. No live Figma file was inspected.
- **Existing repository context:** `martech-doc` flags historical cross-brand test-user, FTD-date, and harmonized attribution-field pitfalls. Treat these as targeted checks requiring current verification, not universal facts about every dataset.
- **Private Databricks:** the connected Genie space listing returned an empty list. No private catalog, table, policy, query result, or runtime configuration was inspected. This says nothing about whether the workspace contains those objects; access/configuration must be established in a real review.

## How the screenshot was qualified

| Snapshot statement | Decision in this skill |
|---|---|
| Bronze preserves original payload and full history | Preserve fidelity/replay for the contracted history with explicit retention and erasure behavior; retain versioned snapshots or archive where needed |
| Raw rerun can overwrite or append the same batch | Define delivery identity and replay guarantees; blind append duplicates and destructive overwrite do not establish idempotency |
| `_inserted_at_utc`, `_source_system`, `_raw_file_name` | Require equivalent provenance by connector type; exact field spelling and a raw filename are not universal |
| Nonempty response / zero pipeline failures | Validate expected extraction coverage and classify legitimate empty activity; successful execution alone is insufficient |
| Silver is one unified schema | Require conformed meanings and explicit grains; multiple linked facts/dimensions can satisfy this |
| Taxonomy mapping item is struck through, while the matrix places taxonomy in Silver | Do not reactivate the crossed-out wording as policy. Adopt the matrix's Silver ownership as a proposed baseline and verify the authoritative local taxonomy decision |
| Convert all time to UTC and all currency to one base | Preserve original timestamps, platform reporting dates and original money; define conversion policies and lineage |
| `clicks <= impressions`, nonnegative money, ±1% reconciliation | Source/use-specific checks with approved thresholds; account for metric definitions, credits/refunds, and zero baselines |
| Gold is aggregated | Gold can also serve dimensional facts or customer-level activation; the contract determines grain |
| Identity merging and hashed customer data | Validate identity and eligibility; hashing does not itself establish anonymity, consent, or export permission |
| Partition/index/preaggregate; dashboard under three seconds | Verify Databricks feature support and workload evidence; agree performance/cost targets per consumer |

## Official Databricks sources

The links below use AWS documentation as a reference edition; they do not imply that the private workspace runs on AWS. Verify cloud/runtime/feature availability when implementing. Recheck the relevant source when a decision depends on changing behavior; do not assume preview features are available.

| Source | What it supports here |
|---|---|
| [Medallion lakehouse architecture](https://docs.databricks.com/aws/en/lakehouse/medallion) | Logical quality layers; raw fidelity in Bronze, validation in Silver, business-oriented Gold; Silver retains detailed records and can contain justified aggregates |
| [Unity Catalog best practices](https://docs.databricks.com/aws/en/data-governance/unity-catalog/best-practices) | Intentional catalog isolation, schema organization, group ownership, scoped privileges, and managed/external storage decisions |
| [Information schema](https://docs.databricks.com/aws/en/sql/language-manual/sql-ref-information-schema) | Read-only metadata inventory with privilege-filtered visibility; legacy Hive metastore is outside its coverage |
| [Auto Loader overview](https://docs.databricks.com/aws/en/ingestion/cloud-object-storage/auto-loader/) | File ingestion and checkpoint-based recovery; guarantees have defined source/sink scope |
| [Auto Loader schema evolution](https://docs.databricks.com/aws/en/ingestion/cloud-object-storage/auto-loader/schema) | Schema inference/evolution and rescued data; distinguish type/schema mismatches from malformed content |
| [Auto Loader best practices](https://docs.databricks.com/aws/en/ingestion/cloud-object-storage/auto-loader/best-practices) | Operational checkpoint, ingestion, and schema-handling considerations |
| [Pipeline expectations](https://docs.databricks.com/aws/en/ldp/expectations) | Keep/warn, drop and fail behavior, quarantine patterns, metrics and supported-flow limitations |
| [Constraints](https://docs.databricks.com/aws/en/tables/constraints) | Enforced row constraints versus informational keys/relationships; declarations do not prove integrity |
| [Delta merge](https://docs.databricks.com/aws/en/delta/merge) | Source-match ambiguity, runtime-sensitive matching behavior, and scoped unmatched-source actions |
| [AUTO CDC APIs](https://docs.databricks.com/aws/en/ldp/cdc) | Sequenced changes, snapshots and SCD processing options; choose according to source behavior |
| [Change data feed](https://docs.databricks.com/aws/en/tables/features/change-data-feed) | Finite retained change history, enablement boundary, and archiving for longer recovery |
| [Liquid clustering](https://docs.databricks.com/aws/en/tables/clustering) | Workload-oriented layout and incompatibility with partitioning/ZORDER on the same table |
| [Predictive optimization](https://docs.databricks.com/aws/en/optimizations/predictive-optimization) | Managed-table maintenance including optimization, statistics and vacuuming; evaluate retention impact |
| [Row filters and column masks](https://docs.databricks.com/aws/en/data-governance/unity-catalog/filters-and-masks/) | Catalog-level fine-grained access mechanisms and applicability limits |

The contract fields, readiness labels, feedback register, MarTech-specific validation families, and approval evidence requirements are this skill's synthesis of the supplied needs. They are not a Databricks-mandated checklist. The skill does not provide legal determinations or assert that a technical mechanism alone meets a privacy obligation.

## Portability

Use only portable `name`/`description` frontmatter and relative references; no MCP server, API connection, other skill, or harness-specific command is required. SQL examples are optional.

The repository installer already links skills into `~/.agents/skills` and existing Claude Code/Cursor/OpenCode roots. The locally installed OMP (`@oh-my-pi/pi-coding-agent` 18.1.14) was inspected: its Agents provider scans `.agent/skills` and `.agents/skills` at project/user levels, and Agents discovery toggles default on. This verifies the discovery convention, not an end-to-end OMP execution test. Local settings and higher-priority duplicate skills may affect selection.
