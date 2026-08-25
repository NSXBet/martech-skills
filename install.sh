#!/usr/bin/env bash
# MarTech skills installer — symlinks every .agents/skills/<name>/ into each harness root
# that exists on this machine (skip-if-absent — no fabrication of harness-specific roots).
# ~/.agents (generic cross-harness convention) is always created — nothing owns it otherwise.
# Idempotent. Prints commit SHA + dirty count for version-drift spotting.
set -uo pipefail

export LANG=C LC_ALL=C
ROOT="$(cd "$(dirname "$0")" && pwd)"
SRC_DIR="$ROOT/.agents/skills"

TARGETS=("$HOME/.agents/skills")
declare -a CANDIDATES=(
  "$HOME/.claude/skills"
  "$HOME/.cursor/skills"
  "$HOME/.config/opencode/skills"
)
for cand in "${CANDIDATES[@]}"; do
  parent="${cand%/*}"
  if [[ -d "$parent" ]]; then
    TARGETS+=("$cand")
  else
    echo "skip: $cand (harness dir '$parent' not present)"
  fi
done

shopt -s nullglob
installed=0
errors=0

for skill_dir in "$SRC_DIR"/*/; do
  name="$(basename "$skill_dir")"
  for target_dir in "${TARGETS[@]}"; do
    mkdir -p "$target_dir" 2>/dev/null || { echo "mkdir failed: $target_dir" >&2; errors=$((errors+1)); continue; }
    dest="$target_dir/$name"
    if [[ -e "$dest" && ! -L "$dest" ]]; then
      echo "replacing non-symlink: $dest"
      if ! rm -rf "$dest" 2>/dev/null; then
        echo "remove failed: $dest" >&2
        errors=$((errors+1))
        continue
      fi
    fi
    if ! ln -sfn "$skill_dir" "$dest" 2>/dev/null; then
      echo "link failed: $dest" >&2
      errors=$((errors+1))
      continue
    fi
  done
  installed=$((installed+1))
  echo "installed $name"
done

# Prune broken links only when they resolve INTO this repo (never other repos' links).
for target_dir in "${TARGETS[@]}"; do
  for entry in "$target_dir"/*; do
    if [[ -L "$entry" && ! -e "$entry" ]]; then
      tgt="$(readlink "$entry" 2>/dev/null || true)"
      if [[ "$tgt" == "$SRC_DIR"/* ]]; then
        rm "$entry"
        echo "pruned broken link (this repo): $entry"
      fi
    fi
  done
done

if (( installed == 0 && errors == 0 )); then
  echo "no skills found in $SRC_DIR" >&2
  exit 1
fi
if (( errors > 0 )); then
  echo "$errors failure(s) — partial install" >&2
  exit 1
fi

if git -C "$ROOT" rev-parse --verify HEAD >/dev/null 2>&1; then
  dirty="$(git -C "$ROOT" status --porcelain | wc -l | tr -d ' ')"
  sha="$(git -C "$ROOT" rev-parse --short HEAD)"
  echo "commit: $sha  dirty: $dirty"
else
  echo "commit: (no commits yet — first commit pending)"
fi
