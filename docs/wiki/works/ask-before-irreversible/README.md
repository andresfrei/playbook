# Work ask-before-irreversible

Makes Claude Code ask the person before a delivery action that cannot be undone, such as a push, a merge, or a release, so rule R14 is enforced and not only written. Andres Frei leads it.

Status: Open.

## Where work stands

Updated 2026-11-19, after ask-before-irreversible-11.

Stage 1, Wiki, is closed; stage 2, Technology, is open. [definition.md](definition.md) holds the definition, and no question is open.

Waiting for a decision: none.

Next steps, in order:

1. Measure in which permission modes a hook's `ask` shows a prompt, and in which it does not (ask-before-irreversible-3).
2. Choose how the hook recognizes each action of ask-before-irreversible-2, and how `/playbook-agents:protect` finds secret files and writes the settings (ask-before-irreversible-9, -10).
3. Write the architecture page and close stage 2.

## Stage table

| Stage | Status | Closed on |
|-------|--------|-----------|
| 1 Wiki | Closed | 2026-11-19 |
| 2 Technology | Open | |
| 3 Skills | Not started | |
| 4 Design system | Not started | |
| 5 Plan | Not started | |
| 6 Execution | Not started | |

## Pages

| Page | Content | Code it governs |
|------|---------|-----------------|
| [definition.md](definition.md) | The problem, what is known, and the coverage of each topic | |
| [measurements.md](measurements.md) | Whether a hook's `ask` shows a prompt in each permission mode | |
| [decisions.md](decisions.md) | The decisions of this work | |
| [questions.md](questions.md) | The open questions | |
