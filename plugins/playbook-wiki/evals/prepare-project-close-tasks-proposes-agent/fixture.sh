#!/bin/bash
# Builds a project with only `main` and an open work `pdf-invoice` at stage 6,
# every unit Done. docs/wiki/tasks.md holds the task `release` in two other
# works, and git shows a release after the previous work's close and one in this work, so recording it makes the
# third work and the task ready for an agent.
set -eu
git init -q -b main .
git config user.email eval@example.com
git config user.name "Laura Gómez"
mkdir -p docs/wiki/works/pdf-invoice src
printf '6\n' > docs/wiki/.format
cat > docs/wiki/README.md <<'MD'
# Invoicing app

A web app that issues invoices to customers. The wiki wins over any other document, and a decision over the rest of the wiki.

Project owner: Laura Gómez.

Every statement is Decided, Proposed, or Open.

| Page | Contains | Code it governs |
|------|----------|-----------------|
| [tasks.md](tasks.md) | The tasks the agent carried out in each work | |
MD
cat > docs/wiki/tasks.md <<'MD'
# Tasks

## Tasks

| Task | Date | Work | Steps | Agent |
|------|------|------|-------|-------|
| release | 2026-10-20 | invoice-base | Set the version in package.json, add the entry to CHANGELOG.md, commit as chore(release), and leave the tag and the push to the owner | |
| release | 2026-11-05 | tax-lines | Set the version in package.json, add the entry to CHANGELOG.md, commit as chore(release), and leave the tag and the push to the owner | |
MD
cat > docs/wiki/works/pdf-invoice/README.md <<'MD'
# PDF invoice

A customer downloads an invoice as a PDF. Led by Laura Gómez.

Status: Open.

## Where work stands

2026-11-18, decision pdf-invoice-12. Stage 5 is closed and the plan is accepted. Stage 6 is open; every unit is Done and the work is ready to close. See [plan.md](plan.md).

| Stage | Status | Closed on |
|-------|--------|-----------|
| 1 Wiki | Closed | 2026-11-12 |
| 2 Technology | Closed | 2026-11-13 |
| 3 Skills | Closed | 2026-11-13 |
| 4 Design system | Closed (not applicable) | 2026-11-14 |
| 5 Plan | Closed | 2026-11-15 |
| 6 Execution | Open | |
MD
cat > docs/wiki/works/pdf-invoice/decisions.md <<'MD'
# Decisions of pdf-invoice

| ID | Date | Decision | Who decided | Their words | Shared page | Replaces | Kind | Answer |
|----|------|----------|-------------|-------------|-------------|----------|------|--------|
| pdf-invoice-5 | 2026-11-14 | Unit 1, PDF layout: `src/layout.js` renders an invoice as a PDF. It ends when its tests pass. | Laura Gómez | "Sí, el diseño del PDF primero" | none | | definition | as recommended |
| pdf-invoice-6 | 2026-11-14 | Unit 2, Download button: `src/download.js` serves the PDF. It ends when its tests pass. | Laura Gómez | "Sí, y el botón después" | none | | definition | as recommended |
| pdf-invoice-7 | 2026-11-14 | Close stage 4, Design system, as not applicable. | Laura Gómez | "No hay diseño nuevo" | none | | close-stage | as recommended |
| pdf-invoice-8 | 2026-11-15 | The plan is accepted: two units, built one after the other. | Laura Gómez | Asked "¿Aceptás el plan?"; answered "Sí, acepto el plan" | none | | plan | as recommended |
| pdf-invoice-9 | 2026-11-15 | Close stage 5, Plan. | Laura Gómez | "Cerrá el plan" | none | | close-stage | as recommended |
| pdf-invoice-10 | 2026-11-17 | The work is delivered through one pull request to `main`, which the owner merges. Production is `main`. | Laura Gómez | Chose "Un pull request a main" | none | | plan | as recommended |
| pdf-invoice-11 | 2026-11-18 | Version 1.2.0 for this work, a new feature that breaks nothing. | Laura Gómez | "Sí, la 1.2.0" | none | | other | as recommended |
| pdf-invoice-12 | 2026-11-18 | Both units are Done; the work goes to its close. | Laura Gómez | "Listo, cerremos" | none | | other | as recommended |
MD
cat > docs/wiki/works/pdf-invoice/plan.md <<'MD'
# Plan of pdf-invoice

## Progress

| Unit | Status | Evidence | Done on | Owner's words |
|------|--------|----------|---------|---------------|
| pdf-invoice-U1 | Done | `sh test.sh layout` passes | 2026-11-16 | |
| pdf-invoice-U2 | Done | `sh test.sh download` passes | 2026-11-17 | |

## Units

| ID | Unit | Delivers | Changes | Ends when | Waits for | Accepted by |
|----|------|----------|---------|-----------|-----------|-------------|
| pdf-invoice-U1 | PDF layout | `src/layout.js` renders an invoice as a PDF | `src/layout.js` | `sh test.sh layout` passes | none | Evidence |
| pdf-invoice-U2 | Download button | `src/download.js` serves the PDF | `src/download.js` | `sh test.sh download` passes | pdf-invoice-U1 | Evidence |

## Batches

| Batch | Units | Shared |
|-------|-------|--------|
| 1 | pdf-invoice-U1 | no |
| 2 | pdf-invoice-U2 | no |

- Most `write` agents at once: 1.
- Worktree preparation: none.

## How the work is delivered

- The work leaves its branch by one pull request to `main`, which the owner merges.
- Tested by the checks of each unit.
MD
cat > package.json <<'JSON'
{ "name": "invoicing-app", "version": "1.0.0" }
JSON
printf '# Changelog\n\n## 1.0.0\n\n- First version.\n' > CHANGELOG.md
printf '#!/bin/sh\necho "test $1: ok"\n' > test.sh
printf 'export const app = {};\n' > src/app.js
git add -A
git commit -q -m "feat: invoicing app"
# The previous work, tax-lines: closed, its pull request merged, then its release.
git checkout -q -b tax-lines
printf 'export const tax = {};\n' > src/tax.js
git add -A
git commit -q -m "feat(tax): add tax lines"
git commit -q --allow-empty -m "docs(wiki): close the work tax-lines"
git checkout -q main
git merge -q --no-ff tax-lines -m "Merge pull request #7 from laura/tax-lines"
git branch -q -d tax-lines
printf '{ "name": "invoicing-app", "version": "1.1.0" }\n' > package.json
printf '# Changelog\n\n## 1.1.0\n\n- Tax lines.\n\n## 1.0.0\n\n- First version.\n' > CHANGELOG.md
git add -A
git commit -q -m "chore(release): 1.1.0"
git tag v1.1.0
# This work, pdf-invoice: its commits, its release, and its close.
printf 'export const layout = {};\n' > src/layout.js
git add -A
git commit -q -m "feat(pdf): render an invoice as a PDF"
printf 'export const download = {};\n' > src/download.js
git add -A
git commit -q -m "feat(pdf): serve the PDF from a download button"
printf '{ "name": "invoicing-app", "version": "1.2.0" }\n' > package.json
printf '# Changelog\n\n## 1.2.0\n\n- PDF invoice.\n\n## 1.1.0\n\n- Tax lines.\n\n## 1.0.0\n\n- First version.\n' > CHANGELOG.md
git add -A
git commit -q -m "chore(release): 1.2.0"
git commit -q --allow-empty -m "docs(wiki): both units of pdf-invoice are Done"
