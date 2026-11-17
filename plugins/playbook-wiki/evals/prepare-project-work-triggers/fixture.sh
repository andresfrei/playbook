#!/bin/bash
# Builds a repository whose wiki is at format 4, with two closed works, on a
# new branch for the work the prompt asks for.
set -eu
git init -q -b main .
git config user.email eval@example.com
git config user.name Eval
mkdir -p docs/wiki/01-product docs/wiki/works/invoices docs/wiki/works/customers src
printf '4\n' > docs/wiki/.format
cat > docs/wiki/README.md <<'MD'
# Invoicing app

A web app that issues invoices to customers. The wiki wins over any other document, and a decision over the rest of the wiki.

Project owner: Laura Gómez.

Every statement is Decided, Proposed, or Open.

| Page | Contains | Code it governs |
|------|----------|-----------------|
| [01-product/invoices.md](01-product/invoices.md) | How an invoice is issued | `src/` |
| [01-product/customers.md](01-product/customers.md) | Who a customer is | |
MD
printf '# Invoices\n\nAn invoice has a number, a customer, and lines (invoices-1).\n' > docs/wiki/01-product/invoices.md
printf '# Customers\n\nA customer has a name and a tax id (customers-1).\n' > docs/wiki/01-product/customers.md
for w in invoices customers; do
  printf '# %s\n\nLed by Laura Gómez.\n\nStatus: Closed 2026-10-01.\n' "$w" > "docs/wiki/works/$w/README.md"
  # The backquotes are Markdown code spans, not shell expansions.
  # shellcheck disable=SC2016
  printf '| ID | Date | Decision | Who decided | Their words | Shared page |\n|---|---|---|---|---|---|\n| %s-1 | 2026-09-01 | See the page | Laura Gómez | "ok" | `01-product/%s.md` |\n' "$w" "$w" > "docs/wiki/works/$w/decisions.md"
done
printf 'export const app = {};\n' > src/app.js
git add -A
git commit -q -m "feat: invoicing app"
git checkout -q -b feat/roles
