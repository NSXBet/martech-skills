#!/usr/bin/env bash
# MarTech skills installer — symlinks every .agents/skills/<name>/ into each harness root.
# Idempotent; overwrites real dirs only after a warn-and-continue prompt.
set -uo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
SRC_DIR="$ROOT/.agents/skills"
mkdir_ok=0

targets=(
  "$HOME/.claude/skills"
  "$HOME/.agents/skills"
  "$HOME/.cursor/skills"
  "$HOME/.config/opencode/skills"
)

for target_dir in "${targets[@]}"; do
  mkdir -p "$target_dir" || { echo "mkdir failed: $target_dir" >&2; }
done

shopt -s nullglob
installed=0
errors=0
for skill_dir in "$SRC_DIR"/*/; do
  name="$(basename "$skill_dir")"
  for target_dir in "${targets[@]}"; do
    dest="$target_dir/$name"
    if [[ -e "$dest" && ! -L "$dest" ]]; then
      echo "overwriting real dir: $dest"
    fi
    if ln -sfn "$skill_dir" "$dest" 2>/dev/null; then
      :
    elif ln -sf "$skill_dir" "$dest/" 2>/dev/null; then
      :
    else
      echo "link failed: $dest" >&2
      errors=$((errors+1))
    fi
  done
  installed=$((installed+1))
  echo "installed $name"
done

# Prune broken links (point at a missing target — e.g. a skill was renamed).
for target_dir in "${targets[@]}"; do
  for entry in "$target_dir"/*; do
    if [[ -L "$entry" && ! -e "$entry" ]]; then
      rm "$entry"
    fi
  done
done

if [[ $installed -eq 0 ]]; then
  echo "no skills found in $SRC_DIR" >&2
  exit 1
fi

if [[ $errors -gt 0 ]]; then
  echo "$errors link failure(s) — partial install" >&2
  exit 1
fi

if git -C "$ROOT" rev-parse --verify HEAD >/dev/null 2>&1; then
  dirty=$(git -C "$ROOT" status --porcelain | wc -l | tr -d ' ')
  sha=$(git -C "$ROOT" rev-parse --short HEAD 2>/dev/null || echo "no-commit")
  echo "commit: $sha  dirty: $dirty"
else
  echo "commit: (no commits yet — first commit pending)"
fi
