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
| setup-commands-U1 | Not started | | | |
| setup-commands-U2 | Not started | | | |
| setup-commands-U3 | Not started | | | |
| setup-commands-U4 | Not started | | | |
| setup-commands-U5 | Not started | | | |
