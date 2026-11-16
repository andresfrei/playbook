# Plan for phase 4

The work of phase 4, the shared core, as an ordered list of units. Stage 5 of phase 4. It builds what [../03-technology/architecture-phase-4.md](../03-technology/architecture-phase-4.md) describes, with the technology of TD24 and TD26 to TD33. The plans of phases 1 to 3, U1 to U27, are in [plan.md](plan.md), [plan-phase-2.md](plan-phase-2.md), and [plan-phase-3.md](plan-phase-3.md); the numbers continue from them.

The owner accepted it (D197). How a unit is delivered is D196.

## Progress

| Unit | Status | Evidence |
|------|--------|----------|
| U28 | Done 2026-11-16. Asked "¿Aceptás la U28 y la uno a `v2`?"; the owner answered "acepto" | Begun when the owner answered the request to start it with "ahora cerremmos esta v2", and continued after the owner logged in to the trial folder, `~/.claude-playbook`. Sixteen rows in [../03-technology/phase-4.md](../03-technology/phase-4.md), under "Tried in U28", each with the command, what was seen, and whether it is as documented. Thirteen are as documented and three are not documented in the pages read; none goes against the documentation, so nothing needs a replacement. What it changes in the units that follow is listed there under "What follows from it". The three plugins and the repositories of the trial were deleted, and the trial folder holds no plugin, marketplace, or skill; it stays logged in for the units that need it |
| U29 | Built 2026-11-16 (waiting for the owner's review) | Branch `feat/u29-remove-opencode`, built by the `write` agent and read by the main session. Removed: `opencode/agents/`, `scripts/install-opencode.sh`, the opencode parts of `scripts/set-models.sh`, `scripts/verify.sh`, and `scripts/verify_test.sh`, the two opencode columns of `plugin/models.conf`, and the mentions in the repository's `README.md`, `CONTRIBUTING.md`, `.github/ISSUE_TEMPLATE/bug.yml`, and one sentence of `plugin/skills/prepare-project/references/1-wiki.md`. Run there on 2026-11-16: `grep -ril opencode --exclude-dir=.git --exclude-dir=docs .` printed nothing; `bash scripts/verify.sh` printed "verify passed: 790 words loaded at session start, limit 800", as before; `bash scripts/verify_test.sh` printed "all cases passed", with 125 cases where there were 172; `sh scripts/set-models.sh --check` exited 0; the three files of `plugin/agents/` did not change. Not met: `shellcheck scripts/*.sh` prints 26 notes, all SC2016 in `scripts/verify_test.sh`; see the notes of U29 below |
| U30 | Not started | |
| U31 | Not started | |
| U32 | Not started | |
| U33 | Not started | |
| U34 | Not started | |
| U35 | Not started | |
| U36 | Not started | |
| U37 | Not started | |
| U38 | Not started | |
| U39 | Not started | |
| U40 | Not started | |
| U41 | Not started | |

The status of a unit is one of: Not started, Built (waiting for the owner's review), Done.

## How every unit works

- A unit delivers one thing and ends on a condition that can be observed. The owner reviews each unit when it ends, before the next one starts (R10).
- How a unit is delivered (D196). It is how this repository delivers now (TD5, D163, D165), with one difference:
  - Each unit is built on its own branch, in its own worktree under `~/dev/playbook-worktrees/` (TD5).
  - The difference: an accepted unit is merged into one branch for the whole phase, `v2`, by a local fast-forward merge, and not into `main`. The owner's Claude Code loads the plugin from the clone on `main` (TD5), and from U30 on the plugin it loads no longer exists in the branch. `main` gets the whole of `v2` at once, by one pull request that the owner merges, when U40 is accepted.
  - Units are built one at a time.
  - Pushing, the pull request, and the tag `v2.0.0` are the owner's decisions (R14, TD22).
- U29 to U40 change this repository. Each of them also ends only when `bash scripts/verify.sh` exits 0, `bash scripts/verify_test.sh` prints "all cases passed", and `shellcheck` prints nothing for the scripts.
- The wiki of phase 4 is the first commit of `v2`, and `v2` has its own worktree, `~/dev/playbook-worktrees/v2`. The wiki is changed there for the rest of the phase, so the clone stays on `main` (TD5).
- "The trial environment" is a second configuration folder of Claude Code, used through `CLAUDE_CONFIG_DIR` (TD6), with the plugins of the unit's worktree. `~/.claude` is not touched. A unit that uses it starts only when the owner authorizes it.
- U41 changes the owner's machine. It starts only when the owner asks for it, and each step that installs, enables, or deletes something there needs the owner's authorization.
- A change that is risky by R20 is read by the `review` agent before the owner reviews the unit: the scripts that change a person's settings, the hooks, and the check.

## Units

| # | Unit | Delivers | Ends when | Needs |
|---|------|----------|-----------|-------|
| U28 | The trial of Claude Code | Each item under "Not verified" in [../03-technology/phase-4.md](../03-technology/phase-4.md), tried in the trial environment with three small plugins made for the trial, outside this repository: a plugin on for one repository only, when a change is used, the dependency, a command only the person calls, the hook for a new subagent, the hook before a merge command, what `claude plugin list` and `details` print, `skillOverrides`, and a `userConfig` value read by a hook | That page says, for each item, the command run, what was seen, and whether it is as documented. For each one that is not, the owner decided what replaces it | The owner's authorization |
| U29 | opencode out of the repository | `opencode/agents/`, `scripts/install-opencode.sh`, the opencode parts of `scripts/set-models.sh`, `scripts/verify.sh`, and `scripts/verify_test.sh`, and the opencode steps of the repository's `README.md`, removed (D191) | `grep -ril opencode` finds files only under `docs/wiki/` | |
| U30 | Three plugins | `plugins/playbook/`, `plugins/playbook-wiki/`, and `plugins/playbook-agents/`, each with its manifest; the three entries of the marketplace; the dependency of `playbook-agents` on `playbook-wiki`; the skills, agents, rules, hooks, and evaluation cases moved as TD30 says, with no change of text beyond the names that must change; `scripts/set-models.sh` and `scripts/verify.sh` working on the three (TD26, TD30, TD31) | `claude plugin validate` passes for each plugin. `plugin/` no longer exists | U28, U29 |
| U31 | The contract and its hooks | `plugins/playbook-wiki/contract.md`, with R5 to R8, R10, and R12 under their numbers, who decides (D172), the step at the merge (D173), the wiki in English (D187), and the two layers (D189). Those rules leave `rules.md`. A hook that prints the contract at the start of a session and one that adds it to a new subagent (TD29). The size limits counted for each plugin, in `scripts/verify.sh` and in [../01-product/style-guide.md](../01-product/style-guide.md) | In the trial environment, a session with only `playbook-wiki` on shows the contract and none of the rules, and a subagent says the contract is in its context. The owner accepts the text of the contract | U30 |
| U32 | The format of a wiki with works | `plugins/playbook-wiki/format.md`, moved out of `prepare-project` and rewritten: the two layers (D189), the folder of a work (TD24), the identifiers (D170, D174), who decided and the page in each row (D179, TD31), the project's owner in `README.md` (D172), when a branch becomes a work (D188), and a closed work that is never reopened (D190). It is format 4 | No skill reads a file inside another skill. The owner accepts the text | U30 |
| U33 | The check of a wiki with works | `plugins/playbook-wiki/check-wiki.sh`: it walks `works/`; an identifier carries its folder's name; a counter is not repeated; the page a decision names exists and cites it; the page tables of the works are joined. With `--decisions` it prints every decision of every work by date (TD31). Tests | The tests show: a sample wiki with two works passes; each broken case fails with its own message; a wiki at format 3 is checked as before (D177) | U32 |
| U34 | `prepare-project` on a work | The skill and its references changed: it starts and continues the folder of a work, with the stage table in the work's `README.md` (D171); before the merge, what the work defined is written in the shared pages (D189); a later change is a new work (D190). The rule that a phase never rewrites earlier pages is removed | The body is within 700 words. `claude plugin eval` scores the cases of the skill as before, and one new case, a work started in a repository that has a wiki. The owner accepts the text | U32 |
| U35 | The step at the merge | The script that lists the decisions that reached the main branch since the work's branch started, the work's own, and the shared pages both changed; the hook that runs it before a merge command (TD28). Tests | The tests show, for a sample repository where two works changed one shared page, a list that names both works' decisions and that page. In the trial environment the list appears when the agent runs `git merge` | U33 |
| U36 | `doctor` reaches format 4 | `references/format-4.md`, the marker, and the notice, which names `/playbook-wiki:doctor` | On a copy of a wiki at format 3: the status says it is behind; after the steps the marker is written; and no row of its `decisions.md` changed | U33 |
| U37 | The start command | `plugins/playbook/skills/init/`, called only by the person, and its script: what to use, where, the language the agent talks in (`userConfig` of `playbook-agents`), the notice of other plugins and of a global `CLAUDE.md` (D186). The script prints each command before it runs it, and writes in no `CLAUDE.md` (D184, D185, TD27, TD31). Tests with a stand-in for the `claude` command | The tests pass for the three cases of the table in [../03-technology/phase-4.md](../03-technology/phase-4.md). In the trial environment each case leaves on the plugins expected, and a session started before the command loads nothing of the product | U30 |
| U38 | The skills that are not the product's | The script that lists them, the steps of the start command that compare and settle them, `skillOverrides` written with the scope chosen, and the row in the wiki for a skill of the project (D193, TD33). Tests | In the trial environment, with one skill of the person and one of the project made for the trial: both are listed; turning the first off writes the setting; a choice about the second is a row in a work's `decisions.md` and in the page of skills | U37, U33 |
| U39 | This wiki at format 4 | The doctor run on this repository's wiki. The shared pages rewritten to say how the product is after phase 4, starting with `01-product/overview.md`. The project's owner named in `README.md` | `wiki-format.sh mark` writes the marker. No row of `decisions.md` changed | U34, U36 |
| U40 | The documents and the version | The repository's `README.md` with how to install and start; `CONTRIBUTING.md`; the wiki pages `skill-set.md`, `style-guide.md`, and `installation.md`; `2.0.0` in the three manifests (TD32) | A person who follows the `README.md` in the trial environment ends with the product started. Then `v2` goes to `main` by the pull request | U31 to U39 |
| U41 | The owner's machine | With the owner's authorization: the installed plugin updated to `2.0.0`; `/playbook:init` run once, choosing the whole product for every project; the two entries of `~/.config/opencode/opencode.json` and the link `~/.config/opencode/agents` removed (D191) | A new session of the owner shows the contract and the rules, and lists the skills of `playbook-wiki` and `playbook-agents`. Nothing under `~/.config/opencode/` points into this repository | U40 |

U29 depends on no other unit. U31, U32, and U37 each need only U30.

## Notes from the units

### U29

- `shellcheck scripts/*.sh` does not print nothing, and it did not before this unit: on `main` it prints 27 notes, all SC2016, an information-level note about a `$` inside single quotes, in `scripts/verify_test.sh`. U29 removed one of them with the cases it deleted and added none. `shellcheck -S warning scripts/*.sh` prints nothing. The plans of phases 1 to 3 record that `shellcheck` printed nothing; the notes came with later work on that file. What to do with the condition of this plan waits for the owner.
- The wiki's check failed in the unit's worktree until the page table of `README.md` stopped naming `opencode/` and `scripts/install-opencode.sh` as code that [../03-technology/architecture-phase-3.md](../03-technology/architecture-phase-3.md) governs. That page is kept as a record.
- One case was added to `scripts/verify_test.sh`, "models: a fourth field is rejected", in place of the removed "a sixth field is rejected": `plugin/models.conf` has three columns now, and the check on the number of fields stays.

## After the plan

The owner wants to submit the product to Anthropic's plugin directory in the release after version 2 (D198). It is not a unit of this plan, and nothing is prepared for it in this phase.

What is known comes from the page "Submit your plugin" of Anthropic's documentation, as the owner pasted it on 2026-11-16; the paste did not hold the page's address. Three points touch what this phase builds, and none was checked beyond that page:

- "Each plugin folder is its own submission in the developer portal", "so a repository that holds several plugins needs one submission for each." The product is three plugins (TD26).
- A listed plugin is added "from claude.ai" and used "in chat, Cowork, and Claude Code". The product is built for Claude Code only (D181), and it works through hooks and shell scripts.
- The start command turns the other two plugins on by the name of this repository's marketplace (TD27). Whether a plugin listed in the directory keeps that name, and whether one listed plugin can depend on another, is not said in the page.

The page also says: the repository must be public before a listing goes live, which it is (D152); the directory follows a branch or a tag for new versions; and "If your `plugin.json` sets `version`, raise it with every release", which TD22 already does.

Seen on 2026-11-16, in the trial folder of U28: `claude plugin marketplace list` names one marketplace that Claude Code brings by itself, `anthropic-plugin-directory`, "Built in (Anthropic Directory)".

Open as Q61 in [../01-product/open-questions.md](../01-product/open-questions.md).

## Left out of the plan

- A hook before each edit that names the page that governs the file. Left for later (TD29, in [../03-technology/phase-4.md](../03-technology/phase-4.md)).
- A tool other than Claude Code (D181, D191).
- An index of works for a team of more than five people (D178).
- The scope `project`, which turns `playbook-wiki` on for everyone in a repository.
- The six proposals to spend fewer tokens, P1 to P6, which wait for the owner outside this phase.
