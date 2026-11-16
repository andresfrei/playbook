# Plan for phase 2

The work of phase 2, replacing gentle-ai in the owner's Claude Code, as an ordered list of units. Stage 5 of phase 2. It builds what [../01-product/phase-2.md](../01-product/phase-2.md) lists under "What is missing", with the technology of [../03-technology/architecture-phase-2.md](../03-technology/architecture-phase-2.md). The plan of phase 1, U1 to U10, is in [plan.md](plan.md); the numbers continue from it.

The owner accepted it (D75).

## Progress

| Unit | Status | Evidence |
|------|--------|----------|
| U11 | Done 2026-11-13 (D76) | Commit `f402481` on `main`, merged from branch `feat/u11-models-agents`. Run there on 2026-11-13: `bash scripts/verify_test.sh` printed "all cases passed"; `bash scripts/verify.sh` exited 0 with 546 words at session start; after `model: haiku` was changed by hand in `explore.md` it exited 1 with "plugin/agents/explore.md has model 'opus', models.conf says 'haiku'", and `sh scripts/set-models.sh` restored it; `shellcheck scripts/*.sh` printed nothing. A session started with `claude --plugin-dir` listed `playbook:explore`, `playbook:write`, and `playbook:review`. A task given to `playbook:explore` from a session on Sonnet was billed to `claude-haiku-5-5` (`modelUsage` of `--output-format json`). Not observed: the models of `write` and `review` at run time |
| U12 | Done 2026-11-13 (D77) | Commit `6580043` on `main`, merged from branch `feat/u12-rules`. Run there on 2026-11-13: `wc -w plugin/rules.md` printed 492 (limit 500); `bash scripts/verify.sh` exited 0 with 733 words at session start (limit 800); `bash scripts/verify_test.sh` printed "all cases passed"; the hook's command printed the file unchanged. The owner accepted the text of each rule (D77) |
| U13 | Done 2026-11-13 (D78) | Commit `5f401fc` on `main`, merged from branch `feat/u13-review-skill`. Run there on 2026-11-13: `bash scripts/verify_test.sh` printed "all cases passed"; `bash scripts/verify.sh` exited 0 with 768 words at session start (limit 800); `shellcheck scripts/*.sh` printed nothing; `claude plugin eval plugin --tag review-change --ablation none --max-cost-usd 2 --no-publish` scored both cases 1.00 in 3 runs each. Behaviour: a session on Sonnet started with `claude --plugin-dir` was asked to review the uncommitted changes with the skill; it returned three findings, and `modelUsage` showed the reading on `claude-opus-5-5` (216 thousand tokens read from cache, 4,480 written) against 1,377 written by the session on Sonnet |
| U14 | Done 2026-11-13 (D79) | Commit `677e617` on `main`, merged from branch `feat/u14-new-phase`. Run there on 2026-11-13: `bash scripts/verify.sh` exited 0 with 776 words at session start (limit 800); `bash scripts/verify_test.sh` printed "all cases passed"; `claude plugin eval plugin --tag prepare-project --ablation none --max-cost-usd 2 --no-publish` scored the three cases 1.00 in 3 runs each. Behaviour: in a scratch repository whose wiki had six closed stages, a session on Sonnet given "Quiero empezar una fase 2 de este proyecto: que los clientes paguen la seña online al reservar. Empecemos." added a stage table for phase 2 with stage 1 Open above the earlier one, kept the earlier one as a record, and recorded decision D13 with those words |
| U15 | Done 2026-11-13 (D81) | Run on 2026-11-13 with `CLAUDE_CONFIG_DIR=$HOME/.claude-playbook`, in `~/dev/playbook`: `claude auth status` printed `loggedIn: true`, `authMethod: claude.ai`; `claude mcp list` printed `engram` and `codegraph` as connected. A session started with `claude -p --model sonnet --output-format stream-json --verbose` listed in its `init` event the agents `playbook:explore`, `playbook:review`, `playbook:write`, the six `playbook:` skills and `engram:memory`, the user MCP servers `engram` and `codegraph` as connected, and `output_style: default`; three `SessionStart` hooks ran, of the `playbook` plugin (2,827 characters, the rules) and of Engram. It listed no agent, skill, hook, or MCP server of gentle-ai or the overlay. Asked what its context held, it answered that the only `CLAUDE.md` was the project's, that it had rules R1 to R24, and that it had the instructions of the `codegraph` and `engram` servers. The checksums of the main installation listed in the notes below were equal before and after |
| U16 | Done 2026-11-13 (D88) | Two pieces of work in one session opened with `claude-playbook`: unit U17 (D83) and a one-line change to `prepare-project`, commit `006ac6a` (D87); see the notes of U16 below. The owner accepted the product for that work. Engram worked without gentle-ai's sections: its hook gave the recent sessions and prompts at session start and its tools were available. CodeGraph was connected and was not exercised: this repository has no index |
| U17 | Done 2026-11-13 (D83) | ../02-current-state/uninstall-rehearsal.md (kept in the private archive). `gentle-ai uninstall -agent claude-code -y` exited 0 inside a sandbox whose home directory was a copy-on-write view of the real one; the page is written from the folder that received its changes. Checksums of the real configuration taken right before and after the run were equal |
| U18 | Done 2026-11-13 (D91) | ../02-current-state/main-installation-switch.md (kept in the private archive): the steps run with the owner's authorization (D89), what a new session of the main installation loads, and how to go back. The backup is `~/backups/claude-pre-switch-2026-11-13/`. A new session lists no agent, skill, hook, or `CLAUDE.md` section of gentle-ai, and the output style `Persona` is active. Not met yet: "one skill per job", because the overlay's `anti-generic-design` stays until U19 |
| U19 | Done 2026-11-13 (D95) | "The overlay retired from Claude Code" in ../02-current-state/removal-map.md (kept in the private archive): each thing removed, how, and where it is now (D92). A new session of the main installation lists no hook, tool, or skill of the overlay, ran a Bash command, and has one skill per job, which also meets what U18 left pending |

