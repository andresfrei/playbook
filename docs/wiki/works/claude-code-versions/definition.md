# Definition of the work claude-code-versions

## The problem

Claude Code ships often: five versions, 2.1.326 to 2.1.330, came out while the wiki last cited 2.1.326. The plugins of this repository are built on Claude Code's hooks, agents, skills, manifests, worktrees, and permissions, so a release can break them or offer a simpler way to do what they do. Nothing records which versions were already read, so a check either repeats work or misses a version. Decided (claude-code-versions-1).

## Who uses it

- The owner asks for an evaluation, in their words, such as "evaluá Claude Code".
- The agent of the session runs it and reports. Decided (claude-code-versions-1).

## The main flow

Decided (claude-code-versions-5):

1. The agent reads the record: the last version evaluated.
2. It reads the installed version with `claude --version`.
3. It reads the changelog entries after the recorded version, up to the installed one.
4. It crosses each entry with what this repository uses: hooks, plugin manifests, agents, skills, commands, worktrees, permissions, and the Codex side when an entry concerns it.
5. It shows a table: the version, the change, what in the repository it touches, and a proposal: optimize, check, or nothing.
6. The owner answers each proposal; then the record moves to the installed version, and proposals left for later are listed as pending (claude-code-versions-4).

## The record

A shared page, `03-technology/claude-code-versions.md`: the last version evaluated, one row per evaluation with its date, its range, and where each accepted proposal went, and the pending proposals. Decided (claude-code-versions-3, claude-code-versions-4).

## What it must not do

- Change any file during the evaluation, beyond the record (R18). Each optimization or fix the owner accepts is a work or a fix of its own. Decided (claude-code-versions-5).
- Serve other projects (claude-code-versions-2).

## Outside systems

Claude Code's public changelog, `CHANGELOG.md` in the repository `anthropics/claude-code` on GitHub. Proposed.

## Volume

A few versions a week; each evaluation reads a few hundred changelog lines. Proposed.

## Topics that do not apply

Users beyond the owner, qualities such as speed or availability, budget, law, and business states: the evaluation is an internal step of this repository.

## First evaluation

Proposed: the first run covers 2.1.326 to 2.1.330, since the wiki cites 2.1.326 only for single facts and no full evaluation of it was recorded.
