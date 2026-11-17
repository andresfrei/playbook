#!/bin/bash
# Builds a repository whose wiki is at format 4, with an open work
# `notifications` at stage 3: stages 1 and 2 closed, the technology decided.
set -eu
git init -q -b main .
git config user.email eval@example.com
git config user.name Eval
mkdir -p docs/wiki/01-product docs/wiki/works/notifications src
printf '4\n' > docs/wiki/.format
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
cat > docs/wiki/works/notifications/README.md <<'MD'
# Notifications

Tell a customer by email when an invoice is issued or overdue. Led by Laura Gómez.

Status: Open.

## Where work stands

2026-11-10, decision notifications-3. Stage 3 is open. Next: the skills the agent needs for the chosen technology.

| Stage | Status | Closed on |
|-------|--------|-----------|
| 1 Wiki | Closed | 2026-11-08 |
| 2 Technology | Closed | 2026-11-10 |
| 3 Skills | Open | |
| 4 Design system | Not started | |
| 5 Plan | Not started | |
| 6 Execution | Not started | |

| Page | Contains | Code it governs |
|------|----------|-----------------|
| [product.md](product.md) | What the notifications do | |
| [technology.md](technology.md) | The technology chosen | |
MD
cat > docs/wiki/works/notifications/product.md <<'MD'
# Product

The app sends one email to the customer when an invoice is issued, and one when it is 7 days overdue (notifications-1).
MD
cat > docs/wiki/works/notifications/technology.md <<'MD'
# Technology

Decided (notifications-2): Node.js 22 for the sender, BullMQ as the job queue, PostgreSQL 16 to store what was sent, and SendGrid to deliver the email.
MD
cat > docs/wiki/works/notifications/decisions.md <<'MD'
| ID | Date | Decision | Who decided | Their words | Shared page |
|----|------|----------|-------------|-------------|-------------|
| notifications-1 | 2026-11-08 | Email on issue and at 7 days overdue; see [product.md](product.md). | Laura Gómez | "Yes, those two emails." | none |
| notifications-2 | 2026-11-09 | Node.js 22, BullMQ, PostgreSQL 16, and SendGrid; see [technology.md](technology.md). | Laura Gómez | "Go with that stack." | none |
| notifications-3 | 2026-11-10 | Stages 1 and 2 are closed. | Laura Gómez | "Close both." | none |
MD
printf 'export const app = {};\n' > src/app.js
git add -A
git commit -q -m "feat: invoicing app"
git checkout -q -b feat/notifications
