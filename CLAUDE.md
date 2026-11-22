# playbook

## Checks

- `sh tests/check-wiki_test.sh` and `sh tests/hooks_test.sh`
- `sh plugins/playbook/scripts/check-wiki.sh docs/playbook`
- `shellcheck plugins/playbook/hooks/*.sh plugins/playbook/scripts/*.sh tests/*.sh`
- `claude plugin validate .`
- A live check: `claude -p --plugin-dir plugins/playbook "<request>"` in a throwaway repository.

## Conventions

- Every piece added or kept is justified by Claude Code's documentation, quoted from its `.md` pages listed at `https://code.claude.com/docs/llms.txt` (basics-2).
- The version lives in `plugins/playbook/.claude-plugin/plugin.json` only (TD22). When a work closes, recommend whether it needs a version and ask the owner; on a yes, after the merge: the tag and the release on GitHub (github-release-1, github-release-2).
- Do not install, move, or delete skills on the owner's machine until the owner asks for that step.
- The owner's Claude loads the plugin from a worktree of local `main` at `~/dev/playbook-main`. Each time a change lands on local `main` (a commit, a merge, or a pull), recommend `git -C ~/dev/playbook-main checkout --detach main`, then `/reload-plugins`.
- When a decision removes a piece, a tool, or a path, run `git grep` for its name and update or delete each mention outside `docs/playbook/works/` in the same commit.
