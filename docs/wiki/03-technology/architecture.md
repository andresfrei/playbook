# Architecture

How the product is built after phase 4. The choices, with their risks, trade-offs, and discarded alternatives, are in [architecture-phase-4.md](architecture-phase-4.md); the evidence for each is in [phase-4.md](phase-4.md). The architecture of phases 1 and 2 is kept in [architecture-phase-2.md](architecture-phase-2.md), and that of phase 3 in [architecture-phase-3.md](architecture-phase-3.md).

## The shape

Three Claude Code plugins in this repository's marketplace, `.claude-plugin/marketplace.json`, each in its own folder under `plugins/` (TD26, TD31). Claude Code's own settings say which are on, for every project or for one repository; the product writes no configuration file of its own (TD27).

```text
this repository (the marketplace)
├── plugins/playbook          the start command, /playbook:init
├── plugins/playbook-wiki     the core, shared by everyone on a project
└── plugins/playbook-agents   the owner's agent system; depends on playbook-wiki
```

One plugin for each thing a person may want alone, because the only switch Claude Code gives for one repository turns a whole plugin on or off.

Three kinds of content, split by when each one loads (D65):

| Loads | Content |
|-------|---------|
| In every session | The contract and the rules, printed by hooks |
| When a job needs it | Skills |
| When work goes to a subagent | Agents, each with a fixed model and effort (TD7, TD8) |

## Modules

