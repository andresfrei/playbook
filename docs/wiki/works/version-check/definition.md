# Definition of the work version-check

What this work must make true: a person with the playbook installed learns, without looking for it, that a newer version exists and what to run after updating. Nothing is updated by itself (version-check-1).

## The problem

Claude Code does not tell a person that a plugin from a third-party marketplace, such as this one, has a new version. Its documentation, read on 2026-11-19 (https://code.claude.com/docs/en/plugins/install.md, "Keep plugins updated"), says automatic update is off for "every other marketplace, including ... third-party marketplaces", and documents a message only after an update: "Plugin updated: <name> · Run /reload-plugins to apply".

So a person keeps an old version without knowing. With 3.0.0, a MAJOR version that moves the wiki to format 5, this matters more: until they update and run the doctor, their agent keeps working on format 4.

What the playbook tells today, read in the repository on 2026-11-19:

- At the start of a session, `wiki-format.sh hook` prints one line when the wiki's format is behind the plugin's, recommending the doctor. The line goes to the agent, not to the person.
- When the wiki is ahead of the plugin, such as a wiki at format 5 with a plugin at format 4, it prints nothing. That case means the plugin is old, and it is known without a network.
- No hook compares the installed version with the published one.

## What the documentation says

Read on 2026-11-19 in https://code.claude.com/docs/en/hooks, in part; to check against the live page in stage 2:

- A SessionStart hook's plain stdout is added to Claude's context. No text says the person sees it.
- `systemMessage`: "Warning message shown to the user"; some events discard it or show it elsewhere, "each event's section says so", and the section of SessionStart does not. Where it shows at the start of a session is not documented.
- `hookSpecificOutput.additionalContext` adds context for Claude. Whether one output may hold it and `systemMessage` together is not documented.
- Output is capped at 10,000 characters; SessionStart hooks should be fast, with no timeout of their own documented.
- Not read yet: when automatic update runs (https://code.claude.com/docs/en/plugins/loading.md), which says whether the local copy of the marketplace, which version-check-2 reads, refreshes by itself.

## Who has it

Every person who installed the playbook from its marketplace, and the agent that works for them.

## What it must do

- Tell the person and the agent, at the start of a session (version-check-3), when the installed version is older than the one available, with both versions.
- Proposed: say what to run after the update, such as the doctor for a new wiki format.
- Proposed: tell when the wiki of the project is at a newer format than the plugin, which means the plugin is old.

## What it must not do

- Update a plugin or a marketplace by itself (version-check-1).
- Stop or noticeably delay the start of a session; on any failure it prints nothing.
- Connect to a network: it reads only the local copy of the marketplace and the wiki's format marker, so a version not yet in the local copy is not seen (version-check-2).

## Later

- A notice for Codex: its installer is a separate route (codex-support-8).

## Coverage of the topics

| Topic | Coverage |
|-------|----------|
| The problem and who has it | Covered |
| Who uses it and what they do | Covered: the person reads the notice, the agent recommends what to run (version-check-3) |
| Main flows | Partly covered (version-check-Q3, version-check-Q5) |
| What it must do | Partly covered (version-check-Q4) |
| What it must not do, and what waits | Covered (version-check-1, version-check-2) |
| Qualities: speed, privacy | Covered: no delay, nothing leaves the machine (version-check-2) |
| Limits | Covered: hooks run `sh`, `sed`, `awk`, and `git` only, as the README of `playbook-wiki` says |
| Outside systems | Does not apply: no network (version-check-2) |
| Volume | Does not apply |
| Who runs and maintains it | Covered: each person on their machine |
| Business rules, states, vocabulary | Covered: versions by TD22, wiki formats by `format.md` |
