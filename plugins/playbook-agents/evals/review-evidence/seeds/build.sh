#!/bin/bash
# Builds a seeded diff of this repository in the current, empty folder: the
# files of a fixed commit as the first commit, then a seeded patch as the
# second, so a reviewer reviews HEAD~1..HEAD. Nothing else of the history is
# copied, so no other commit shows the seeded defect.
# Usage: bash build.sh <seed folder> <base commit> <message> [--rule]
# --rule writes the review rule into CLAUDE.md in the first commit, so the
# diff stays the seeded patch alone.
set -eu
seed=$1 base=$2 message=$3 rule=${4:-}
repo=$(cd "$(dirname "$0")/../../../../.." && pwd)
git -C "$repo" archive "$base" | tar -x
if [ "$rule" = --rule ]; then
  cat "$(dirname "$0")/rule.md" >> CLAUDE.md
fi
git init -q -b main .
git config user.email eval@example.com
git config user.name Eval
git add -A
git commit -qm "chore: start from $base"
git apply "$seed/seed.patch"
git add -A
git commit -qm "$message"
