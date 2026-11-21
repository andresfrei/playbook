#!/bin/bash
# Builds a repository whose wiki is at the playbook's present format, 6, and
# passes its check.
set -eu
git init -q -b main .
git config user.email eval@example.com
git config user.name "Laura Gómez"
mkdir -p docs/wiki/01-product docs/wiki/works/invoices src
printf '6\n' > docs/wiki/.format
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
printf '# Invoices\n\nIssue invoices. Led by Laura Gómez.\n\nStatus: Closed 2026-10-01.\n' > docs/wiki/works/invoices/README.md
cat > docs/wiki/works/invoices/decisions.md <<'MD'
| ID | Date | Decision | Who decided | Their words | Shared page | Replaces | Kind | Answer |
|----|------|----------|-------------|-------------|-------------|----------|------|--------|
| invoices-1 | 2026-09-01 | An invoice has a number, a customer, and lines. | Laura Gómez | "ok" | `01-product/invoices.md` | | definition | as recommended |
MD
printf 'export const app = {};\n' > src/app.js
git add -A
git commit -q -m "feat: invoicing app"
