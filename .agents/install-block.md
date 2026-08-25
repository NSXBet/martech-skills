# Install / update contract (canonical — README and docs point here)

Initial install (one-time):

```bash
git clone https://github.com/NSXBet/martech-skills.git ~/martech-skills
~/martech-skills/install.sh
# then restart your harness (claude / codex / cursor / opencode)
```

Update:

```bash
git -C ~/martech-skills pull --ff-only
~/martech-skills/install.sh
```

The installer:
- Symlinks `.agents/skills/<skill-name>` into each harness root. Harness-specific roots are wired only when the harness dir exists — nothing fabricated. The generic convention root `~/.agents/skills/` is always created (nothing owns it otherwise).
- Replaces pre-existing non-symlink dirs/locations at the target path (warns, replaces, never nests a useless link).
- Prunes **broken links that point into this repo** — never touches links owned by other repos, so it can't wipe someone else's harness config.
- Prints `commit: <sha>  dirty: <n>` — the version fingerprint between colleagues.

Pre-PR verification:

```bash
bash scripts/validate.sh
for f in install.sh scripts/*.sh; do bash -n "$f"; done
```

Skill source layout:

- `.agents/skills/<name>/SKILL.md` — portable frontmatter (see `TEMPLATE.md` for the field whitelist).
- `.agents/skills/<name>/references/<topic>.md` — deep detail, one level below SKILL.md.
