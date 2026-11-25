# Playbook reference

One page per piece of the Playbook plugin: what it is, when it runs, what it reads and writes, what it asks the owner, and what it connects to.

## Skills

- [define](define.md): defines a change with the owner before code and records each decision.
- [close](close.md): checks a built work or unit against its spec, proposes rule lines, and updates the wiki.
- [audit](audit.md): adopts a project on its first run, then reports contradictions, limits passed, and tool collisions.
- [audit-learning](audit-learning.md): finds what repeats across works and proposes a delegation, rule, skill, or agent.
- [release](release.md): sets the version, commits, and drafts release notes; the owner publishes.
- [permissions](permissions.md): asks about attribution and permission rules, and writes the accepted ones to Claude Code's settings.
- [presets](presets.md): saves a preset from a project and applies it to another of the same stack: rules, skills, and agents.

## Agents

- [builder](builder.md): builds one unit from a brief, on Sonnet.
- [reviewer](reviewer.md): a read-only second reader that checks a change against its spec.
- [auditor](auditor.md): a read-only explorer of one part of the audit.

## Hooks

- [session-start](session-start.md): loads the rules, the wiki README, and the language at session start.
- [adopt](adopt.md): recommends the audit in a project that is not yet adopted.
- [ask](ask.md): asks before a push, pull request, merge, or release.
- [commit-check](commit-check.md): stops a commit when the wiki check fails.

## Concepts

- [rules](rules.md): the rules loaded at every session start.
- [wiki](wiki.md): the `docs/playbook/` folder a project gets, and its check.
- [build-mode](build-mode.md): who builds each unit, `main` or `builder`.
- [sessions](sessions.md): why sessions are short.
- [upgrade-from-4](upgrade-from-4.md): moving from 4.x to 5.
