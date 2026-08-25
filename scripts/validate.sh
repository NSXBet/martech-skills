#!/usr/bin/env bash
# Validate every .agents/skills/<name>/SKILL.md in this repo — anchored to the repo root (via $1).
set -uo pipefail
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"
shopt -s nullglob

fail=0
DIRS=(.agents/skills/*/)
if [[ ${#DIRS[@]} -eq 0 ]]; then
  echo "FAIL — no skill directories under $REPO_ROOT/.agents/skills" >&2
  exit 1
fi

BANNED_HARNESS_FIELDS="context disable-model user-invocable user-invocable-disable disallowed model-effort effort background arguments allowed-tools"
RESERVED_WORDS="anthropic claude"

for d in "${DIRS[@]}"; do
  name="$(basename "$d")"
  f="$d/SKILL.md"
  if [[ ! -f "$f" ]]; then
    echo "MISSING: $f"
    fail=1
    continue
  fi

  # Extract just the YAML frontmatter (between the first and second '---' lines).
  fm="$(awk '/^---$/{c++; if (c==2) exit} c>=1' "$f")"
  name_val="$(printf '%s\n' "$fm" | sed -n 's/^[[:space:]]*name:[[:space:]]*//p' | tr -d "'\"" | head -1)"
  desc_len=$(printf '%s\n' "$fm" | sed -n 's/^[[:space:]]*description:[[:space:]]*//p' | head -1 | wc -c | tr -d ' ')

  if [[ "$name_val" != "$name" ]]; then
    echo "BADNAME: $f — frontmatter 'name' is '$name_val' but dir is '$name'"
    fail=1
  fi
  if (( desc_len < 2 )); then
    echo "NODESC: $f"
    fail=1
  fi
  if [[ ${#name_val} -lt 6 || ${#name_val} -gt 64 ]]; then
    echo "BADLENGTH: $f — name length ${#name_val}"
    fail=1
  fi
  for word in $RESERVED_WORDS; do
    if [[ "$name_val" == *"$word"* ]]; then
      echo "BANNEDNAME: $f — contains reserved word '$word'"
      fail=1
    fi
  done
  # kebab-case only
  if [[ ! "$name_val" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]]; then
    echo "BADCASE: $f — name is not kebab-case"
    fail=1
  fi
  fields_allowed="name description license compatibility metadata allowed-tools"
  while IFS= read -r key; do
    key="${key%%:*}"
    ok=0
    for allowed in $fields_allowed; do
      [[ "$key" == "$allowed" ]] && { ok=1; break; }
    done
    if [[ $ok -eq 0 ]]; then
      echo "BANNEDFIELD: $f — '$key'"
      keep_banned=0
      for banned in $BANNED_HARNESS_FIELDS; do
        if [[ "$key" == "$banned" ]]; then
          echo "(confirm harness-specific field on $key)" >&2
        fi
      done
      fail=1
    fi
  done < <(printf '%s\n' "$fm" | grep -E '^[[:space:]]*[a-zA-Z-]+[[:space:]]*:' | sed 's/:.*$//' | sort -u)
done

if [[ $fail -eq 0 ]]; then
  echo "OK — ${#DIRS[@]} skill(s) valid"
fi
exit "$fail"
