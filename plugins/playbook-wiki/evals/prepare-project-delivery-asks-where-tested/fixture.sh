#!/bin/bash
# Builds a new project with only `main` and an open work `pdf-invoice` at
# stage 5, with its units listed and no delivery decided.
set -eu
git init -q -b main .
git config user.email eval@example.com
git config user.name "Laura Gómez"
mkdir -p docs/wiki/works/pdf-invoice src
printf '4\n' > docs/wiki/.format
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

2026-11-15, decision pdf-invoice-5. Stage 5 is open. The units are listed in [plan.md](plan.md); how the work is delivered is not decided.

| Stage | Status | Closed on |
|-------|--------|-----------|
| 1 Wiki | Closed | 2026-11-12 |
| 2 Technology | Closed | 2026-11-13 |
| 3 Skills | Closed | 2026-11-13 |
| 4 Design system | Closed (not applicable) | 2026-11-14 |
| 5 Plan | Open | |
| 6 Execution | Not started | |
MD
cat > docs/wiki/works/pdf-invoice/plan.md <<'MD'
# Plan of pdf-invoice

| ID | Unit | Delivers | Ends when | Accepted by |
|----|------|----------|-----------|-------------|
| pdf-invoice-U1 | PDF layout | An invoice rendered as a PDF | Its tests pass | Evidence |
| pdf-invoice-U2 | Download button | A customer downloads the PDF | The owner tries it | Judgement |

## How the work is delivered

Not decided.
MD
printf 'export const app = {};\n' > src/app.js
git add -A
git commit -q -m "feat: invoicing app"
