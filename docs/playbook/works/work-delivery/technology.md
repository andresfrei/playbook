# Technology of work-delivery

What the work needs from its technology, from [definition.md](definition.md). Stage 2. No new dependency: the step is text in `prepare-project`, and the agent reads files and runs git, as it already does.

## Needs and choices

| # | Need | Choice | Status |
|---|------|--------|--------|
| N1 | Find the project's own skill for delivery (work-delivery-2) | The agent reads the project's skills, `.claude/skills/` and the skills a project's `CLAUDE.md` or `AGENTS.md` names, and its `CONTRIBUTING.md` when it exists, as it reads any definition. No file is required | Decided (work-delivery-11) |
| N2 | Read how the repository delivers today, as a source (work-delivery-6) | git, already used: `git branch -a` for the branches, and `git log --merges --first-parent` on each long-lived branch for how units reach it. The forge is not queried | Decided (work-delivery-11) |
| N3 | A tracker for the work branch (work-delivery-5) | A draft pull request on the project's forge, from the work branch to where the work goes. On GitHub, `gh pr create --draft --base <branch>` (checked in `gh pr create --help`, gh 2.92.0, on 2026-11-18). The agent opens it only when the owner says so (R14). When units merge locally, there is no tracker: the work branch alone holds the work | Decided (work-delivery-11) |
| N4 | Know where the work is tested (work-delivery-8) | The owner's answer. The repository may suggest it, such as a `staging` branch or a deploy file, but the agent asks and does not infer | Decided (work-delivery-11) |
| N5 | The two evaluation cases | `claude plugin eval`, with cases in `plugins/playbook-wiki/evals/`, as the earlier works did ([../../03-technology/skill-evaluation.md](../../03-technology/skill-evaluation.md)) | Already used |

## Architecture

The problem: stage 5 decides delivery with questions that assume the main branch, and stage 6 closes a work without the check where it is tested ([current-state.md](current-state.md)).

The shape: two reference files of `prepare-project` change, and nothing else.

| Module | Changes | Does not |
|--------|---------|----------|
| `plugins/playbook-wiki/skills/prepare-project/references/5-plan.md` | Step 5 becomes the delivery step: the sources (N1, N2), where the work is tested (N4), the three ways of integrating with their cost, the risk warning, and the branch names. "Project already started" and the closing condition follow | Open a branch or a pull request |
| `plugins/playbook-wiki/skills/prepare-project/references/6-execution.md` | Step 2 delivers each unit as the delivery decision says; the close waits for the owner's check where the work is tested, and its fixes are units of the same work | Add a workflow of its own |
| `plugins/playbook-wiki/evals/` | Two new cases | |

A reference file is read only when its stage is current, so the step loads only at stage 5 and its close only at stage 6: nothing is added to what every session loads (L1, L4 of [../../01-product/style-guide.md](../../01-product/style-guide.md)). `SKILL.md` does not change.

Data: the delivery decision is one row of the work's `decisions.md`, and the plan names it, as today.

Outside systems: git, required, as today. The forge, optional, only for the tracker and only when the owner asks.

Risks:

| Risk | What reduces it |
|------|-----------------|
| A project's own skill names a flow the agent misreads | The agent states what it read and from where, and the owner confirms it (work-delivery-6) |
| The step grows long and the agent asks several questions at once, against R3 | The step lists its questions in order; the skill already asks one at a time |

Trade-offs: the step asks where the work is tested instead of reading it, which costs one question and avoids guessing a homelab or a worktree the repository does not show (work-delivery-8).

Discarded: a script that detects the flow, because the owner's answer and a reading of git are enough; a seventh stage (work-delivery-4).

Evolution: a project that settles its flow writes it once in its own skill, and the step then only confirms it (work-delivery-2).

## Not verified

- The behaviour of `gh pr create --draft` on a forge other than GitHub; the step names the forge's own draft request without assuming GitHub.
