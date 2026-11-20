# Architecture of the work task-agents

## The problem

The main session runs every task on its own model, the most costly one. A task that repeats with the same steps across works could run on a dedicated agent with a cheaper model. Nothing notices the repetition.

## Requirements and assumptions

- Tasks are recorded at the close of each work, in `docs/wiki/tasks.md` (task-agents-3, -8).
- A task counts as repeated when it is held in 3 distinct works (task-agents-4).
- Its model follows from its weight. What decides, designs, or touches R14 or R20 stays in the main session (task-agents-5).
- The agent lives in the project's `.claude/agents/`, outside L4. One that serves every project is proposed to the playbook (task-agents-6).
- Assumption: the project uses `playbook-wiki` and closes its works with `prepare-project`.

## Shape

It reuses the shape of evidence: a page, a script that counts, and a step at the close of a work.

```text
close of a work (prepare-project, 6-execution.md step 6)
   -> references/tasks.md
        -> tasks.sh add      one row per task of the work      (task-agents-9)
        -> tasks.sh count    tasks in 3 distinct works, no agent yet
        -> proposal to the owner: weight, model, steps that stay  (task-agents-5, -10)
        -> yes: .claude/agents/<task>.md, rows name the agent      (task-agents-11)
           no:  a decision of kind other, rows say "declined"      (task-agents-12)
```

## Modules

| Module | Path | Responsible for | Does not |
|--------|------|-----------------|----------|
| Tasks script | `plugins/playbook-agents/tasks.sh` | `add <task> <work> <steps> [wiki dir]`: appends a row inside the table, creating the page with its header when it is missing. `count [wiki dir]`: prints one line "ready: <task>: N works, last <date>" per task held in 3 distinct works whose rows name no agent and are not declined. `set-agent <task> <name|declined> [wiki dir]`: fills the agent cell of the task's rows (task-agents-11, -12). `check [wiki dir]`: validates the page. The wiki folder defaults to `$CLAUDE_PROJECT_DIR/docs/wiki`, else `docs/wiki`. `--help` prints its usage, and each kind of failure has its own exit code (task-agents-9) | Read transcripts. Create an agent. Judge a task's weight |
| Close step | `plugins/playbook-wiki/skills/prepare-project/references/6-execution.md`, `references/tasks.md` | At the close, it records the work's tasks from its git log, its plan, and what was done. It runs `count`, and for each task ready proposes an agent with its weight, model, effort, and the steps that stay in the main session. On a yes it writes the agent; on a no it records the decision (task-agents-10, -11, -12) | Run without `playbook-agents`. Propose a task that decides, designs, or touches R14 or R20 |

## Data

`docs/wiki/tasks.md` holds one table:

| Column | Holds |
|--------|-------|
| Task | A short name in kebab case, the same each time, such as `release` |
| Date | The date of the close |
| Work | The work's name |
| Steps | The steps, in one line |
| Agent | Empty, the agent's name, or "declined" |

## Outside systems

| System | What for | How critical |
|--------|----------|--------------|
| Claude Code's project subagents | Running the dedicated agent from `.claude/agents/` | Required for the agent; the record works without it |

## Risks

| Risk | What reduces it |
|------|-----------------|
| The same task gets a different name in two works, so it is never counted | `references/tasks.md` tells the agent to reuse a name `tasks.sh` already lists, and the close shows the names it recorded |
| A task given to a cheap model needs judgement it cannot give | The proposal names its steps and the steps that stay in the main session, and the owner decides (task-agents-5) |
| The project's agent descriptions load in every session | One line each. They do not count in the plugins' L4, but they cost words |
| A dedicated agent is created and never used | Out of scope here; a later work may count its use |

## Trade-offs

- Recording at the close (task-agents-8): it costs nothing at session start. The cost is that a task done outside a work is not recorded.
- A project agent (task-agents-6): no cost in L4. The cost is that each project builds its own until one goes up to the playbook.

## Discarded alternatives

- Reading transcripts: costly, and they are removed after about 30 days (task-agents-3).
- Recording when each task ends: it needs room in `rules.md`, which is full (task-agents-8).
- A skill `write-agent`: more words at session start (task-agents-11).
- A command apart from the close: it depends on the person remembering to run it (task-agents-10).

## How it can evolve

- Count the use of each dedicated agent, and propose removing one that is never used.
- Propose a cheaper model for an existing agent, such as `classify`.
