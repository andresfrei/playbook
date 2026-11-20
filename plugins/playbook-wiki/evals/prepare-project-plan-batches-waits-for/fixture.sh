#!/bin/bash
# Builds a new project with only `main` and an open work `pdf-invoice` at
# stage 5, stages 1 to 4 closed. Its decisions define three units; the third
# uses what the first two build.
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

2026-11-15, decision pdf-invoice-9. Stage 5 is open and the plan is not written. The units are in [decisions.md](decisions.md).

| Stage | Status | Closed on |
|-------|--------|-----------|
| 1 Wiki | Closed | 2026-11-12 |
| 2 Technology | Closed | 2026-11-13 |
| 3 Skills | Closed | 2026-11-13 |
| 4 Design system | Closed (not applicable) | 2026-11-14 |
| 5 Plan | Open | |
| 6 Execution | Not started | |
MD
cat > docs/wiki/works/pdf-invoice/decisions.md <<'MD'
# Decisions of pdf-invoice

| ID | Date | Decision | Who decided | Their words |
|----|------|----------|-------------|-------------|
| pdf-invoice-5 | 2026-11-14 | Unit 1, PDF layout: `src/layout.js` renders an invoice as a PDF. It ends when its tests pass. | Laura Gómez | "Sí, el diseño del PDF primero" |
| pdf-invoice-6 | 2026-11-14 | Unit 2, Invoice numbering: `src/numbering.js` gives each invoice a sequential number. It uses nothing from the layout. It ends when its tests pass. | Laura Gómez | "Sí, y la numeración aparte" |
| pdf-invoice-7 | 2026-11-14 | Unit 3, Download button: `src/download.js` shows the button that downloads the PDF. It prints the number from unit 2 on the PDF that unit 1 renders, so it uses what both build. It ends when the owner tries it. | Laura Gómez | "Sí, el botón al final" |
| pdf-invoice-8 | 2026-11-15 | Close stage 4, Design system, as not applicable. | Laura Gómez | "No hay diseño nuevo" |
| pdf-invoice-9 | 2026-11-15 | Stage 5 opens. | Laura Gómez | "Pasemos al plan" |
MD
printf 'export const app = {};\n' > src/app.js
git add -A
git commit -q -m "feat: invoicing app"
