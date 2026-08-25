# MarTech Skills

**Internal only — not for external distribution.** Skills for the NSX MarTech team.

One `SKILL.md` format, one private repo, one bootstrap. Works in **Claude Code**, **Codex CLI**, **Cursor**, **OpenCode** — and any harness reading the `~/.agents/skills/` convention (Gemini CLI, Goose, Amp, GitHub Copilot marked **untested**).

Right now: the repo lives at `~/Desktop/martech-skills` locally; the GitHub repo gets created the first time the maintainer pushes.

## Install (one-time)

Requirements: `git` + either `gh auth login` (HTTPS) or SSH keys.

```bash
# maintainers: gh repo create NSXBet/martech-skills --private --source=~/Desktop/martech-skills --push
# colleagues:
git clone https://github.com/NSXBet/martech-skills.git ~/martech-skills   # HTTPS; or
git clone git@github.com:NSXBet/martech-skills.git ~/martech-skills       # SSH
~/martech-skills/install.sh   # or: bash ~/martech-skills/install.sh
```

The installer symlinks `.agents/skills/<name>` into every harness root and prints the commit SHA + dirty count so colleagues can spot version drift.

## Update

```bash
git -C ~/martech-skills pull --ff-only
~/martech-skills/install.sh
```

## Available skills

| Skill | What it does |
|-------|--------------|
| `martech-doc` | MarTech Technical Review & Approval — exact 8-section walk + anti-slop + Notion paste shape |

New skills go in `.agents/skills/<kebab-case-name>/SKILL.md`. See `TEMPLATE.md`.

## Harness roots wired (verified on macOS with the repo's installer)

| Harness | Root | Status |
|---|---|---|
| Claude Code | `~/.claude/skills/` | verified |
| Codex CLI | `~/.agents/skills/` | verified |
| Cursor | `~/.cursor/skills/` (and `~/.agents/skills/`) | verified |
| OpenCode | `~/.config/opencode/skills/` | verified |
| Gemini CLI / Goose / Amp / Copilot | `~/.agents/skills/` | **untested** |

## Contributing

1. Branch, add `.agents/skills/<name>/` with `SKILL.md` (start from `TEMPLATE.md`).
2. Validate: `bash scripts/validate.sh` (and `bash install.sh` to confirm install wiring; both must be clean).
3. Open a PR — no direct pushes to `main`.

If the source docx (`Doc — MarTech Technical Review & Approval.docx`) changes, update `references/source-doc.md` and the matching `SKILL.md` in the same PR, so the skill and its source stay in sync.

## Content policy (hard rule)

No production data, PII, credentials, tokens, connection strings, or internal-only identifiers in skill files. Conventions, workflows, and structure only.
