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

2026-11-15, decision pdf-invoice-13. Stage 5 is open and the plan is not written. The units are in [decisions.md](decisions.md).

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

| ID | Date | Decision | Who decided | Their words | Shared page | Kind | Answer |
|----|------|----------|-------------|-------------|-------------|------|--------|
| pdf-invoice-5 | 2026-11-14 | Unit 1, PDF layout: `src/layout.js` renders an invoice as a PDF. It ends when its tests pass. | Laura Gómez | "Sí, el diseño del PDF primero" | none | definition | as recommended |
| pdf-invoice-6 | 2026-11-14 | Unit 2, Invoice numbering: `src/numbering.js` gives each invoice a sequential number. It uses nothing from the layout. It ends when its tests pass. | Laura Gómez | "Sí, y la numeración aparte" | none | definition | as recommended |
| pdf-invoice-7 | 2026-11-14 | Unit 3, Download button: `src/download.js` shows the button that downloads the PDF. It prints the number from unit 2 on the PDF that unit 1 renders, so it uses what both build. It ends when the owner tries it. | Laura Gómez | "Sí, el botón al final" | none | definition | as recommended |
| pdf-invoice-8 | 2026-11-15 | Close stage 4, Design system, as not applicable. | Laura Gómez | "No hay diseño nuevo" | none | close-stage | as recommended |
| pdf-invoice-9 | 2026-11-15 | Stage 5 opens. | Laura Gómez | "Pasemos al plan" | none | other | as recommended |
| pdf-invoice-10 | 2026-11-15 | The work is delivered through a work branch, `feat/pdf-invoice`; each unit is built on its own branch and enters the work branch by a local merge. | Laura Gómez | Chose "Rama de obra y merge local" | none | plan | as recommended |
| pdf-invoice-11 | 2026-11-15 | The work is tested only by the tests and the checks of each unit; there is no place apart where it is tested. | Laura Gómez | Chose "Solo los tests y los checks" | none | plan | as recommended |
| pdf-invoice-12 | 2026-11-15 | Branches are named `<type>/<work>`, and a unit's branch `<type>/<work>-<NN>-<slice>`, such as `feat/pdf-invoice-01-layout`. | Laura Gómez | Chose "Como recomendás" | none | plan | as recommended |
| pdf-invoice-13 | 2026-11-15 | The work leaves its branch by one pull request to `main`, which the owner merges. Production is `main`. | Laura Gómez | Chose "Un pull request a main" | none | plan | as recommended |
MD
printf 'export const app = {};\n' > src/app.js
git add -A
git commit -q -m "feat: invoicing app"
