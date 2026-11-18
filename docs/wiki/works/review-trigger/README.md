# Work review-trigger

Makes the agent `review` read a change when R20 calls it risky, without depending on the writing agent remembering R20, and counts again how often it does. Andres Frei leads it.

Status: Open.

## Where work stands

Updated 2026-11-17, after review-trigger-5.

Stage 2, technology, is open. The definition is in [definition.md](definition.md). [questions.md](questions.md) Q4 blocks stage 5.

Next:

1. Stage 2: how the hook knows that `review` ran in the session, how it holds a commit call only once, and what it shows the agent, checked against Claude Code's documentation of hooks.
2. The owner closes stage 2.

## Stage table

| Stage | Status | Closed on |
|-------|--------|-----------|
| 1 Wiki | Closed | 2026-11-17 |
| 2 Technology | Open | |
| 3 Skills | Not started | |
| 4 Design system | Not started | |
| 5 Plan | Not started | |
| 6 Execution | Not started | |

## Pages

| Page | Content | Code it governs |
|------|---------|-----------------|
| [decisions.md](decisions.md) | The work's decisions, with the owner's words | |
| [questions.md](questions.md) | The work's open questions | |
| [definition.md](definition.md) | What the work must make true, what exists today, and what it must and must not do | |
