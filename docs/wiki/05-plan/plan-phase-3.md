# Plan for phase 3

The work of phase 3, support for opencode 2.x, as an ordered list of units. Stage 5 of phase 3. It builds what [../03-technology/architecture-phase-3.md](../03-technology/architecture-phase-3.md) adds, with the technology of TD13 to TD20. The plans of phases 1 and 2, U1 to U19, are in [plan.md](plan.md) and [plan-phase-2.md](plan-phase-2.md); the numbers continue from them.

The owner accepted it (D118).

## Progress

| Unit | Status | Evidence |
|------|--------|----------|
| U20 | Done 2026-11-13 (D119) | Commit `3c21167` on `main`, merged from branch `feat/u20-opencode-agents`. Run there on 2026-11-13: `sh scripts/set-models.sh` wrote `opencode/agents/explore.md`, `write.md`, and `review.md`; `sh scripts/set-models.sh --check` exited 0; `bash scripts/verify_test.sh` printed "all cases passed", with ten new cases, among them a generated file changed by hand, which fails `--check`; `bash scripts/verify.sh` exited 0 with 776 words at session start; `shellcheck scripts/*.sh` printed nothing; `git diff plugin/agents` was empty. In a temporary project whose `.opencode/agents` was a link to `opencode/agents/`, `opencode debug agents` on opencode 2.3.0 listed `explore` on `openai/gpt-6-luna` variant `medium`, `write` on `openai/gpt-6.1-sol` variant `medium`, and `review` on `openai/gpt-6.1-sol` variant `high`, the three as subagents, with the `edit` action denied for `explore` and `review` and not for `write`; four runs gave the same result. No model was called. See the notes of U20 below |
| U21 | Done 2026-11-13 (D120) | Commit `f16bbe2` on `main`, merged from branch `feat/u21-review-rule`. The first rule of `review-change` became two: an agent that wrote the change, or saw it being written, hands the request to the `review` agent and returns its report unchanged; otherwise it is a reader that has not seen the conversation. The owner accepted the text ("acepto"). Run there on 2026-11-13: the body has 457 words (limit 700) and the description 198 characters (limit 250), counted with the commands of the style guide; `bash scripts/verify.sh` exited 0 with 776 words at session start; `bash scripts/verify_test.sh` printed "all cases passed"; `claude plugin validate plugin` passed with warnings, not read; `claude plugin eval plugin --tag review-change --ablation none --max-cost-usd 2 --no-publish`, run when the owner asked for it, scored both cases 1.00 in 3 runs each and cost 0.62 US dollars. Not checked in this unit: that a model in opencode follows the rule, which is for U27 |
| U22 | Done 2026-11-13 (D121) | Commit `165bbc9` on `main`, merged from branch `feat/u22-opencode-checks`. Run there on 2026-11-13: `bash scripts/verify_test.sh` printed "all cases passed" with 43 cases, 12 of them new; `bash scripts/verify.sh` exited 0 with 776 words at session start; `shellcheck scripts/*.sh` printed nothing. Against opencode 2.3.0, with `sh scripts/verify.sh --opencode <folder>`: in a temporary copy of the repository with the two configuration entries and the link it exited 0, in 4 seconds; in a second copy whose `instructions` entry named a file that does not exist it exited 1 and printed that entry; in the worktree itself, where the product is not installed in opencode, it exited 1 with ten failures. No model was called. See the notes of U22 below |
| U23 | Done 2026-11-13 (D122) | Commit `8ad68bf` on `main`, merged from branch `feat/u23-opencode-installer`. Run there on 2026-11-13: `bash scripts/verify_test.sh` printed "all cases passed" with 68 cases, 25 of them for the installer, each run against a temporary directory: an empty directory is installed; a second run changes nothing; an existing `opencode.json` keeps its checksum and the two entries are printed; an `agents` folder or a link that leads elsewhere stops it with nothing written. `bash scripts/verify.sh` exited 0 with 776 words at session start; `shellcheck scripts/*.sh` printed nothing. The `review` agent read the change and returned six findings, all answered: see the notes of U23 below. The installer was not run on purpose against the real `~/.config/opencode/`; one test run wrote there by mistake and it was undone, also in the notes |
| U24 | Done 2026-11-13 (D123) | Run on the owner's machine on 2026-11-13 at 18:06, when the owner asked for it ("si"), from the clone on `main` at commit `70f0df4`. Before: `~/.config/opencode/` held only opencode's own `service.json`, and `XDG_CONFIG_HOME` was not set. `sh scripts/install-opencode.sh` wrote `~/.config/opencode/opencode.json` with the two entries and made the link `~/.config/opencode/agents` to `opencode/agents` in the clone, and exited 0. `opencode reload` printed "Configuration reloaded". `sh scripts/verify.sh --opencode` printed "opencode loads the rules, the skills, and the agents from this repository" and exited 0. From an unrelated temporary folder with no project configuration, `opencode debug agents` listed `explore` on `openai/gpt-6-luna` variant `medium`, `write` on `openai/gpt-6.1-sol` variant `medium`, and `review` on `openai/gpt-6.1-sol` variant `high`, as subagents, with `edit` denied for `explore` and `review` only: the link is followed for the global folder. From the same folder opencode's list of skills held the six of the product, each with a path under `plugin/skills/` of the clone, among 49 skills in all. No opencode session was opened and no model was called |
| U25 | Done 2026-11-13 (D124) | Run on the owner's machine on 2026-11-13 at 18:12, when the owner asked for it ("podemos instalar los 3 mcp en opencode ya?"). Before: `opencode mcp list` printed "No MCP servers configured". Run: `opencode mcp add --global engram -- engram mcp --tools=agent`, `opencode mcp add --global codegraph -- codegraph serve --mcp`, and `opencode mcp add --global context7 -- npx -y --package=@upstash/context7-mcp@2.2.5 -- context7-mcp`; each printed that the server was added to `~/.config/opencode/opencode.json` and exited 0. After `opencode reload`, `opencode mcp list` printed `codegraph`, `context7`, and `engram` as connected. `sh scripts/verify.sh --opencode` still exited 0. No tool of a server was called and no opencode session was opened |
| U26 | Done 2026-11-13 (D125) | Run on the owner's machine on 2026-11-13 at 18:17, when the owner asked for it by choosing "Sí, borrar las 23". The 23 entries of `~/.agents/skills/` were deleted with no copy. Afterwards the folder holds no entry; opencode listed 22 skills from that folder before and lists none after `opencode reload`; `sh scripts/verify.sh --opencode` exited 0. What was deleted, how, and what was left is in "The skills of `~/.agents/skills/` deleted" in ../02-current-state/removal-map.md (kept in the private archive). See the notes of U26 below |
| U27 | Done 2026-11-13 (D127) | The owner chose to have the agent run a check first and then to work in a project. The agent's check was run on 2026-11-13 and saw the five points of the unit: see the notes of U27 below. Afterwards the owner said "parace qeu funciona... avancemos". Not recorded: which work the owner did in opencode, and in which project |

