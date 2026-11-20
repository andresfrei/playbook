# Plan of the work task-agents

The units that build [architecture.md](architecture.md), in order.

## Progress

| Unit | Status | Evidence | Done on | Owner's words |
|------|--------|----------|---------|---------------|
| task-agents-U1 | Done | `sh scripts/verify_test.sh` passes with gawk and with mawk (1077 cases, 82 of `tasks.sh`), `sh scripts/verify.sh` passes, shellcheck clean; each case seen to fail with its behaviour broken, 16 mutations on 7cda528 and 13 on the fixes. Reviewed: eight findings, fixed in 3b9169d and 050cdcb. Merged into `feat/task-agents` with `--no-ff` (c322198) | 2026-11-20 | |
| task-agents-U2 | Not started | | | |

## Units

| ID | Unit | Delivers | Changes | Ends when | Waits for | Accepted by |
|----|------|----------|---------|-----------|-----------|-------------|
| task-agents-U1 | The tasks script | `tasks.sh add`, `count`, and `check` on `docs/wiki/tasks.md`, as [architecture.md](architecture.md) defines (task-agents-9, -12) | `plugins/playbook-agents/tasks.sh`, `scripts/verify_test.sh`, `scripts/verify.sh`, `plugins/playbook-agents/README.md` | `verify_test.sh` passes, with gawk and with mawk, cases where `add` creates the page and appends, `count` marks a task in 3 distinct works and not one in 3 rows of 2 works, skips a task with an agent or "declined", and `check` fails on a malformed row; each case seen to fail with its behaviour broken. `verify.sh` passes and shellcheck is clean | none | Evidence |
| task-agents-U2 | The close step | A step in the close of `6-execution.md` that points to a new `references/tasks.md`: record the work's tasks, run `count`, propose an agent for each task ready with its weight, model, effort, and the steps that stay in the main session; on a yes write `.claude/agents/<task>.md`; on a no record the decision (task-agents-5, -6, -8, -10, -11, -12) | `plugins/playbook-wiki/skills/prepare-project/references/6-execution.md`, `plugins/playbook-wiki/skills/prepare-project/references/tasks.md`, `plugins/playbook-wiki/skills/prepare-project/SKILL.md`, `plugins/playbook-wiki/evals/prepare-project-close-tasks-*` | `verify.sh` passes with L2 and L4 unchanged, `claude plugin validate plugins/playbook-wiki` passes, and a case of behaviour at a close with a task ready in 3 works shows the proposal with its model and asks before writing the agent | task-agents-U1 | Judgement: the method's text |

U2 runs `tasks.sh`, which U1 builds, so it waits for U1.

## Batches

| Batch | Units | Shared |
|-------|-------|--------|
| 1 | task-agents-U1 | no |
| 2 | task-agents-U2 | no |

- Most `write` agents at once: 1, since each batch holds one unit.
- Worktree preparation: none. The repository is POSIX `sh` and `awk`, with no dependencies.

## How the work is delivered

- Tested by the checks of each unit and its case of behaviour. A paid evaluation runs only when the owner asks.
- Each unit is built in its own worktree from the work's branch `feat/task-agents`, on `feat/task-agents-01-script` and `feat/task-agents-02-close`, and enters by a local merge.
- It reaches `main` by one pull request, which the owner merges (R14).

## Left out

- Recording tasks of works closed before this one.
- Counting the use of a dedicated agent.
- Changing the model of an existing agent of `playbook-agents`.
