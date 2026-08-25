---
name: martech-tech-review-notion
description: Use when writing or reviewing a MarTech Technical Review & Approval as a Notion page — proposals touching marketing data flows, attribution, payback/LTV, segments, tracking, or integrations. Enforces the exact 8-section template, a minimal Notion layout, and an anti-slop gate. Differentiator: standardized evidence floor + presentation for MarTech approvals, not generic Notion docs or PR review.
---

# MarTech Technical Review & Approval (Notion)

Purpose: one **normalised, standard** shape for every MarTech review across the team. Same 8 sections, same order, same marker language — whoever wrote it.

Two modes: **author** (walk each point with the user; output is always a paste-ready Notion markdown block) and **review** (score a filled doc; report blockers/concerns). "Notion-ready" is a rendering property of the output, not a third mode.

## The point-by-point walk (author mode)

Do NOT dump a blank template. **Walk each point, in order**, getting one of exactly three outcomes before advancing:

- **Answered** — real content from the user.
- **Confirmed marker** — the user says "Not applicable" / "Not relevant", with a reason. Never assume this for them.
- **TBD — <what's missing>** — anything not yet decided. Valid only if the user confirms it.

Ask one thing at a time, or tightly-related groups ("Section 3 surfaces 2–4 all No?"). Reuse facts already given. **Skipping the walk and filling silently is the #1 failure this skill exists to stop.**

## Anti-slop gate

1. Every sentence must answer a reviewer question. Context/history that doesn't change the decision goes.
2. No **verbatim repetition** of the same sentence across sections. Cross-references ("see § — item X") are required where the structure references another section.
3. Jargon defined at first use or removed. MarTech surface names (Payback, LTA, MMM…) are fine; project nicknames are not.
4. No filler transitions ("In today's fast-paced…", "As we all know…").
5. Tables over prose for field/value and check/result content (§1, §4 flags, §5, §6, §8). Prose only for §2's narrative (which is where "why this is needed" lives — that's the one allowed motivation).
6. A genuinely undecided field is `TBD — <what's missing>` — never padded. Genuinely-not-applying fields get `Not applicable — <reason>` — never deleted.

## The 8 sections (exact, in order, exact titles)

1. **Initiative Overview** — name, owner, tech contact, go-live date, risk level.
2. **What Are We Changing?** — current state / proposed / why (short narrative), then the **Incremental Delivery Plan** (smallest release, target, outcome, proof signal, next step).
3. **MarTech Impact** — select impacted surfaces from the canonical list + one-line summary:
   Payback v1 / v1.1–v1.4 / v2 · LTV v1 / LTV v2 · Attribution v2 (True Last Click) / Attribution v3 (Data Driven) · Conversion Funnel · Product Journey Optimization · Campaign Insights · Payback Insights · Data Foundation · MMM · Other.
4. **Data / System Flow** — current + proposed arrow lines; new integration / destination / vendor flags (Yes/No each).
5. **Data Quality Evidence** — status **Green / Amber / Red / N/A — no data flow changed** (N/A is unavailable when §4 flags any Yes) + a table of Completeness, Accuracy, Consistency → Pass/Issue + evidence (a number or validation method) + known issues. `TBD` counts as Red.
6. **What Needs MarTech Review?** — fixed 11-item list, each answered **OK / Issue / N/A** + note: use appropriateness, customer journey/experience, data used is appropriate for the purpose, DQ evidence sufficient, segmentation/personalisation logic, tracking/measurement, integration impact, consent/preference, known limitations and fallback, no additional MarTech requirements identified, Other.
7. **Supporting Evidence** — link list; only links a reviewer needs to open.
8. **MarTech Decision** — **reviewer-only. Never fill it for the human.** Fields: Decision (Approved / Approved with conditions / Changes required / Further review required / Not approved), Conditions/comments, MarTech Specialist, Date. In generated docs these render `TBD — reviewer to complete`.

## Notion presentation (defined here, once)

- `H1` title = initiative name. Subtitle line naming the section it covers.
- Sections use numbered `H2` headings (`## 2. What Are We Changing?`).
- §1 table (5 rows). §2 prose + delivery-plan table (5 rows). §3 task-list checkboxes (`- [x]`), full 14-item surface list. §4 arrow lines + flags table (3 rows). §5 status + 3-row table. §6 fixed table (11 rows). §7 link list. §8 rendered as a table with `TBD — reviewer` placeholders.
- Checkboxes are for the doc's §3 selections. Reviewer-side checklists in these files use plain bullets.
- Target length: ~1.5 screens. Overflow goes into linked pages (§7).

## Review mode

Classify findings **Blocker (B)** or **Concern (C)** per `references/checklist.md` — no numeric scores.

Pre-read verdict: **PRE-READ APPROVABLE** (zero blockers; concerns listed) or **PRE-READ BLOCKED — <blockers>**. This is the agent's screening before the human records their Section 8 value. Never write a five-enum Section 8 word.

## Structured checkpoints (both modes)

1. **Before generating** — the gate-field set only: owner, risk level, ≥1 surface selected, DQ status, consent answer (when customer-level data/segments/personalization touched). List unresolved gate fields; mark everything else `TBD — <missing>` automatically. Never guess gate fields.
2. **After generating** — confirm: "I filled these N points from context: [factual list]. Confirm these are correct?" — verifiable, no opinion questions.
3. **In review mode** — surface blockers; resolve with the user before producing the pre-read verdict.
4. **Non-interactive fallback** — when the harness can't ask (batch/CI/headless): fill everything you couldn't resolve with `TBD — <missing>` and end output with a "Unresolved gaps" list. The point-by-point walk rules otherwise apply unchanged.

## Gotchas

- The Incremental Delivery Plan (§2) is the section authors butcher most — genuinely SMALLEST release, measurable proof signal.
- Consent (§6): customer-level data, segments, or personalization → must be answered explicitly. When genuinely no customer data is touched, `N/A — <reason>` is allowed with the reason stated as a note.
- NSX data traps before finalizing §5 — test users exist in bronze/silver (and gold is contaminated); `is_test` exists but is Betnacional-only, so cross-brand needs a different exclusion; FTD cohorts are FTD-date based; attribution uses harmonized fields (`harm_source`, `harm_medium`, `channel_group`). Any FTD/GGR/NGR number without the test-user exclusion has to be flagged as a Concern on §5.

## References

- `references/template.md` — blank template, exact structure.
- `references/checklist.md` — pre-read scoring list (Blockers/Concerns).
- `references/notion-paste.md` — compliant filled example.
- `references/source-doc.md` — extract of the source document this skill encodes.
