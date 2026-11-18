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
| When work is delegated | Agents, each with a fixed model and effort (TD7, TD8) |

## Modules

| Module | Path | Responsible for | Does not |
|--------|------|-----------------|----------|
| Start command | `plugins/playbook/skills/init/` | The wizard: the wiki alone or the whole product, this repository or every project, and the language (D183, D184, TD31). It names the other plugins on and a global `CLAUDE.md` (D186), and the skills that are not the product's (D193, TD33). Its script, `scripts/init.sh`, runs Claude Code's plugin commands and prints each one | Load by itself (`disable-model-invocation: true`). Write in a `CLAUDE.md` (D185). Change anything of another tool (D186) |
| Contract | `plugins/playbook-wiki/contract.md` | The rules about deciding, R5 to R8, R10, and R12, reading the wiki before changing code, the two layers of a wiki, and the step at the merge (D175, D189, D173) | Say how a person's agent talks, delegates, tests, or commits |
| Format | `plugins/playbook-wiki/format.md` | Format 4 of a project's wiki: the shared pages, the works, their files and identifiers (D201) | |
| Check | `plugins/playbook-wiki/check-wiki.sh` | Failing on a wiki that breaks the present format, work by work (D202) | Read a wiki at an earlier format: it sends it to the doctor. Detect two decisions that contradict each other (D173) |
| Check at the commit | `plugins/playbook-wiki/hooks/commit-check-hook.sh` | Running the check before an agent's `git commit` when anything under `docs/wiki/` differs from the last commit, and stopping the commit with the check's output when it fails (wiki-check-on-commit-1, wiki-check-on-commit-3, wiki-check-on-commit-6) | Check a wiki below the present format (wiki-check-on-commit-4). Reach a commit a person runs in their own terminal (wiki-check-on-commit-5). Read which files the commit carries: it checks the files on disk. Stop a commit by its own error |
| Step at the merge | `plugins/playbook-wiki/merge-step.sh`, `plugins/playbook-wiki/hooks/merge-step-hook.sh`, with `hooks/git-hook-lib.sh`, which both hooks on git share | Listing, before a merge, the decisions each side added and the shared pages both changed, and, when there is something to compare, asking the person in the permission prompt before the merge runs (TD28) | Decide which decision holds |
| Wiki skills | `plugins/playbook-wiki/skills/` | `prepare-project`, which works on the open work (D203); `doctor`, which brings a wiki to the present format (D207) and, moving a state section that is too long, takes out what another page holds and what is finished (wiki-check-on-commit-2); `write-docs` (TD30) | |
| Hold at the commit | `plugins/playbook-agents/hooks/review-before-commit.sh`, `hooks/review-ran.sh`, with `hooks/hook-lib.sh`, which parses for both | Holding an agent's `git commit` once, in every project, when the agent `review` has not run since the last commit of the session, with R20 and what the commit changes, so the agent judges whether the change is risky (review-trigger-2, review-trigger-3, review-trigger-4, review-trigger-6). After the hold, or after `review`, letting commits run until `HEAD` moves (review-trigger-15, review-trigger-16). Letting a commit of `docs/wiki/` alone run (review-trigger-14) | Judge whether a change is risky: the agent does (review-trigger-3). Stop a person, or a commit by its own error (review-trigger-5). Change what `review` does |
| Rules | `plugins/playbook-agents/rules.md` | The owner's rules that are not in the contract (D175, D200) | Define the wiki |
| Agents | `plugins/playbook-agents/agents/` | `explore`, `write`, and `review`, each with its model and effort (TD8) | Decide when to delegate; the rules do |
| Model configuration | `plugins/playbook-agents/models.conf`, `scripts/set-models.sh` | The one place where the model and effort of each agent are set; the script writes them into the agent files (TD11) | Run at session time |
| Agent skills | `plugins/playbook-agents/skills/` | `keep-minimal`, `review-change`, `write-skill`, and `avoid-generic-design` (TD30) | |
| Evaluation cases | `plugins/playbook-wiki/evals/`, `plugins/playbook-agents/evals/` | Cases where a skill must load and where it must not, run with `claude plugin eval` (TD4) | Run by themselves |
| Checks of this repository | `scripts/verify.sh`, `scripts/verify_test.sh` | Failing a change that breaks the format of a skill or a size limit, counted for each plugin (D199) | Judge the quality of a skill |

