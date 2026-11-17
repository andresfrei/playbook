# Technology of wiki-check-on-commit

What the work needs from its technology, from [definition.md](definition.md), and what is chosen for each need. Stage 2. No new dependency: everything is what `playbook-wiki` already uses.

## Needs

| # | Need | Choice | Status |
|---|------|--------|--------|
| N1 | Run before a commit the agent runs | A command added to the `PreToolUse` hook of `playbook-wiki` that already runs on `Bash(git *)`, in `plugins/playbook-wiki/hooks/hooks.json` (TD28) | Decided (wiki-check-on-commit-7) |
| N2 | Find the repository the commit runs in: the session's folder, a `cd` before it, or `git -C <dir>` | The parser of `plugins/playbook-wiki/hooks/merge-step-hook.sh`, which already reads the command and the session's `cwd` for `git merge`, made to take the subcommand | Decided (wiki-check-on-commit-7) |
| N3 | Know whether the commit changes the wiki | Anything under `docs/wiki/` that differs from the last commit, staged or not, new files included, as `git status --porcelain -- docs/wiki` lists it. The hook runs before the whole command, so in `git add -A && git commit` nothing is staged yet; the check reads the files on disk | Decided (wiki-check-on-commit-6) |
| N4 | Stop the commit and give the failure to the agent (wiki-check-on-commit-3) | The hook answers `permissionDecision` `"deny"`, with the check's output as the reason, which is "shown to Claude" | Decided (wiki-check-on-commit-7) |
| N5 | Let a wiki below the playbook's format through (wiki-check-on-commit-4) | Compare `docs/wiki/.format` with `check-wiki.sh --format`; a missing or lower marker exits 0 with nothing printed | Decided (wiki-check-on-commit-7) |
| N6 | Never stop a commit by the hook's own error | Exit 0 with nothing printed whenever the command cannot be parsed, the repository has no `docs/wiki/`, or a script is missing, as the hook of the step at the merge does | Decided (wiki-check-on-commit-7) |
| N7 | Not slow a commit down | `check-wiki.sh` runs in under a second; it runs only when N3 says the wiki changed | Decided (wiki-check-on-commit-7) |

## Sources

- N4: [Hooks](https://code.claude.com/docs/en/hooks.md), quoted in [../../03-technology/phase-4.md](../../03-technology/phase-4.md) on 2026-11-16: "`"deny"` prevents the tool call", and the reason is "shown to Claude". Claude Code here is 2.1.326, read on 2026-11-16 with `claude --version`.
- N7: measured once each on 2026-11-16 with `time sh plugins/playbook-wiki/check-wiki.sh docs/wiki`: 0.34 s on this wiki, 0.54 s on the wiki of huellitas-id.

## Architecture

The problem: a wiki leaves its format between two runs of its check (see [definition.md](definition.md)).

The shape: one more command in the existing `PreToolUse` hook on `Bash(git *)`. It finds a `git commit` in the command, the repository it runs in, and whether the wiki changed; when it did and the wiki is at the playbook's format, it runs `check-wiki.sh` and denies the call with the check's output when the check fails.

Modules:

- The parser of the command, shared with the hook of the step at the merge: it gives the repository of the first `git <subcommand>`. It does not run git.
- The hook of the commit: it decides, runs the check, and answers. It writes nothing.
- `check-wiki.sh`: unchanged.
- `doctor/references/format-4.md`: one more step, text only (wiki-check-on-commit-2).

Risks:

- A command the parser does not read, such as a commit inside a script or an alias: the commit is not checked. Reduced by N6: nothing breaks, the wiki is checked at the next commit the parser reads.
- A deny on a commit the person wants anyway: the person commits in their own terminal (wiki-check-on-commit-5).

Discarded: running the check after each edit (wiki-check-on-commit-1); a git `pre-commit` hook in the project, because the product writes nothing in a project outside `docs/wiki/` and `CLAUDE.md` (D185, `format.md`).

Not applicable: data and outside systems beyond git, because the hook keeps no data.
