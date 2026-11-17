# Plan of wiki-check-on-commit

Stage 5. It builds what [definition.md](definition.md) and [technology.md](technology.md) decide.

## Progress

| Unit | Status | Evidence | Done on | Owner's words |
|------|--------|----------|---------|---------------|
| wiki-check-on-commit-U1 | Done 2026-11-16, accepted by its evidence | Built by the `write` agent, read by the `review` agent, corrected by the main session. `plugins/playbook-wiki/hooks/git-hook-lib.sh` holds the parser of the command and the JSON helpers, now shared with `merge-step-hook.sh`, whose behaviour did not change; `hooks/commit-check-hook.sh` runs `check-wiki.sh` for a `git commit` when `docs/wiki/` is at the playbook's format and differs from the last commit, and answers `"deny"` with the check's output when the check exits 1; `hooks.json` runs it as a second command under the `PreToolUse` group on `Bash(git *)`. The `review` agent found no defect that lets a failing change through or stops a commit by the hook's own error. It found four things, each settled: a marker of ten digits or more was denied where the check treats it as no marker, corrected; no test for a marker above the format, added; `scripts/verify.sh` accepted a narrower condition on the commit hook, which would miss `git -C <dir> commit`, now refused with a test; and `definition.md` said the hook never touches a commit with no wiki change, which wiki-check-on-commit-6 does not hold, corrected, with the two limits of reading the disk written as a risk in `technology.md`. Run on 2026-11-16: `bash scripts/verify.sh` printed "verify passed: playbook-wiki loads 337 words at session start, limit 350; playbook-agents loads 609, limit 620"; `sh scripts/verify_test.sh` printed "all cases passed" with 413 cases, once with `gawk` and once with `mawk` as `awk`; `shellcheck` printed nothing for the scripts and the hooks; `claude plugin validate plugins/playbook-wiki` printed "Validation passed". In the trial environment on 2026-11-16, with Claude Code 2.1.326 and `playbook-wiki` alone from this worktree, in a repository built for the trial whose work `notes` had an uncommitted "Where work stands" of 301 words: `claude -p --model sonnet`, asked to commit all the changes and to repair and retry if refused, answered "The wiki check refused the first attempt. The 'Where work stands' section in `docs/wiki/works/notes/README.md` had 301 words, over the 250 limit", repaired it, and committed; the committed wiki passed the check. The plugin, the marketplace, its cache, and the repository were deleted, and the trial folder's `settings.json` is as before | 2026-11-16 | |
| wiki-check-on-commit-U2 | Done 2026-11-16, accepted by the owner's judgement | One item in step 5 of `plugins/playbook-wiki/skills/doctor/references/format-4.md`, after the one on links, as wiki-check-on-commit-2 says; the sentence that called the links the only change to the moved text now names this item too. Run on 2026-11-16: `bash scripts/verify.sh` printed "verify passed: playbook-wiki loads 337 words at session start, limit 350; playbook-agents loads 609, limit 620"; the check of the wiki passed | 2026-11-16 | Asked "¿Aceptás la U2 con este texto?"; answered "dale, avanzá" |

## Units

| ID | Unit | Delivers | Ends when | Accepted by |
|----|------|----------|-----------|-------------|
| wiki-check-on-commit-U1 | The hook of the commit | The parser of `plugins/playbook-wiki/hooks/merge-step-hook.sh` made to take the subcommand and shared by both hooks; a hook that, for a `git commit` in a repository whose `docs/wiki/` is at the playbook's format and differs from the last commit, runs `check-wiki.sh` and answers `"deny"` with its output when it fails; its line in `hooks/hooks.json`; tests in `scripts/verify_test.sh` (N1 to N7) | The tests show: a failing wiki change stops `git commit`, `git add -A && git commit`, `cd <dir> && git commit`, and `git -C <dir> commit`, with the check's output; a passing wiki, a commit with no wiki change, a wiki below the format, a repository with no `docs/wiki/`, and a command that cannot be parsed print nothing; the cases of the step at the merge still pass. `bash scripts/verify.sh` exits 0, `sh scripts/verify_test.sh` prints "all cases passed" with `gawk` and `mawk`, `shellcheck` prints nothing, `claude plugin validate` passes. In the trial environment, a session with `playbook-wiki` alone is stopped committing a wiki with a "Where work stands" over 250 words, and repairs it | Evidence |
| wiki-check-on-commit-U2 | The doctor's step | One step in `plugins/playbook-wiki/skills/doctor/references/format-4.md`, as wiki-check-on-commit-2 says | The step is written and `bash scripts/verify.sh` exits 0 | Judgement: it is the text of a definition |

U2 depends on no other unit. U1 is first because it is the one that prevents the problem.

## How a unit is delivered

Accepted by the owner (wiki-check-on-commit-8), read from how this repository delivers (TD5, D196): both units are built on this work's branch, `feat/wiki-check-on-commit`, in its worktree `~/dev/playbook-worktrees/wiki-check-on-commit`, one after the other and not in parallel. The work reaches `main` by one pull request, which the owner merges (R14). U1 changes a hook, so the `review` agent reads it before it is Done (R20).

## Left out

- The version of the plugins: settled by version-on-close-9. This work and version-on-close are released together as 2.1.0 when this work is merged.
- Checking a commit a person runs in their own terminal (wiki-check-on-commit-5).
