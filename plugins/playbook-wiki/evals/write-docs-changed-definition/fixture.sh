#!/bin/bash
# Builds a repository whose wiki is at format 6, with a shared page that states
# the invoice number as year plus counter, code that follows it, and an open
# work `numbering` with no decision yet.
set -eu
git init -q -b main .
git config user.email eval@example.com
git config user.name "Laura Gómez"
mkdir -p docs/wiki/01-product docs/wiki/works/numbering src/invoices
printf '6\n' > docs/wiki/.format
cat > docs/wiki/README.md <<'MD'
# Invoicing app

A web app that issues invoices to customers. The wiki wins over any other document, and a decision over the rest of the wiki.

Project owner: Laura Gómez.

Every statement is Decided, Proposed, or Open.

| Page | Contains | Code it governs |
|------|----------|-----------------|
| [01-product/invoices.md](01-product/invoices.md) | How an invoice is numbered and issued | `src/invoices/` |
MD
cat > docs/wiki/01-product/invoices.md <<'MD'
# Invoices

How an invoice is numbered and issued.

An invoice number is the year and a counter of four digits, such as 2026-0042 (invoices-1). The counter restarts each year (invoices-1).
MD
cat > docs/wiki/works/numbering/README.md <<'MD'
# Numbering

Change how invoices are numbered. Led by Laura Gómez.

Status: Open.

## Where work stands

No decision yet. Next: record the new number format and bring the code to it.

| Page | Contains | Code it governs |
|------|----------|-----------------|
MD
printf '| ID | Date | Decision | Who decided | Their words | Shared page | Replaces | Kind | Answer |\n|----|------|----------|-------------|-------------|-------------|----------|------|--------|\n' > docs/wiki/works/numbering/decisions.md
cat > src/invoices/number.js <<'JS'
// Builds the number of the next invoice: the year and a counter of four digits.
export function nextNumber(year, last) {
  return `${year}-${String(last + 1).padStart(4, '0')}`;
}
JS
git add -A
git commit -q -m "feat: invoice numbers"
git checkout -q -b feat/numbering
