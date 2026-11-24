# define

The skill `/playbook:define` defines a change with the owner before any code is written, and records each decision in the owner's words.

## When it runs

- The owner asks for a change larger than a small one: a feature, a new technology, or a new project.
- The owner asks to define, specify, or plan a change before it is built.
- It is not used for a small change, one that could be finished from the request and the diff alone.

## What it reads

- `docs/playbook/README.md`. When there is none and the repository already holds code, it offers to run [audit](audit.md) first.
- The `decisions.md` of every work, before each question, so it cites a decision that already answers instead of asking again.
- The project's code, so it asks only what the code cannot answer.
- For a new technology: its current documentation (version, limits, price), and the names and descriptions of the skills available.
- The line `Build mode:` in `~/.claude/CLAUDE.md` and in `CLAUDE.local.md`.

## What it writes

- For a new project without a wiki, `docs/playbook/README.md` first.
- A folder `docs/playbook/works/<name>/` with `spec.md` (what and why, out of scope, technology and skills chosen, the check, and the units) and `decisions.md` (one row per decision, with the owner's words).
- On a new technology, the link and the date of each check; `design.md` for a new project with an interface; a skill only after the owner says yes.
- The line `Delivery:` in the spec, copied from `technology.md`.
- The line `Build mode:` in `~/.claude/CLAUDE.md` or `CLAUDE.local.md`, when neither has it and the owner chooses where.
- The accepted spec as a decision, and the work as the open work in `docs/playbook/README.md`, with its first unit named as the next one.
- It runs the [wiki](wiki.md) check and fixes what it lists. It writes no code, scaffold, or dependency until the owner accepts the spec.

## What it asks the owner

- One question at a time, with a recommendation, asking with `AskUserQuestion` when available.
- The type of change, which the owner may correct: a feature on the project's technology, a feature that adds or replaces a technology, or a new project.
- The interview itself: what the change does, for whom, what is out of scope, how it will be checked.
- Each technology, skill, and design choice, and the optional lines `Delivery default:` and `Versioning:` for a new project.
- The build mode, once, when no file has it.
- Acceptance of the spec, once; then whether to close the session and continue in a clean one.

## Connects to

- [audit](audit.md), offered when the project has code and no wiki.
- [close](close.md), which closes the work this skill defines.
- [builder](builder.md) and [build-mode](build-mode.md), which build the units.
- [wiki](wiki.md), [rules](rules.md), and [sessions](sessions.md).

Source: [plugins/playbook/skills/define/SKILL.md](../../plugins/playbook/skills/define/SKILL.md)