| Module | Path | Responsible for | Does not |
|--------|------|-----------------|----------|
| Start command | `plugins/playbook/skills/init/` | The wizard: the wiki alone or the whole product, this repository or every project, and the language (D183, D184, TD31). It names the other plugins on and a global `CLAUDE.md` (D186), and the skills that are not the product's (D193, TD33). Run again, it shows what is on and asks "Keep" or "Change" (setup-commands-5); it remembers each "Keep both" under `playbook.keepBoth` and asks no more about that pair (setup-commands-8, setup-commands-15); in a repository with no wiki it offers the skeleton (setup-commands-6). Its script, `scripts/init.sh`, runs Claude Code's plugin commands and prints each one | Load by itself (`disable-model-invocation: true`). Write in a `CLAUDE.md`, except the two sentences of a skeleton after a yes (D185). Change anything of another tool (D186) |
| Contract | `plugins/playbook-wiki/contract.md` | The rules about deciding, R5 to R8, R10, and R12, reading the wiki before changing code, the two layers of a wiki, and the step at the merge (D175, D189, D173) | Say how a person's agent talks, delegates, tests, or commits |
| Format | `plugins/playbook-wiki/format.md` | Format 5 of a project's wiki: the shared pages, the works, their files and identifiers (D201), and the kind and answer of each decision of a work (delegation-8). Its closed list of kinds includes `consolidate`, with the format number still 5 (repeated-corrections-28). `docs/wiki/evidence.md` is an optional file that a tool keeps, with no change of format (repeated-corrections-19) | |
| Skeleton | `plugins/playbook-wiki/skeleton.md` | The one text of the steps that write a wiki's skeleton: the entry point with the project's owner, asked with git's `user.name` recommended, the marker, and the two `CLAUDE.md` sentences after a yes (setup-commands-2, setup-commands-3). `/playbook-wiki:init`, `prepare-project`, and `/playbook:init` read it | Open a work |
| Check | `plugins/playbook-wiki/check-wiki.sh` | Failing on a wiki that breaks the present format, work by work (D202); with `--delegations`, printing each kind the owner answered as recommended at least 10 times, at least 80%, never rejected (delegation-6, delegation-11) | Read a wiki at an earlier format: it sends it to the doctor. Detect two decisions that contradict each other (D173) |
| Check at the commit | `plugins/playbook-wiki/hooks/commit-check-hook.sh` | Running the check before an agent's `git commit` when anything under `docs/wiki/` differs from the last commit, and stopping the commit with the check's output when it fails (wiki-check-on-commit-1, wiki-check-on-commit-3, wiki-check-on-commit-6) | Check a wiki below the present format (wiki-check-on-commit-4). Reach a commit a person runs in their own terminal (wiki-check-on-commit-5). Read which files the commit carries: it checks the files on disk. Stop a commit by its own error |
| Step at the merge | `plugins/playbook-wiki/merge-step.sh`, `plugins/playbook-wiki/hooks/merge-step-hook.sh`, with `hooks/git-hook-lib.sh`, which both hooks on git share | Listing, before a merge, the decisions each side added and the shared pages both changed, and, when there is something to compare, asking the person in the permission prompt before the merge runs (TD28) | Decide which decision holds |
| Wiki skills | `plugins/playbook-wiki/skills/` | `init`, which writes the skeleton where no wiki exists and changes nothing where one does (setup-commands-2); `prepare-project`, which works on the open work (D203) and, at stage 5, asks how the work is delivered: where it is tested, how its units integrate, and how its branches are named (work-delivery-4, work-delivery-5, work-delivery-6, work-delivery-8), and asks no question a delegation in force covers (delegation-7); `doctor`, which brings a wiki to the present format (D207) and, moving a state section that is too long, takes out what another page holds and what is finished (wiki-check-on-commit-2), and at format 5 fills the kind and answer of earlier decisions as estimated (delegation-9); `write-docs` (TD30) | |
| Hold at the commit | `plugins/playbook-agents/hooks/review-before-commit.sh`, `hooks/review-ran.sh`, with `hooks/hook-lib.sh`, which parses for both, for `hooks/rules-for-subagent.sh`, and for `hooks/ask-before-delivery.sh`; its tokenizer is a function the commit hold and the delivery hook share (ask-before-irreversible-12) | Holding an agent's `git commit` once, in every project, when the agent `review` has not run since the last commit of the session, with R20 and what the commit changes, so the agent judges whether the change is risky (review-trigger-2, review-trigger-3, review-trigger-4, review-trigger-6). After the hold, or after `review`, letting commits run until `HEAD` moves (review-trigger-15, review-trigger-16). Letting a commit of `docs/wiki/` alone run (review-trigger-14). `review-ran.sh` also does the check of the classifier, below | Judge whether a change is risky: the agent does (review-trigger-3). Stop a person, or a commit by its own error (review-trigger-5). Change what `review` does |
| Rules | `plugins/playbook-agents/rules.md` | The owner's rules that are not in the contract (D175, D200) | Define the wiki |
| Agents | `plugins/playbook-agents/agents/` | `explore`, `write`, `review`, and `classify`, each with its model and effort (TD8, repeated-corrections-10). `review` has the tool `Agent` and, when it ends with findings, starts `classify` with the findings, the root of the reviewed tree, and a review identifier; it still changes no code (repeated-corrections-17) | Decide when to delegate; the rules do |
| The classifier | `plugins/playbook-agents/agents/classify.md` | The agent `classify`, seen as `playbook-agents:classify`, with the model `sonnet`: its instructions hold the criteria that decide the kind and the level of a finding, judged the same way each time (repeated-corrections-7, changed by repeated-corrections-27), and it adds rows to the project's `docs/wiki/evidence.md` (repeated-corrections-10, repeated-corrections-11, repeated-corrections-17, repeated-corrections-27) | Consolidate, rename a kind, or delete a row: it only adds rows, and a consolidation is proposed to the owner at the close of a work (repeated-corrections-13). Count: a script does (repeated-corrections-6). Get the person's model from `playbook.models`: the hook of that choice covers `explore`, `write`, and `review` only |
| Tasks | `plugins/playbook-agents/tasks.sh` | `tasks.sh`, in `sh` and `awk`, keeps a project's `docs/wiki/tasks.md` (task-agents-3, task-agents-9). `add <task> <work> <steps> [wiki dir]` puts a row inside the table; `count` prints "ready: <task>: N works, last <date>" for each task held in 3 distinct works whose rows name no agent and are not declined (task-agents-4); `set-agent <task> <name|declined>` fills the agent cell (task-agents-11, task-agents-12); `check` validates the page. It counts only valid rows inside the table, refuses a page that is a symbolic link, and writes atomically | Judge a task's weight, or write an agent: the close step does |
| Evidence | `plugins/playbook-agents/evidence.sh`, `plugins/playbook-agents/evidence-rules.md` | `evidence.sh`, in `sh` and `awk`, has five modes. `check` validates the page `docs/wiki/evidence.md`; `count` prints, per kind and level, the distinct reviews and the last date, marking a group "ready" at 3 distinct reviews, a value of the script; `rules` prints the rules of level 2 and up, of the page and of `evidence-rules.md`; `index` prints one line per kind of level 2 and up with when it applies; `rule <kind>` prints that kind's level, rule, when it applies, and source (repeated-corrections-12, repeated-corrections-18, repeated-corrections-19, seed-evidence-31). Hooks call it, so the cycle does not depend on the agent remembering (repeated-corrections-4). It never writes a file. `evidence-rules.md` holds the playbook's general rules in the same table of kinds, 15 of level 2, and ships with each release (repeated-corrections-20, seed-evidence-32) | Judge whether two findings are the same: the classifier does (repeated-corrections-6). Use the wiki's check for the page: it has its own (repeated-corrections-19) |
| Model configuration | `plugins/playbook-agents/models.conf`, `scripts/set-models.sh` | The default model and effort of each agent; the script writes them into the agent files (TD11) | Run at session time. Hold the person's choice, which sits above it (setup-commands-10) |
| The person's models | `plugins/playbook-agents/skills/config/`, `plugins/playbook-agents/hooks/agent-models.sh` | `/playbook-agents:config` shows each agent's model, effort, and where they come from, and writes the person's choice under `playbook.models` for one repository or every project (setup-commands-4). Before each call of `explore`, `write`, or `review`, the hook adds that model and effort to the call, the repository's first (setup-commands-10) | Accept a model that is not an alias: the Agent call takes only `haiku`, `sonnet`, `opus`, or `fable`. Change a call when nothing is set. Act in Codex (setup-commands-7) |
| Ask before delivery | `plugins/playbook-agents/hooks/ask-before-delivery.sh`, registered in `plugins/playbook-agents/hooks/hooks.json` | Answering `permissionDecision` `ask`, with the reason "R14: push, pull requests, merges, and releases are the owner's decisions. Confirm this one.", before the delivery actions of R14: `git push` in every form, `gh pr create`, `gh pr merge`, and `gh release create`, `edit`, and `delete` (ask-before-irreversible-2, ask-before-irreversible-21). It finds them per segment with the tokenizer of `hook-lib.sh`, after `cd`, `git -C`, global options, and environment variables, outside quoted text, and reads the text of `sh -c`, `bash -c`, and `eval` once; it asks when it cannot read its input and prints nothing otherwise (ask-before-irreversible-12). The entry has no `if`, so it runs on every Bash call and exits at once when the command holds no `git` or `gh` (ask-before-irreversible-13). It asks every time, also after a "yes" in the conversation, and for subagents too (ask-before-irreversible-4, ask-before-irreversible-5) | Deny, allow, or remember an earlier answer (ask-before-irreversible-4). Stop deleting files, resetting history, or reading secrets: `protect` proposes rules for those (ask-before-irreversible-7) |
| Protect script | `plugins/playbook-agents/protect.sh` | In `sh` and `awk`, with no new dependency (ask-before-irreversible-14). `scan` lists the secret files of the repository by name, skipping `.git` and `node_modules`. `apply <settings file> <items>` adds the chosen rules with `json_add` of `init.sh`, creating the file when missing and changing no other key; adding a rule twice changes nothing. The items: per secret file, `permissions.deny` `Read(<path>)` and `sandbox.filesystem.denyRead`; `permissions.ask` for `rm -r`, `rm -rf`, `git reset --hard`, `git branch -D`, and `git clean`; `sandbox.enabled` `true`; and, apart and with a warning, `sandbox.allowUnsandboxedCommands` `false` (ask-before-irreversible-9, ask-before-irreversible-15) | Read the content of a secret file. Remove a rule. Write an item the person did not choose |
| Protect command | `plugins/playbook-agents/skills/protect/` | The command `/playbook-agents:protect`, started only by the person (`disable-model-invocation: true`, so not in the limit L4), inside a repository and again when it changes: runs `scan`, shows each item with the warning of `allowUnsandboxedCommands`, asks which to write, asks once where, `.claude/settings.json` recommended or `.claude/settings.local.json`, runs `apply`, and shows what it wrote (ask-before-irreversible-8, ask-before-irreversible-9, ask-before-irreversible-10) | Write without the person's choice. Change a key it does not add to |
| Rules for a subagent | `plugins/playbook-agents/hooks/rules-for-subagent.sh` | At the start of `write` and `review`, running `evidence.sh index` and giving the index of the rules of level 2 and up as extra context, in one line of JSON, with the absolute command `evidence.sh rule <kind>` that prints one rule; level 1 records are evidence and are not given (repeated-corrections-18, seed-evidence-31). Each line says when the kind applies and the subagent judges, since the hook's input holds no task text, and reads the rule only of the kinds that match its task (repeated-corrections-18, seed-evidence-31). It prints nothing when there are no rules or the input cannot be read, and never blocks | Filter by the task. Read the page of any directory but the session's start: see the limits below |
| Agent skills | `plugins/playbook-agents/skills/` | `keep-minimal`, `review-change`, `write-skill`, `avoid-generic-design` (TD30), `config` (setup-commands-4), `seed-evidence` (seed-evidence-2), and `protect` (ask-before-irreversible-8) | |
| The reader of past reviews | `plugins/playbook-agents/seed-reviews.sh` | `list` and `show`: finds the transcript folders of a repository and its worktrees under `$CLAUDE_CONFIG_DIR/projects/` or `~/.claude/projects/`, plus those of `--from <old path>`, repeatable, for a moved repository; lists its reviews with identifier and findings, marking those already on the page; prints one review's text and identifier. In `sh` and `awk`, with no JSON parser (seed-evidence-7, seed-evidence-14) | Write a file or call a model. List a review resumed after its session restarted: its notice of the end carries no call identifier |
| Seed the evidence | `plugins/playbook-agents/skills/seed-evidence/` | The command `/playbook-agents:seed-evidence`, started only by the person (`disable-model-invocation: true`, so not in the limit L4): runs `seed-reviews.sh list`, shows the preview with each review's date and findings and the number of runs, asks which to seed, every review with findings chosen by default, then starts `classify` once per chosen review, in order, with its date, and ends with `evidence.sh count` (seed-evidence-2, seed-evidence-3, seed-evidence-4, seed-evidence-5) | Classify or write the page itself. Seed a review that said "No findings." |
| Evaluation cases | `plugins/playbook-wiki/evals/`, `plugins/playbook-agents/evals/` | Cases where a skill must load and where it must not, run with `claude plugin eval` (TD4) | Run by themselves |
| Checks of this repository | `scripts/verify.sh`, `scripts/verify_test.sh` | Failing a change that breaks the format of a skill or a size limit, counted for each plugin (D199) | Judge the quality of a skill |

