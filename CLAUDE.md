# playbook

## Checks

- `sh tests/check-wiki_test.sh` and `sh tests/hooks_test.sh`
- `sh plugins/playbook/scripts/check-wiki.sh docs/playbook`
- `shellcheck plugins/playbook/hooks/*.sh plugins/playbook/scripts/*.sh tests/*.sh`
- `claude plugin validate .`
- A live check: `claude -p --plugin-dir plugins/playbook "<request>"` in a throwaway repository.
- The live check of a skill that reads `docs/playbook/works/` includes a work in the format before `basics` (no `spec.md`) and a spec with no `Status:` line, as this repository holds both.

## Conventions

- Every piece added or kept is justified by Claude Code's documentation, quoted from its `.md` pages listed at `https://code.claude.com/docs/llms.txt` (basics-2).
- The version lives in `plugins/playbook/.claude-plugin/plugin.json` only (TD22). When a work closes, recommend whether it needs a version and ask the owner; on a yes, after the merge: the tag `v<version>` and the release on GitHub titled `playbook <version>` (github-release-1, github-release-2).
- When a work only changes rules, skills, or the README text of the plugin, recommend PATCH; MINOR is for a new skill, agent, hook, or script (the owner chose PATCH over a recommended MINOR in builder-load and ask-to-clear).
- Do not install, move, or delete skills on the owner's machine until the owner asks for that step.
- The owner's Claude loads the plugin from a worktree of local `main` at `~/dev/playbook-main`. The git hook `reference-transaction` in this clone's `.git/hooks/` checks out each new `main` there; after a change lands on `main`, recommend `/reload-plugins` in open sessions. When the hook says the worktree has local changes, or it is missing, recommend `git -C ~/dev/playbook-main checkout --detach main`.
- When a decision removes a piece, a tool, or a path, run `git grep` for its name and update or delete each mention outside `docs/playbook/works/` in the same commit.
