#!/usr/bin/env bash
# Validate every .agents/skills/<name>/SKILL.md in this repo — anchored to the repo root (via $0).
# PORTABLE frontmatter whitelist + derived-rule checks (kebab name, reserved words, refs).
set -uo pipefail
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"
shopt -s nullglob

ALLOWED_FIELDS="name description license compatibility metadata allowed-tools"
RESERVED_WORDS="anthropic claude"

fail=0
DIRS=(.agents/skills/*/)
if (( ${#DIRS[@]} == 0 )); then
  echo "FAIL — no skill directories under $REPO_ROOT/.agents/skills" >&2
  exit 1
fi

for d in "${DIRS[@]}"; do
  name="$(basename "$d")"
  f="$d/SKILL.md"
  if [[ ! -f "$f" ]]; then
    echo "MISSING: $f" >&2
    fail=1
    continue
  fi

  fm="$(awk '/^---$/{c++; if (c==2) exit} c>=1' "$f")"
  name_val="$(printf '%s\n' "$fm" | sed -n 's/^[[:space:]]*name:[[:space:]]*//p' | tr -d "'\"" | head -1)"
  desc_len=$(printf '%s\n' "$fm" | sed -n 's/^[[:space:]]*description:[[:space:]]*//p' | head -1 | wc -c | tr -d ' ')

  [[ "$name_val" != "$name" ]] && { echo "BADNAME: $f — name '$name_val' != dir '$name'"; fail=1; }
  (( desc_len < 2 )) && { echo "NODESC: $f"; fail=1; }
  (( ${#name_val} < 6 || ${#name_val} > 64 )) && { echo "BADLENGTH: $f — ${#name_val} chars"; fail=1; }
  [[ ! "$name_val" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]] && { echo "BADCASE: $f — not kebab-case"; fail=1; }
  for word in $RESERVED_WORDS; do
    [[ "$name_val" == *"$word"* ]] && { echo "BANNEDNAME: $f — '$word'"; fail=1; }
  done

  # Field whitelist — top-level keys only (sub-keys of metadata: are allowed).
  while IFS= read -r key; do
    key="${key%%:*}"
    keeponly="$(printf '%s' "$key" | sed 's/^[[:space:]]*//')"
    ok=0
    for allowed in $ALLOWED_FIELDS; do
      [[ "$keeponly" == "$allowed" ]] && { ok=1; break; }
    done
    (( ok == 0 )) && [[ "$key" =~ ^[[:space:]]*[A-Za-z0-9] ]] && { echo "BANNEDFIELD: $f — '$key'"; fail=1; }
  done < <(printf '%s\n' "$fm" | grep -E '^[[:space:]]*[A-Za-z0-9-]+[[:space:]]*?' | sed 's/:.*$//' | grep -v '^[[:space:]]' | sort -u)

  # Broken reference links — anchored with right boundary, no trailing punctuation.
  ref_links="$(grep -oE '(^|[^./A-Za-z0-9-])references/[A-Za-z0-9._-]+[A-Za-z0-9]' "$f" 2>/dev/null | sed 's/^[^{]references/references/' || true)"
  for rel in $ref_links; do
    [[ ! -f "$d$rel" ]] && { echo "BROKENREF: $f — '$rel' doesn't exist"; fail=1; }
  done
done

(( fail == 0 )) && echo "OK — ${#DIRS[@]} skill(s) valid"
exit "$fail"
