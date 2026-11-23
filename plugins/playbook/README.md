# playbook

A Claude Code plugin that helps you build software fast: it defines each change with you before code, records your decisions in your words, and learns from its own mistakes.

```sh
claude plugin marketplace add andresfrei/playbook
claude plugin install playbook@playbook
```

| Piece | What it does |
|-------|--------------|
| `/playbook:define` | Interviews you until the change's spec can be written, with only the steps its type needs |
| `/playbook:close` | Checks the build against the spec, has `reviewer` read a risky change, and proposes one line for each repeated mistake or answer |
| `/playbook:audit-wiki` | On its first run, adopts the project: builds the wiki in `docs/playbook/` from what the project already holds. Then reads the wiki against the code and reports each contradiction for you to resolve; run it before a release |
| `/playbook:audit-tools` | Checks the tools the repository has on (plugins, MCP servers, skills, agents, hooks) for collisions with the playbook, and suggests what to do with each; run it when you add or remove a tool |
| `/playbook:audit-learning` | Finds what repeats across two works (the same answer, correction, or procedure) and proposes a delegation, a rule, a skill, or an agent; `close` offers it when a work closes |
| `/playbook:release` | Sets the version, commits, and drafts the notes; you push and publish |
| `reviewer` | A read-only agent that checks a change against its spec, for correctness only |
| `builder` | An agent on `sonnet` that builds one unit from a brief, used when the line `Build mode: builder` is set |
| Rules | Loaded at session start, near 50 lines, with the project's `docs/playbook/README.md` |
| Hooks | Ask before push, pull request, merge, and release; run the wiki check on commit; recommend `/playbook:audit-wiki` in a project not yet adopted |

## Build mode

One line, in `~/.claude/CLAUDE.md` for every project or in the project's `CLAUDE.local.md` for one, says who builds each unit: `Build mode: main` (the main session builds, with `/clear` and `/model sonnet` between units) or `Build mode: builder` (the agent `builder` on Sonnet builds from a brief, and the main session verifies with the tests and the diff). In `builder`, the main session proposes to split a unit too large for one builder and to build independent units at the same time, and you decide. The local line wins; with no line it is `main`. `/playbook:define` asks once when neither file has it.

## Why sessions are short

The context each request carries is what costs. Claude Code's documentation: "Use `/clear` to start fresh when switching to unrelated work"; "Each model has its own cache. Switching with `/model` means the next request reads the entire conversation history with no cache hits"; "Pick your model and effort level at the top of a session." So the playbook cuts a session where the handoff is already written: at the end of a task when the next is a different one, and after a unit, it asks whether to close there, and on a yes you type `/clear`, since Claude cannot run built-in commands; choose the model at the start, not mid-way; and a fresh session beats `--resume`, since "your first message after a break longer than the cache lifetime misses the cache and reprocesses your full context."

For cheaper searches, copy `extras/Explore.md` to `~/.claude/agents/`: it runs Claude Code's Explore on `haiku`.
