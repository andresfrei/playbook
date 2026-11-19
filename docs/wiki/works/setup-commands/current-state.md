# Current state

What exists on 2026-11-18, before this work, for the three commands. Checked by reading the files named; nothing was run.

## `/playbook:init`

- Skill `plugins/playbook/skills/init/SKILL.md`, script `plugins/playbook/skills/init/scripts/init.sh` (TD31, D184, D193). Only when the person types it.
- `init.sh scan` prints the product's plugins and whether each is on, the other plugins on, and whether a global `CLAUDE.md` exists. The skill does not use that to skip anything: it always asks "wiki" or "all", and "local" or "user".
- `init.sh apply` runs `claude plugin install` for each plugin at the scope. Installing a plugin already installed turns it on again, so a second run does no harm, but it asks everything again.
- Skill pairs: a choice "Turn mine off" is written as `skillOverrides` in a settings file; a choice about a project's skill is a decision in the wiki. A choice "Keep both" about a skill of the person or of another plugin is written nowhere, so a second run cannot know it was settled. This work stores it in the person's settings (setup-commands-8).
- It never looks at `docs/wiki/`.

## A wiki's skeleton

- Written today only by `prepare-project`, in "A new project" of `plugins/playbook-wiki/skills/prepare-project/references/1-wiki.md`: it asks the owner and the first work, writes the project's `README.md` and the work's folder, runs `wiki-format.sh mark`, and asks about the two `CLAUDE.md` sentences.
- `/playbook-wiki:doctor` repairs a wiki that exists and stops when there is none.

## Models of the agents

- `plugins/playbook-agents/models.conf` holds the model and effort of `explore`, `write`, and `review` (TD11). `scripts/set-models.sh` writes them into the `model` and `effort` lines of `plugins/playbook-agents/agents/<agent>.md`, and `scripts/verify.sh` fails when they differ.
- Both files are inside the plugin. A person who installed from GitHub has them in Claude Code's plugin cache: an edit there is lost at the next update, and `scripts/set-models.sh` is not part of the installed plugin.
- Defaults: `explore` haiku medium, `write` sonnet medium, `review` opus high.

## What separates this from the definitions

- `/playbook:init` needs to read what is on before asking, and to remember a "Keep both" choice (setup-commands-5, setup-commands-8).
- The skeleton moves out of `prepare-project` into `/playbook-wiki:init` (setup-commands-2).
- A place for the person's models outside the plugin, for one repository and for every project, that Claude Code honours (setup-commands-4). Which mechanism is stage 2.
