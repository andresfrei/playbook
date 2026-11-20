# Definition of the work task-agents

What this work must make true: a task the agent repeats with the same steps is noticed, and at the close of a work the owner is offered a dedicated agent for it, with a model that fits the task's weight; on a yes, that agent exists and the task runs there (task-agents-1, task-agents-2).

## The problem

The main session runs every task on its own model, the strongest and most costly. Some tasks repeat with the same steps and need little judgement, and nothing notices it. The agents `explore`, `write`, `review`, and `classify` each have their own model (`plugins/playbook-agents/models.conf`), but each was designed by hand, once.

## An example

The owner confirmed this picture (task-agents-2). On 2026-11-20 the release was done three times, for 3.3.0, 3.4.0, and 3.5.0, each time with the same steps:

1. a branch `chore/release-X`;
2. the version in the three manifests;
3. two READMEs of the wiki;
4. a pull request, which the owner merges;
5. the tag;
6. the release with its notes.

All steps but the notes are mechanical. At the close, the agent would say: "The task *release* repeated 3 times with the same steps. I propose an agent `release`, on `haiku` with low effort, because it is mechanical; the release notes stay in the main session."

## Who has it

A person who uses the playbook over many works, and pays for every task the main model runs.

## What is known

- Claude Code loads a subagent from a Markdown file with front matter (`name`, `description`, `tools`, `model`, `effort`). A plugin ships them in `agents/`. A project keeps its own in `.claude/agents/`. Recalled, not checked for this work: stage 2 checks it.
- The description of each agent of `playbook-agents` counts toward L4, the words loaded at session start, which is already at 620 of 620 (`scripts/verify.sh`).
- The playbook already turns repetition into something durable: `evidence.sh count` marks a kind of finding ready when it appears in 3 distinct reviews, and the close of a work proposes it (repeated-corrections-5, -13).
- `/playbook-agents:config` sets the model and the effort of an agent per repository or for every project (setup-commands-4).

## Coverage of the topics

| Topic | Coverage |
|-------|----------|
| The problem and who has it | Covered |
| Who uses it and what they do | Covered: the owner answers a proposal at the close of a work (task-agents-2) |
| Main flows | Partly: how a repeated task is noticed is task-agents-Q1 |
| What it must do | Partly: when a task counts as repeated is task-agents-Q2; how its model is chosen is task-agents-Q3 |
| What it must not do, and what waits | Partly: which steps of a task stay in the main session is task-agents-Q3 |
| Qualities | Covered: the dedicated agent costs less than the main model for the same result |
| Limits | Partly: where the agent lives, given L4, is task-agents-Q4 |
| Outside systems | Covered: Claude Code's subagents |
| Volume | Does not apply |
| Who runs and maintains it | Covered: it ships in `playbook-agents` |
| Business rules, states, vocabulary | Covered: a repeated task, a dedicated agent, the weight of a task |
