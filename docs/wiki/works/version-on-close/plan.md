# Plan of version-on-close

Stage 5. It builds what [definition.md](definition.md) and [technology.md](technology.md) decide.

## Progress

| Unit | Status | Evidence | Done on | Owner's words |
|------|--------|----------|---------|---------------|
| version-on-close-U1 | Not started | | | |

## Units

| ID | Unit | Delivers | Ends when | Accepted by |
|----|------|----------|-----------|-------------|
| version-on-close-U1 | The version at the close of a work | One item in step 6 of `plugins/playbook-wiki/skills/prepare-project/references/6-execution.md`, before the step at the merge: when git has a version tag, recommend whether the work needs a new version and which one, by the project's own rule or else Semantic Versioning, and ask; on a yes, record the version in the work and list the release steps as next steps (version-on-close-1 to version-on-close-3, version-on-close-5) | `bash scripts/verify.sh` exits 0 and `sh scripts/verify_test.sh` prints "all cases passed". In the trial environment, with `playbook-wiki` alone, in a repository with the tag `v1.0.0` and a work whose plan is Done, a session asked to close the work recommends a version and asks; in a repository with no tag, it does not ask | Judgement: it is the text of a definition |

## How a unit is delivered

Proposed, as in wiki-check-on-commit (wiki-check-on-commit-8): the unit is built on this work's branch, `feat/version-on-close`, in its worktree `~/dev/playbook-worktrees/version-on-close`. The work reaches `main` by one pull request, which the owner merges (R14).

## Left out

- Making the release: the agent lists its steps, and makes it only when asked (version-on-close-5).
- The version of this repository's plugins. When this work closes, the repository's `CLAUDE.md` asks for it (github-release-2): the unit changes a plugin, so a MINOR version is likely.