## Hooks

| Plugin | Event | What runs |
|--------|-------|-----------|
| `playbook-wiki` | `SessionStart` | Prints the contract on every start. On `startup` only, two notices, each one JSON object with `systemMessage` for the person and `additionalContext` for the agent: the wiki's format when it is behind, recommending the doctor, or ahead of the plugin, recommending an update (`skills/doctor/scripts/wiki-format.sh hook`; its `status` mode is unchanged); and a newer version of `playbook-wiki` in the marketplace's local copy than the one installed (`hooks/version-check.sh`) (version-check-3, version-check-5, version-check-9, version-check-16) |
| `playbook-wiki` | `SubagentStart` | Gives the contract to each subagent as extra context (TD29) |
| `playbook-wiki` | `PreToolUse` on `Bash(git *)` | The step at the merge, for a `git merge` |
| `playbook-wiki` | `PreToolUse` on `Bash(git *)` | The check at the commit, for a `git commit` (wiki-check-on-commit-1) |
| `playbook-agents` | `SessionStart` | Prints the rules, then "Talk to the person in <language>." when the person set a language |
| `playbook-agents` | `SubagentStart` on `^playbook-agents:(write\|review)$` | `rules-for-subagent.sh`: gives the subagent the index of the rules of level 2 and up from `evidence.sh index`, one line per kind with when it applies, and the command `evidence.sh rule <kind>` that prints a rule; the subagent reads only the rules whose kind matches its task (repeated-corrections-18, seed-evidence-31) |
| `playbook-agents` | `SubagentStop` on `^playbook-agents:review$` | Writes the session's mark under `${CLAUDE_PLUGIN_DATA}/review/` (review-trigger-7). Then `review-ran.sh` reads the review's transcript: when the last message has no line that is exactly "No findings.", the transcript holds no call of `playbook-agents:classify`, and the hook has not blocked that subagent before (a mark per `agent_id` under `${CLAUDE_PLUGIN_DATA}/classify-asked/`, as `stop_hook_active` is not set on its repeated stops), it stops the review with `decision: block` and asks for the classifier, once (repeated-corrections-17, repeated-corrections-31). The mark is written first, so the commit hold does not depend on the classifier |
| `playbook-agents` | `PreToolUse` on `Bash(git *)` | The hold at the commit, for a `git commit` (review-trigger-4) |
| `playbook-agents` | `PreToolUse` on `Bash` | `ask-before-delivery.sh`: asks the person before a `git push`, `gh pr create`, `gh pr merge`, or `gh release create`, `edit`, or `delete`, with no `if` (ask-before-irreversible-2, ask-before-irreversible-13) |
| `playbook-agents` | `PreToolUse` on `Agent` | Adds the person's model and effort to a call of the product's agents (setup-commands-10) |

