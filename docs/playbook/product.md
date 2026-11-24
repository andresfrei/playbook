# Product

## What it is

A Claude Code plugin, `playbook`, for Claude Code only (basics-3). It helps a person create fast and does not complicate: it adds only what Claude Code does not already do, and each piece is justified by Claude Code's documentation (basics-2). It is meant for other users, kept simple (basics-2).

## How a change goes

1. **Define.** The skill `define` names the type of change and runs only its steps (basics-6):

   | Type of change | Steps |
   |----------------|-------|
   | Small change | None: done directly, with no work |
   | Feature on the project's technology | Define |
   | Feature that adds or replaces a technology | Define, Technology, Skills |
   | New project | Define, Technology, Skills, and Design when it has an interface |

   Define interviews the person until the spec can be written. Technology checks each technology in its current documentation, with the link and the date, by any tool (basics-8). Skills finds, for each new technology, a skill to install, one to write, or none needed. The person accepts the spec once (basics-9). A project may hold two optional lines in `technology.md`, a default way of delivery and a versioning policy; Define copies the delivery default into each spec and asks only when there is none or the work needs another way (delivery-versioning-1, -2, -3).
2. **Build.** By the person's `Build mode:` line (build-mode-1, build-mode-2, build-mode-5): in `main`, the default, in the main session on the model the person chooses with `/model` at the start of a session, not mid-way; in `builder`, the agent `builder` on Sonnet builds each unit from a brief and the main session verifies with the tests and the diff (build-mode-3). In `builder`, before it writes a brief the main session evaluates the load and proposes, for the person to decide: to split a unit whose brief would name two results checked apart (builder-load-2), and to build at the same time, one `builder` each in the same folder, the pending units that change different files and do not use what another builds (builder-load-1, builder-load-3). Either way with the check the spec names (basics-7, session-cost-1). One big mechanical change across many files can use Claude Code's `/batch` (builder-load-4). The session is cut by the person's answer to a question at the end of each task, and the person types `/clear` (ask-to-clear-1).
3. **Close.** The skill `close` checks the build against the spec, has the agent `reviewer` read a risky change, and proposes one concrete line for each mistake seen twice or each finding Claude should have known: into `CLAUDE.md`, `.claude/rules/`, or a skill. The person accepts each line or not (basics-4).
4. **Audit.** Two skills, each started by the person or offered by the agent and run on the person's yes (agent-runs-skills-1). `audit`, on its first run, adopts the project: it builds the wiki from the knowledge the project already holds and cleans its rules (basics-15). On every run it reads the wiki against the code and reports each contradiction with both quotes; the person says which side is right (basics-12). It also reports each of five items the project has not defined (product and owner, technology, how a change is checked, versioning, delivery), and the person may leave it Open (delivery-versioning-4). Its tools part checks the tools the repository has on for collisions with the playbook's way of working, and suggests a way out for each; the person decides, and the answer is applied with Claude Code's own commands, for that repository only; what belongs to the user's level is proposed for and changed only when the person asks explicitly (one-audit-5). Its setup part shows every source that loads at startup, `CLAUDE.md`, rules, the auto memory, the wiki's README, the output style, and the descriptions of skills and agents, with its lines and size, marks what passes a limit of Claude Code's documentation, reports the collisions between pieces, and proposes the documentation's way to load on demand what applies only sometimes; it also reports, from Claude Code's `/skill-doctor`, the skills loaded but never used with their context cost, one finding per source, and proposes hiding them from the project's listing (skill-usage-1, skill-usage-2); it also shows the load of a fresh session by category from Claude Code's `/context`, so the person no longer runs it and pastes it (context-measure-1); no threshold of its own (one-audit-1, one-audit-3). The three parts explore first on read-only agents `auditor`, in one message, and the main session shows every finding in one table before it asks (one-audit-6, one-audit-8). The first run adopts the project in the main session and then runs the three parts, and `audit wiki`, `setup`, or `tools` runs one part alone (one-audit-9, one-audit-11). Each finding the person leaves as it is becomes a decision that quotes it; the next audit shows that finding as already decided, citing the decision, and asks again only when its quote changed. A memory link that matches no file, and a delegation in the project's `CLAUDE.md` that wins over a rule of the playbook, are not findings (audit-decided-1). The plugin names no outside tool and keeps no list of tools in the wiki (basics-24, basics-25). `audit-learning`, also offered by `close` when a whole work closes, reads in a subagent the decisions of each work whose `spec.md` has no line `Learned:`, a work with no `spec.md` being history that is only searched (cross-work-learning-14), finds what repeats in two different works, and proposes one piece for each: a delegation in `CLAUDE.md` for the same answer, a rule for the same correction, a skill for the same procedure, an agent for a repeated task with long output, or a warning for `define` when a subject is replaced twice; it keeps no record of its own (cross-work-learning-1 to -6). Each session inside a git repository recommends `audit` while the wiki has no line "Last audit".
5. **Release.** The skill `release`, started by the person or offered by `close` and run on the person's yes (agent-runs-skills-1), proposes the version naming the number each kind gives, such as "PATCH: 5.5.1" (audit-decided-4), sets it where the project's versioning line says, commits, and drafts the notes; the person tags, pushes, and publishes.

