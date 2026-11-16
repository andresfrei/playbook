# Technology for phase 4

What phase 4, the shared core, needs from its technology, and what is chosen for each need. Stage 2 of phase 4. Status on 2026-11-16: stage 2 is closed (D192). Every need has a decision (TD24, TD26 to TD33) or is met by what the product already uses. TD33 was decided after the stage closed, the same day. TD23 and TD25 were taken earlier the same day and replaced by TD26. The shape that results is in [architecture-phase-4.md](architecture-phase-4.md).

The product definition it comes from is [../01-product/phase-4.md](../01-product/phase-4.md). The terms core, agent system, and work are in the [glossary](../01-product/glossary.md). Phase 4 is built for Claude Code only (D181).

## Needs

Taken from [../01-product/phase-4.md](../01-product/phase-4.md). The numbers continue from N15 of [phase-3.md](phase-3.md).

| # | Need | From | Status |
|---|------|------|--------|
| N16 | Hold each work's decisions, questions, units, and state in files of its own, so that two works never write the same file. Identifiers are the work's name and a counter, and each decision's row says who decided | D170, D171, D174, D179 | Decided: a folder for each work (TD24), under "The files of a work" |
| N17 | Give each work a name that is unique in the project | D170, D171 | Decided: the name of the work's folder (TD24). Two branches that use the same name write the same paths, and git stops the merge |
| N18 | Let the person who merges see the decisions a work brings, and the ones it must be read against, with git only | D173, D178 | Decided: a script lists them, and a hook runs it when the agent is about to merge (TD28), under "The step at the merge" |
| N19 | Give the minimal contract to the agent of every person who works on the project | D168, D175, D181 | Decided: the contract is a file of `playbook-wiki` (TD26). A hook gives it to the main session, and another to each subagent (TD29), under "How the contract reaches an agent" |
| N20 | Run the check with no agent running, and make it check the files of each work | D168 | Decided: a shell script of `playbook-wiki` (TD26, TD2). What it checks follows N16 |
| N21 | Keep the core apart from the owner's agent system, in this repository, so that a person can use it alone | D176, D179, D182 | Decided: two plugins, `playbook-wiki` and `playbook-agents`, and the second depends on the first (TD26). Which skill goes to which is TD30, in [architecture-phase-4.md](architecture-phase-4.md) |
| N22 | Let a person who does not use the owner's agent system get the core | D176, D182 | Decided: that person installs from this repository's marketplace and chooses the wiki alone (TD26, TD27) |
| N23 | Bring a wiki written before the core to the new format, without renumbering its decisions | D177 | Met by what the product already uses: the format marker and the doctor, which gets one more format to migrate to |
| N24 | Install once, and use the product in every project or in one repository | D183 | Decided: Claude Code's scopes `user` and `local` (TD27) |
| N25 | Load nothing of the product in a session until the person starts it | D184 | Decided: a third plugin that holds only the start command, and the other two disabled until then (TD26) |
| N26 | Ask the person what to use and where, with Claude Code's own question dialog | D184 | Met by Claude Code as it is: the `AskUserQuestion` tool, which `prepare-project` already uses (D58) |
| N27 | Apply the answers with a script, and keep them for each repository outside git | D184 | Decided: a script that runs `claude plugin enable` and `disable` (TD27). It writes in no `CLAUDE.md` (D185) |
| N29 | Keep one place that says how the project is now, however many works there were | D189, D190 | Met by the format the product already uses, where a page that states a definition says only the current one, and by the step at the merge (TD28). Two additions are Decided (TD31), under "The present and the history" |
| N30 | Take out of this repository what phase 3 built for opencode | D191 | No technology to choose. The files are listed in [architecture-phase-4.md](architecture-phase-4.md); what is on the owner's machine waits for the owner's authorization |
| N31 | Release the result as version 2 | TD32 | Decided: `2.0.0` in the manifest of each plugin (TD22, TD32) |
| N32 | List the skills that are not the product's: the project's, the person's, and other plugins' | D193 | Decided: a script reads the skill folders and runs `claude plugin list` and `details` (TD33) |
| N33 | Let the person settle each pair of skills that do the same job, and keep what was settled | D193 | Decided: `skillOverrides` in the person's settings for a skill of the person, and a decision in the wiki's page of skills for a skill of the project (TD33) |
| N28 | Tell the person which other plugins are on, and whether a global `CLAUDE.md` exists, before `playbook-agents` is turned on | D186 | Met by Claude Code as it is and plain shell: `claude plugin list`, under "Seen on the machine", and a test for the file `~/.claude/CLAUDE.md` |

