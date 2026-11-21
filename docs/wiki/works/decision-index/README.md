# Work decision-index

Makes format 6 of `playbook-wiki`: decisions name what they replace, and a printed index shows the decisions in force, so an agent reads what holds instead of every decision. Andres Frei leads it.

Status: Closed 2026-11-20.

## Where work stands

Updated 2026-11-20, after decision-index-17.

All stages are closed and the five units are Done. Format 6 adds Replaces, for entire replacements only, and the index `check-wiki.sh --decisions --in-force [page]` (decision-index-4, -14). `migrate` replaces the doctor, holds no older format, runs in the agent `wiki-writer`, and migrates directly (decision-index-5, -10, -12, -13, -15). This wiki is at format 6, with the history in `works/history/` and its shared pages filled from the pages that cite it. The pre-merge review's eleven findings are fixed; `stale-reference-after-layout-change` went to level 2 and up to `evidence-rules.md` (decision-index-16, -17). Released as 4.0.0 (decision-index-3).

Waiting for a decision: none.

Next steps, in order:

1. The owner merges the pull request of `feat/decision-index` into `main`.
2. Release 4.0.0: five manifests, the tag, the release on GitHub; remove the worktree and the branch.
3. Restart Claude Code so the installed plugins carry `migrate` and `wiki-writer`; then resume `rule-promotion`, which must be migrated to format 6 first.

## Stage table

| Stage | Status | Closed on |
|-------|--------|-----------|
| 1 Wiki | Closed | 2026-11-20 |
| 2 Technology | Closed | 2026-11-20 |
| 3 Skills | Closed | 2026-11-20 |
| 4 Design system | Closed (not applicable) | 2026-11-20 |
| 5 Plan | Closed | 2026-11-20 |
| 6 Execution | Closed | 2026-11-20 |

## Pages

| Page | What it holds | Status |
|------|---------------|--------|
| [decisions.md](decisions.md) | The decisions of the work | |
| [definition.md](definition.md) | The problem, today, and what changes | |
| [architecture.md](architecture.md) | What changes in each module | |
| [plan.md](plan.md) | The units and how the work is delivered | |
| [questions.md](questions.md) | The open questions | |
