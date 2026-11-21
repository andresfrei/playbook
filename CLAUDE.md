# playbook

This repository builds the Claude Code plugin `playbook`, in `plugins/playbook/`. Read `docs/wiki/README.md` first: the product, the decisions, and the open work.

## Checks

- `sh tests/check-wiki_test.sh` and `sh tests/hooks_test.sh`
- `sh plugins/playbook/scripts/check-wiki.sh docs/wiki`
- `shellcheck plugins/playbook/hooks/*.sh plugins/playbook/scripts/*.sh tests/*.sh`
- `claude plugin validate .`
- A live check: `claude -p --plugin-dir plugins/playbook "<request>"` in a throwaway repository.

## Conventions

- Every piece added or kept is justified by Claude Code's documentation, quoted from its `.md` pages listed at `https://code.claude.com/docs/llms.txt` (basics-2).
- The version lives in `plugins/playbook/.claude-plugin/plugin.json` only (TD22). When a work closes, recommend whether it needs a version and ask the owner; on a yes, after the merge: the tag and the release on GitHub (github-release-1, github-release-2).
- Do not install, move, or delete skills on the owner's machine until the owner asks for that step.