## How the evidence is kept

Findings that repeat become rules the agents keep in mind at the step where they happened (repeated-corrections-1, repeated-corrections-3).

1. At the start of `write` or `review`, the `SubagentStart` hook gives the index of the rules of level 2 and up; the subagent reads the rule of each kind that matches its task (repeated-corrections-18, seed-evidence-31).
2. When `review` ends with findings, it starts `classify` with them. The classifier stores each real finding as a row of evidence under a kind, or under a new kind at level 1 (repeated-corrections-17).
3. If `review` ended with findings and started no classifier, the `SubagentStop` hook stops it and asks for one (repeated-corrections-17).
4. At the close of a work, `evidence.sh count` lists the groups with 3 distinct reviews at one kind and level. Each is proposed to the owner as a rule one level up, replacing its rows; when the owner delegated the kind `consolidate`, the agent makes it and says so (repeated-corrections-13, repeated-corrections-28).
5. A rule marked general is proposed to go up to `evidence-rules.md` (repeated-corrections-20).
6. To start a repository's page from the reviews it already had, the person runs `/playbook-agents:seed-evidence`; each chosen review goes through step 2 with its own date (seed-evidence-2, seed-evidence-5).

Known limits:

- The `SubagentStart` hook reads the page of the session's start directory, `$CLAUDE_PROJECT_DIR/docs/wiki`, or the `cwd` of the hook input when that variable is not set; a session started in one directory that works in another gets the rules of the first (repeated-corrections-18).
- Evidence is stored only when a subagent can start a subagent, which Claude Code allows by default, up to three layers. With `CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH=1`, `review` cannot start `classify` and nothing is stored (repeated-corrections-17). Checked on 2026-11-19 in https://code.claude.com/docs/en/sub-agents.
- A hook of type `prompt` or `agent` cannot start the classifier: it only allows or blocks (repeated-corrections-17).
- `seed-reviews.sh` reads Claude Code's transcripts, whose format is not documented and which are kept about 30 days (recalled, not verified): if their shape changes, the list comes back empty and says so (seed-evidence-7). A moved repository needs `--from <old path>` (seed-evidence-14).

