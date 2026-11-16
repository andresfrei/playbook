---
name: init
description: Start the playbook in a repository. Asks whether to use the wiki alone or the whole product, and for this repository or every project, then turns the plugins on.
disable-model-invocation: true
---

## When to use

- The person types `/playbook:init` to start the playbook in a repository, or to change what is on.

Do not use it for Claude Code's own `/init`, which writes a `CLAUDE.md`.

## Rules

- Write in no `CLAUDE.md`, the person's or the project's.
- Read no file to decide. The script reads the state and applies the answers.
- Change nothing of another tool. Only tell the person what is on.
- Do not handle skills that are not the product's. That is another step.
- Ask with the AskUserQuestion tool, the recommended option first.

## Steps

1. Run `sh "${CLAUDE_SKILL_DIR}/scripts/init.sh" scan` and read what it prints.
2. Ask two questions with AskUserQuestion:
   - What to use: "The wiki alone" (`wiki`, only the plugin `playbook-wiki`) or "The whole product" (`all`, `playbook-wiki` and `playbook-agents`).
   - Where: "This repository" (`local`, kept out of git) or "Every project" (`user`).
   For the whole product, also ask the language the agent talks to the person in, or none, to follow the language the person writes in. Recommend the language the person is writing in.
3. For the whole product, before turning `playbook-agents` on, tell the person from the scan which other plugins are on and whether a global `CLAUDE.md` exists. Two agent systems in one session collide. Only tell. The person decides whether to go on; stop when they do not.
4. Run `sh "${CLAUDE_SKILL_DIR}/scripts/init.sh" apply <wiki|all> <local|user> [language]`, with the answers; leave the language out for none. Show its output. When it fails, show the failing command and its message, and stop.
5. Tell the person that what was turned on is used from the next session. A plugin turned on during a session is not used by that session.

## Output

- What the scan found: the product's plugins, the other plugins on, the global `CLAUDE.md`.
- The commands that ran and their results.
- What is on now, where, and that it takes effect from the next session.
