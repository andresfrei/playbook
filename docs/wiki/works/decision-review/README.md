# Work decision-review

Checks whether each decision of `docs/wiki/decisions.md` still holds against the code and the current Claude Code, and has the owner decide each one that does not. Andres Frei leads it.

Status: Closed 2026-11-20.

## Where work stands

Updated 2026-11-20, after decision-review-14.

All stages are closed. [report.md](report.md) classes the 241 decisions: 79 of the 83 findings are history replaced by design, since format 4. The entry points now say so (decision-review-9), two stale lines are fixed (-11, -12), and release tags stay `v<version>` (-13). The owner chose a new work, `decision-index`, for format 6 (decision-review-10). No new version (decision-review-14).

Waiting for a decision: none.

Next steps, in order:

1. The owner merges the pull request of `docs/decision-review` into `main`.
2. Remove the worktree `../playbook-decision-review` and the branch.
3. Open the work `decision-index`; `rule-promotion` waits after it.

## Stage table

| Stage | Status | Closed on |
|-------|--------|-----------|
| 1 Wiki | Closed | 2026-11-20 |
| 2 Technology | Closed | 2026-11-20 |
| 3 Skills | Closed (not applicable) | 2026-11-20 |
| 4 Design system | Closed (not applicable) | 2026-11-20 |
| 5 Plan | Closed | 2026-11-20 |
| 6 Execution | Closed | 2026-11-20 |

## Pages

| Page | What it holds | Status |
|------|---------------|--------|
| [decisions.md](decisions.md) | The decisions of the work | |
| [definition.md](definition.md) | Scope, classes, and flow | |
| [technology.md](technology.md) | The tools of the review | |
| [report.md](report.md) | The classification and the rows for the owner | |
| [plan.md](plan.md) | The units and how the work is delivered | |
| [questions.md](questions.md) | The open questions | |
