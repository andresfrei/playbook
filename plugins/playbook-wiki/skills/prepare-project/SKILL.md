---
name: prepare-project
description: Start a new project, a new work or phase in a project with a wiki (such as a feature to define before code), or prepare one already started when asked. Runs six stages before any code, from the wiki to plan and execution, each closed by the owner.
---

## When to use

- The owner starts a new project.
- The owner explicitly asks to prepare a project already started.
- The owner starts a new phase of a project with a wiki, which is a new work, or continues or closes a stage of the open work.

Do not use it for a small change in an existing repository that has no wiki. Do that change directly and do not propose this method.

## Rules

- Read the format of a wiki, `<this skill's folder>/../../format.md`, before you write in the wiki.
- A work is prepared in six stages, in this order: 1 wiki, 2 technology, 3 skills, 4 design system, 5 plan, 6 execution.
- Work on one stage at a time. Never start a stage before the one before it is closed.
- Only the owner closes a stage, also as not applicable, or a delegation does. Never skip one.
- No code before stage 6. In stages 1 to 5, do not write the product's code, generate a scaffold, or add a dependency.
- For a project already started, also follow "Project already started" in each reference file.
- What is in progress lives in the work's folder: its decisions, questions, plan, and the pages of each stage. The shared pages change only when the work closes.
- Mark every statement Decided, Proposed, or Open. Decided means a row of the work's `decisions.md`.
- When a decision changes a shared page that existed before the work, say so, name the project's owner from `docs/wiki/README.md`, and ask who decides. Record the name given; do not enforce it.
- Record each decision with its date, in the decider's language; its kind and answer exactly as `format.md` lists them.
- Before asking, read `references/delegation.md`. Ask one question at a time, with a recommendation, then stop and wait. Use `AskUserQuestion` when available, recommended option first, with what each option costs.
- "Stage" names only the six stages. One step of the work plan is a "unit". Never use one word for both.

## Gotchas

- After the recommendation, the closing line asks two things, such as "Which breads does the bakery bake each day, and can customers order ahead?". End with the one question the recommendation answers.

## Steps

1. Run `sh "${CLAUDE_SKILL_DIR}/../migrate/scripts/wiki-format.sh" status docs/wiki`; on any output, show it and stop.
2. Read `docs/wiki/README.md`. When there is none, this is a new project, or a project already started when the repository holds code: follow "A new project" in `references/1-wiki.md`.
3. The current work is the folder under `docs/wiki/works/` whose `README.md` says Open. When none does, ask the owner for the work's name and what it is for; create its folder at the first decision, question, or plan. When several do, ask which.
4. The current stage is the first one in the work's stage table that is not closed. Tell the owner which one it is, in one line.
5. Do the steps of the current stage's reference file.
6. Write each result in the work's folder when it is produced, with the `write-docs` skill. Then rewrite "Where work stands" in the work's `README.md`.
7. When the closing condition of the stage holds and `sh <this skill's folder>/../../check-wiki.sh docs/wiki` passes, list what it leaves Decided, Proposed, and Open, and ask the owner to close it, unless delegated.
8. When it is closed, record that as a decision. In the stage table, set the stage to Closed with the date and the next stage to Open.

## Output

- Written: the work's folder, with its `README.md` up to date.
- Returned: the current stage, the pages that changed, and one question or the request to close the stage.

## References

Read the current stage's references.

- `references/1-wiki.md` — project topics.
- `references/2-technology.md` — technology and architecture.
- `references/3-skills.md` — required skills.
- `references/4-design-system.md` — identity, tokens, patterns.
- `references/5-plan.md` — plan and delivery.
- `references/6-execution.md` — execution and close.
- `references/delegation.md` — delegations.
- `references/evidence.md` — consolidation and graduation at close.
- `references/tasks.md` — recurring tasks at close.
- `references/working-agents.md` — the client's working-agent instructions: scripts, review findings, task profiles. Read it with `6-execution.md`, `evidence.md`, `tasks.md`.