## The pieces

| Piece | What it does |
|-------|--------------|
| `rules.md` | The rules for every session, near 50 lines, loaded at session start: the rules and the wiki's README share 9,000 of the 10,000 characters of a hook's output, the rest left for the two lines of the language (basics-21, audit-2026-11-22-1). A decision the owner delegates is a line in the project's `CLAUDE.md` (R6). A question with options to offer is asked with Claude Code's question dialog, `AskUserQuestion`, one question per dialog and the recommended option first; a question with no options to offer, in text (R3, question-dialog-1) |
| `define`, `close`, `audit`, `audit-learning`, `release` | The five skills above |
| `reviewer` | A read-only agent that reads a change against its spec, for correctness only |
| `builder` | An agent on `sonnet` that builds one unit from a brief, in the mode `Build mode: builder` (build-mode-3) |
| `auditor` | A read-only agent with no `CLAUDE.md` in its context, one per part of `audit` (one-audit-8) |
| `startup-context.sh` | A script that prints the table of what loads at startup, for the setup part of `audit` (one-audit-4); its skill rows follow `skillOverrides`, and the skills synced from claude.ai have their own row (skill-overrides-1) |
| `Explore.md` | A search agent on `haiku`, which the person copies to `~/.claude/agents/` to make searches cheaper (basics-7). Read-only as Claude Code's own Explore: no Write or Edit, and Bash kept for searching, held by its instruction (basics-22) |
| A hook before delivery | Asks before push, pull request, merge, and release |
| The check of the wiki | Run by `define`, `close`, `audit`, `audit-learning`, and on commit |
| `userConfig` | The language of the replies, asked once when empty (reply-language-1, reply-language-3) |

## What it leaves to Claude Code

Writing (the main session, or `builder` by the person's choice), memory (auto memory), one big mechanical change across many files (`/batch`; in `builder` mode the independent units of a spec may be built by `builder` agents at the same time, on the person's yes, builder-load-4), searching (Explore), cleaning old instructions (`/doctor prompt-audit`), and writing skills (`skill-creator`). The product depends on no MCP server (basics-7, basics-8).

## The wiki of a project

In `docs/playbook/` (basics-16), flat, one page per step of `define`, holding only what the code does not say: `README.md`, `product.md`, `technology.md`, `skills.md`, `design.md` when there is an interface, and per work `spec.md` and `decisions.md` (basics-9). A decision has an ID, a date, the decision, who decided, and their words. Its `README.md` loads at the start of every session (basics-11).

## Rules decided

- Only the person decides; the agent records each decision with their words (idea 2, kept by basics-1).
- Push, pull requests, merges, and releases are the person's decisions (idea 8, kept by basics-1).
- Every action has a weight that says whether the person is asked: light is done, medium is asked once, heavy is asked by a hook; when unsure, medium (basics-13).
- A project's own rules win over the plugin's; the hooks that ask before heavy actions ask anyway (basics-15).
- One job, one skill (D6).
- Every piece added or kept is justified by Claude Code's documentation, quoted (basics-2).