## What the product already uses

Not decided again in this phase.

| Technology | Used for | Decision |
|------------|----------|----------|
| Markdown | Every page of a wiki | Nothing else was ever used |
| Plain shell, with no extra tool | The check, `plugin/skills/prepare-project/scripts/check-wiki.sh`, and the format marker, `plugin/skills/doctor/scripts/wiki-format.sh` | TD2 |
| git | Branches and merges | D173, D178 |
| A format marker, `docs/wiki/.format`, written by a script | Saying which format a wiki is in, so that an older one is noticed and migrated | D136 to D142, in [../01-product/wiki-maintenance.md](../01-product/wiki-maintenance.md) |
| A Claude Code plugin from this repository's marketplace | Installing the product | TD1, TD22 |

## Checked in Claude Code's documentation

Read on 2026-11-16 by research agents, which quoted the pages below. Quotes are from the documentation.

How a plugin is loaded ([Plugin loading](https://code.claude.com/docs/en/plugins/loading.md), [Host a marketplace](https://code.claude.com/docs/en/plugins/host-marketplace.md), [Plugins reference](https://code.claude.com/docs/en/plugins-reference.md)):

- A plugin installed from a git address is copied: "Claude Code copies the plugin into `cache/<marketplace>/<plugin>/<version>/` at install and loads that copy." "Files outside the plugin directory aren't copied".
- A plugin cannot declare a component outside itself: "It rejects a component path that resolves outside the plugin root".
- A marketplace added from a local folder, as the owner's is, loads its plugin in place: "Claude Code reads plugins with relative-path sources directly from that directory instead of copying them."

Where a plugin is enabled ([Discover plugins](https://code.claude.com/docs/en/discover-plugins.md), [Settings](https://code.claude.com/docs/en/settings.md)):

- A plugin is turned on or off by "`"<name>@<marketplace>": true` or `false` under `enabledPlugins` in a settings file".
- Three scopes. User: "The entry goes in `enabledPlugins` in `~/.claude/settings.json`." Project: "The entry goes in `.claude/settings.json`, which you commit." Local: "the plugin is enabled for you in this repository only. The entry goes in `.claude/settings.local.json`."
- "the local setting overrides the project setting, and the project setting overrides the user setting."
- The local file and git: "Claude Code keeps it out of git when it creates the file; if you create it by hand, add it to `.gitignore` yourself".

Several plugins in one marketplace ([Plugin dependencies](https://code.claude.com/docs/en/plugins/dependencies.md)):

- Each plugin has its own identifier, `<name>@<marketplace>`.
- "A plugin can declare other plugins that it depends on." "Claude Code looks it up in the same marketplace as the declaring plugin unless you set `marketplace`." "Claude Code also installs and enables the plugin's declared dependencies at the same scope."

What cannot be turned off inside one plugin ([Skills](https://code.claude.com/docs/en/skills.md)):

- "Plugin skills are not affected by `skillOverrides`. Manage those through `/plugin` instead." The documentation gives no way to turn off one skill or one agent of a plugin for one project.
- A skill of a plugin is called "as `/plugin-name:skill-name`".

Values a plugin asks for ([Plugins reference](https://code.claude.com/docs/en/plugins-reference.md)):

- "`userConfig` declares values Claude Code prompts the user for when the plugin is enabled". They are kept "under `pluginConfigs` in the user's `settings.json`", so for the person, not for a repository.

Hooks and subagents ([Hooks](https://code.claude.com/docs/en/hooks.md), [Subagents](https://code.claude.com/docs/en/sub-agents.md)):

- A subagent and `CLAUDE.md`: "Explore and Plan start without your CLAUDE.md files and the git status snapshot". "Other built-in and custom subagents load both, unless you set omitClaudeMd".
- An event for a new subagent: "`SubagentStart` | When a subagent is spawned". "SubagentStart hooks can't block subagent creation, but they can inject context into the subagent." Its output `additionalContext` is a "String added to the subagent's context at the start of its conversation, before its first prompt."
- Hooks and subagents: "When a subagent calls a tool, tool events such as `PreToolUse` and `PostToolUse` fire the same configured hooks". "Hooks from settings files, managed policy settings, and plugins also run inside subagents."
- A hook before a tool call can stop it: "`"deny"` prevents the tool call", and the reason is "shown to Claude". It receives the call: "Claude Code sends the tool input as JSON on stdin to the hook", for a shell command with its text.
- A plugin's hooks: "`hooks/hooks.json` | When plugin is enabled".

Skills that are not a plugin's ([Skills](https://code.claude.com/docs/en/skills.md)):

- Where they are: "Personal | `~/.claude/skills/<skill-name>/SKILL.md`" and "Project | `.claude/skills/<skill-name>/SKILL.md`".
- Two with one name: "Enterprise over personal, and personal over project." "A plugin skill and a skill at any of the locations above | Both load, because plugin skills are namespaced as `/plugin-name:skill-name`".
- Turning one off: set a skill to `"off"` in `skillOverrides`. "In user, project, and local settings, Claude Code matches entries against skill names only." The `/skills` menu writes to `.claude/settings.local.json`.

## Seen on the machine

Read from the help of Claude Code 2.1.325 on 2026-11-16. It says the commands exist, not how they behave.

| Fact | Evidence |
|------|----------|
| `claude plugin enable <plugin>` and `claude plugin disable [plugin]` take `-s, --scope <scope>`: "Installation scope: user, project, local (default: auto-detect)" | `claude plugin enable --help`, `claude plugin --help` |
| `claude plugin list [options]`: "List installed plugins". Its options and its output were not read | `claude plugin --help` |
| `claude plugin list` takes `--json`: "Output as JSON" | `claude plugin list --help` |
| `claude plugin details <name>`: "Show a plugin's component inventory and projected token cost". It has no option for JSON | `claude plugin details --help` |
| `claude plugin install <plugin>` takes `-s, --scope <scope>`: "Installation scope: user, project, or local (default: "user")" | `claude plugin install --help` |

## The files of a work

Chosen: a folder for each work (TD24).

```text
docs/wiki/
├── README.md        # the project, its owner, and the shared pages
├── decisions.md     # the decisions written before the core (D#), untouched (D177)
├── 01-product/ ...  # the shared definitions
└── works/
    ├── auth/
    │   ├── README.md     # where the work stands, its stage table, the table of its own pages
    │   ├── decisions.md  # auth-1, auth-2 ...
    │   ├── questions.md  # auth-Q1 ...
    │   └── plan.md       # auth-U1 ...
    └── billing/
        └── ...
```

- There is no index of works. The folders under `works/` are the index, so starting a work changes no shared file.
- A work's `README.md` holds the table of that work's own pages, with the code each one governs. The project's `README.md` keeps the table of the shared pages only.
- Tested on 2026-11-16 with git 2.43.0. Two branches that each add a folder with a different name merge with no conflict. Two branches that each add `works/auth/decisions.md` give `CONFLICT (add/add)`.

| Way | Result |
|-----|--------|
| A folder for each work | Chosen. Everything of a work is in one place, and a phase has room for its own pages. The check walks the folders and joins the page tables |
| One file for each work, with a section for the state, the decisions, the questions, and the units | Discarded. The lightest for a small change, but the file of a phase grows long and its own pages have no place |
| A folder for each kind of file, with one file for each work inside | Discarded. A work is spread over four folders |

## The step at the merge

Chosen: a script and a hook of `playbook-wiki` (TD28).

- The script interprets nothing. It lists the decisions that reached the main branch since the work's branch started, the work's own decisions, and the shared pages that both changed.
- A hook before a shell command runs the script when the command is a merge, and puts the list in front of the agent, which shows it to the person (D173).
- A merge made outside Claude Code, such as one on a forge's site, does not pass through the hook. The rule of the contract covers it alone.

| Way | Result |
|-----|--------|
| A script and a hook | Chosen. The list is made the same way every time, at the moment it is needed |
| The rule of the contract alone | Discarded by the owner: it depends on someone remembering |
| The check fails when a work is marked merged with no record of the review | Discarded. Stricter, and one more state of a work to keep |

## How the contract reaches an agent

Chosen: two hooks of `playbook-wiki`, and the project's `CLAUDE.md` (TD29).

| Agent | How it gets the contract |
|-------|--------------------------|
| The main session | A hook at the start of the session prints the contract, as today's hook prints `plugin/rules.md` (TD1) |
| A subagent, whoever defined it | A hook when it is spawned adds the contract to its context. The two sentences in the project's `CLAUDE.md`, which a custom subagent loads, send it to the wiki as well |

It holds for a person who has `playbook-wiki` on in that repository. A person who has it off gets only the two sentences in the project's `CLAUDE.md`: the contract is in the plugin, not in the repository (TD26).

A hook before each edit, with a script that names the page that governs the file, was left for later: it is the strongest way, and it runs on every edit.

## The present and the history

The shared pages say how the project is now. The folders of the works say how it got there (D189).

An example. A work named `rbac` defined roles and permissions and was merged. Later, rules must be added:

```text
docs/wiki/
├── 01-product/rbac.md     # the present: every rule in force, each citing its decision
└── works/
    ├── rbac/              # history: rbac-1 ... rbac-7, closed
    └── rbac-approvals/    # the new work: rbac-approvals-1 ...
```

1. A new branch is a new work, `rbac-approvals`. The work `rbac` is not reopened (D190).
2. The agent reads `README.md`, finds that `rbac.md` governs the code, and reads that page. It opens `works/rbac/` only for the reason behind a rule, by the decision the page cites.
3. The new rules are decided in `works/rbac-approvals/decisions.md`. One that replaces an earlier decision names it.
4. In the same branch, `rbac.md` is rewritten to say every rule in force, the earlier ones that hold and the new ones.
5. At the merge, the script of TD28 shows whether another work changed `rbac.md` in the meantime.

Decided with the other proposals of stage 2 (TD31):

- Each row of a work's `decisions.md` names the shared page it changed, or says none. The check fails when that page does not exist or does not cite the decision.
- One list of every decision of every work is printed by a script when asked. It is not a file, because a file that every branch rewrites brings the conflicts back.

## When a branch becomes a work

A branch is a work, with a folder under `works/`, from its first decision, question, or plan (D188). Two other ways were discarded: a folder for every branch, which asks one for a typo, and a threshold of size, which needs a judgement and a rule of `playbook-agents`.

## Skills that are not the product's

Chosen: a list made by a script, a comparison made by the agent, and a choice made by the person (D193, TD33). It runs in the start command, before a plugin is turned on, and again when the person asks.

| Step | Who | How |
|------|-----|-----|
| List what is present | A script | The project's skills in `.claude/skills/`, the person's in `~/.claude/skills/`, and the other plugins with `claude plugin list` and `details` |
| Find a conflict | The agent | Two skills with one name are not a conflict: a plugin's skill carries the plugin's name, so both load. The conflict is two skills for the same job. The agent reads the names and descriptions the script listed and points out each pair; a script cannot judge it |
| Settle it | The person | Turn their own skill off, keep both, or leave the product's plugin off |
| Keep what was settled | Claude Code's settings, or the wiki | A skill of the person: `skillOverrides` in the person's settings, for the repository or for every project. A skill of the project: a decision, written in the wiki's page of skills, which stage 3 of the method already writes |

One skill of another plugin cannot be turned off; only the whole plugin can.

It is not the skill registry that D52 discarded: no index is kept.

## How the product is split and started

Chosen: three plugins in this repository's marketplace (TD26), turned on by a script that the wizard runs (TD27).

| Plugin | Holds | Enabled |
|--------|-------|---------|
| The start plugin | Only the start command: the wizard and its script | Always, once installed. It adds nothing to a session until the person types the command |
| `playbook-wiki` | The core: the contract, the format, the check, and what keeps a wiki | Only where the wizard turned it on |
| `playbook-agents` | The owner's agent system. It depends on `playbook-wiki` | Only where the wizard turned it on |

What a person does:

1. Install from this repository's marketplace, once.
2. In a repository, type the start command, `/playbook:init` (TD31). The wizard asks what to use, the wiki alone or the whole product, and where, this repository or every project. For the whole product it also asks the language the agent talks in, which Claude Code keeps for the person with `userConfig` (TD31).
3. The script enables the plugins chosen, with the scope `local` for this repository or `user` for every project.

Why three plugins: the only switch Claude Code gives for one repository turns a whole plugin on or off (above). With one plugin, a person who chose the wiki alone would still get the owner's skills and agents.

| Way | Result |
|-----|--------|
| Three plugins, and Claude Code's settings hold the answers | Chosen (TD26, TD27). Nothing loads until the person starts it (D184), and the wiki alone hides the agents and the skills of `playbook-agents` |
| One plugin, and a configuration file of the product's own in each repository, written by a script and kept out of git. The owner's first proposal | Discarded. A script can choose what a hook prints, but it cannot hide the plugin's skills or agents |
| Two plugins, both enabled when installed | Discarded by D184: the product would load before the person starts it |
| The values a plugin asks for, `userConfig` | Discarded. They are kept for the person, not for a repository |
| The core's files copied into each project by a script (TD23), with a generated copy inside the plugin (TD25) | Replaced by TD26. It was chosen while the core had to work with any agent tool; D181 limits phase 4 to Claude Code, where a plugin delivers the files |

## Not verified

- That a plugin disabled with the scope `user` and enabled with the scope `local` is on in that repository only. The documentation says the local setting overrides the user one; it was not tried.
- Whether a plugin enabled by the script is used by the session that ran the wizard, or by the next one.
- That a command only the person can call adds nothing to a session. A summary of the [Skills](https://code.claude.com/docs/en/skills.md) page gives, for a skill with `disable-model-invocation: true`, "Description not in context, full skill loads when invoked"; the sentence was not read in the page's own text.
- That a person can install one plugin of a marketplace and not the others. The documentation gives each plugin its own identifier and never says the opposite.
- What `claude plugin list` prints, and whether it says which plugins are on for one repository. N28 depends on it.
- That a plugin's `hooks/hooks.json` can hold a hook for a new subagent and one before a shell command. The pages read name no event a plugin cannot use, and do not say it outright.
- Whether what a hook prints at the start of a session reaches a subagent. That part of the page was not read; TD29 does not depend on it.
- What `skillOverrides` is, in the page's own words: the definition came from a summary of the [Skills](https://code.claude.com/docs/en/skills.md) page. What its value `"name-only"` does is not said.
- What `claude plugin details` prints, and whether a script can read it.
- No hook of this page was written or run.
- Nothing was installed, enabled, or disabled on the owner's machine.