## How a delivery action is stopped

R14 makes push, pull requests, merges, and releases the owner's decisions. A plugin cannot ship permission rules, so the delivery hook asks, and `protect` writes a repository's own rules for what cannot be undone there (ask-before-irreversible-2, ask-before-irreversible-7). The work was built in three units and delivered by one pull request: the hook and the script accepted by their evidence, the command by judgement (ask-before-irreversible-19).

A hook's `ask` showed the prompt in `bypassPermissions`, also for a subagent in the background; `acceptEdits` and `auto` were not measured (ask-before-irreversible-3, ask-before-irreversible-5).

Accepted limits:

- A heredoc's body is read as commands, so a line in it such as `gh pr merge now` asks: a false ask, never a missed one. The tokenizer is shared with the commit hold and is not changed for it (ask-before-irreversible-12).
- A `Read` deny rule stops the file tools and only the Bash commands Claude Code recognizes, such as `cat`, not every command; that is why `protect` also offers `sandbox.filesystem.denyRead` for each secret file (ask-before-irreversible-15).
- In a mode that shows no prompt, such as a non-interactive run, an `ask` becomes a refusal with the same reason, and the agent asks in the conversation (ask-before-irreversible-3).
- On Linux the sandbox needs `bwrap` and `socat`. When they are missing, commands run without the sandbox unless `sandbox.failIfUnavailable` is `true`; `protect` says when either is missing (ask-before-irreversible-15).
- A form of push the tokenizer misses, such as a script that pushes inside, is not stopped; the sandbox and the rules of `protect` reduce it (ask-before-irreversible-12, ask-before-irreversible-15).

