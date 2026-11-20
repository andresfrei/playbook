#!/bin/bash
# Builds a project on the work branch `feat/demo`, with an open work
# `pdf-invoice` at stage 6: three units, the third waiting for the first two.
set -eu
git init -q -b main .
git config user.email eval@example.com
git config user.name "Laura Gómez"
mkdir -p docs/wiki/works/pdf-invoice src
printf '5\n' > docs/wiki/.format
cat > docs/wiki/README.md <<'MD'
# Invoicing app

A web app that issues invoices to customers. The wiki wins over any other document, and a decision over the rest of the wiki.

Project owner: Laura Gómez.

Every statement is Decided, Proposed, or Open.

| Page | Contains | Code it governs |
|------|----------|-----------------|
MD
cat > docs/wiki/works/pdf-invoice/README.md <<'MD'
# PDF invoice

A customer downloads an invoice as a PDF. Led by Laura Gómez.

Status: Open.

## Where work stands

2026-11-15, decision pdf-invoice-9. Stage 5 is closed and the plan is accepted. Stage 6 is open; no unit has started. See [plan.md](plan.md).

| Stage | Status | Closed on |
|-------|--------|-----------|
| 1 Wiki | Closed | 2026-11-12 |
| 2 Technology | Closed | 2026-11-13 |
| 3 Skills | Closed | 2026-11-13 |
| 4 Design system | Closed (not applicable) | 2026-11-14 |
| 5 Plan | Closed | 2026-11-15 |
| 6 Execution | Open | |
MD
cat > docs/wiki/works/pdf-invoice/plan.md <<'MD'
# Plan of pdf-invoice

## Progress

| Unit | Status | Evidence | Done on | Owner's words |
|------|--------|----------|---------|---------------|
| pdf-invoice-U1 | Not started | | | |
| pdf-invoice-U2 | Not started | | | |
| pdf-invoice-U3 | Not started | | | |

## Units

| ID | Unit | Delivers | Ends when | Waits for | Accepted by |
|----|------|----------|-----------|-----------|-------------|
| pdf-invoice-U1 | PDF layout | `src/layout.js` renders an invoice as a PDF | `sh test.sh layout` passes | none | Evidence |
| pdf-invoice-U2 | Invoice totals | `src/totals.js` adds the lines and the tax | `sh test.sh totals` passes | none | Evidence |
| pdf-invoice-U3 | Download button | `src/download.js` serves the PDF with its totals | `sh test.sh download` passes | pdf-invoice-U1, pdf-invoice-U2 | Evidence |

## Batches

| Batch | Units |
|-------|-------|
| 1 | pdf-invoice-U1, pdf-invoice-U2 |
| 2 | pdf-invoice-U3 |

- Most `write` agents at once: 2.
- Worktree preparation: none.

## How the work is delivered

- The work's branch is `feat/demo`. Each unit is built on its own branch, `feat/demo-u1`, `feat/demo-u2`, and `feat/demo-u3`, and enters `feat/demo` by a local merge.
- Tested by the checks of each unit.
MD
printf 'export const app = {};\n' > src/app.js
printf '#!/bin/sh\necho "test $1: ok"\n' > test.sh
git add -A
git commit -q -m "feat: invoicing app"
git switch -q -c feat/demo
