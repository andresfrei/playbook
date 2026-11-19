#!/bin/bash
set -eu
git init -q -b main .
git config user.email eval@example.com
git config user.name Eval
mkdir -p docs/wiki
cat > docs/wiki/evidence.md <<'MD'
# Evidence

## Kinds

| Kind | Level | Rule | Applies when | Source | Scope |
|------|-------|------|--------------|--------|-------|
| missing-test | 1 | Write a test with each change of behaviour | Any change of behaviour | U1 | general |

## Evidence

| Kind | Level | Review | Date | Finding |
|------|-------|--------|------|---------|
| missing-test | 1 | U1 | 2026-11-10 | A changed function has no test |
MD
git add -A
git commit -q -m "docs: evidence"
