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
| Hold at the commit | `plugins/playbook-agents/hooks/review-before-commit.sh`, `hooks/review-ran.sh`, with `hooks/hook-lib.sh`, which parses for both and for `hooks/rules-for-subagent.sh` | Holding an agent's `git commit` once, in every project, when the agent `review` has not run since the last commit of the session, with R20 and what the commit changes, so the agent judges whether the change is risky (review-trigger-2, review-trigger-3, review-trigger-4, review-trigger-6). After the hold, or after `review`, letting commits run until `HEAD` moves (review-trigger-15, review-trigger-16). Letting a commit of `docs/wiki/` alone run (review-trigger-14). `review-ran.sh` also does the check of the classifier, below | Judge whether a change is risky: the agent does (review-trigger-3). Stop a person, or a commit by its own error (review-trigger-5). Change what `review` does |
| Rules | `plugins/playbook-agents/rules.md` | The owner's rules that are not in the contract (D175, D200) | Define the wiki |
| Agents | `plugins/playbook-agents/agents/` | `explore`, `write`, `review`, and `classify`, each with its model and effort (TD8, repeated-corrections-10). `review` has the tool `Agent` and, when it ends with findings, starts `classify` with the findings, the root of the reviewed tree, and a review identifier; it still changes no code (repeated-corrections-17) | Decide when to delegate; the rules do |
| The classifier | `plugins/playbook-agents/agents/classify.md` | The agent `classify`, seen as `playbook-agents:classify`, with the model `sonnet`: its instructions hold the criteria that decide the kind and the level of a finding, judged the same way each time (repeated-corrections-7, changed by repeated-corrections-27), and it adds rows to the project's `docs/wiki/evidence.md` (repeated-corrections-10, repeated-corrections-11, repeated-corrections-17, repeated-corrections-27) | Consolidate, rename a kind, or delete a row: it only adds rows, and a consolidation is proposed to the owner at the close of a work (repeated-corrections-13). Count: a script does (repeated-corrections-6). Get the person's model from `playbook.models`: the hook of that choice covers `explore`, `write`, and `review` only |
| Evidence | `plugins/playbook-agents/evidence.sh`, `plugins/playbook-agents/evidence-rules.md` | `evidence.sh`, in `sh` and `awk`, has three modes. `check` validates the page `docs/wiki/evidence.md`; `count` prints, per kind and level, the distinct reviews and the last date, marking a group "ready" at 3 distinct reviews, a value of the script; `rules` prints the rules of level 2 and up, of the page and of `evidence-rules.md` (repeated-corrections-12, repeated-corrections-18, repeated-corrections-19). Hooks call it, so the cycle does not depend on the agent remembering (repeated-corrections-4). It never writes a file. `evidence-rules.md` holds the playbook's general rules in the same table of kinds, and ships with each release (repeated-corrections-20) | Judge whether two findings are the same: the classifier does (repeated-corrections-6). Use the wiki's check for the page: it has its own (repeated-corrections-19) |
| Model configuration | `plugins/playbook-agents/models.conf`, `scripts/set-models.sh` | The default model and effort of each agent; the script writes them into the agent files (TD11) | Run at session time. Hold the person's choice, which sits above it (setup-commands-10) |
| The person's models | `plugins/playbook-agents/skills/config/`, `plugins/playbook-agents/hooks/agent-models.sh` | `/playbook-agents:config` shows each agent's model, effort, and where they come from, and writes the person's choice under `playbook.models` for one repository or every project (setup-commands-4). Before each call of `explore`, `write`, or `review`, the hook adds that model and effort to the call, the repository's first (setup-commands-10) | Accept a model that is not an alias: the Agent call takes only `haiku`, `sonnet`, `opus`, or `fable`. Change a call when nothing is set. Act in Codex (setup-commands-7) |
| Rules for a subagent | `plugins/playbook-agents/hooks/rules-for-subagent.sh` | At the start of `write` and `review`, running `evidence.sh rules` and giving the rules of level 2 and up as extra context, in one line of JSON; level 1 records are evidence and are not given (repeated-corrections-18). Each rule says when it applies and the subagent judges, since the hook's input holds no task text (repeated-corrections-18). It prints nothing when there are no rules or the input cannot be read, and never blocks | Filter by the task. Read the page of any directory but the session's start: see the limits below |
| Agent skills | `plugins/playbook-agents/skills/` | `keep-minimal`, `review-change`, `write-skill`, `avoid-generic-design` (TD30), and `config` (setup-commands-4) | |
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
| `playbook-agents` | `SubagentStop` on `^playbook-agents:review$` | Writes the session's mark under `${CLAUDE_PLUGIN_DATA}/review/` (review-trigger-7). Then `review-ran.sh` reads the review's transcript: when the last message has no line that is exactly "No findings.", the transcript holds no call of `playbook-agents:classify`, and the hook did not already block once, it stops the review with `decision: block` and asks for the classifier (repeated-corrections-17). The mark is written first, so the commit hold does not depend on the classifier |
| `playbook-agents` | `PreToolUse` on `Bash(git *)` | The hold at the commit, for a `git commit` (review-trigger-4) |
| `playbook-agents` | `PreToolUse` on `Agent` | Adds the person's model and effort to a call of the product's agents (setup-commands-10) |

