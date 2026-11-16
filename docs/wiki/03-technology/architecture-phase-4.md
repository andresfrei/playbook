# Architecture of phase 4

How the product is split into a shared core and the owner's agent system, and how a person starts it in a repository. Stage 2 of phase 4. Status on 2026-11-16: accepted by the owner when stage 2 of phase 4 was closed (D192).

The definition is in [../01-product/phase-4.md](../01-product/phase-4.md), and the evidence for each choice in [phase-4.md](phase-4.md). The product as it is before this phase is in [architecture.md](architecture.md) and [architecture-phase-3.md](architecture-phase-3.md). The terms core, agent system, and work are in the [glossary](../01-product/glossary.md).

## The problem

More than one person works on a project, and each has their own way of working with an AI coding agent. The wiki of the project must stay one source of truth for all of them. Today the definition of a wiki lives inside the owner's agent system, and the format of a wiki assumes that one person writes it.

## Requirements and assumptions

| Requirement | From |
|-------------|------|
| A person can use the core alone, without the owner's skills, agents, or rules | D168, D182 |
| A person chooses for each repository, or for every project | D183 |
| Nothing of the product loads until the person starts it, and a wizard asks what to use | D184 |
| The product writes in no `CLAUDE.md` beyond the two sentences that send an agent to the wiki, and it only tells of another agent system, never changes it | D185, D186 |
| A script applies the answers; the agent reads no file to decide | D184 |
| Two works never write the same file | D170, D171, D179 |
| Claude Code only, for now | D181 |
| Two to five people, a handful of works at once, git only | D173, D178 |
| Plain shell, no extra tool | TD2 |

Assumptions:

- Every person who works on a shared project uses Claude Code and installs from this repository's marketplace (D181).
- Claude Code's local setting for a plugin overrides the user one, as its documentation says. It was not tried.

## The shape

Three plugins in this repository's marketplace (TD26). Claude Code's own settings say which are on, for every project or for one repository (TD27).

```text
this repository (the marketplace)
├── start plugin        always on; holds only the start command
├── playbook-wiki       the core; on where the wizard turned it on
└── playbook-agents     the owner's agent system; depends on playbook-wiki
```

It fits the requirements because the only switch Claude Code gives for one repository turns a whole plugin on or off. One plugin for each thing a person may want alone is the smallest split that lets the wiki be used without the agents, and lets both stay off until started.

## The modules

The three plugins and what each is for are TD26, which skill goes to which is TD30, and the name of the start plugin and the folders are TD31.

| Module | Responsible for | Does not | Used by |
|--------|-----------------|----------|---------|
| The start plugin, `playbook`, whose command is `/playbook:init` (TD31) | The start command: a wizard of two questions, what to use and where; a notice of the other plugins that are on and of a global `CLAUDE.md`, before `playbook-agents` is turned on (D186); the list of the skills that are not the product's, and what the person settles about the ones that do the same job (D193, TD33); and the script that applies the answers | Hold a rule, an agent, or a skill the model can load by itself. Write in a `CLAUDE.md` (D185). Change anything of another tool (D186) | The person, by typing the command |
| `playbook-wiki` | The contract (D175), in one file a hook prints at the start of a session. The format of a wiki and the files of a work (TD24). The check. The format marker and its migration. The script and the hook of the step at the merge (TD28). The hooks that give the contract to the main session and to each subagent (TD29). The skills `prepare-project`, `doctor`, and `write-docs` (TD30) | Say how a person's agent talks, delegates, tests, or commits | Every person on the project. `playbook-agents` depends on it |
| `playbook-agents` | The owner's rules without the ones in the contract, printed by a hook. The agents `explore`, `write`, and `review` with their models. The skills `keep-minimal`, `review-change`, `write-skill`, and `avoid-generic-design` (TD30). The language the agent talks to the person in, which the wizard asks and Claude Code keeps with `userConfig` (TD31) | Define the wiki, or change what `playbook-wiki` holds | The owner, and anyone who wants the whole product |
| The wizard's script | Running `claude plugin install`, `enable`, and `disable` with the scope chosen, and printing each command before it runs | Write a file of its own, or change a setting other than these plugins | The start command |
| The check | Failing on a wiki that breaks the format, with the files of each work | Detect two decisions that contradict each other (D173) | A person, a skill, or any script, with plain shell |

Layout: one folder for each plugin under `plugins/`, in place of today's `plugin/` (TD31).

What leaves the repository with opencode (D191), read from the repository on 2026-11-16: `opencode/agents/`, `scripts/install-opencode.sh`, the part of `scripts/set-models.sh` that writes the opencode agents, the part of `scripts/verify.sh` that checks opencode, and the steps for opencode in the repository's `README.md`.

What changes inside the skills (TD30), found by reading them on 2026-11-16:

| Piece | Change |
|-------|--------|
| `prepare-project` | The format of a wiki, `references/1-wiki.md`, and the check, `scripts/check-wiki.sh`, leave it for the plugin's own level, next to the contract. Today `doctor` reads them inside `prepare-project`, and `prepare-project` runs a script inside `doctor`. It works on the folder of a work (D171). Its rule that a phase writes pages of its own and never rewrites the earlier ones gives way to D189: before the merge, what a work defined is written in the shared pages |
| `doctor` | It reads the format and the check at the plugin's level, and gets the migration to the new format |
| `write-docs` | None. It keeps its rule to write in English (D187) |
| `review-change` | It names its agent as `playbook-agents:review` |
| The agent `write` | Its sentence about reading the wiki follows the page table of a work (TD24) |
| `rules.md` | R5 to R8, R10, and R12 go to the contract with their numbers. The limits of size are counted for each plugin |
| `keep-minimal`, `write-skill`, `avoid-generic-design`, the agents `explore` and `review` | None |

