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
| test-passes-when-broken | 2 | Break the code on purpose to check that each new test fails | Any change that adds or changes a test | U1, U2, U3 | general |

## Evidence

| Kind | Level | Review | Date | Finding |
|------|-------|--------|------|---------|
| test-passes-when-broken | 2 | U4 | 2026-11-10 | A test kept passing after the tested function was changed to return nothing |
MD
git add -A
git commit -q -m "docs: evidence"
