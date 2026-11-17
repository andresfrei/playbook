# Plan of wiki-check-on-commit

Stage 5. It builds what [definition.md](definition.md) and [technology.md](technology.md) decide.

## Progress

| Unit | Status | Evidence | Done on | Owner's words |
|------|--------|----------|---------|---------------|
| wiki-check-on-commit-U1 | Not started | | | |
| wiki-check-on-commit-U2 | Not started | | | |

## Units

| ID | Unit | Delivers | Ends when | Accepted by |
|----|------|----------|-----------|-------------|
| wiki-check-on-commit-U1 | The hook of the commit | The parser of `plugins/playbook-wiki/hooks/merge-step-hook.sh` made to take the subcommand and shared by both hooks; a hook that, for a `git commit` in a repository whose `docs/wiki/` is at the playbook's format and differs from the last commit, runs `check-wiki.sh` and answers `"deny"` with its output when it fails; its line in `hooks/hooks.json`; tests in `scripts/verify_test.sh` (N1 to N7) | The tests show: a failing wiki change stops `git commit`, `git add -A && git commit`, `cd <dir> && git commit`, and `git -C <dir> commit`, with the check's output; a passing wiki, a commit with no wiki change, a wiki below the format, a repository with no `docs/wiki/`, and a command that cannot be parsed print nothing; the cases of the step at the merge still pass. `bash scripts/verify.sh` exits 0, `sh scripts/verify_test.sh` prints "all cases passed" with `gawk` and `mawk`, `shellcheck` prints nothing, `claude plugin validate` passes. In the trial environment, a session with `playbook-wiki` alone is stopped committing a wiki with a "Where work stands" over 250 words, and repairs it | Evidence |
| wiki-check-on-commit-U2 | The doctor's step | One step in `plugins/playbook-wiki/skills/doctor/references/format-4.md`, as wiki-check-on-commit-2 says | The step is written and `bash scripts/verify.sh` exits 0 | Judgement: it is the text of a definition |

U2 depends on no other unit. U1 is first because it is the one that prevents the problem.

## How a unit is delivered

Accepted by the owner (wiki-check-on-commit-8), read from how this repository delivers (TD5, D196): both units are built on this work's branch, `feat/wiki-check-on-commit`, in its worktree `~/dev/playbook-worktrees/wiki-check-on-commit`, one after the other and not in parallel. The work reaches `main` by one pull request, which the owner merges (R14). U1 changes a hook, so the `review` agent reads it before it is Done (R20).

## Left out

- The version of the plugins. Only the owner raises it (TD22); an installation from GitHub gets the hook only then. The owner's installation reads the clone in place.
- Checking a commit a person runs in their own terminal (wiki-check-on-commit-5).
