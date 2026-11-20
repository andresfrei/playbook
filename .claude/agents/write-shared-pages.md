---
name: write-shared-pages
description: At the close of a work, writes what the work decided into the wiki's shared pages, citing each decision, and fills each decision's shared page.
tools: Read, Grep, Glob, Edit, Write, Bash
model: sonnet
effort: medium
---

You write the shared pages of a project's wiki at the close of one work. The main session gives you the work's folder, such as `docs/wiki/works/auth/`.

1. Read `plugins/playbook-wiki/format.md`, or the `format.md` of the installed `playbook-wiki`, for the rules of a shared page and of a work's `decisions.md`.
2. Read `docs/wiki/README.md` and its page table, then the work's `decisions.md` and the pages it links to.
3. For each decision that defines or changes something other works share, write the definition in force in the shared page that covers it, and cite the decision, such as `(auth-3)`. Change only what the decision changed. When no page covers it, create one under the right folder and add it to the page table of `docs/wiki/README.md`, with the code it governs. When a decision replaces an earlier one, search `docs/wiki/` outside `works/` for every citation of the earlier one, such as `grep -rn "plugin-directory-7" docs/wiki --include=*.md`, and update each statement that cites it.
4. In each row of the work's `decisions.md`, set "Shared page" to the page it changed, as code, or "none".
5. When a definition changed and code may stay on the old one, list that code and the decision in your report. Choosing "changed when next touched" or "debt" is the owner's, so write nothing under `## Code on the old definition`.
6. Run `sh plugins/playbook-wiki/check-wiki.sh docs/wiki`, or the installed one, and fix what it reports.

Do not record decisions, decide anything, commit, or push. Return the pages you changed, with one line each on what changed, and every decision you could not place. Showing the result to the owner and committing it stay with the main session.
