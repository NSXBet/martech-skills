# Layer standards

These are proposed MarTech engineering controls informed by the supplied snapshot and the official sources in `sources-and-decisions.md`. Validate them against approved local contracts. Databricks' medallion pattern describes logical responsibilities; it does not mandate a particular catalog layout or three physical copies of every dataset.

## Responsibility and exit evidence

| Stage | Responsibility | Evidence before accepting the stage |
|---|---|---|
| Source / ingestion | Define extraction coverage and delivery semantics | Source agreement, expected entities/accounts/history, pagination and cursor handling, freshness and replay results |
| Bronze | Preserve source observations and provenance for audit/replay | Raw payload fidelity, ingestion manifest, coverage, duplicate-delivery handling, durable history and tested recovery |
| Silver | Produce reusable, typed, validated records at a declared grain | Schema/key checks, versioned conformance rules, reconciliation, late-data handling, invalid-record accounting |
| Gold | Serve a specified business/activation contract | Approved metric definitions, join and identity checks, source-to-output reconciliation, destination/UAT evidence |

Suggested ownership from the snapshot: Engineering for Bronze; Engineering and Data PM for Silver; Data PM, Analytics Engineering, and MarTech specialists for Gold. Data Platform owns catalog policy. Confirm actual groups and accountable owners; role suggestions are not sign-offs.

## Source and Bronze

- Specify sources, entities, accounts/brands, API version, requested fields/breakdowns, granularity, extraction interval, reporting timezone, earliest required date, source retention limits, and permissions. Distinguish event occurrence, source update, extraction, and ingestion timestamps.
- Handle pagination, rate limits, token expiry, timeouts, partial responses, retries/backoff, cursor advancement, and overlap windows. Advance a cursor only after the relevant data is durably captured. A `200` response, nonempty payload, or green run does not demonstrate full extraction.
- Reconcile expected deliveries to a manifest by source/account and time interval: requested versus completed windows/pages, received records, empty responses, failures, retry state, and checkpoint. Prove empty activity where expected instead of treating all empty responses as either success or failure.
- Preserve source values and structure with minimal technical parsing. Carry raw content or a durable governed pointer when typed extraction cannot preserve fidelity. Currency conversion, taxonomy replacement, identity merging, business filtering, and aggregate-only storage do not satisfy this baseline's raw contract.
- Preserve invalid/unparseable input in a restricted raw or quarantine path with provenance and error details. Account for it downstream; a successful pipeline that silently loses malformed input fails completeness.
- Require ingestion time in UTC, source system/entity, brand/account context, batch/run or delivery ID, source record identity where supplied, and source update/event time where available. Record file path for file input or request/window/cursor metadata for APIs; `_raw_file_name` is not meaningful for every connector. Avoid logging credentials or sensitive request parameters.
- Separate **delivery duplicates** from **source history**. Retries must not multiply an already persisted delivery; genuine repeat events and later source revisions must remain recoverable. Define an immutable delivery key or equivalent checkpoint/manifest design. Do not deduplicate raw business events by an unproven business key.
- Prefer append/versioned observations. A latest-snapshot table is acceptable as a projection when retained immutable snapshots or a change archive support the agreed replay/history contract. An overwrite-only snapshot plus assumed indefinite time travel is insufficient. Test rerunning the same interval and processing a changed source revision.
- Document raw retention, storage protection, and erasure requirements together. Raw preservation is within the approved retention period, not a mandate to retain personal data forever. Verify recovery before destructive maintenance; a checkpoint is progress state, not a source-data backup.

## Silver

