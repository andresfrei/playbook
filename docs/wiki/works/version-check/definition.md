# Definition of the work version-check

What this work must make true: a person with the playbook installed learns, without looking for it, that a newer version exists and what to run after updating. Nothing is updated by itself (version-check-1).

## The problem

Claude Code does not tell a person that a plugin from a third-party marketplace, such as this one, has a new version: automatic update is off for those marketplaces, and there is no notice. Proposed, recalled from the work `delegation` and to be verified in stage 2.

So a person keeps an old version without knowing. With 3.0.0, a MAJOR version that moves the wiki to format 5, this matters more: until they update and run the doctor, their agent keeps working on format 4.

What the playbook tells today, read in the repository on 2026-11-19:

- At the start of a session, `wiki-format.sh hook` prints one line when the wiki's format is behind the plugin's, recommending the doctor. The line goes to the agent, not to the person.
- When the wiki is ahead of the plugin, such as a wiki at format 5 with a plugin at format 4, it prints nothing. That case means the plugin is old, and it is known without a network.
- No hook compares the installed version with the published one.

## Who has it

Every person who installed the playbook from its marketplace, and the agent that works for them.

## What it must do

- Proposed: tell the person, at the start of a session, when the installed version is older than the one available, with both versions.
- Proposed: say what to run after the update, such as the doctor for a new wiki format.
- Proposed: tell when the wiki of the project is at a newer format than the plugin, which means the plugin is old.

## What it must not do

- Update a plugin or a marketplace by itself (version-check-1).
- Stop or noticeably delay the start of a session; on any failure it prints nothing.
- Proposed: connect to a network (version-check-Q1).

## Later

- A notice for Codex: its installer is a separate route (codex-support-8).

## Coverage of the topics

| Topic | Coverage |
|-------|----------|
| The problem and who has it | Covered |
| Who uses it and what they do | Partly covered: who reads the notice (version-check-Q2) |
| Main flows | Partly covered (version-check-Q2, version-check-Q3, version-check-Q5) |
| What it must do | Partly covered (version-check-Q4) |
| What it must not do, and what waits | Partly covered (version-check-Q1) |
| Qualities: speed, privacy | Partly covered: no delay; privacy depends on version-check-Q1 |
| Limits | Covered: hooks run `sh`, `sed`, `awk`, and `git` only, as the README of `playbook-wiki` says |
| Outside systems | Partly covered: GitHub only if version-check-Q1 allows it |
| Volume | Does not apply |
| Who runs and maintains it | Covered: each person on their machine |
| Business rules, states, vocabulary | Covered: versions by TD22, wiki formats by `format.md` |
