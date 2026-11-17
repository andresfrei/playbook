# Definition of wiki-check-on-commit

## The problem

A wiki leaves its format between two runs of its check, and nothing notices until the next run.

The check, `plugins/playbook-wiki/check-wiki.sh`, is run only by `prepare-project`, at the end of a stage or a unit, and by the doctor, in `wiki-format.sh mark`. The hooks of `playbook-wiki` print the contract, the notice of the format, and the step at the merge; none runs the check. A session that changes the wiki outside those two skills, such as one that closes a task, is never checked.

The case that showed it, in the project huellitas-id, verified by reading its history on 2026-11-16: commit `db00edfe`, "docs: close the open-work feature and list the next task with the owner", took the section "Where work stands" of `docs/wiki/README.md` from 232 words to 264, over the limit of 250 that the check enforced already in version 1 (`plugin/skills/prepare-project/scripts/check-wiki.sh`, `max_state_words=250`). The doctor, moving that section to the work `phase-1` at format 4, was the first to run the check, and it failed there.

## Decided

- Before an agent commits a change under `docs/wiki/`, a hook of `playbook-wiki` runs the check; when the check fails, the commit is stopped and the failure is shown (wiki-check-on-commit-1).
- The check does not run after each edit of a page: while a page is written the wiki passes through states that fail (wiki-check-on-commit-1).
- The doctor gets no check before it moves anything: the check refuses a wiki below the playbook's format at once, so it cannot check one at its own format. `doctor/references/format-4.md` says what to do when the section "Where work stands" it moves holds more than 250 words or finished work: remove what another page already holds, move finished work to the page of its plan and link it, and open no new section in the work's `README.md` (wiki-check-on-commit-2).
- When the check fails, the hook stops the commit and gives the failure to the agent to repair; it does not ask the person (wiki-check-on-commit-3).
- When the wiki is below the playbook's format, the hook lets the commit through and prints nothing; the notice at the start of a session already sends that wiki to the doctor (wiki-check-on-commit-4).
- The hook reaches only a commit the agent runs through Claude Code's Bash tool. A commit a person runs in their own terminal is not checked; this is how a `PreToolUse` hook works, as the hook of the step at the merge does (wiki-check-on-commit-5).

## Open

Nothing. The questions are in [questions.md](questions.md).

## Topics

| Topic | Coverage | What is missing |
|-------|----------|-----------------|
| The problem, and who has it | Covered | Above |
| Who uses it | Covered | A person with `playbook-wiki` on, and the agent that commits for that person |
| Main flows | Covered | The commit (wiki-check-on-commit-1) and the doctor (wiki-check-on-commit-2) |
| What it must do | Covered | wiki-check-on-commit-1, wiki-check-on-commit-3, wiki-check-on-commit-4 |
| What it must not do | Covered | It does not run after each edit (wiki-check-on-commit-1). It does not touch a commit with no change under `docs/wiki/` |
| Qualities | Covered, the how in stage 2 | Never stopping a commit by its own error, as the hook of the step at the merge does: stage 2 |
| Limits | Covered | Claude Code only (D181); sh, sed, and awk, as the other hooks |
| Outside systems | Covered | git only (D173) |
| Volume | Not applicable | |
| Who runs and maintains it | Covered | The owner maintains `playbook-wiki` (D179) |
| Rules, states, vocabulary | Covered | The [glossary](../../01-product/glossary.md) |
