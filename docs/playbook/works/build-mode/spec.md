# Spec of the work build-mode

Status: Accepted (build-mode-6).

Delivery: one branch and one pull request per work (delivery-versioning-2).

## What and why (build-mode-1)

Today the playbook builds in the main session only (`rules.md`: "Build in the main session"), and after a spec is accepted it asks the developer to run `/clear` and `/model sonnet` (session-cost-1). Some developers prefer not to clear and switch models by hand: the main session on Opus defines and verifies, and a subagent on Sonnet builds. Which way is the developer's choice, to save tokens, time, or decisions, not the project's.

Claude Code's documentation, read on 2026-11-22:

- sub-agents.md: the `model` field takes "`sonnet`, `opus`, `haiku`, `fable`, a full model ID such as `claude-opus-5-5`, or `inherit`"; "Each subagent starts with a fresh, isolated context window."
- memory.md: user instructions live in `~/.claude/CLAUDE.md`; "For private per-project preferences that shouldn't be checked into version control, create a `CLAUDE.local.md` at the project root"; "All discovered files are concatenated into context rather than overriding each other"; "if two instructions contradict each other, Claude may pick one arbitrarily."

## What changes

1. A line `Build mode: main` or `Build mode: builder`, in `~/.claude/CLAUDE.md` or in the project's `CLAUDE.local.md` (build-mode-2, build-mode-5). With no line, `main`.
2. `rules.md` replaces "Build in the main session..." with the two modes: in `main`, build in the main session as today; in `builder`, write the brief, run `builder`, and verify with the tests and the diff, never with the summary alone, and `reviewer` when the change is risky (build-mode-3). The local line wins over the global one (build-mode-2). Delegating a wide search or a full test run holds in both modes.
3. A plugin agent `builder`, `model: sonnet`: it builds one unit from a brief that names the spec, the unit, the files to read, and the check; it runs the check and reports what it changed and the check's result (build-mode-3).
4. `define`, when neither file holds the line, asks the mode and where to write it in one dialog, and writes the line (build-mode-4). At acceptance it recommends, in `main`, `/clear`, `/model sonnet`, and the first unit, as today; in `builder`, staying on the current model and building the first unit with `builder` (build-mode-6).
5. `close` keeps recommending `/clear` after a unit in both modes: in `builder` the main session still grows with each brief and summary (build-mode-6).
6. The plugin's README names the two modes, the line, and the agent `builder` with the same name (build-mode-5).

## Out of scope

- A hook that sets or enforces the mode: the playbook asks and records, the developer decides.
- Writing the mode in the project's `CLAUDE.md` or the wiki (build-mode-1).
- Haiku for searches: `extras/Explore.md` already offers it.

## Check

- `check-wiki.sh`, the tests, `shellcheck`, and `claude plugin validate .` pass.
- In a throwaway repository with `Build mode: builder` in its `CLAUDE.local.md` and a small accepted spec, `claude -p --plugin-dir plugins/playbook "build the first unit"` runs the agent `builder` and the main session reports the tests and the diff; with no line, it builds in the main session.

## Units

| Unit | What | Check | State |
|------|------|-------|-------|
| 1 | Changes 1 to 6 | The check above | To do |
