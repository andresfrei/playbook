---
name: define
description: Define a change with the owner before code, such as a feature, a new technology, or a new project. Names the type of change, interviews the owner until the spec can be written, and records each decision in their words.
---

## When to use

- The owner asks for a change larger than a small one: a feature, a new technology, or a new project.
- The owner asks to define, specify, or plan a change before it is built.

Do not use it for a small change, one that could be finished from the request and the diff alone: do it directly.

## Rules

- Ask one question at a time, with a recommendation, then stop and wait. Ask it with `AskUserQuestion` when available, one question per dialog, recommended option first; ask in text a question that has no options to offer.
- Only the owner decides. Before each question, search `docs/playbook/works/*/decisions.md`; when a decision already answers it, cite it instead of asking.
- Record an answer as a decision only when the owner chose between real options or set a limit you could not infer, the code does not say it, and someone would ask why in six months. Going ahead with a step is not a decision.
- Write only what the code does not say: what, why, the decisions, and how to check it. Do not describe files or architecture that Claude can read.
- No code, scaffold, or dependency until the owner accepts the spec.

## Steps

1. Read `docs/playbook/README.md`. When there is none and the repository already holds code, offer to run the skill `audit-wiki` to adopt the project first; run it on a yes, and otherwise stop (agent-runs-skills-1). For a new project, create the wiki first: `README.md` with the product in two lines, the owner's name, the open work, and the list of pages; ask the owner for what is missing.
2. Name the type of change in one line and let the owner correct it:

   | Type | Steps that follow |
   |------|-------------------|
   | Feature on the project's technology | Define |
   | Feature that adds or replaces a technology | Define, Technology, Skills |
   | New project | Define, Technology, Skills, and Design when it has an interface |

3. Choose the work's name, lowercase words with hyphens, and create `docs/playbook/works/<name>/` with `spec.md` and `decisions.md`.
4. **Define.** Interview the owner until the spec can be written: what the change does, for whom, what is out of scope, and how it will be checked. Read the code first so you ask only what the code cannot answer.
5. **Technology**, when the type has it. List what the change needs from its technology. For each need, propose the simplest candidate, check it in its current documentation (version, limits, price), and write the link and the date. Say when something is recalled and not checked. Ask the owner to decide each one. For a new project, also offer the two optional lines of `technology.md`, and the owner may leave either Open (delivery-versioning-1, -3):
   - `Delivery default:` one of three forms, or the owner's words: one branch and one pull request per work; one per unit; a worktree of its own for parallel sessions (delivery-versioning-2).
   - `Versioning:` what carries a version, where it is declared, and when a tag is made: after the merge of each work, when `close` recommends it; after several works together, when the owner asks; never (delivery-versioning-3).
6. **Skills**, when the type has it. For each new technology, read the names and descriptions of the skills available, and propose one: a skill that exists, to install after reading it; one to write with `skill-creator`; or none needed. Install or write a skill only after the owner's yes.
7. **Design**, for a new project with an interface. Agree with the owner on the typeface, the colours, and the layout, each with its reason, in `docs/playbook/design.md`.
8. Write `spec.md`: what and why, out of scope, the technology and skills chosen, the check that says it is done, and its units: size each one to fit one short session, with its own check, so the `/clear` after a unit falls where the spec holds the handoff (session-cost-4). Add the line `Delivery:` copied from the `Delivery default` of `technology.md`; ask only when the project has none, or when the work needs another way, such as a worktree for parallel sessions (delivery-versioning-1).
9. Run `sh "${CLAUDE_PLUGIN_ROOT}/scripts/check-wiki.sh" docs/playbook` and fix what it lists.
10. Look for the line `Build mode:` in `~/.claude/CLAUDE.md` and in `CLAUDE.local.md`. When neither holds it, ask once, in one dialog, the mode (`main` or `builder`) and where to write it (`~/.claude/CLAUDE.md` for every project, or `CLAUDE.local.md` for this one), and write the line there (build-mode-4). The local line wins over the global one (build-mode-2).
11. Show the spec and ask the owner to accept it once. Record the acceptance as a decision, and set the work as the open work in `docs/playbook/README.md`, naming the first unit as the next one (session-cost-8). Then recommend in one line. In `main`: `/clear`, `/model sonnet`, and build the first unit by name (session-cost-1). In `builder`: stay on the current model and build the first unit by name with `builder` (build-mode-6).

## Gotchas

- A decision row has five columns: `| ID | Date | Decision | Who decided | Their words |`. IDs are `<work>-<n>`. "Their words" holds the owner's own text, or the option they chose, quoted.
- An answer that differs from an earlier decision replaces it: start the new decision with "Replaces <ID>." and leave the earlier row as it is; `close` marks it when it moves the shared pages to the new decision.
- An answer the owner already gave in an earlier decision is a rule waiting to be written: propose the line, or the delegation in the project's `CLAUDE.md`, citing both decisions.

## Output

- The type of change, the work's folder, and the spec accepted, or the one question waiting for the owner.
