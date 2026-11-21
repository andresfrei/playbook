#!/bin/bash
# Builds a started repository with `main` and `staging`, whose history merges
# each unit of an earlier work into `staging` one by one, and an open work
# `user-roles` at stage 5 with its units listed and no delivery decided.
set -eu
git init -q -b main .
git config user.email eval@example.com
git config user.name "Laura Gómez"
mkdir -p docs/wiki/works/user-roles src
printf '6\n' > docs/wiki/.format
cat > docs/wiki/README.md <<'MD'
# Invoicing app

A web app that issues invoices to customers. The wiki wins over any other document, and a decision over the rest of the wiki.

Project owner: Laura Gómez.

Every statement is Decided, Proposed, or Open.

| Page | Contains | Code it governs |
|------|----------|-----------------|
MD
printf 'export const app = {};\n' > src/app.js
git add -A
git commit -q -m "feat: invoicing app"
git checkout -q -b staging
for n in 1 2 3; do
  git checkout -q -b "feat/invoices-u$n" staging
  printf 'export const u%s = %s;\n' "$n" "$n" > "src/invoices-$n.js"
  git add -A
  git commit -q -m "feat(invoices): unit $n"
  git checkout -q staging
  git merge -q --no-ff -m "Merge feat/invoices-u$n into staging" "feat/invoices-u$n"
done
git checkout -q -b feat/user-roles staging
cat > docs/wiki/works/user-roles/README.md <<'MD'
# User roles

Roles and permissions for the users of the app. Led by Laura Gómez.

Status: Open.

## Where work stands

2026-11-15, decision user-roles-6. Stage 5 is open. The units are listed in [plan.md](plan.md); how the work is delivered is not decided.

| Stage | Status | Closed on |
|-------|--------|-----------|
| 1 Wiki | Closed | 2026-11-12 |
| 2 Technology | Closed | 2026-11-13 |
| 3 Skills | Closed | 2026-11-13 |
| 4 Design system | Closed (not applicable) | 2026-11-14 |
| 5 Plan | Open | |
| 6 Execution | Not started | |
MD
cat > docs/wiki/works/user-roles/plan.md <<'MD'
# Plan of user-roles

| ID | Unit | Delivers | Ends when | Accepted by |
|----|------|----------|-----------|-------------|
| user-roles-U1 | Roles table | The roles and their permissions | Its tests pass | Evidence |
| user-roles-U2 | Checks on each route | A route refuses a user without the permission | Its tests pass | Evidence |
| user-roles-U3 | Roles screen | An admin assigns roles | The owner tries it | Judgement |

## How the work is delivered

Not decided.
MD
git add -A
git commit -q -m "docs(wiki): plan of user-roles"