The status of a unit is one of: Not started, Built (waiting for the owner's review), Done.

## How every unit works

The rules of "How every unit works" in [plan.md](plan.md) hold, with two differences:

- U11 to U14 change the plugin. Each is built in its own worktree and tested there with `claude --plugin-dir` (TD5). When the owner merges one into `main`, the owner's main installation loads it at once, next to gentle-ai.
- U15 to U19 change the owner's machine, not this repository. Each starts only when the owner asks for it, and each step that installs, moves, or deletes something there needs the owner's authorization. What the repository receives is the record: the commands run and what was observed.

## Units

| # | Unit | Delivers | Ends when | Needs |
|---|------|----------|-----------|-------|
| U11 | Model configuration and the three agents | `plugin/models.conf`, the shell script that writes it into the agent files, the agents `explore`, `write`, and `review` (TD7, TD8, TD11), and `scripts/verify.sh` extended to compare them | `claude plugin validate` passes. The verify script exits 0, and exits non-zero after one agent's model is changed by hand. `shellcheck` reports nothing. A session started with `claude --plugin-dir` lists the three agents, each with the model of the configuration | |
| U12 | The eight new rules | The rules of D66 added to `plugin/rules.md`: change authorization, task size, the high-risk list, delegation naming the agents of U11, edit surfaces, CodeGraph first, what belongs in Engram, remote authorization | The verify script passes: the file is under 500 words and what loads at session start is under 800. Running the hook's command by hand prints the file unchanged. The owner accepts the text of each rule | U11 |
| U13 | Skill: review a change | The review skill, running in a separate context on the `review` agent (D66, TD10), and its two evaluation cases | See "When a skill unit ends" in [plan.md](plan.md). In addition, a review asked for in a session returns findings, and the session's own context does not hold the files the reviewer read | U11 |
| U14 | `prepare-project`: a rule for a new phase | The skill says what to do when the six stages are closed and a new phase starts (Q37), and its evaluation cases still pass | The verify script and the skill's two evaluation cases pass. Given a wiki whose six stages are closed and a request to start a new phase, the skill opens a new stage table at stage 1 and keeps the earlier one | |
| U15 | The trial environment | A second configuration directory with its own login, the plugin, Engram, and CodeGraph, opened with an alias (TD6) | A session opened with the alias shows the product's rules, skills, and agents, and the tools of Engram and CodeGraph. It shows no section of gentle-ai's instructions, no skill of gentle-ai or the overlay, and no hook of either. `~/.claude` is unchanged | U11 to U14 merged |
| U16 | The trial | Real work in one project of the owner's choice, done in the trial environment (D69), and a record of what failed or was missed | The owner says the product works for that work, or lists what must change first. The record says whether Engram and CodeGraph worked without gentle-ai's sections | U15 |
| U17 | Rehearsal of the uninstall | `gentle-ai uninstall` run against a copy of the configuration directory, and a page that lists what it removed and what it left (TD9) | The page is written from a comparison of the copy before and after. `~/.claude` is unchanged | |
| U18 | The switch of the main installation | A backup of `~/.claude`; the persona saved as the owner's own output style (D70); gentle-ai removed from Claude Code with its uninstall and the list of U17; the skills deferred by D61 removed | A new session in a project shows no section of gentle-ai in its instructions, no hook of gentle-ai, and one skill per job. The persona is active. The backup exists, and the steps to restore it are written in the wiki | U16 accepted, U17 |
| U19 | Retiring the overlay | The overlay's eight hook commands, its `longterm-mem` server, and its skills removed from Claude Code (D68). The overlay repository is not changed | A new session shows no hook, tool, or skill of the overlay. The removal map lists each thing removed and where its backup is | U18 |

U17 depends on nothing and can be done at any point before U18.

## Notes from the units

U11, written by an agent on Claude Sonnet 5.5 at medium effort and checked by the main agent. The points the unit decided that no decision covered, accepted by the owner as written (D76):

- The agents are named with the plugin's prefix in a session: `playbook:explore`, `playbook:write`, `playbook:review`.
- `write` may use Read, Grep, Glob, Bash, Edit, and Write. `explore` and `review` may use Read, Grep, Glob, and Bash, and their instructions forbid any command that changes something; nothing enforces that for Bash.
- `scripts/set-models.sh` takes `--check` and an optional repository root. A line of `models.conf` with more than three fields is rejected.
- `scripts/verify.sh` applies the description limit (L3) to agents and counts their descriptions in what loads at session start (L4): 546 words of 800 with the three agents.
- `claude plugin validate` passes with two warnings that predate this unit: `plugin.json` has no `version` (TD3) and the plugin has no `LICENSE`.

U12, written by the main agent:

- The eight concepts of D66 are seven numbered rules, R18 to R24: edit surfaces are the last sentence of the delegation rule (R21), as D66 says.
- The rules sit under the five existing headings, so their numbers are not in order inside the file. [../01-product/rules.md](../01-product/rules.md) says where each one comes from.
- The first draft had 539 words and failed the verify script; the texts were shortened to 492. After this unit, 67 words remain for what else loads at session start, which the description of the review skill of U13 must fit in.

U13, written by an agent on Claude Sonnet 5.5 at medium effort, then reviewed with the skill itself and corrected by the main agent:

- The skill is named `review-change`. Its `agent` field is `playbook:review`, the name with the plugin's prefix; the run above shows it resolves to the `review` agent on Opus.
- The first real run of the skill reviewed this unit and returned three findings, all corrected before the commit: the verify script accepted `agent` without `context`; its message did not say that the order of the keys matters; and one row of the style guide still said the front matter holds `name` and `description` only.
- After the correction, a skill's front matter is either `name` and `description`, or those two followed by `context: fork` and `agent`, in that order. The verify script fails anything else.
- When a request does not say which change to review, the skill reviews the uncommitted changes, or the last commit when there are none, and says which.
- The skill does not review for excess; it points to `keep-minimal`. A defect that was already there before the change is not a finding.
- That one review cost 0.63 dollars at API prices, and the six evaluation runs 0.57.
- After this unit, 32 words remain of the 800 that may load at session start.

U14, written by the main agent:

- The rule is one step in `SKILL.md` and a section "A new phase" in `references/1-wiki.md`: record the phase as a decision, add a stage table above the earlier one, do the six stages as for a project already started, write the phase in pages of its own, and continue the numbers of decisions, questions, and units.
- The first trial failed. The session did not load the skill, opened no stage table, and asked a technology question at once. The skill's description did not mention a new phase, and the description is what decides whether a skill loads. It now starts "Start a new project, start a new phase of a finished one, or prepare one already started".
- A third evaluation case, `prepare-project-new-phase-triggers`, covers that request. `prepare-project` is the only skill with three cases.
- The second trial loaded the skill but wrote nothing: a session started with `claude -p` could not read the plugin's reference file, which is outside its working directory, and the skill refused to invent the format. The third trial was given read access with `--add-dir` and passed. Whether an installed plugin's reference files are readable in an interactive session without that flag was seen to hold in this session, where the references of `prepare-project` were read.
- The three trials cost 0.53 dollars at API prices, and the nine evaluation runs 1.18.
- After this unit, 24 words remain of the 800 that may load at session start.

U15, built by the main agent on 2026-11-13. The owner authorized the steps (D80) and accepted the unit (D81). Every command was run with `CLAUDE_CONFIG_DIR=$HOME/.claude-playbook`.

What was run, in order:

1. `mkdir ~/.claude-playbook`.
2. `claude plugin marketplace add ~/dev/playbook` and `claude plugin install playbook@playbook --scope user`. `claude plugin list` shows the plugin read from `~/dev/playbook/plugin`, so the trial environment loads what is on `main`, as the main installation does.
3. `claude plugin marketplace add Gentleman-Programming/engram` and `claude plugin install engram@engram --scope user`. It installed version 0.1.22; the main installation has 0.1.19.
4. `claude mcp add --scope user engram -- engram mcp --tools=agent` and `claude mcp add --scope user codegraph -- codegraph serve --mcp`. Engram's plugin holds hooks and a skill and no MCP server, so the server is added apart.
5. One alias added at the end of `~/.bashrc`: `alias claude-playbook='CLAUDE_CONFIG_DIR="$HOME/.claude-playbook" claude'`.
6. The owner opened `claude-playbook` and made the login.
7. `claudeMdExcludes` added to `~/.claude-playbook/settings.json` (TD12), after the first check failed.

What failed first:

- The first session opened in `~/dev/playbook` held all of `~/.claude/CLAUDE.md`, the instructions of gentle-ai. Its skills, agents, hooks, and MCP servers were already only the product's, Engram's, and CodeGraph's.
- The same question asked in a session opened in a directory outside the home directory answered that it held no `CLAUDE.md`. Asked again in the repository with `--settings '{"claudeMdExcludes":["~/.claude/CLAUDE.md"]}'`, it answered that it held only the project's `CLAUDE.md`.
- So a session reads `.claude/CLAUDE.md` in the parent directories of its project, and for any project under the home directory that reaches `~/.claude/CLAUDE.md`. The setting excludes it (TD12). Whether a session held a file was taken from the session's own answer, not from a log.

Other points:

- Nothing was copied from `~/.claude`: no permissions, model, status line, persona, or other MCP server. The trial environment's `settings.json` holds the two plugins, their two marketplaces, and `claudeMdExcludes`. A session there has the output style `default`; the persona arrives with U18 (D70).
- `~/.claude` is unchanged. Checksums taken before the first step and after the last are equal for `~/.claude/settings.json`, `~/.claude/CLAUDE.md`, the two plugin lists under `~/.claude/plugins/`, the `mcpServers` key of `~/.claude.json`, and the listing of `skills`, `agents`, `hooks`, `output-styles`, and `commands`. Outside the new directory only `~/.bashrc` changed.
- Engram keeps its data in `~/.engram` and CodeGraph in `~/.codegraph`, outside the configuration directory, so the trial environment and the main installation share one memory. The check sessions' prompts are now in Engram's list of recent prompts.
- A session there also lists the connectors of the owner's claude.ai account (Claude Docs, Google Drive, Calendar, Gmail) and the skills and plugins built into Claude Code. They come with the login and with Claude Code, not with gentle-ai.
- The two check sessions on Sonnet cost 0.24 and 0.07 dollars at API prices. The two on Haiku were not measured.
- What happens to `~/.claude-playbook` and the alias after the switch of U18 was open as Q40 and is decided: removed after a few days of work on the main installation (D96).

U16, not started. What the owner chose for it (D82):

- The trial is two pieces of work, both in a session opened with `claude-playbook`: unit U17 in this repository, and one small real task in a project with code.
- The session that does U17 starts with no earlier conversation. It takes the state of the work from this wiki and from Engram, and that is part of what the trial observes.
- The project with code is `huellitas-id` (D85). Seen there on 2026-11-13, read-only: it has a CodeGraph index, a wiki, 275 test files, its own `CLAUDE.md` and `AGENTS.md`, and a session of the main installation at work on the branch `feat/shops-c5h`.
- No task is done in `huellitas-id`: the owner accepted the trial without it (D88).

The task with code in this repository (D86), built by the main agent on 2026-11-13 in the same session, accepted and merged (D87):

- The change is one line of `plugin/skills/prepare-project/SKILL.md`, step 5: "Write each result in the wiki when it is produced, with the `write-docs` skill." Commit `006ac6a` on `main`, merged by fast-forward from the branch `feat/prepare-project-write-docs`, built in the worktree `~/dev/playbook-worktrees/u16-prepare-project-docs` (TD5).
- Run there: the body of the skill has 692 words (limit 700, 688 before); `bash scripts/verify.sh` exited 0 with 776 words at session start; `bash scripts/verify_test.sh` printed "all cases passed"; `claude plugin validate plugin` passed with the warnings known since U11; `shellcheck scripts/*.sh` printed nothing.
- Behaviour: in a scratch repository, a session on Sonnet started with `claude -p --plugin-dir` and `--add-dir` on the worktree's plugin was given a brief for a new project in Spanish. It loaded `playbook:prepare-project`, read `references/1-wiki.md`, loaded `playbook:write-docs`, and then wrote seven wiki pages. The text of the skill it loaded held the new line. It cost 0.23 dollars at API prices.
- Not run: the same session without the change, the paid evaluation cases of `prepare-project` (its description did not change), and a review with `review-change` (a one-line change, not risky by R20).
- For the trial: the skill `write-skill` loaded for the change and its style guide gave the limits and the checks. The agents `write` and `review` and CodeGraph were not used; the task was too small to need them (R19).

U17, built by the main agent on 2026-11-13 in a session opened with `claude-playbook`, as the first piece of the trial (D82):

- The copy is not a second directory. gentle-ai has no option to point at another directory, so the command ran in a `bwrap` sandbox with the home directory as an overlay: reads come from the real one and changes go to a separate folder. That covers the whole home directory, not only `~/.claude`.
- The uninstall leaves three of the five sections of `~/.claude/CLAUDE.md` (12,758 words) and gentle-ai's eight agents, and it removes Engram's MCP server and the whole `permissions` key of the settings. The page lists what U18 must do by hand, as Proposed.
- After D83 the owner asked for the open points to be tested ("prueba todo lo que necesites"). In sandboxes: the uninstall's backup restores the configuration exactly, a later `gentle-ai sync` writes nothing into Claude Code, and the proposed steps of U18 run in order give a new session with no agent, skill, or section of gentle-ai, with Engram connected and the persona active. The page has the detail.
- For the trial: the session had no earlier conversation and took the state of the work from the wiki's entry point and the uncommitted record of D82. Engram's summary at session start listed recent prompts and titles; nothing had to be searched in it. CodeGraph was not used: this repository has no index and the unit read no code. The skill `write-docs` loaded when the page was written.

## Decided inside the units, not here

- The text of each of the eight rules (U12). The eight share about 195 words.
- The names of the configuration file, the script, and the agents, which are working names (TD8, TD11).
- The tools each agent may use (U11).
- The project used for the trial (U16): this repository, for unit U17, and `huellitas-id` for the task with code (D82, D85).
- The name of the second configuration directory: `~/.claude-playbook` (D80).

## Not in this plan

- A skill for pull requests, review comments, or issues (D67).
- Support for a tool other than Claude Code (D57).
- Changes to the overlay repository (D68), and placing the Genesis skills in the Genesis repository (D60).
- The questions about sharing the product and about Engram's data in [../01-product/open-questions.md](../01-product/open-questions.md).

## Not verified

The four points of [../03-technology/architecture-phase-2.md](../03-technology/architecture-phase-2.md). U11 checks two of them (that a plugin's agents load, and that each alias resolves to the model named), U13 one (the model of a skill that names an agent), and U17 one (what the uninstall removes), now checked: see ../02-current-state/uninstall-rehearsal.md (kept in the private archive).

## What the phase left

- **Installed:** the plugin is on the owner's machine for all projects and loads the rules, six skills, and three agents in every session. gentle-ai was removed from Claude Code on 2026-11-13 (D89): 02-current-state/main-installation-switch.md (kept in the private archive) says what was run, what a session loads now, and how to go back. The overlay was retired from Claude Code the same day (D92), with everything moved to an archive folder: 02-current-state/removal-map.md (kept in the private archive). Afterwards the owner had the overlay, Pi, gentle-shell, Codex, opencode, and gentle-ai deleted from the machine (D93, D94, same page). opencode 2.3.0 was installed again later the same day; Claude Code is still the only AI coding tool with the product.
- **Phase 2 so far:** the definition is in [01-product/phase-2.md](../01-product/phase-2.md), and the inventory of what gentle-ai adds to a session is in 02-current-state/gentle-ai-layer.md (kept in the private archive). The four problems phase 2 solves are decided (D64) and are the criteria for the rest. What each of the nineteen concepts becomes is decided (D66), and the workflow lives in short rules plus skills on demand (D65).

What was done in phase 2, in order, and what is left:

1. U11 to U14, the four units that change the plugin, are done and merged (D76 to D79). Evidence is in [05-plan/plan-phase-2.md](plan-phase-2.md).
2. U15, the trial environment, is done (D81): `~/.claude-playbook`, opened with the alias `claude-playbook`, holds the plugin, Engram, and CodeGraph and loads nothing of gentle-ai or the overlay (D80, TD6, TD12). `~/.claude` is unchanged.
3. U16, the trial, is done (D88): unit U17, the rehearsal of `gentle-ai uninstall` (D83, 02-current-state/uninstall-rehearsal.md (kept in the private archive)), and a one-line change to `prepare-project` in this repository (D87), both in a session opened with `claude-playbook`. It did not exercise CodeGraph or work in an application.
4. U18, the switch of the main installation, is done (D91): 02-current-state/main-installation-switch.md (kept in the private archive).
5. U19, retiring the overlay from Claude Code, is done (D95): 02-current-state/removal-map.md (kept in the private archive). It was the last unit of the plan.
6. Stage 6 and phase 2 are closed (D98). Not verified before closing: an interactive session with real work on the switched main installation. The trial environment `~/.claude-playbook` and its alias `claude-playbook` were removed on 2026-11-13, when the owner asked for it (D96, D131). `context7` is a necessary dependency and stays as it is for now (D97). The other tools the owner removed are set up again later, one at a time, outside this repository unless the owner decides otherwise (D93).
