---
name: prepare-project
description: Start a new project, start a new phase of a finished one, or prepare one already started when the owner asks for it. Runs six stages before any code (wiki, technology, skills, design system, plan, execution), each closed by the owner.
---

## When to use

- The owner starts a new project.
- The owner explicitly asks to prepare a project already started.
- The owner asks to continue or close a stage of a project whose `docs/wiki/README.md` has a stage table.
- The owner starts a new phase of a project whose six stages are closed.

Do not use it for a small change in an existing repository that has no wiki. Do that change directly and do not propose this method.

## Rules

- A project is prepared in six stages, in this order: 1 wiki, 2 technology, 3 skills, 4 design system, 5 plan, 6 execution.
- Work on one stage at a time: the first one in the stage table that is not closed. Never start a stage before the owner closes the one before it.
- Only the owner closes a stage. A stage that does not apply to the project is also closed by the owner, as not applicable. Never skip one.
- No code before stage 6. In stages 1 to 5, do not write the product's code, generate a scaffold, or add a dependency.
- A project already started follows the same six stages. What differs is under "Project already started" in each reference file.
- `docs/wiki/` is the project's source of truth, and `docs/wiki/README.md` is its single entry point. Keep the state of the work there, never only in the conversation.
- Mark every statement in the wiki Decided, Proposed, or Open. Decided means numbered in `docs/wiki/decisions.md`. A technology that the owner's brief names is Proposed until the owner decides it in stage 2.
- Only the owner turns Proposed into Decided. Never invent a missing definition: write it as an open question and ask.
- Record each decision with its date and the owner's words verbatim, in the owner's language.
- Ask one question at a time, with a recommendation, then stop and wait. Use the `AskUserQuestion` tool when it is available: put the recommended option first and say what each option costs.
- "Stage" names only the six stages. One step of the work plan is a "unit". Never use one word for both.
- Read the reference file of the current stage only.

## Steps

1. Read `docs/wiki/README.md` if it exists. When it has a stage table, the current stage is the first one that is not closed. Tell the owner which one it is, in one line.
2. When every stage is closed, wait until the owner starts a new phase, then follow "A new phase" in `references/1-wiki.md`.
3. When there is no stage table, the current stage is stage 1. Look at whether the repository already holds code: if it does, this is a project already started.
4. Read the reference file of the current stage and do its steps.
5. Write each result in the wiki when it is produced, with the `write-docs` skill. Then rewrite "Where work stands" in `docs/wiki/README.md`.
6. When the closing condition of the stage holds and this skill's `scripts/check-wiki.sh docs/wiki` passes, list what the stage leaves Decided, Proposed, and Open, and ask the owner to close it.
7. When the owner closes it, record that as a decision. In the stage table, set the stage to Closed with the date and the next stage to Open.

## Output

- Written: the pages of `docs/wiki/`, with `README.md` up to date.
- Returned to the owner: the current stage, the pages that changed, and either one question or the request to close the stage.

## References

Each file holds the steps of one stage, what differs for a project already started, and the closing condition. Read a file when its stage is the current one.

- `references/1-wiki.md` — the files of the wiki, the stage table, and the topics a product definition covers.
- `references/2-technology.md` — how each technology is decided, and what the architecture page contains.
- `references/3-skills.md` — the skills the agent needs for the decided technology.
- `references/4-design-system.md` — the visual identity, the tokens, and the patterns.
- `references/5-plan.md` — the work plan, in units, and how a unit is delivered.
- `references/6-execution.md` — building the plan, unit by unit.
