#!/bin/bash
# Builds a repository whose wiki has no format marker and no stage table: it
# was written before the stages existed, so it is at format 1.
set -eu
git init -q -b main .
git config user.email eval@example.com
git config user.name Eval
mkdir -p docs/wiki src
cat > docs/wiki/README.md <<'MD'
# Invoicing app

Notes on the invoicing app. The wiki wins over any other document.

| Page | Contains |
|------|----------|
| [decisions.md](decisions.md) | What was decided |
| [architecture.md](architecture.md) | How the app is built |

## Where work stands

The app issues invoices. Next: customers.
MD
cat > docs/wiki/architecture.md <<'MD'
# Architecture

A Node.js service with a PostgreSQL database.
MD
cat > docs/wiki/decisions.md <<'MD'
| ID | Date | Decision | Who decided | Their words |
|----|------|----------|-------------|-------------|
| D1 | 2026-03-02 | Use PostgreSQL | Laura Gómez | "Yes, PostgreSQL." |
MD
printf 'export const app = {};\n' > src/app.js
git add -A
git commit -q -m "feat: invoicing app"
