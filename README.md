# MarTech Skills

Engineering and documentation skills maintained by NSX MarTech.

## Install / update contract

The canonical contract is [`/.agents/install-block.md`](.agents/install-block.md). Quick version:

```bash
git clone https://github.com/NSXBet/martech-skills.git ~/martech-skills
~/martech-skills/install.sh
# then restart your harness
```

Update:

```bash
git -C ~/martech-skills pull --ff-only
~/martech-skills/install.sh
```

## Available skills

| Skill | What it does |
|-------|--------------|
| `martech-doc` | MarTech Technical Review & Approval — 9-section walk + anti-slop + Notion paste shape |
| `martech-medallion` | Engineering advice and readiness reviews for ingestion, Bronze/Silver/Gold, data quality, history, and Databricks governance |
| `martech-visualizations` | Sourced dashboard knowledge — schema/joins, KPI definitions, conventions, and SQL for the eight MarTech dashboards (FTD Tier, Payback, Copa, LTV, Attribution, Last Touch, Cockpit, Paid Media) |

New skills go in `.agents/skills/<kebab-case-name>/`. See `TEMPLATE.md`.

## Harness roots wired (harness-specific skipped if absent; `~/.agents` always created)

| Harness | Root |
|---|---|
| Claude Code | `~/.claude/skills/` |
| Codex CLI / generic | `~/.agents/skills/` |
| OMP (Oh My Pi) | `~/.agents/skills/` (Agents discovery; supported by inspected OMP 18.1.14) |
| Cursor | `~/.cursor/skills/` and `~/.agents/skills/` |
| OpenCode | `~/.config/opencode/skills/` |
| Gemini/Goose/Amp/Copilot | `~/.agents/skills/` (**untested**) |

## Using the engineering skill

After installing/updating and restarting your harness, ask it to use `martech-medallion`. For example:

```text
Use martech-medallion to advise on this ad-platform ingestion design.
Define Bronze/Silver/Gold responsibilities, the data contract, and validation checks.

Use martech-medallion to review these pipeline definitions and DQ reports.
Assess readiness for the specified brands, history, metrics, and consumers.
```

In Codex, invoke `$martech-medallion` with the request. Natural-language invocation keeps the examples portable across harnesses. OMP must have Agents skill discovery enabled; higher-priority copies with the same name can shadow this version.

The skill includes [layer standards](.agents/skills/martech-medallion/references/layer-standards.md), [readiness evidence formats](.agents/skills/martech-medallion/references/validation-and-readiness.md), a [contract/dictionary guide](.agents/skills/martech-medallion/references/data-contract.md), and [dated research and decisions](.agents/skills/martech-medallion/references/sources-and-decisions.md). It proposes a team baseline and checks actual evidence; Data Platform retains authority over local governance. It can work from supplied artifacts without a Databricks connection and labels unexecuted checks accordingly.

## Contributing

1. Branch, add `.agents/skills/<name>/` with `SKILL.md` (from `TEMPLATE.md`).
2. `bash scripts/validate.sh` and `for f in install.sh scripts/*.sh; do bash -n "$f"; done`.
3. Open a PR. Do not include production data, PII, credentials, tokens, connection strings, or confidential internal identifiers.
