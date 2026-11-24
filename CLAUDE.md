# playbook

## Checks

- `sh tests/check-wiki_test.sh`, `sh tests/hooks_test.sh`, `sh tests/startup-context_test.sh`, and `sh tests/reference_test.sh`
- `sh plugins/playbook/scripts/check-wiki.sh docs/playbook`
- `shellcheck plugins/playbook/hooks/*.sh plugins/playbook/scripts/*.sh tests/*.sh`
- `claude plugin validate .`
- A live check: `claude -p --plugin-dir plugins/playbook "<request>"` in a throwaway repository.
- The live check writes the plugin's data to `~/.claude/plugins/data/playbook-inline/`, the owner's own; remove what it creates there.

## Conventions

- Every piece added or kept is justified by Claude Code's documentation, quoted from its `.md` pages listed at `https://code.claude.com/docs/llms.txt` (basics-2).
- The owner delegates delivery: after a confirmed version, Claude runs the push, the pull request, the merge (`gh pr merge --admin`), the tag, and the release, and checks the pull request is MERGED before tagging (one-audit-13). A change with no version is pushed, opened as a pull request, and merged the same way, with no tag (audit-2026-11-24-1).
- Do not install, move, or delete skills on the owner's machine until the owner asks for that step.
- The owner's Claude loads the plugin from a worktree of local `main` at `~/dev/playbook-main`. The git hook `reference-transaction` in this clone's `.git/hooks/` checks out each new `main` there; after a change lands on `main`, recommend `/reload-plugins` in open sessions. When the hook says the worktree has local changes, or it is missing, recommend `git -C ~/dev/playbook-main checkout --detach main`.
- A work of the plugin changes only the plugin; findings about this repository's own setup (its memory, its audit answers) are resolved apart, by running the plugin, never as a unit of the work (audit-decided-2).
- An agent's model follows task-agents-5: `haiku` only for mechanical steps with fixed commands, `sonnet` for writing or a small change (as `builder`); an agent that judges keeps no `model:` line and inherits the session's model. Do not ask again (audit-2026-11-24-15).
- When a decision removes a piece, a tool, or a path, run `git grep` for its name and update or delete each mention outside `docs/playbook/works/` in the same commit.
