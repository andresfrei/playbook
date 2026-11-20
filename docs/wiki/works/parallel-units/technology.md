# Technology of the work parallel-units

What the work needs from its technology, from [definition.md](definition.md) and decisions parallel-units-3 to -9. Documentation read on 2026-11-20 by a `claude-code-guide` agent, through summaries of each page:

- code.claude.com/docs/en/worktrees.md
- code.claude.com/docs/en/sub-agents.md
- code.claude.com/docs/en/hooks.md

Claude Code 2.1.329.

## Needs

| ID | Need | From | Proposed answer | Status |
|----|------|------|-----------------|--------|
| N1 | Create the worktree of each unit from the work's branch, so the unit sees the units it waits for | parallel-units-4, -5 | The main agent runs `git worktree add -b <type>/<work>-<NN>-<slice> <folder> <work branch>`, with the branch name of the plan's rule (`5-plan.md`, step 5), and gives `write` the folder and the exact paths it may change. It does not use the Agent tool's `isolation: "worktree"`; see the facts below | Decided |
| N2 | Prepare the new worktree | parallel-units-9 | The plan names a command that installs the dependencies and a list of ignored files to copy from the main folder, such as `.env`. The main agent runs both in the new folder before it starts `write`. With no command and no files, nothing is run | Decided |
| N3 | Run several `write` agents at once, up to the plan's number | parallel-units-8 | Several Agent calls in one message, each in the background, one per ready unit. A unit ready beyond the plan's number starts when an agent ends | Decided |
| N4 | Bring each unit into the work's branch | parallel-units-6 | In the main folder, on the work's branch: `git merge --no-ff <unit branch>`, then the checks of the unit. After the merge, `git worktree remove <folder>` and `git branch -d <unit branch>` | Decided |
| N5 | Write the batches into the method | parallel-units-3, -5, -7, -8, -9 | Change `prepare-project`: `references/5-plan.md` writes the column "Waits for", the batches derived from it, the most agents at once, and how a worktree is prepared, in place of the yes or no question on parallel units; `references/6-execution.md` builds units as soon as what they wait for is Done | Decided |

## Facts that shape the answers

- **Where a subagent's worktree starts.** A subagent started with `isolation: "worktree"` branches from the repository's default branch, not from the main session's `HEAD`. The setting `worktree.baseRef` changes that: `"fresh"`, the default, uses the remote default branch; `"head"` uses the local `HEAD`. With the default, a unit would not see the units merged before it into the work's branch.
- **Name and cleanup.** The documentation gives neither the path nor the branch name of a subagent's worktree. It also does not say whether a plugin agent, such as `playbook-agents:write`, may set `isolation` in its front matter. A worktree with no changes is removed at once; one with changes stays until a periodic sweep (`cleanupPeriodDays`).
- **`.worktreeinclude`.** A file at the project's root, in `.gitignore` syntax. It copies the ignored files that match, such as `.env`, into each git worktree that Claude Code creates, subagents included. It does not apply to a worktree that `git worktree add` creates.
- **Worktree hooks.** `WorktreeCreate` replaces how Claude Code creates a worktree and must print the folder's path. `WorktreeRemove` receives that path. Installing dependencies is not a documented use of either.
- **Hooks in subagents.** The hooks of a plugin's `hooks/hooks.json` run inside subagents. Whether a subagent's `session_id` is the main session's is not documented.
- **Concurrency limits.** By default at most 20 subagents run at once in a session (`CLAUDE_CODE_MAX_CONCURRENT_SUBAGENTS`). Subagents nest three levels deep by default.
