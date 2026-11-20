# Technology of the work task-agents

What the work needs from its technology, from [definition.md](definition.md) and decisions task-agents-2 to -8. The format of a subagent is recalled from Claude Code's subagent documentation (code.claude.com/docs/en/sub-agents.md) and from the agents of `playbook-agents`, which use it on 2.1.329; it is not checked again for this work.

## Needs

| ID | Need | From | Proposed answer | Status |
|----|------|------|-----------------|--------|
| N1 | Keep and count the repeated tasks | task-agents-3, -4 | A script `tasks.sh` in `playbook-agents`, POSIX `sh` and `awk` like `evidence.sh`. `add` appends a row to `docs/wiki/tasks.md`, creating the page with its header when it is missing. `count` prints "ready" for each task held in 3 distinct works that has no agent yet. `check` validates the page. One table: task, date, work, steps, agent | Decided |
| N2 | Record the tasks and propose an agent at the close of a work | task-agents-2, -5, -8 | A new step in the close of `prepare-project` (`references/6-execution.md`, step 6) that points to a new reference, `references/tasks.md`, as the close already does for evidence. It records the work's tasks with `tasks.sh add`, runs `count`, and proposes an agent for each task ready, with its weight, model, and the steps that stay in the main session. It is skipped when `playbook-agents` is missing | Decided |
| N3 | Create the dedicated agent | task-agents-5, -6 | On a yes, write `.claude/agents/<task>.md` in the project, with `name`, a one-line `description`, `tools`, `model`, and `effort`, and a body that lists the task's steps as instructions. Then fill the row's "agent" cell with its name. When it serves every project, say that it can go up to the playbook, as a proposal the owner carries | Decided |
| N4 | Decide later which proposals are made | task-agents-2 | A declined proposal is recorded as a decision of kind other, and its row's "agent" cell says "declined", so `count` does not offer it again | Decided |

## Facts that shape the answers

- A project's subagents live in `.claude/agents/*.md`. Their front matter holds `name`, `description`, `tools`, `model`, and `effort`, as the agents of `playbook-agents` do. Their descriptions load at session start, outside the L4 of the plugins.
- `evidence.sh` already shows the shape of N1: a page with a table, a script with `count` and `check`, and a step at the close of a work that reads `count` (repeated-corrections-13).
- The close of a work finds the scripts of `playbook-agents` from `prepare-project` with the command in `references/evidence.md`, step 1.
