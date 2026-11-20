# Architecture of the work parallel-units

## The problem

A work's plan lists its units in order, and stage 6 builds them one by one, although some do not depend on each other. Several `write` agents could build those units at once. The plan does not say which units go together, where each agent works, or how its result reaches the work's branch.

## Requirements and assumptions

- The batches follow from what each unit waits for. The owner accepts them with the plan (parallel-units-3, -5).
- Each agent works in its own worktree, so a shared file is not a reason to wait (parallel-units-4).
- A worktree holds only what git tracks, so it is prepared as the plan says. When that costs too much, the batch shares one worktree, with exclusive paths (parallel-units-9, -12).
- A unit starts when what it waits for is Done (parallel-units-7). Each plan sets the most agents at once (parallel-units-8).
- Assumption: the project uses git and works on a work branch, as `5-plan.md` already recommends.

## Shape

Nothing new is installed. The change lives in the text of `prepare-project`, in its stage 5 and stage 6 references (parallel-units-15). The main agent runs git and the Agent tool as that text says:

```text
plan.md (Waits for, batches, most agents, worktree preparation)
   |
   v
main agent, on the work's branch
   |-- git worktree add -b <unit branch> <folder> <work branch>   (parallel-units-11)
   |-- install command + copy ignored files                       (parallel-units-12)
   |-- Agent: write, in the background, one per ready unit        (parallel-units-13)
   |
   v  when a unit's checks pass, after review when risky
git merge --no-ff <unit branch>, the unit's checks on the work's branch,
git worktree remove, git branch -d                                (parallel-units-6, -14)
```

## Modules

| Module | Path | Responsible for | Does not |
|--------|------|-----------------|----------|
| Plan of batches | `plugins/playbook-wiki/skills/prepare-project/references/5-plan.md` | Writing in `plan.md` the column "Waits for" of the units table, the batches that follow from it, the most agents at once, and how a worktree is prepared: an install command and ignored files to copy. These replace the yes or no question on parallel units (parallel-units-3, -5, -8, -9, -12) | Choose the batches by judgement. Run anything |
| Execution of batches | `plugins/playbook-wiki/skills/prepare-project/references/6-execution.md` | Starting each unit when what it waits for is Done, up to the plan's number of agents. For each unit, it creates the worktree, prepares it, starts `write` with the folder and its paths, then merges the unit, runs its checks, and removes the worktree and the branch (parallel-units-6, -7, -11 to -14) | Push, or merge into the main branch (R14). Use `isolation: "worktree"` |

## Data

- `plan.md` gains a column "Waits for" in the units table, holding unit identifiers or "none". It also gains a short section that names the most agents at once, the install command, and the ignored files to copy.
- The batches are not stored. They follow from "Waits for".

## Outside systems

| System | What for | How critical |
|--------|----------|--------------|
| git | Worktrees, branches, merges | Required, as today |
| Claude Code's Agent tool | Several `write` agents in the background | Required. By default at most 20 subagents run at once, above any plan's number |

## Risks

| Risk | What reduces it |
|------|-----------------|
| Two units change the same lines, so the merge conflicts | The main agent resolves the conflict and runs the checks of both units again (parallel-units-6) |
| Units pass alone and fail together | The unit's checks run on the work's branch after each merge (parallel-units-14) |
| Preparing a worktree is slow or heavy, as with `npm install` in a large project | The plan says so, and the batch shares one worktree with exclusive paths (parallel-units-9) |
| A `write` agent changes files in the main folder instead of its own | It gets the absolute folder and its paths (R21). `review` reads a risky unit before the merge |
| An agent fails and leaves its worktree and branch behind | The main agent lists them with `git worktree list` and removes them before the work closes |
| The commit hold of `playbook-agents` holds the first commit in each new worktree once | The agent commits again, as it does today. It is a hold, not a refusal |
| Parallel agents spend tokens at the same time | Each plan sets the number, and the owner accepts it (parallel-units-8) |

## Trade-offs

- Git worktrees made by the main agent (parallel-units-11): always from the work's branch, with the plan's branch names, and relying on nothing undocumented. The cost is a few commands per unit, and `.worktreeinclude` does not apply.
- A worktree per agent (parallel-units-4): a shared file does not hold a unit back. The cost is preparing each worktree and one merge per unit.
- Batches derived from "Waits for" (parallel-units-5): nothing is grouped by judgement. The cost is one more column for each unit.

## Discarded alternatives

- The Agent tool's `isolation: "worktree"`: it starts from the default branch, and its branch name and support for plugin agents are not documented (parallel-units-11).
- A workflow script that orchestrates the agents: it needs the owner's opt-in in each work, and it costs more (parallel-units-13).
- Rebase or squash in place of a merge: each unit's history is lost, and a conflict is solved commit by commit (parallel-units-14).
- A new skill: it adds words at session start, and L4 is full (parallel-units-15).
- Exclusive paths in one worktree as the only way: two units that share a file could never be built together (parallel-units-4).

## How it can evolve

- The Agent tool's worktrees, once their base and branch name are documented or measured.
- A script that derives the batches from "Waits for" and checks that no unit waits for itself.
