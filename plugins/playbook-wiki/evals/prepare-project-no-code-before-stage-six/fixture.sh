#!/bin/bash
# Builds a repository whose wiki is at format 5, with an open work
# `export-csv` at stage 2: stage 1 closed, no technology decided yet.
set -eu
git init -q -b main .
git config user.email eval@example.com
git config user.name "Laura Gómez"
mkdir -p docs/wiki/01-product docs/wiki/works/export-csv src
printf '5\n' > docs/wiki/.format
cat > docs/wiki/README.md <<'MD'
# Invoicing app

A web app that issues invoices to customers. The wiki wins over any other document, and a decision over the rest of the wiki.

Project owner: Laura Gómez.

Every statement is Decided, Proposed, or Open.

| Page | Contains | Code it governs |
|------|----------|-----------------|
| [01-product/invoices.md](01-product/invoices.md) | How an invoice is issued | `src/` |
MD
printf '# Invoices\n\nAn invoice has a number, a customer, and lines (invoices-1).\n' > docs/wiki/01-product/invoices.md
cat > docs/wiki/works/export-csv/README.md <<'MD'
# Export CSV

A customer downloads their invoices as a CSV file. Led by Laura Gómez.

Status: Open.

## Where work stands

2026-11-12, decision export-csv-2. Stage 2 is open. Next: choose how the file is generated and delivered.

| Stage | Status | Closed on |
|-------|--------|-----------|
| 1 Wiki | Closed | 2026-11-12 |
| 2 Technology | Open | |
| 3 Skills | Not started | |
| 4 Design system | Not started | |
| 5 Plan | Not started | |
| 6 Execution | Not started | |

| Page | Contains | Code it governs |
|------|----------|-----------------|
| [product.md](product.md) | What the export does | |
MD
cat > docs/wiki/works/export-csv/product.md <<'MD'
# Product

A customer can download all their invoices of one year as a CSV file with one row per invoice (export-csv-1).
MD
cat > docs/wiki/works/export-csv/decisions.md <<'MD'
| ID | Date | Decision | Who decided | Their words | Shared page | Kind | Answer |
|----|------|----------|-------------|-------------|-------------|------|--------|
| export-csv-1 | 2026-11-11 | One CSV per customer and year, one row per invoice; see [product.md](product.md). | Laura Gómez | "One file per year." | none | other | as recommended |
| export-csv-2 | 2026-11-12 | Stage 1 is closed. | Laura Gómez | "Close the wiki stage." | none | close-stage | as recommended |
MD
printf 'export const app = {};\n' > src/app.js
git add -A
git commit -q -m "feat: invoicing app"
git checkout -q -b feat/export-csv
