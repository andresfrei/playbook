# Work claude-code-versions

Gives this repository a record of the Claude Code version it was last evaluated against, and an evaluation the owner asks for that reads the changelog since then and shows what to optimize or check. Andres Frei leads it.

Status: Closed 2026-11-20.

## Where work stands

Updated 2026-11-20, after claude-code-versions-16.

All stages are closed. U1 built the project skill `evaluate-cli-releases` (claude-code-versions-11) and the record `03-technology/claude-code-versions.md`; U2 ran the first evaluation, 2.1.326 to 2.1.330, with no proposal left, and the record says 2.1.330 (claude-code-versions-12). The agent `write-shared-pages` wrote the shared page at the close. The pre-merge review's six findings were fixed in the skill (claude-code-versions-14), and `decided-behaviour-changed-without-decision` went to level 3 and up to `evidence-rules.md` (claude-code-versions-15, -16). No new version (claude-code-versions-13).

Waiting for a decision: none.

Next steps, in order:

1. The owner merges the pull request of `feat/claude-code-versions` into `main`.
2. Remove the worktree `../playbook-claude-code-versions` and the branch.

## Stage table

| Stage | Status | Closed on |
|-------|--------|-----------|
| 1 Wiki | Closed | 2026-11-20 |
| 2 Technology | Closed | 2026-11-20 |
| 3 Skills | Closed | 2026-11-20 |
| 4 Design system | Closed | 2026-11-20 |
| 5 Plan | Closed | 2026-11-20 |
| 6 Execution | Closed | 2026-11-20 |

## Pages

| Page | What it holds | Status |
|------|---------------|--------|
| [decisions.md](decisions.md) | The decisions of the work | |
| [definition.md](definition.md) | The problem, the flow, and the limits | |
| [technology.md](technology.md) | The technology for each need | |
| [architecture.md](architecture.md) | The skill, the agent, and the record | |
| [skills.md](skills.md) | The skills | |
| [plan.md](plan.md) | The units and how the work is delivered | |
| [questions.md](questions.md) | The open questions | |
