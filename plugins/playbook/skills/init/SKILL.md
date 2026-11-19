---
name: init
description: Start the playbook in a repository, or change what is on. Asks whether to use the wiki alone or the whole product, and where, settles the skills that do the same job, turns the plugins on, and offers a wiki.
disable-model-invocation: true
---

## When to use

- The person types `/playbook:init` to start the playbook in a repository, or to change what is on.

Do not use it for Claude Code's own `/init`, which writes a `CLAUDE.md`.

## Rules

- Write in no `CLAUDE.md`, except the two sentences of a wiki's skeleton after a yes.
- Read no file to learn what is on or which skills exist. The script reads them and applies the answers.
- Change nothing of another tool; only tell the person what is on. Write only the choices of step 8 and, on a yes, a wiki's skeleton.

## Steps

1. Run `sh "${CLAUDE_SKILL_DIR}/scripts/init.sh" scan`. When this or another run of the script fails, show its message, and stop.
2. When a plugin of the product is on here, show what is on and at which scope, and ask "Keep" or "Change". On "Keep", go to step 9.
3. Ask two questions, with AskUserQuestion when available, the recommended option first, with its reason:
   - What to use: "The wiki alone" (`wiki`, only the plugin `playbook-wiki`) or "The whole product" (`all`, `playbook-wiki` and `playbook-agents`).
   - Where: "This repository" (`local`, kept out of git) or "Every project" (`user`).
   For the whole product, also ask the language the agent talks to the person in, or none, to follow the language the person writes in. Recommend the language the person is writing in.
4. For the whole product, before turning `playbook-agents` on, tell the person from the scan which other plugins are on and whether a global `CLAUDE.md` exists. The person decides whether to go on; stop when they do not.
5. Run `sh "${CLAUDE_SKILL_DIR}/scripts/init.sh" skills <wiki|all>`. Compare each skill the choice turns on with each other skill listed, by name and description. Point out each pair that does the same job; sharing a name alone makes no pair. Leave out a skill marked `(off)` or `(kept)`, and a pair the wiki's page of skills under `docs/wiki/04-skills/` already settles. When there is no pair, say so in one line.
6. For each pair, ask the person what to do. Write nothing yet.
   - With a skill of the person: "Keep both", "Turn mine off in this repository", "Turn mine off in every project", or "Leave the product off".
   - With a skill of the project or of another plugin: "Keep both" or "Leave the product off".
   - "Leave the product off": stop here and change nothing. Say which of the product's plugins the scan shows on: they stay on.
7. Run `sh "${CLAUDE_SKILL_DIR}/scripts/init.sh" apply <wiki|all> <local|user> [language]`, with the answers; leave the language out for none. Show its output.
8. Then write each choice:
   - A skill of the person turned off: add `"<name>": "off"` under `skillOverrides` in `.claude/settings.local.json` for this repository, or in the `settings.json` of the folder that holds the person's skills folder the script printed, for every project. Create the key or the file when missing, and change nothing else in it.
   - "Keep both" with a skill of the person or of another plugin: run `sh "${CLAUDE_SKILL_DIR}/scripts/init.sh" keep <local|user> <name>`, at the scope of step 3, with the name as `skills` printed it.
   - A choice about a skill of the project, when `docs/wiki/` exists: a decision with the person's words, in the work this branch carries, as the format the script printed says. Write nothing in `docs/wiki/04-skills/`: it changes when the work closes.
9. When the scan says "Wiki of this repository: missing", ask whether to add one. On a yes, read the file it names after "The skeleton of a wiki" and do its steps; when it names none, point to `/playbook-wiki:init`.
10. Tell the person that what was turned on, and a skill turned off, take effect from the next session.

## Output

- What the scan found: the product's plugins, the other plugins on, the global `CLAUDE.md`, and whether the repository has a wiki.
- Each pair of skills found, and what the person chose for it.
- The commands that ran and their results, and the files written.
- What is on now, where, and that it takes effect from the next session.
