# build-mode

Build mode says who builds each unit of a spec.

## The line

One line, in `~/.claude/CLAUDE.md` for every project or in the project's `CLAUDE.local.md` for one:

- `Build mode: main`: the main session builds, with `/clear` and `/model sonnet` between units.
- `Build mode: builder`: the agent [builder](builder.md) on Sonnet builds from a brief, and the main session verifies with the tests and the diff.

The local line wins; with no line it is `main`. [define](define.md) asks once when neither file has it.

## In builder mode

- The main session proposes to split a unit too large for one builder, and to build independent units at the same time. You decide.
- It verifies each unit with the tests and the diff, and with [reviewer](reviewer.md) when the change is risky.

## Connects to

- [builder](builder.md), [reviewer](reviewer.md), [define](define.md), [close](close.md).
- [rules](rules.md), which state the mode, and [sessions](sessions.md).

Source: [plugins/playbook/rules.md](../../plugins/playbook/rules.md)
