# Spec of the work driven-mode

Status: Accepted (driven-mode-4)

Learned: 2026-11-28

Delivery: one branch and one pull request per work (delivery-versioning-2).

## What and why

Playbook's rules assume a person at the terminal: R3 asks with `AskUserQuestion`, a finished task asks whether to clear the session, and the session start may ask the language. A session driven by another session, such as a bot of playbot, cannot answer a dialog: its settings deny `AskUserQuestion` (playbot-18), and it asks in text through SendMessage (playbot-25). Today it still loads the rules for a person, and only the launcher's prompt tells it otherwise.

- Decided (dialog-learning-5): the mode is per session, set by whoever launches it, not a line of a file, since the same project is worked by hand one day and by a bot the next. With a person, the default, nothing changes.
- Decided (driven-mode-1): the session-start hook sees the variable and loads a short block in place of the dialog rules. The block says to ask in text with the type first, send the question to the named session with SendMessage, and end the turn. It also says to open no dialog, not ask the language, and hand back what cannot be written outside the project.
- Decided (driven-mode-2): the variable is `PLAYBOOK_DRIVEN_BY=<session name>`. Its value is where each question goes, so the block survives a compaction: SessionStart runs again on `compact`.
- Decided (driven-mode-4): the block. The hook prints `rules.md` without the line of ask-to-clear-2, then this block, with the session's name in place of `<name>`:

  > This session is driven: no person is at its terminal, and the session `<name>` answers for the owner. Where a rule or a skill says to ask, or to ask with `AskUserQuestion`, write the question in text instead, with its type first (one of the words of R3, as `Scope: ...`) and its options with the recommended one first. Send it with SendMessage to `<name>`, one question per message, naming the project and the step, then end your turn and wait. A reply from `<name>` is the owner's answer. Open no dialog, and do not ask to close or clear the session. Do not write outside the project's folder, such as a line for `~/.claude/CLAUDE.md`, a user setting, or a preset: send it to `<name>` as a proposal.

- Decided (driven-mode-4): a value that holds a newline or a double quote, or is longer than 200 characters, is not used. The hook prints the rules for a person and one line saying the variable was ignored (the same limits as playbot's `launch.sh`).
- Decided (driven-mode-4): in a driven session, the hook prints no instruction to ask the language. The language lines of the option Language still print, and the language-asked record is not created.

## Out of scope

- Setting the variable when playbot launches a bot: a work of the playbot repository. Its bot file's `env` or its `launch.sh` can set it.
- Keeping the text questions for `audit-learning` (driven-mode-3).
- The hooks that ask before a push, a pull request, a merge, or a release (`ask.sh`). They raise a permission prompt in a driven session too, and playbot's guard and heavy relay handle it.
- Telling a driven session apart without the variable: the documentation read on 2026-11-28 names no field or variable that says nobody is at the terminal (dialog-learning-5).

## Technology

Pages of Claude Code's documentation read on 2026-11-28, from `https://code.claude.com/docs/en/`.

| Need | Technology | Why |
|------|------------|-----|
| The launcher marks the session | An environment variable, in the launcher's environment or the `env` of the settings file it passes | settings-reference.md: `env`, "Set environment variables for every session and its subprocesses"; settings.md: `--settings` "pass a key as JSON, inline or as a path to a file" |
| The hook reads it | The existing `session-start.sh` | hooks.md: "Handlers run in the current directory with Claude Code's environment." That a variable from a settings file's `env` reaches a SessionStart hook is inferred, not read: the live check confirms it |
| The block survives a compaction | SessionStart's matcher `compact` | hooks.md: "`SessionStart` \| how the session started \| `startup`, `resume`, `clear`, `compact`, `fork`" |

Skills: none needed; the hook is plain shell, as the plugin's hooks are (audit-2026-11-25-1).

## Check

The check covers four things:
- Offline: the hook's test with `PLAYBOOK_DRIVEN_BY=playbot` prints the block with `playbot` in it, no ask-to-clear line, and no instruction to ask the language. Without the variable, the output is the same as before the change. With an invalid value, it prints the rules for a person and the ignored line. `rules.md` plus this repository's README plus the block stay under 9,000 characters.
- Live: in a throwaway repository, `claude -p --plugin-dir plugins/playbook --settings '{"env":{"PLAYBOOK_DRIVEN_BY":"tester"}}' "<a request that needs a question>"` answers with a question in text, its type first, and opens no dialog. Without the setting, the same run behaves as today. This confirms the inferred row of Technology.
- `product.md`, `docs/reference/session-start.md`, and the plugin's README say how a launcher sets the variable.
- Every check of `CLAUDE.md` passes.

## Units

| Unit | What it delivers | Check | Status |
|------|------------------|-------|--------|
| driven | `session-start.sh` reads `PLAYBOOK_DRIVEN_BY` and prints the block in place of the dialog rules. The tests, `product.md`, the reference page, and the plugin's README follow. | The work's check above. | Done |
