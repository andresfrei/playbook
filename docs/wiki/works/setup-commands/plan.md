# Setup commands execution plan

Accepted in setup-commands-14. The units build what [current-state.md](current-state.md) lists as missing, with the modules and data of [architecture.md](architecture.md).

## Units

| ID | Unit | Deliverable and ending condition | Accepted by |
|----|------|---------------------------------|-------------|
| setup-commands-U1 | Model hook | A `PreToolUse` hook on `Agent` in `plugins/playbook-agents/hooks/`, registered in its `hooks.json`. Tests on sample inputs pass: nothing set leaves the input unchanged; the person's value is added; the repository's value wins; another agent is untouched; every field of the input is kept. A `claude -p` trial shows `playbook-agents:explore` running on the model set. `review-change` finds nothing open. | Evidence |
| setup-commands-U2 | `/playbook-agents:config` | The skill, with its script and two evaluation cases. The script prints each agent's model, effort, and source (repository, person, or `models.conf`), and writes a choice at the scope given, refusing a model that is not an alias or an effort out of the list. Tests pass on temporary settings files, keeping every other key. A trial that saves a permission in Claude Code shows whether the `playbook` key survives; the result is recorded. `review-change` finds nothing open. | Evidence |
| setup-commands-U3 | `/playbook-wiki:init` | The skill, with two evaluation cases, writing the skeleton of setup-commands-2 and setup-commands-3, and doing nothing where a wiki exists. "A new project" of `prepare-project` calls it. In a temporary repository the skeleton passes `check-wiki.sh`, and a second run changes nothing. | Judgement |
| setup-commands-U4 | `/playbook:init` run again | `init.sh scan` also prints the `playbook` key and whether `docs/wiki/README.md` exists. The skill asks "Keep" or "Change", writes "Keep both" choices to `keepBoth`, and offers `/playbook-wiki:init` in a repository with no wiki. Tests of `init.sh` pass on temporary settings files. `review-change` finds nothing open. | Judgement |
| setup-commands-U5 | Shared pages | What the work defined is written in `01-product/skill-set.md`, `03-technology/architecture.md`, `04-skills/`, and the plugins' `README.md`, each citing its decisions. `check-wiki.sh` and `scripts/verify.sh` pass. | Evidence |

U3 and U4 are accepted by judgement because each writes a skill's text and a flow the person uses, which a check cannot judge.

## Order

U1, then U2, which writes the key U1 reads. U3, then U4, which offers U3. U5 last.

## Delivery

Decided (setup-commands-14), as the repository's history delivers: the five units in order on `feat/setup-commands`, one at a time, and the work reaches `main` by one pull request. Push, merge, and release stay the owner's decisions.

## Left out

- Codex (setup-commands-7).
- A full `claude-` model id or `inherit` set by the person: the Agent call takes an alias only ([technology.md](technology.md)).
- Changes to `models.conf`, `scripts/set-models.sh`, or the agents' files.

## Progress

| Unit | Status | Evidence | Done on | Owner acceptance |
|------|--------|----------|---------|------------------|
| setup-commands-U1 | Done | `scripts/verify_test.sh`: all cases passed, 20 for the hook, each case of the ending condition among them; `scripts/verify.sh` and ShellCheck passed. `claude -p` on Claude Code 2.1.327, hook from a settings file, a repository value `explore: sonnet low`: Claude called `playbook-agents:explore` with `model: opus`, the subagent ran on `claude-sonnet-5-5` by its answer and `modelUsage`. So `updatedInput` applies with no `permissionDecision`, and of a key named twice the last wins. `review-change`: no findings; it notes BusyBox awk takes 3.7 s on a 100 KB prompt, against 0.04 s for GNU awk. | 2026-11-18 | |
| setup-commands-U2 | Done | `scripts/verify_test.sh`: all cases passed, 27 for `config.sh`; `scripts/verify.sh` and ShellCheck passed. Trial on Claude Code 2.1.327: `claude plugin disable` and then `enable` at local scope rewrote `.claude/settings.local.json` and kept the `playbook` key; saving a permission from the interactive prompt was not run. Evals, one run per arm: `config-set-repository` 1.00 with the plugin, 0.00 without; `config-keeps-settings` 0.75 and 0.25, its judge passing alone on a rerun. The eval sandbox keeps `.claude/` read-only, so the cases grade the command and the reply, not the file. `review-change` found three defects, all fixed with a test each: `show` disagreed with the hook on an invalid repository value, `local` followed the current folder, a malformed file was written. | 2026-11-18 | |
| setup-commands-U3 | Built | The skill `plugins/playbook-wiki/skills/init/` and its steps in `plugins/playbook-wiki/skeleton.md`, shared with `prepare-project`, whose "A new project" now reads that file: `scripts/verify.sh` forbids a skill reading inside another. In a temporary repository the skeleton passed `wiki-format.sh mark` and `check-wiki.sh`. Evals, one run per arm: `init-new-wiki` wrote the README with the owner, the page table, and the two `CLAUDE.md` sentences, ran `mark`, and opened no work, 5 of 5 graders with the plugin; `init-wiki-exists` changed nothing and pointed to `/playbook-wiki:doctor`, 1.00 with the plugin, 0.75 without. The eval sandbox keeps the temporary folder read-only, so `mark` cannot write `.format` there and no grader reads it. | | |
| setup-commands-U4 | Not started | | | |
| setup-commands-U5 | Not started | | | |
