# Plan of version-on-close

Stage 5. It builds what [definition.md](definition.md) and [technology.md](technology.md) decide.

## Progress

| Unit | Status | Evidence | Done on | Owner's words |
|------|--------|----------|---------|---------------|
| version-on-close-U1 | Done 2026-11-16, accepted by the owner's judgement | One item in step 6 of `plugins/playbook-wiki/skills/prepare-project/references/6-execution.md`, before the work's status is set to Closed. Run on 2026-11-16: `bash scripts/verify.sh` printed "verify passed: playbook-wiki loads 337 words at session start, limit 350; playbook-agents loads 609, limit 620"; `sh scripts/verify_test.sh` printed "all cases passed"; `claude plugin validate plugins/playbook-wiki` passed; the check of the wiki passed. In the trial environment on 2026-11-16, with Claude Code 2.1.326, `playbook-wiki` alone from this worktree, and two repositories built for the trial, each with a wiki at format 4 and a work `pdf` whose only unit was Done, `claude -p --model sonnet` was asked to close the work and to write its questions instead of asking. With the tag `v1.0.0`, the session closed the work and asked: "the repo has the tag `v1.0.0`, and the project has no written versioning rule, so Semantic Versioning applies. The PDF button adds a feature without breaking anything, so I recommend a MINOR release, `1.1.0`", listing the bump in `package.json`, the tag, and the release, "only do those when you ask". With no tag, it closed the work and wrote "git has no version tag, so I recommended no version and made no release", asking nothing about a version. In the first case it set the work to Closed before the answer, because it could not ask in that mode. The plugin, the marketplace, its cache, and the repositories were deleted, and the trial folder's `settings.json` is as before | 2026-11-16 | Asked "¿Aceptás la U1 con este texto?"; answered "acepto" |

## Units

| ID | Unit | Delivers | Ends when | Accepted by |
|----|------|----------|-----------|-------------|
| version-on-close-U1 | The version at the close of a work | One item in step 6 of `plugins/playbook-wiki/skills/prepare-project/references/6-execution.md`, before the step at the merge: when git has a version tag, recommend whether the work needs a new version and which one, by the project's own rule or else Semantic Versioning, and ask; on a yes, record the version in the work and list the release steps as next steps (version-on-close-1 to version-on-close-3, version-on-close-5) | `bash scripts/verify.sh` exits 0 and `sh scripts/verify_test.sh` prints "all cases passed". In the trial environment, with `playbook-wiki` alone, in a repository with the tag `v1.0.0` and a work whose plan is Done, a session asked to close the work recommends a version and asks; in a repository with no tag, it does not ask | Judgement: it is the text of a definition |

## How a unit is delivered

Accepted by the owner (version-on-close-8), as in wiki-check-on-commit (wiki-check-on-commit-8): the unit is built on this work's branch, `feat/version-on-close`, in its worktree `~/dev/playbook-worktrees/version-on-close`. The work reaches `main` by one pull request, which the owner merges (R14).

## Left out

- Making the release: the agent lists its steps, and makes it only when asked (version-on-close-5).
- The version of this repository's plugins. When this work closes, the repository's `CLAUDE.md` asks for it (github-release-2): the unit changes a plugin, so a MINOR version is likely.