## How the evidence is kept

Findings that repeat become rules the agents keep in mind at the step where they happened (repeated-corrections-1, repeated-corrections-3).

1. At the start of `write` or `review`, the `SubagentStart` hook gives the index of the rules of level 2 and up; the subagent reads the rule of each kind that matches its task (repeated-corrections-18, seed-evidence-31).
2. When `review` ends with findings, it starts `classify` with them. The classifier stores each real finding as a row of evidence under a kind, or under a new kind at level 1 (repeated-corrections-17).
3. If `review` ended with findings and started no classifier, the `SubagentStop` hook stops it and asks for one (repeated-corrections-17).
4. At the close of a work, `evidence.sh count` lists the groups with 3 distinct reviews at one kind and level. Each is proposed to the owner as a rule one level up, replacing its rows; when the owner delegated the kind `consolidate`, the agent makes it and says so (repeated-corrections-13, repeated-corrections-28).
5. A rule marked general is proposed to go up to `evidence-rules.md` (repeated-corrections-20).

Known limits:

- The `SubagentStart` hook reads the page of the session's start directory, `$CLAUDE_PROJECT_DIR/docs/wiki`, or the `cwd` of the hook input when that variable is not set; a session started in one directory that works in another gets the rules of the first (repeated-corrections-18).
- Evidence is stored only when a subagent can start a subagent, which Claude Code allows by default, up to three layers. With `CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH=1`, `review` cannot start `classify` and nothing is stored (repeated-corrections-17). Checked on 2026-11-19 in https://code.claude.com/docs/en/sub-agents.
- A hook of type `prompt` or `agent` cannot start the classifier: it only allows or blocks (repeated-corrections-17).

## How a review runs

1. The main agent, or the person, asks for a review of a change.
2. `review-change` starts in a separate context (`context: fork`) on the agent `playbook-agents:review`, which is Claude Opus at high effort (TD8, TD10).
3. The agent reads the change there and returns only its findings. With findings, it starts `classify` first (repeated-corrections-17).

The reviewer starts without the conversation, so the request must say what to review.

## The data

- In a project's repository: the wiki, in two layers (D189). The shared pages say how the project is now; the folder of each work, `docs/wiki/works/<name>/`, holds its decisions with their reasons and who decided (TD24).
- On a person's machine, in `${CLAUDE_PLUGIN_DATA}` of `playbook-agents`: a mark per session after `review` runs, and the commit held per session, each a few bytes, removed after seven days (review-trigger-7).
- On a person's machine: which plugins are on, `enabledPlugins` in `~/.claude/settings.json` for every project or in a repository's `.claude/settings.local.json` for one (TD27); the language, with `userConfig` of `playbook-agents` (TD31); a skill the person turned off, with `skillOverrides` (TD33).
- On a person's machine, under the key `playbook` of the same settings files: `models`, the model and effort the person chose for each agent, such as `"review": "opus xhigh"` (setup-commands-10); `keepBoth`, the skills whose pair the person settled with "Keep both", a skill of the project in the repository's file (setup-commands-8, setup-commands-15). Claude Code keeps the key when it rewrites the file, tried with `claude plugin enable` and `disable` on 2.1.327; saving a permission was not tried (setup-commands-11).
- In a project's repository: `docs/wiki/evidence.md`, two tables: the kinds, each with its level, rule, when it applies, source, and scope; and the evidence, one row per finding with its kind, level, review, date, and a general line. A consolidation replaces the rows of one kind and level with a rule one level up, and git keeps the rows removed (repeated-corrections-5, repeated-corrections-15, repeated-corrections-19). In the playbook: `plugins/playbook-agents/evidence-rules.md`, the general rules, in the same table (repeated-corrections-20).
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
