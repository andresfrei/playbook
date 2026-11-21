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

   Define interviews the person until the spec can be written. Technology checks each technology in its current documentation, with the link and the date, by any tool (basics-8). Skills finds, for each new technology, a skill to install, one to write, or none needed. The person accepts the spec once (basics-9).
2. **Build.** In the main session, on the model the person chooses with `/model`, with the check the spec names (basics-7). A large mechanical change can use Claude Code's `/batch`.
3. **Close.** The skill `close` checks the build against the spec, has the agent `reviewer` read a risky change, and proposes one concrete line for each mistake seen twice or each finding Claude should have known: into `CLAUDE.md`, `.claude/rules/`, or a skill. The person accepts each line or not (basics-4).
4. **Audit.** The skill `audit`, started only by the person. On its first run it adopts the project: it builds the wiki from the knowledge the project already holds, cleans its rules, and proposes turning off what competes (basics-15). After that it reads the wiki against the code and reports each contradiction with both quotes; the person says which side is right (basics-12). Each session recommends it while the wiki has no line "Last audit".
5. **Release.** The skill `release`, started only by the person, sets the version, commits, and drafts the notes; the person tags, pushes, and publishes.

## The pieces

| Piece | What it does |
|-------|--------------|
| `rules.md` | The rules for every session, near 50 lines, loaded at session start: the rules and the wiki's README share the 10,000 characters of a hook's output (basics-21). A decision the owner delegates is a line in the project's `CLAUDE.md` (R6) |
| `define`, `close`, `audit`, `release` | The four skills above |
| `reviewer` | A read-only agent that reads a change against its spec, for correctness only |
| `Explore.md` | A search agent on `haiku`, which the person copies to `~/.claude/agents/` to make searches cheaper (basics-7). Read-only as Claude Code's own Explore: no Write or Edit, and Bash kept for searching, held by its instruction (basics-22) |
| A hook before delivery | Asks before push, pull request, merge, and release |
| The check of the wiki | Run by `define`, `close`, `audit`, and on commit |
| `userConfig` | The language of the replies |

## What it leaves to Claude Code

Writing (the main session), memory (auto memory), parallel work (`/batch`), searching (Explore), cleaning old instructions (`/doctor prompt-audit`), and writing skills (`skill-creator`). The product depends on no MCP server (basics-7, basics-8).

## The wiki of a project

In `docs/playbook/` (basics-16), flat, one page per step of `define`, holding only what the code does not say: `README.md`, `product.md`, `technology.md`, `skills.md`, `design.md` when there is an interface, and per work `spec.md` and `decisions.md` (basics-9). A decision has an ID, a date, the decision, who decided, and their words. Its `README.md` loads at the start of every session (basics-11).

## Rules decided

- Only the person decides; the agent records each decision with their words (idea 2, kept by basics-1).
- Push, pull requests, merges, and releases are the person's decisions (idea 8, kept by basics-1).
- Every action has a weight that says whether the person is asked: light is done, medium is asked once, heavy is asked by a hook; when unsure, medium (basics-13).
- A project's own rules win over the plugin's; the hooks that ask before heavy actions ask anyway (basics-15).
- One job, one skill (D6).
- Every piece added or kept is justified by Claude Code's documentation, quoted (basics-2).
