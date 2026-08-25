# Skill template

Start a new skill as `.agents/skills/<your-name>/SKILL.md`. Four valid `name` constraints:

- kebab-case only (lowercase letters, digits, single hyphens — e.g. `martech-doc`)
- 6–64 characters
- no reserved words `anthropic` / `claude`
- must equal the directory name

Field whitelist — only these frontmatter fields are portable and allowed in shared skills:

```yaml
name description license compatibility metadata allowed-tools
```

A skill with any other field (e.g. `context`, `hooks`, `disable-model-invocation`, `paths`) is harness-specific and will misbehave in Codex / Cursor / OpenCode.

Description discipline:

- max 1024 characters
- what it does + when to use it + what it is NOT

Split deep detail into `.agents/skills/<name>/references/<topic>.md` — one level deep from SKILL.md.

```markdown
---
name: your-skill-name
description: "Use when <trigger> — <what it does>. Differentiator: <what it's NOT>."
---
```

(Quote the description — YAML misparses on embedded colons.)

Validate before pushing:

```bash
bash scripts/validate.sh
```
