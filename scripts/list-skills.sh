#!/usr/bin/env bash
# Deterministic inventory of source skills in this repo.
# Prints one skill per line: "<dir-name>". Validator and README generations read this.
set -uo pipefail

export LANG=C LC_ALL=C
REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$REPO_ROOT"
shopt -s nullglob

dirs=(.agents/skills/*/)
if (( ${#dirs[@]} == 0 )); then
  exit 0
fi
for d in "${dirs[@]}"; do
  basename "$d"
done
