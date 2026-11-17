#!/bin/bash
# Builds a repository whose wiki is at format 3: a marker of 3, a column "Code
# it governs", and a "Where work stands" section with a stage table whose
# stages are all closed.
set -eu
git init -q -b main .
git config user.email eval@example.com
git config user.name "Laura Gómez"
mkdir -p docs/wiki/01-product src
printf '3\n' > docs/wiki/.format
cat > docs/wiki/README.md <<'MD'
# Invoicing app

A web app that issues invoices to customers. The wiki wins over any other document, and a decision over the rest of the wiki.

Every statement is Decided, Proposed, or Open.

| Page | Contains | Code it governs |
|------|----------|-----------------|
| [decisions.md](decisions.md) | Numbered decisions with the owner's words | |
| [01-product/invoices.md](01-product/invoices.md) | How an invoice is issued | `src/` |

## Where work stands

Updated 2026-10-01, decision D2. No phase is open. Phase 1 is finished.

| Stage | Status | Closed on |
|-------|--------|-----------|
| 1 Wiki | Closed | 2026-09-01 |
| 2 Technology | Closed | 2026-09-05 |
| 3 Skills | Closed | 2026-09-10 |
| 4 Design system | Closed (not applicable) | 2026-09-10 |
| 5 Plan | Closed | 2026-09-20 |
| 6 Execution | Closed | 2026-10-01 |
MD
printf '# Invoices\n\nAn invoice has a number, a customer, and lines (D1).\n' > docs/wiki/01-product/invoices.md
cat > docs/wiki/decisions.md <<'MD'
| ID | Date | Decision | Who decided | Their words |
|----|------|----------|-------------|-------------|
| D1 | 2026-03-02 | An invoice has a number, a customer, and lines | Laura Gómez | "Yes." |
| D2 | 2026-03-09 | Issue invoices by email | Laura Gómez | "By email." |
MD
printf 'export const app = {};\n' > src/app.js
git add -A
git commit -q -m "feat: invoicing app"
