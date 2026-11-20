# Plan of the work parallel-units

The units that build [architecture.md](architecture.md), in order.

## Progress

| Unit | Status | Evidence | Done on | Owner's words |
|------|--------|----------|---------|---------------|
| parallel-units-U1 | Done | Built in parallel by two `write` agents, each in its own worktree from `feat/parallel-units` (be1b791, a956721), merged with `--no-ff` (08be5e7, 691f522); `review` found 13 findings, settled by parallel-units-21 to -24 and fixed in 49e7acf and 0b82763. `sh scripts/verify.sh` passes with L4 unchanged, `claude plugin validate plugins/playbook-wiki` and `check-wiki.sh` pass, both fixtures run, and each grader regex was tested with `grep -P` against good and bad samples. Cases of behaviour not run (paid) | 2026-11-20 | "si, acepto U1 y U2" (Andres Frei) |
| parallel-units-U2 | Done | Built in parallel by two `write` agents, each in its own worktree from `feat/parallel-units` (be1b791, a956721), merged with `--no-ff` (08be5e7, 691f522); `review` found 13 findings, settled by parallel-units-21 to -24 and fixed in 49e7acf and 0b82763. `sh scripts/verify.sh` passes with L4 unchanged, `claude plugin validate plugins/playbook-wiki` and `check-wiki.sh` pass, both fixtures run, and each grader regex was tested with `grep -P` against good and bad samples. Cases of behaviour not run (paid) | 2026-11-20 | "si, acepto U1 y U2" (Andres Frei) |

## Units

| ID | Unit | Delivers | Ends when | Waits for | Accepted by |
|----|------|----------|-----------|-----------|-------------|
| parallel-units-U1 | The plan of batches | `references/5-plan.md` of `prepare-project` writes the column "Waits for", the batches that follow from it, the most agents at once, and how a worktree is prepared: an install command and the ignored files to copy. These replace the yes or no question on parallel units (parallel-units-3, -5, -8, -9, -12, -15) | `sh scripts/verify.sh` passes with L2 and L4 unchanged. `claude plugin validate plugins/playbook-wiki` passes. A case of behaviour under `plugins/playbook-wiki/evals/prepare-project-*` asks for a plan whose units table has "Waits for" and that names the batches | none | Judgement: the method's text |
| parallel-units-U2 | The execution of batches | `references/6-execution.md` starts each unit when what it waits for is Done, up to the plan's number. For each unit it creates the worktree from the work's branch, prepares it, starts `write` in the background with the folder and its paths, merges with `--no-ff`, runs the checks, and removes the worktree and the branch (parallel-units-6, -7, -11, -13, -14, -15) | `sh scripts/verify.sh` passes. A case of behaviour gives a plan with two units that wait for none and one that waits for both, and the agent starts the first two in one message, each in its own `git worktree add` from the work's branch | none | Judgement: the method's text |

U1 and U2 change different files, and each takes its rules from the decisions, not from the other's text. So both wait for none, and they form one batch.

## Batches

| Batch | Units |
|-------|-------|
| 1 | parallel-units-U1, parallel-units-U2 |

- Most `write` agents at once: 2.
- Worktree preparation: none. The repository is POSIX `sh` and `awk`, with no dependencies and no ignored files the checks need.

## How the work is delivered

- Tested by the checks of each unit and its cases of behaviour. A paid evaluation runs only when the owner asks.
- Each unit is built in its own worktree, on `feat/parallel-units-01-plan` and `feat/parallel-units-02-execution`, from the work's branch `feat/parallel-units`. It enters that branch by a local merge, as the work defines. This work is its own first use.
- It reaches `main` by one pull request, which the owner merges (R14).

## Left out

- The Agent tool's `isolation: "worktree"` (parallel-units-11).
- A script that derives the batches or checks "Waits for": a later work may add one.
- Changes to the agent `write`: it already gets its folder and its paths (R21).
