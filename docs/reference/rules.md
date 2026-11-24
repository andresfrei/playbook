# rules

The rules are a short file of about 50 lines that the playbook loads at the start of every session, in every project where it is on.

## What they are

- "The owner" is the person Claude works for. A project's own rules, in its `CLAUDE.md` or `.claude/rules/`, add to these and win over them; the hooks that ask before heavy actions ask anyway.
- They are grouped as talking to the owner, deciding, the wiki, building, learning, and delivering. Most carry a number, from R1 to R24 with gaps, so decisions and skills can cite them.
- What they say, in short:
  - Reply in the owner's language; write code, documentation, and commits in English. Answer briefly. Ask one question at a time, with a recommendation. Verify before stating.
  - Define a change larger than a small one with [define](define.md) before it is built. Only the owner decides; record each decision with the owner's words. Heavy actions are asked for, light ones done, medium ones asked once (R18).
  - Keep the wiki true to the code, and write it so any agent understands it without the conversation.
  - Choose the simplest solution; a change in behaviour comes with its tests; a risky change is read by [reviewer](reviewer.md) before delivery (R20).
  - Build mode `main` or `builder` says who builds each unit; see [build-mode](build-mode.md). Ask whether to close and continue in a clean session at the end of a task or unit; see [sessions](sessions.md).
  - When the same mistake happens twice, propose one line for the project's rules.
  - Conventional commits with no AI attribution; push, pull requests, merges, and releases are the owner's decisions (R13, R14).

## When they load

- The hook [session-start](session-start.md) prints them at the start of each session, followed by the project's `docs/playbook/README.md` when there is one.

## Connects to

- [session-start](session-start.md), which loads them, and [ask](ask.md), which enforces R14.
- [define](define.md), [close](close.md), [builder](builder.md), [reviewer](reviewer.md).
- [wiki](wiki.md), [build-mode](build-mode.md), and [sessions](sessions.md).

Source: [plugins/playbook/rules.md](../../plugins/playbook/rules.md)