## How a review runs

1. The main agent, or the person, asks for a review of a change.
2. `review-change` starts in a separate context (`context: fork`) on the agent `playbook-agents:review`, which is Claude Opus at high effort (TD8, TD10).
3. The agent reads the change there and returns only its findings. With findings, it starts `classify` first (repeated-corrections-17).

The reviewer starts without the conversation, so the request must say what to review.

## How units are planned and built in parallel

Stage 5 of `prepare-project` adds to a work's plan a table of batches, built batch by batch in stage 6 (parallel-units-2). It writes in `plan.md` a column "Waits for" in the units table: a unit that uses what another builds waits for it, and sharing a file is not waiting (parallel-units-5). The batches follow from that column and are written in a Batches table with a column "Shared"; batch 1 holds the units that wait for none, batch 2 those that wait only on batch 1, and so on (parallel-units-3, parallel-units-5). A column "Changes" gives the exact paths each unit may change (parallel-units-4). The plan also names the most `write` agents at once, and how a worktree is prepared: the command that installs the dependencies and the ignored files to copy, such as `.env`. The owner accepts all of it with the plan (parallel-units-8, parallel-units-9, parallel-units-12, parallel-units-15).

Stage 6 starts a unit as soon as every unit it waits for is Done, up to the plan's number of agents (parallel-units-7, parallel-units-8). For each ready unit the main agent:

1. creates a worktree with `git worktree add -b <unit branch> <folder> <work branch>`, never with the Agent tool's `isolation: "worktree"` (parallel-units-11);
2. runs the plan's install command and copies its ignored files, and nothing when the plan names none (parallel-units-12);
3. starts `write` in the background with the folder and its paths, as several Agent calls in one message; when one ends, the next ready unit starts (parallel-units-13);
4. runs `review` from the main folder when the unit is risky, so `classify` writes the evidence once, on the work's branch (parallel-units-6, parallel-units-24);
5. merges the unit with `git merge --no-ff <unit branch>`, runs its checks, and removes the worktree and its branch (parallel-units-14).

A batch the plan marks as Shared gets one worktree and one branch, prepared once and merged once; in it two units that change the same file cannot run together (parallel-units-23). On a conflict the main agent resolves it and runs the checks of both units again (parallel-units-6).

This happens only when the plan delivers through a work branch with local merges (parallel-units-21) and `playbook-agents` is on. Without it, where `write` does not exist, the main agent builds each unit directly, one at a time, and the batches stay in the plan (parallel-units-22).