- Declare what one row represents before choosing a key. For ad performance this may include source, account, brand, campaign, report date, and every requested breakdown. Campaign names are mutable labels; IDs may be scoped to accounts. `campaign_id + date` is an example to assess, never a default universal key.
- Use explicit, versioned schemas, casts, nullability, units, and nested-data handling. Preserve raw IDs where needed for joins. Report parse failures separately from legitimate source nulls; do not coerce unknown values to zero to make checks green. Stage incompatible schema changes and assess downstream consumers before promotion.
- Define deterministic deduplication and update precedence: event/delivery identity, source version or update sequence, tie handling, and delete semantics. Test uniqueness and orphan relationships with data; informational PK/FK declarations are insufficient.
- Keep a validated record-level representation that supports replay, drill-down, and reconciliation. Shared joins/enrichment and justified intermediate aggregates may be Silver. A single flattened cross-channel table is optional; related facts/dimensions with common contracts can be more appropriate. Do not discard source detail simply to force one universal schema.
- Own taxonomy centrally in Silver and consume its governed output in Gold. Use effective dates/version, original values, mapping precedence, accountable owner, and a repair/backfill policy. Report unmatched counts and rates by source/brand/date. `Unassigned` can preserve records; it is not evidence that mappings are complete. Resolve its treatment per use case and agreed threshold.
- Normalize event instants to UTC while preserving original timezone/offset when needed. Keep platform-local reporting dates distinct from UTC dates; conversion must not silently shift daily totals. Record business timezone and daylight-saving behavior.
- Retain original amount/currency alongside normalized values. Define rate source, currency pair/direction, effective date, missing-rate behavior, precision/rounding, and restatement policy. Use appropriate fixed-precision arithmetic for money. Source/platform reporting currencies must be understood before comparison.
- Apply null, domain, range, cardinality, and referential checks where semantically valid. `clicks <= impressions`, nonnegative revenue/spend, and mandatory identifiers require source-specific definitions: refunds, adjustments, alternate click metrics, and anonymous events can be legitimate. Document accepted exceptions with their impact.
- Specify late-arrival/update windows, watermark behavior, expired-window handling, backfill procedure, deletes, and historical model (current state or SCD history). Watermarks can bound processing but do not establish historical completeness. Validate the historical interval independently from recent streaming success.
- Account for each input disposition: accepted, quarantined, deduplicated, or deliberately excluded. Explain row expansion/reduction from flattening, joins, and aggregation; a naive row-count equality is not valid across changed grains.

## Gold

- Define consumers, row grain, dimensions, metrics, refresh/finality, allowed use, and version. Gold may contain aggregates, dimensional facts, or customer-level activation records; aggregation is not mandatory for every output. It must inherit the relevant Silver controls.
- Record business definitions for attribution, CAC, ROAS, LTV, FTD, GGR/NGR, or other requested metrics: eligible population, windows, event/date anchor, numerator/denominator, currency, refunds/adjustments, and model version. Do not add metrics the consumer did not request.
- Prove join cardinality before joining spend facts to events or identities. Reconcile measures before and after the join by business key; multiplying a campaign's spend across customer events can inflate totals while row-level checks pass. Specify attribution weights and verify their conservation where applicable.
- Reuse harmonized channel fields; avoid a competing taxonomy in Gold or dashboards. Document consumer-specific groupings that intentionally derive from the governed taxonomy.
- Validate identity namespaces, match confidence, merge/split rules, and historical behavior. Shared identifiers or matching hashes do not establish consent or justify merging people across brands.
- Confirm test-user exclusion separately for every brand and dataset. The existing documentation skill warns that an `is_test` field had brand-limited coverage; inspect current semantics before reuse. Preserve/flag legitimate source records upstream and apply the correct business eligibility in Gold. Missing test flags do not mean a customer is real.
- For FTD cohorts, verify the approved first-deposit date anchor and qualifying deposit definition. For attribution, verify approved harmonized fields (such as `harm_source`, `harm_medium`, `channel_group`) and their current lineage instead of trusting names.
- For activation, validate consent/preferences, suppression, purpose, destination schema/identity format, freshness/TTL, deletions, rejected rows, retry idempotency, and recipient eligibility. Test payloads and destination acknowledgements using approved test data. Hashing an email is not an authorization to export it or proof of anonymity.
- Reconcile outputs to upstream facts and agreed platform/source totals using aligned time, currency, scope, and as-of state. Include unmatched records and excluded populations. Validate both audience membership and aggregate metrics with the consumer.
- Benchmark representative query/activation workloads against agreed latency, freshness, and cost targets. Choose physical layout from workload evidence and platform support. Do not prescribe indexes/partitions for every table or a universal dashboard latency target.

## Exceptions

A view can implement valid layer responsibilities; separate materialization alone adds no assurance. For a bypass or shared multi-stage transformation, identify where each required control executes, replay evidence, ownership, consumers, and the approved exception. A direct raw view relabeled Gold without these controls is a layer-fit issue. Never rename a table to close an architectural finding without fixing or demonstrating its responsibilities.
