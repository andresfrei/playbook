# Spec of the work builder-load

Status: Accepted (builder-load-6).

Delivery: one branch and one pull request per work (delivery-versioning-2).

## What and why (builder-load-1)

In `Build mode: builder` the main session writes a brief and the agent `builder` builds one unit (build-mode-3). Two things are missing.

- Nothing looks at a unit's size when it is built. `define` sizes each unit to fit one short session (session-cost-4), but a unit can be written too large, or grow with what the earlier units taught. It then goes whole to one builder, whose context grows as the main session's did, which is the cost `session-cost` and `build-mode` set out to avoid.
- Units that do not depend on each other are built one after the other, though nothing makes one wait.

The main session evaluates the load before it writes a brief. It recommends; the owner decides. Nothing is launched in parallel or split by itself.

Claude Code's documentation, read on 2026-11-22:

- sub-agents.md: "Each subagent starts with a fresh, isolated context window." The `isolation` field gives a worktree "branched by default from your default branch rather than the parent session's `HEAD`".
- best-practices.md: subagents pay off when "Running independent pieces of work at the same time, so the whole task finishes sooner"; "What they cost you is mostly tokens, since every subagent sends its own requests"; "When you have separate pieces of work going at once, give each its own checkout so the edits can't collide."; "For one big mechanical change across many files, `/batch` splits the work into 5 to 30 units and shows you the plan."
- The documentation gives no criterion for a task too large for one subagent.

Building at the same time saves time, not tokens. What keeps a builder's context small is the size of its unit.

## What changes

1. **A unit too large** (builder-load-2). In `rules.md`, in `builder` mode: when the brief of a unit would name two or more results that can be checked apart, those are two units. The main session proposes the split in `spec.md` and builds after the owner's answer; a split changes an accepted spec, so the owner decides it (R8). No count of files and no threshold of tokens.
2. **Units at the same time** (builder-load-1, builder-load-3). In `rules.md`, in `builder` mode: when two or more pending units do not use what another of them builds and change different files, the main session proposes to build them at the same time. On the owner's yes it runs one `builder` per unit in one message. Each brief names the paths its unit may change and its unit's check. When all have ended, the main session runs the whole check and verifies each unit with the tests and the diff, and with `reviewer` when the unit is risky (R20), as today. Units that share a file, or where one uses what another builds, are built one after the other.
3. **The agent `builder`.** When the brief names the paths it may change, it changes only those; when the unit needs another path, it stops and reports it. It runs its unit's check only, and it does not undo a change it did not make, since another builder may be working in the same folder (builder-load-3).
4. **`product.md` and the READMEs** (builder-load-4). "What it leaves to Claude Code" says `/batch` for one big mechanical change across many files; step Build says that in `builder` mode independent units may be built at the same time. The root `README.md` and the plugin's README say the same in one sentence each.

Accepted with the spec (builder-load-6):

- The units table of a spec gets no new column for what a unit waits for. The main session reads it from the units' text and from the files each brief names, when it writes the briefs.
- No number of our own caps the builders at once: the count is the independent units pending, and the owner sees it in the proposal.

## Out of scope

- Worktrees, and a builder that commits (builder-load-3).
- Launching builders in parallel, or splitting a unit, without the owner's answer.
- A threshold of files or tokens (builder-load-2).
- The batches, the plan, and the column "Waits for" of the work `parallel-units`, which belong to the method before `basics`.
- `Build mode: main`: there, parallel work stays with `/batch` and sessions in worktrees.

## Check

- `check-wiki.sh`, the tests, `shellcheck`, and `claude plugin validate .` pass.
- Live, in a throwaway repository with `Build mode: builder` in its `CLAUDE.local.md`, run with `claude -p --plugin-dir plugins/playbook`:
  - An accepted spec with three units, where the first two change different files and the third uses the first. Asked to build the pending units, the session proposes the first two together. Told yes in the request, it runs two `builder` agents in one message, each brief with its paths, then the third alone, and reports the whole check and the diff.
  - An accepted spec with one unit that holds two results checked apart. Asked to build it, the session proposes the split and runs no builder.

## Units

| Unit | What | Check | State |
|------|------|-------|-------|
| 1 | Change 1 | The first four checks, and the second live check | Done |
| 2 | Changes 2 to 4 | The first four checks, and the first live check | Done |