Accepted risks (the work's own page lists them with what reduces each):

- Two units change the same lines and the merge conflicts (parallel-units-6).
- Units pass alone and fail together, so the checks run again on the work's branch after each merge (parallel-units-14).
- Preparing a worktree is slow or heavy; then the batch is Shared (parallel-units-9, parallel-units-23).
- A `write` agent changes files in the main folder instead of its own; it gets the absolute folder and its paths (parallel-units-4).
- An agent fails and leaves its worktree and branch behind; the main agent lists them with `git worktree list` and removes them before the work closes (parallel-units-14).
- The commit hold of `playbook-agents` holds the first commit in each new worktree once; the agent commits again.
- Parallel agents spend tokens at the same time; the plan sets the number (parallel-units-8).

## How a repeated task becomes an agent

At the close of a work, when `playbook-agents` is installed, `prepare-project` follows `references/tasks.md` (task-agents-10). It reads the git log since the previous work's close, so it sees steps done after that close, such as the previous work's release (task-agents-8, task-agents-18), and records each task it would carry out again with `tasks.sh add`. Then it runs `count`. For each task held in 3 distinct works it judges the weight of the steps (task-agents-4, task-agents-5):

| Steps | Model | Effort |
|-------|-------|--------|
| Mechanical, with fixed commands | `haiku` | `low` |
| Write text or judge a small change | `sonnet` | `medium` |
| Decide, design, or touch R14 or R20 | the main session | |

It proposes one task at a time and asks the owner even under a delegation. On a yes it writes `.claude/agents/<task>.md` in the project, with only the steps that do not stay in the main session and a line naming those that do; the owner carries to the playbook an agent that serves every project (task-agents-6, task-agents-11). On a no the rows say "declined" and the task is not proposed again (task-agents-12).

## The data

- In a project's repository: the wiki, in two layers (D189). The shared pages say how the project is now; the folder of each work, `docs/wiki/works/<name>/`, holds its decisions with their reasons and who decided (TD24).
- On a person's machine, in `${CLAUDE_PLUGIN_DATA}` of `playbook-agents`: a mark per session after `review` runs, and the commit held per session, each a few bytes, removed after seven days (review-trigger-7).
- On a person's machine: which plugins are on, `enabledPlugins` in `~/.claude/settings.json` for every project or in a repository's `.claude/settings.local.json` for one (TD27); the language, with `userConfig` of `playbook-agents` (TD31); a skill the person turned off, with `skillOverrides` (TD33).
- On a person's machine, under the key `playbook` of the same settings files: `models`, the model and effort the person chose for each agent, such as `"review": "opus xhigh"` (setup-commands-10); `keepBoth`, the skills whose pair the person settled with "Keep both", a skill of the project in the repository's file (setup-commands-8, setup-commands-15). Claude Code keeps the key when it rewrites the file, tried with `claude plugin enable` and `disable` on 2.1.327; saving a permission was not tried (setup-commands-11).
- In a project's repository: `docs/wiki/evidence.md`, two tables: the kinds, each with its level, rule, when it applies, source, and scope; and the evidence, one row per finding with its kind, level, review, date, and a general line. A consolidation replaces the rows of one kind and level with a rule one level up, and git keeps the rows removed (repeated-corrections-5, repeated-corrections-15, repeated-corrections-19). In the playbook: `plugins/playbook-agents/evidence-rules.md`, the general rules, in the same table (repeated-corrections-20).
- In a project's repository: `docs/wiki/tasks.md`, one table with a row per task of each closed work: its name, the date, the work, its steps in one line, and its agent, empty or "declined" (task-agents-3, task-agents-12). A project's dedicated agents live in its `.claude/agents/` (task-agents-6).
- In the owner's agent system: Engram for what was learned across sessions, and CodeGraph for the map of a codebase (D25, D36).

## Outside systems

| System | For | How critical |
|--------|-----|--------------|
| Claude Code | Loading the plugins, their hooks, skills, and agents; the question dialog of the wizard; the commands its script runs | The product does not work without it (D181) |
| git | Branches and merges of works | The core's way of working with several people depends on it (D173, D178) |
| Anthropic's models | Haiku, Sonnet, and Opus for the four agents | Total for `playbook-agents` |
| Claude Code's nested subagents | `review` starting `classify` | Without them no evidence is stored; the rest works (repeated-corrections-17) |
| Engram, CodeGraph | Memory and the map of the code, for the owner's agent system | The work continues without them |

## Size limits

Counted for each plugin by `scripts/verify.sh` (D199):

| Plugin | Always-loaded file | What loads at session start |
|--------|--------------------|-----------------------------|
| `playbook-wiki` | The contract, at most 270 words (delegation-2) | At most 370 words (delegation-2) |
| `playbook-agents` | The rules, at most 400 words | At most 620 words |

## How it can evolve

- A tool other than Claude Code: the contract is one Markdown file and the check is plain shell, so both can be given to another tool as files (D191).
- A project that wants `playbook-wiki` on for everyone: Claude Code's scope `project`, an entry in the repository's `.claude/settings.json`.
- A team of more than five people: an index of works, decided when that team exists (D178).
- A listing in Anthropic's plugin directory, once the owner's organization is Verified (plugin-directory-9).
- A new model: one line of `models.conf`, by a decision (TD8, TD11).
- When Claude Code gets a setting for one agent's model, it replaces the hook, and `playbook.models` moves there (setup-commands-10).