The status of a unit is one of: Not started, Built (waiting for the owner's review), Done.

## How every unit works

- A unit delivers one thing and ends on a condition that can be observed. The owner reviews each unit when it ends, before the next one starts (R10).
- How a unit is delivered (D117): on its own branch, in its own worktree under `~/dev/playbook-worktrees/` (TD5); merged into `main` by a local fast-forward merge when the owner accepts it, with no pull request; one unit at a time. Pushing is the owner's decision (R14).
- U20 to U23 change this repository. Claude Code reads the plugin from the clone on `main`, so a merged unit is loaded by the owner's Claude Code at once. Each of these units also ends only when `bash scripts/verify.sh` exits 0, `bash scripts/verify_test.sh` prints "all cases passed", and `shellcheck scripts/*.sh` prints nothing.
- U24 to U27 change the owner's machine, not this repository. Each starts only when the owner asks for it, and each step that installs, links, or deletes something there needs the owner's authorization. What the repository receives is the record: the commands run and what was observed.
- A check that asks opencode is done in a temporary project folder until U24: a folder with its own `opencode.json` and `.opencode/`, outside this repository and outside `~/.config/opencode/`. opencode reads a project's configuration the same way as the global one ([../03-technology/phase-3.md](../03-technology/phase-3.md), N9 and N12).

## Units

| # | Unit | Delivers | Ends when | Needs |
|---|------|----------|-----------|-------|
| U20 | The agent files of opencode | Two more columns in `plugin/models.conf`, the opencode model and variant of each agent (TD16); `scripts/set-models.sh` extended to write `opencode/agents/explore.md`, `write.md`, and `review.md` from the description and body of each `plugin/agents/<name>.md`; its `--check` extended to them; the three generated files; tests in `scripts/verify_test.sh` (TD15, D114) | Each generated file holds only `description`, `mode`, `model`, and `permissions`, and the same body as its source. `sh scripts/set-models.sh --check` exits 0, and exits 1 after one generated file is changed by hand. `git diff` shows no change in `plugin/agents/`. In a temporary project whose `.opencode/agents` is a link to `opencode/agents/`, `opencode debug agents` lists the three agents as subagents with the models of TD16, and `edit` denied for `explore` and `review` only | |
| U21 | The rule in `review-change` | One rule in the shared text of the skill: an agent that wrote the change hands the review to the `review` agent and returns its report (TD17) | The body of the skill is within 700 words and what loads at session start within 800. `claude plugin eval plugin --tag review-change` scores both cases of the skill as before. The owner accepts the text of the rule | |
| U22 | The checks for opencode | A part for opencode in `scripts/verify.sh` (TD19): the generated agent files match their source and hold only allowed fields; the limits hold; and a check of an installation that asks opencode for the skills and agents it resolved and tests that the rules path exists. Tests in `scripts/verify_test.sh` | The script exits 1 when a generated agent file holds a field that is not allowed. In a temporary project with the two configuration entries and the link, the check of the installation passes; after the rules path is changed to a file that does not exist it exits 1 and names the path; without opencode installed it says that part was skipped and the rest still runs | U20 |
| U23 | The installer and the steps | `scripts/install-opencode.sh` and the same steps in the repository's `README.md` (TD18, D114). The `review` agent reads the script before delivery, because it writes on a person's machine (R20) | Run against a temporary directory in place of `~/.config/opencode/`: it creates `opencode.json` with the two entries and the link to `opencode/agents/`; run a second time it changes nothing; with an `opencode.json` already there it prints the two entries and the file's checksum is unchanged; with an `agents` folder already there that is not the link it stops and changes nothing. The review's findings are answered | U20 |
| U24 | The product in the owner's opencode | The installer run on the owner's machine, with the owner's authorization | `opencode debug agents` lists `explore`, `write`, and `review` with the models of TD16. opencode's list of skills holds the six of the product, each with a path inside the clone. The check of the installation of U22 passes. Whether the link is followed for the global folder is recorded | U20 to U23 merged |
| U25 | The three servers in opencode | Engram, CodeGraph, and `context7` added with `opencode mcp add --global` (TD20), with the owner's authorization | `opencode mcp list` shows the three as connected | |
| U26 | The other skills removed | The 23 skills of `~/.agents/skills/` deleted with no copy (D111), when the owner asks for it | The folder holds none of them, opencode's list of skills holds none from that folder, and ../02-current-state/removal-map.md (kept in the private archive) lists what was deleted | |
| U27 | The trial in opencode | Real work in one project of the owner's choice, in an opencode session (TD19), and a record of what failed or was missed | The record says, each as seen or not seen: the rules are in the session; a skill loads when its job is asked for; a delegated job runs on the model of its agent; a review asked of the agent that wrote the change is done by `review` (TD17); the tools of Engram and CodeGraph answer. The owner says the product works in opencode for that work, or lists what must change first | U24, U25, U26 |

U21 depends on no other unit. U25 and U26 depend on no other unit and can be done at any point before U27.

## Notes from the units

### U20

- Each generated file opens with a comment line inside its front matter that says it is generated and names its source. opencode read the files with it.
- opencode merges the product's `explore` with its own built-in agent of that name. The description, the model, and the body are the product's. The list of permissions is the built-in one, which denies every action and then allows `shell`, `grep`, `glob`, `webfetch`, `websearch`, and `read`, followed by the product's rule that denies `edit`. So in opencode `explore` also may not start a subagent, which the built-in list denies. `review` and `write` have no built-in agent to merge with.
- `mode: subagent` is fixed in the generator, not read from `plugin/models.conf`: the three agents are delegated jobs (TD8).
- Seen once and not explained: one earlier run of `opencode debug agents`, in a temporary folder that had just been deleted and made again at the same path, listed opencode's built-in `explore` and no `review`. The same sequence repeated afterwards listed the three agents every time.

### U22

- The check of the installation is asked for with a flag: `sh scripts/verify.sh --opencode [repository root]`. Without the flag the script asks nothing of opencode, so it still runs in a worktree, where opencode does not load the product. With the flag it asks opencode what it resolves when started in the repository root: `opencode api GET /api/config` for the `instructions` entries, `opencode api GET /api/skill` for the skills and their paths, and `opencode debug agents` for the agents and their models.
- opencode loads a directory it has not opened yet in the background. Seen on 2.3.0: the first request for the skills of a new folder answered with an empty list, and the same request two seconds later answered with the whole list. The check therefore asks again, up to five times two seconds apart, before a problem counts. This is the likely cause of the run noted under U20 that listed no `review`; it was not reproduced to confirm it.
- The tests use a stand-in for the `opencode` command that prints what opencode 2.3.0 printed for each request, so they run without opencode. The `OPENCODE` variable names the command to run, and `OPENCODE_TRIES` how many times to ask.
- The check matches a rules entry only when it is the absolute path of `plugin/rules.md` in the repository checked. An entry written with `~/` is reported as a failure.
- The size limits need no separate count for opencode: it loads the same rules file and the same descriptions as Claude Code, so the one count of the script serves both tools (D109).
- The last run against opencode was made before one line was added to the script, the message printed when the check passes. That line is covered by the tests with the stand-in.

### U27

The agent's check, run on 2026-11-13 when the owner chose "Primero un chequeo mío, después vos". Four requests were sent with `opencode run --format json` in a temporary git project with one small JavaScript file and its test, outside this repository. What each session ran on was read with `opencode session export`. `opencode stats` afterwards showed 3 sessions, 3 subagents, 4 prompts, 27 steps, and 238.1 thousand tokens for the whole check.

| Point of the unit | Seen | Evidence |
|-------------------|------|----------|
| The rules are in the session | Yes | Asked for its rules without using a tool, the session listed R1 to R24 in the order of `plugin/rules.md` and quoted R14 word for word. It ran on the agent `build` and the model `openai/gpt-6.1-sol` (TD21). The request used 8,403 input tokens, which is everything the session held at its start |
| A skill loads when its job is asked for | Yes | Asked "Now review that change before I merge it", the session called opencode's `skill` tool with `review-change` |
| A delegated job runs on the model of its agent | Yes, for the three | Asked to delegate a change, the session called the `subagent` tool with `write`, whose session ran on `openai/gpt-6.1-sol`, variant `medium`; it changed the two files it was allowed to and its check, `node duration.test.js`, printed "ok". Asked to find a function, `explore` ran on `openai/gpt-6-luna`, variant `medium`, and returned `duration.js:2`. The `review` session ran on `openai/gpt-6.1-sol`, variant `high` |
| A review asked of the agent that saw the change written is done by `review` | Yes | In the session that had delegated the change, the request to review it loaded `review-change` and then called the `subagent` tool with `review` (TD17). The `review` session loaded `review-change` itself and answered "No findings." with a "Not checked" line |
| The tools of Engram and CodeGraph answer | Yes | Engram's `mem_current_project` returned the name of the temporary project. CodeGraph's `codegraph_explore` answered that the folder has no index. `context7` was not called |

Also seen:

- The skills the session said it had: the six of the product, the owner's six of `~/.claude/skills/`, and opencode's own `OpenCode` and `Report`. None of the thirteen hidden by D126 was among them, so the permission rules hide a skill from the model.
- The subagents it said it could delegate to: `explore`, `general`, `review`, `write`.
- opencode reached the tools of the two servers through its own `execute` tool: it searched for the tool and then called it as code, such as `tools.engram.mem_current_project(...)`. The servers' tools are not listed to the model one by one.
- Subagents run in the background in opencode: the main session answered that the agent was working and reported the result when it came back.

Not seen in the check: a skill loading without being named or hinted at in a real task, a task large enough to compact the conversation, the limits of the owner's OpenAI plan, and any work in a real project. Those are for the owner's part of the trial.

The temporary project was left in place: opencode's background service keeps a folder it has opened, and a reload fails once when such a folder is gone (notes of U25).

### The synced skills hidden in opencode (D126)

Done on the owner's machine on 2026-11-13, outside the units, when the owner chose it: a `permissions` list with thirteen rules, each `{ "action": "skill", "resource": "<identifier>", "effect": "deny" }`, was added to `~/.config/opencode/opencode.json`. opencode's documentation says of that effect: "Hides matching skills from the model and rejects loading" ([skills](https://opencode.ai/docs/skills/)). After `opencode reload`, `opencode debug agents` shows the thirteen rules in the permissions of `build`, `plan`, `general`, `explore`, `write`, and `review`, next to opencode's own rule that denies its `browser` skill. `sh scripts/verify.sh --opencode` exited 0, the three servers are connected, and the default model is still `openai/gpt-6.1-sol`. opencode's list of registered skills still holds the 28; that a model in a session no longer sees the thirteen was seen in the check of U27. To go back, delete the `permissions` entry and run `opencode reload`.

### The model of the main session (TD21)

Done on the owner's machine on 2026-11-13, outside the units, when the owner chose it: the line `"model": "openai/gpt-6.1-sol"` was added to `~/.config/opencode/opencode.json`. Before it, `opencode api GET /api/model/default` reported `opencode/iceman-free`; after `opencode reload` it reports `openai/gpt-6.1-sol`. `sh scripts/verify.sh --opencode` exited 0 and `opencode mcp list` still shows the three servers connected. To go back, delete that line and run `opencode reload`.

### U26

- After the deletion opencode lists 28 skills: the six of the product, three built into opencode, and 19 from `~/.claude/skills/`. That is more than the five D113 was decided on. Six are folders at the top of `~/.claude/skills/`: the five of D113 and `style-sampling`. Thirteen are under `~/.claude/skills/synced/`, a folder that Claude Code fills by itself: `built-in-browser`, `chrome-browser`, `computer-use`, `deep-research`, `docs`, `docx`, `google-workspace`, `import-memory`, `morning`, `pdf`, `pptx`, `skill-creator`, `xlsx`. One of them, `skill-creator`, does the job of the product's `write-skill`. The owner was not told of these fourteen when D113 was decided; the owner then decided to hide the thirteen synced ones and keep the six of their own (D126).

### U25

- opencode wrote the three servers under `mcp.servers` in `~/.config/opencode/opencode.json` and reformatted the `skills` entry onto three lines. The file is no longer identical to the one the installer writes, so a new run of `scripts/install-opencode.sh` reports it as "Not confirmed" and exits 0 (D122, notes of U23); `sh scripts/verify.sh --opencode` is what confirms it.
- How to go back: delete the `mcp` entry from that file and run `opencode reload`.
- The first `opencode reload` of this unit failed with "Directory not found" for a temporary folder that an earlier check of U24 had opened and deleted. The servers connected anyway, and a second `opencode reload` printed "Configuration reloaded". opencode's background service keeps a folder it has opened for a while; a reload fails once when such a folder no longer exists.
- Each server is started by its command name, found through the `PATH` of opencode's background service: `engram` under Homebrew, `codegraph` and `npx` under the Node version of `nvm` in use on 2026-11-13. A change of Node version can break the last two; `opencode mcp list` shows it.

### U24

- How to go back: delete `~/.config/opencode/opencode.json` and the link `~/.config/opencode/agents`, then run `opencode reload`. Both were made by this unit; nothing that existed before was changed.
- The 49 skills opencode lists are the six of the product, three built into opencode, and 40 that are not the product's, from `~/.claude/skills/` and `~/.agents/skills/` with the folders nested in them. The ones of `~/.agents/skills/` are for U26 (D111); the ones of `~/.claude/skills/` stay (D113).
- The installation points to the clone at `~/dev/playbook`. Whatever is checked out there is what opencode loads, as with Claude Code.

### U23

- The `review` agent read the staged change on 2026-11-13 and returned six findings. Each was fixed and has a test:

  | Finding | Answer |
  |---------|--------|
  | An existing configuration file that named the two paths anywhere, even in a comment, was reported as "Installed" | The script says "Installed" only for a file identical to the one it writes. A file it did not write that names both paths outside comment lines is reported as "Not confirmed", with the check to run. Paths found only in comment lines count as missing |
  | A write that failed left an empty `opencode.json` and printed "Nothing was changed" | The incomplete file is removed, and "Nothing was changed" is printed only when it is true |
  | The default folder ignored `XDG_CONFIG_HOME`, which opencode follows | The default is `$XDG_CONFIG_HOME/opencode`, or `~/.config/opencode` without the variable. The README says so |
  | With `CDPATH` set the path of the clone was read wrong | The script clears `CDPATH` where it changes directory |
  | A link that led to the right folder but was written another way stopped the run | The link is compared by the folder it leads to, not by its text |
  | The command printed at the end broke with a space in the clone's path | The path is printed in single quotes |

- Not changed: `scripts/verify.sh`, `scripts/set-models.sh`, and `scripts/verify_test.sh` find the repository root with the same line that `CDPATH` breaks. They were not part of this change.
- A mistake made while building this unit, and its repair. At 18:01 on 2026-11-13 the new test cases were run against the first version of the installer, because the corrected version had failed to save. One case ran the installer with no argument, and that version used `~/.config/opencode` as its default, so it wrote `opencode.json` and the link `agents` in the owner's real configuration folder, both pointing into a temporary directory that the test then deleted. The owner had not authorized any change there (U24). Both were removed within a minute, after checking that the file held exactly what the test writes and that the link pointed into that temporary directory; the folder again holds only opencode's own `service.json`, as before. Since then every run of the installer in the tests gets `HOME` and `XDG_CONFIG_HOME` inside the temporary directory, and a later full run of the tests left the real folder unchanged, compared by its listing before and after.
- Not verified: the installer on BSD or macOS tools, and what opencode does with `opencode.json` and `opencode.jsonc` side by side.

## Not in this plan

- Paid evaluations in opencode (TD19).
- A plugin of the product for opencode, and support for opencode 1.x (D112, [../03-technology/architecture-phase-3.md](../03-technology/architecture-phase-3.md)).
- Any change to how the product works in Claude Code (D112), apart from the rule of U21, which is shared text.
- Hiding the five skills of `~/.claude/skills/` in opencode (D113).
- Engram's memory printed at the start of an opencode session (TD20).
- A persona for opencode. D70 keeps the persona as the owner's own file, outside the product.
- Removing the trial environment of phase 2 (D96), and the questions about sharing the product and about Engram's data in [../01-product/open-questions.md](../01-product/open-questions.md).

## Not verified

The points of [../03-technology/architecture-phase-3.md](../03-technology/architecture-phase-3.md). U24 checks that a link is followed for the global agents folder. U27 checks that a model in opencode follows the rule of TD17 and records the limits of the owner's plan that are seen.

## What the phase left

- **What phase 3 left:** opencode 2.x reads the same rules and skills as Claude Code, in place from this clone, through the `instructions` and `skills` keys of its global configuration (TD13, TD14). The three agents have one text each; `scripts/set-models.sh` generates their opencode files into `opencode/agents/`, reached through a link (TD15), with `explore` on `gpt-6-luna` and `write` and `review` on `gpt-6.1-sol` (TD16). A rule in `review-change` hands a review to the `review` agent when the reader wrote the change (TD17). `scripts/install-opencode.sh` and the repository's README install it (TD18), and `sh scripts/verify.sh --opencode` checks what opencode loads (TD19). The eight units, U20 to U27, are done.
- **Not verified when phase 3 was closed (D128):** which work the owner did in opencode; a skill loading by itself in a real task, and a task long enough to compact the conversation; the limits of the owner's OpenAI plan in opencode; the installer on BSD or macOS tools; `context7` called from opencode.
- **opencode on the machine:** version 2.3.0 is installed and signed in with OpenAI. Since U24 it loads the product from this clone, and since U25 Engram, CodeGraph, and `context7` are connected to it; since U26 `~/.agents/skills/` is empty, and of the 19 skills it finds in `~/.claude/skills/`, thirteen are hidden and six are visible (D126). Its state before U24 is in 02-current-state/opencode-on-the-machine.md (kept in the private archive).
