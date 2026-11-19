# Setup commands: product definition

What the three commands do for the person who uses them. Each statement is Decided (it cites a decision of [decisions.md](decisions.md)), Proposed, or Open (it cites a question of [questions.md](questions.md)).

## The problem

- A person can install the playbook for every project and then open a repository that has no wiki: an old project, or someone else's project already started. Today nothing writes only a wiki there. The only route is `prepare-project`, which also opens a work and runs stage 1 (setup-commands-1).
- A person who installs `playbook-agents` from GitHub cannot choose the model and effort of the agents. They live in `plugins/playbook-agents/models.conf` (TD11), inside the plugin. An edit to the installed copy is lost at the next update (setup-commands-1).
- `/playbook:init` run a second time asks every question again, as if nothing was on (setup-commands-1).

## Who uses them

- The person who installed the playbook, in their own repository or in someone else's. In the second case they may not be the project's owner (setup-commands-3).

## The commands

### `/playbook:init`

Decided (setup-commands-1): it starts the playbook only where it is not on yet, and does not redo what is.

Decided (setup-commands-5): run again, it shows what is on and where, and asks "Keep" or "Change". "Keep" ends it; "Change" runs the wizard again and asks only about skill pairs no earlier choice settled. A "Keep both" choice is remembered in the person's settings, under a key of the playbook (setup-commands-8); with a skill of the project, in the repository's (setup-commands-15).

Decided (setup-commands-6): at its end, in a repository with no wiki, it asks whether to add one and runs `/playbook-wiki:init` only on a yes.

### `/playbook-wiki:init`

Decided (setup-commands-1): it writes the skeleton of a wiki in a repository that has none, and does not run stage 1.

Decided (setup-commands-2): the skeleton is what "A new project" in `prepare-project` writes before stage 1, without the folder of a first work:

1. `docs/wiki/README.md`, with the project and its owner. The owner is always asked, recommending the git `user.name` of the person running the command (setup-commands-3).
2. `docs/wiki/.format`, written by `wiki-format.sh mark`.
3. The two sentences of the format in the project's `CLAUDE.md`, after asking.

`prepare-project` calls this command for a new project and keeps only the first work, so the skeleton has one writer (setup-commands-2). When a wiki already exists, it says so and changes nothing; when its format is behind, it points to `/playbook-wiki:doctor` (setup-commands-9).

### `/playbook-agents:config`

Decided (setup-commands-1): it sets the model and the effort of `explore`, `write`, and `review`, and the choice survives an update of the plugin.

It shows the current value of each agent and where it comes from, and asks for the new ones (setup-commands-9). Decided (setup-commands-4): it asks whether they apply to this repository or to every project, as `/playbook:init` asks, and the repository's value wins. How the value reaches Claude Code is stage 2.

## What they must not do

- No command writes a `CLAUDE.md` except the two sentences of the format, after asking (format 4).
- `/playbook-wiki:init` opens no work and writes no decision (setup-commands-1).
- `/playbook-agents:config` covers Claude Code only. Codex keeps the models of its installer (codex-support-4, setup-commands-7).

## Qualities and limits

- Each command does nothing that is not needed and says what it found (setup-commands-1).
- The same rules as `/playbook:init`: only when the person types it, and nothing of another tool is changed (TD31, D184, setup-commands-9).