Stage 6 of `prepare-project` names no agent: "Build the unit with the execution workflow that the session's instructions define". So it serves a person with another agent system as it is.

## The data

- In a project's repository: the wiki, in two layers (D189). The shared pages say how the project is now; the folder of each work holds its decisions, with their reasons, as history. Its layout is in [phase-4.md](phase-4.md), under "The files of a work".
- On a person's machine: which plugins are on. For every project, `enabledPlugins` in `~/.claude/settings.json`. For one repository, the same key in that repository's `.claude/settings.local.json`, which Claude Code keeps out of git when it creates the file.

The product writes no configuration file of its own (TD27).

## Outside systems

| System | For | How critical |
|--------|-----|--------------|
| Claude Code | Loading the plugins, the question dialog of the wizard, and the commands the script runs | The product does not work without it (D181) |
| git | Branches and merges of works | The core's way of working with several people depends on it (D173) |

Engram and CodeGraph stay as they are, with the owner's agent system.

## Risks

| Risk | What reduces it |
|------|-----------------|
| A plugin off for the user and on for one repository does not behave as documented | The first unit of stage 6 tries it on the owner's machine, with the owner's authorization, before anything is built on it |
| The plugins the wizard turns on are not used until the next session | The same unit finds out. The wizard then says so, or asks for `/reload-plugins` |
| The owner's installation breaks: today's plugin `playbook` becomes the start plugin and loses its skills, agents, and rules | It is version `2.0.0` (TD22, TD32). After it, the owner runs the start command once and chooses the whole product for every project |
| Removing opencode (D191) leaves, on the owner's machine, entries that point into this repository: `instructions` and `skills` in `~/.config/opencode/opencode.json`, and the link `~/.config/opencode/agents` (TD13 to TD15) | A unit of the plan lists them. They are undone only with the owner's authorization |
| A person opens a repository with a wiki and has `playbook-wiki` off, so nothing gives the contract to the agent | The two sentences in the project's `CLAUDE.md` send any agent, and any custom subagent, to the wiki's `README.md` (TD29). The wiki's `README.md` can say that the project uses `playbook-wiki`; whether it must is left to the plan |
| The contract reaches an agent as text, and a person's own rules may say otherwise | Nothing forces it. The check and the step at the merge catch part of what a broken contract leaves |
| The agent misses two skills that do the same job, or names a pair that does not | The person decides each pair, and the start command can be run again (D193) |
| A merge made outside Claude Code skips the hook | The rule of the contract (D173, TD28) |
| The script changes settings on a person's machine | It runs only Claude Code's own plugin commands, and prints each one first |
| The size limits of a session (D48) are checked for one plugin | `scripts/verify.sh` checks each plugin, and the sum for a person who uses the whole product |

## Trade-offs

| Decision | Gained | Given up |
|----------|--------|----------|
| The contract and the check live in `playbook-wiki`, not in the project's repository (TD26) | No copy in each project that grows old | A project does not stand alone: a person needs the plugin. A tool other than Claude Code needs another way to get them |
| Three plugins (TD26) | The wiki alone, with none of the owner's skills or agents, and nothing on before the start | Three manifests to keep, and a dependency between two of them |
| Claude Code's settings hold the answers (TD27) | No file to write, read, or keep out of git | The product depends on how Claude Code's plugin commands and scopes behave |
| No support for opencode (D191) | One tool to build for and to check while the product is still being defined. The owner: "mientras no tiene sertido ir cambiando todo todos los días" | The owner loses the product's rules, skills, and agents in opencode, which D105 wanted for the models of other providers at a lower cost |
| A deliberate start (D184) | A person who installed it loads nothing in the projects where they do not want it | The owner starts it once, where today it loads by itself (D58) |
| The shared pages are rewritten by each work that changes a definition (D189) | An agent understands the project from the pages, without reading the history | Two works that change the same page meet at the merge, which is where D173 wants it seen |
| A folder for each work, with no index (TD24) | Starting a work changes no shared file | To see every work a person lists a folder, or runs the check |

## Discarded alternatives

Each one, with the reason, is in [phase-4.md](phase-4.md): under "The files of a work" for the layout of a work, and under "How the product is split and started" for one plugin with its own configuration file, two plugins, `userConfig`, and the core's files copied into each project.

## How it can evolve

- A tool other than Claude Code: the contract is one Markdown file and the check is plain shell, so both can be given to another tool as files. That was TD23, replaced when D181 limited the phase to Claude Code.
- A project that wants `playbook-wiki` on for everyone: Claude Code's scope `project`, an entry in the repository's `.claude/settings.json`. Its documentation says "Committing that entry turns the plugin on for your collaborators but doesn't download it to their machines." ([Discover plugins](https://code.claude.com/docs/en/discover-plugins.md))
- A team of more than five people: an index of works, decided when that team exists (D178).

## Not verified

The list is in [phase-4.md](phase-4.md), under "Not verified". Nothing in this page was built or tried.