## Hooks

| Plugin | Event | What runs |
|--------|-------|-----------|
| `playbook-wiki` | `SessionStart` | Prints the contract, then the notice of the wiki's format when it is behind (`skills/doctor/scripts/wiki-format.sh hook`) |
| `playbook-wiki` | `SubagentStart` | Gives the contract to each subagent as extra context (TD29) |
| `playbook-wiki` | `PreToolUse` on `Bash(git *)` | The step at the merge, for a `git merge` |
| `playbook-wiki` | `PreToolUse` on `Bash(git *)` | The check at the commit, for a `git commit` (wiki-check-on-commit-1) |
| `playbook-agents` | `SessionStart` | Prints the rules, then "Talk to the person in <language>." when the person set a language |
| `playbook-agents` | `SubagentStop` on `^playbook-agents:review$` | Writes the session's mark under `${CLAUDE_PLUGIN_DATA}/review/` (review-trigger-7) |
| `playbook-agents` | `PreToolUse` on `Bash(git *)` | The hold at the commit, for a `git commit` (review-trigger-4) |

## How a review runs

1. The main agent, or the person, asks for a review of a change.
2. `review-change` starts in a separate context (`context: fork`) on the agent `playbook-agents:review`, which is Claude Opus at high effort (TD8, TD10).
3. The agent reads the change there and returns only its findings.

The reviewer starts without the conversation, so the request must say what to review.

## The data

- In a project's repository: the wiki, in two layers (D189). The shared pages say how the project is now; the folder of each work, `docs/wiki/works/<name>/`, holds its decisions with their reasons and who decided (TD24).
- On a person's machine, in `${CLAUDE_PLUGIN_DATA}` of `playbook-agents`: a mark per session after `review` runs, and the commit held per session, each a few bytes, removed after seven days (review-trigger-7).
- On a person's machine: which plugins are on, `enabledPlugins` in `~/.claude/settings.json` for every project or in a repository's `.claude/settings.local.json` for one (TD27); the language, with `userConfig` of `playbook-agents` (TD31); a skill the person turned off, with `skillOverrides` (TD33).
- In the owner's agent system: Engram for what was learned across sessions, and CodeGraph for the map of a codebase (D25, D36).

## Outside systems

| System | For | How critical |
|--------|-----|--------------|
| Claude Code | Loading the plugins, their hooks, skills, and agents; the question dialog of the wizard; the commands its script runs | The product does not work without it (D181) |
| git | Branches and merges of works | The core's way of working with several people depends on it (D173, D178) |
| Anthropic's models | Haiku, Sonnet, and Opus for the three agents | Total for `playbook-agents` |
| Engram, CodeGraph | Memory and the map of the code, for the owner's agent system | The work continues without them |

## Size limits

Counted for each plugin by `scripts/verify.sh` (D199):

| Plugin | Always-loaded file | What loads at session start |
|--------|--------------------|-----------------------------|
| `playbook-wiki` | The contract, at most 250 words | At most 350 words |
| `playbook-agents` | The rules, at most 400 words | At most 620 words |

## How it can evolve

- A tool other than Claude Code: the contract is one Markdown file and the check is plain shell, so both can be given to another tool as files (D191).
- A project that wants `playbook-wiki` on for everyone: Claude Code's scope `project`, an entry in the repository's `.claude/settings.json`.
- A team of more than five people: an index of works, decided when that team exists (D178).
- A listing in Anthropic's plugin directory, once the owner's organization is Verified (plugin-directory-9).
- A new model: one line of `models.conf`, by a decision (TD8, TD11).
