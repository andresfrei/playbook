---
name: define
description: Define a change with the owner before code, such as a feature, a new technology, or a new project. Names the type of change, interviews the owner until the spec can be written, and records each decision in their words.
---

## When to use

- The owner asks for a change larger than a small one: a feature, a new technology, or a new project.
- The owner asks to define, specify, or plan a change before it is built.

Do not use it for a small change, one that could be finished from the request and the diff alone: do it directly.

## Rules

- Ask one question at a time, with a recommendation, using `AskUserQuestion` when available, recommended option first. Then stop and wait.
- Only the owner decides. Record each answer as a decision with the owner's words verbatim.
- Write only what the code does not say: what, why, the decisions, and how to check it. Do not describe files or architecture that Claude can read.
- No code, scaffold, or dependency until the owner accepts the spec.

## Steps

1. Read `docs/wiki/README.md`. When there is none, create the wiki first: `README.md` with the product in two lines, the owner's name, the open work, and the list of pages; ask the owner for what is missing.
2. Name the type of change in one line and let the owner correct it:

   | Type | Steps that follow |
   |------|-------------------|
   | Feature on the project's technology | Define |
   | Feature that adds or replaces a technology | Define, Technology, Skills |
   | New project | Define, Technology, Skills, and Design when it has an interface |

3. Choose the work's name, lowercase words with hyphens, and create `docs/wiki/works/<name>/` with `spec.md` and `decisions.md`.
4. **Define.** Interview the owner until the spec can be written: what the change does, for whom, what is out of scope, and how it will be checked. Read the code first so you ask only what the code cannot answer.
5. **Technology**, when the type has it. List what the change needs from its technology. For each need, propose the simplest candidate, check it in its current documentation (version, limits, price), and write the link and the date. Say when something is recalled and not checked. Ask the owner to decide each one.
6. **Skills**, when the type has it. For each new technology, read the names and descriptions of the skills available, and propose one: a skill that exists, to install after reading it; one to write with `skill-creator`; or none needed. Install or write a skill only after the owner's yes.
7. **Design**, for a new project with an interface. Agree with the owner on the typeface, the colours, and the layout, each with its reason, in `docs/wiki/design.md`.
8. Write `spec.md`: what and why, out of scope, the technology and skills chosen, the check that says it is done, and, for a change too large for one sitting, its units, each with its own check.
9. Run `sh "${CLAUDE_PLUGIN_ROOT}/scripts/check-wiki.sh" docs/wiki` and fix what it lists.
10. Show the spec and ask the owner to accept it once. Record the acceptance as a decision, and set the work as the open work in `docs/wiki/README.md`.

## Gotchas

- A decision row has five columns: `| ID | Date | Decision | Who decided | Their words |`. IDs are `<work>-<n>`. "Their words" holds the owner's own text, or the option they chose, quoted.

## Output

- The type of change, the work's folder, and the spec accepted, or the one question waiting for the owner.
