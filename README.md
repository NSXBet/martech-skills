# MarTech Skills

**Internal only — not for external distribution.**

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
| `martech-doc` | MarTech Technical Review & Approval — 8-section walk + anti-slop + Notion paste shape |

New skills go in `.agents/skills/<kebab-case-name>/`. See `TEMPLATE.md`.

## Harness roots wired (harness-specific skipped if absent; `~/.agents` always created)

| Harness | Root |
|---|---|
| Claude Code | `~/.claude/skills/` |
| Codex CLI / generic | `~/.agents/skills/` |
| Cursor | `~/.cursor/skills/` and `~/.agents/skills/` |
| OpenCode | `~/.config/opencode/skills/` |
| Gemini/Goose/Amp/Copilot | `~/.agents/skills/` (**untested**) |

## Contributing

1. Branch, add `.agents/skills/<name>/` with `SKILL.md` (from `TEMPLATE.md`).
2. `bash scripts/validate.sh` and `for f in install.sh scripts/*.sh; do bash -n "$f"; done`.
3. Open a PR. Internal only — no production data, PII, credentials, tokens, connection strings, or internal-only identifiers.
