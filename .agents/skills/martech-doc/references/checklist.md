# Pre-read scoring (define ONCE — the only scoring interpretation)

Each check is Blocker (B) or Concern (C). Verdict:
- `PRE-READ APPROVABLE` — zero Blockers; Concerns listed for awareness.
- `PRE-READ BLOCKED — <blocked sections + lines>`.

The human's Section 8 word (Approved / Approved with conditions / Changes required / Further review required / Not approved) is final. The pre-read feeds it; never substitutes for it.

## Structure
- B: all 9 sections present, exact order, exact titles
- B: no section omitted; not-applying fields explicitly marked

## Anti-slop gate (define ONCE)
- B: filler transitions ("In today's fast-paced…", "As we all know…")
- B: verbatim repetition across sections (same sentence repeated; cross-references are fine)
- B: motivations that belong in §2 leaked elsewhere (e.g. "Conclusion")
- C: jargon undefined at first use (project nicknames are never fine)

## Section 1 — Initiative Overview
- B: any of owner, tech contact, go-live date, risk level missing (explicit markers count)
- C: risk High without a note

## Section 2 — What Are We Changing?
- B: current / proposed / why all blank
- B: Delivery Plan — smallest release missing
- C: proof signal unmeasurable ("we'll monitor")
- B: §2 uses formulas, code, field/system names, or analogies
- C: §2 answers are one-liners lacking detail (current / proposed / why each under ~1 sentence)
- C: §2 fails the outsider test — a non-specialist wouldn't get it on first read

## Section 3 — Supporting Evidence
- C: docs referenced earlier but not linked
- C: links that are unreviewable (broken, private-wiki dead)

## Section 4 — MarTech Impact
- B: ≥1 surface must be selected
- C: "Other" without a short name
- B: impact summary blank

## Section 5 — Data / System Flow
- C: any flag Yes without a linked technical design in §3
- C: flags missing / ambiguous wording

## Section 6 — Data Quality Evidence
- B: status missing (`TBD` counts as Red)
- B: Red without mitigation
- B: each of Completeness / Accuracy / Consistency needs Pass/Issue + evidence
- C: for NSX data — the test-user/`is_test` exclusion not addressed
- C: N/A status claimed while any §5 flag is Yes
- C: Amber without reason

## Section 7 — What Needs MarTech Review?
- B: any of the 11 fixed items skipped
- B: consent/preference blank when customer-level data/segments/personalization is touched
- C: item marked N/A without a reason note
- B: answer vocabulary not on list (OK / Issue / N/A)
- C: generically "sounds fine" answers without a note

## Section 8 — MarTech Decision
- B: generated doc contains values for this section (must be `TBD — reviewer to complete`)
- C: pre-read verdict substituting for the human's five-enum word

## Section 9 — Delivery Outcome Confirmation
- C: §9 pre-filled at submission (it belongs to the business owner post-delivery)

## Checklist usage
The unchecked boxes in this file are reviewer-side markers, NOT the doc's §4/§7 on-off syntax. Do not paste them into a doc; do not read uncomputed checklists as unmet blockers.
