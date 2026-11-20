---
name: seed-evidence
description: Seed this repository's evidence page from its past reviews, found in the person's Claude Code transcripts. Shows the reviews, asks which to seed, then stores each one's findings with classify.
disable-model-invocation: true
---

## When to use

- The person types `/playbook-agents:seed-evidence` inside a repository whose evidence page is empty or missing, to rebuild it from the reviews already made there.

Do not use it to store the findings of a review just made; that is `playbook-agents:classify`.

## Rules

- Read the transcripts only through `seed-reviews.sh`. Never open a transcript file yourself.
- Write nothing yourself. Only `classify` writes the page.
- Start `classify` for one review at a time, in order, never in parallel.
- Ask once, before the first `classify`, and wait for the answer.
- Do not paste a report into the reply, beyond what a step needs.
- Never commit, push, or change git state.

## Gotchas

- A review marked "already seeded" is not chosen by default: it is counted once by its identifier, so seeding it again adds nothing.
- A review that says "No findings." is never chosen.
- The identifier given to `classify` is the first line of `show`, unchanged. Do not make one up.

## Steps

In what follows `<script>` is `${CLAUDE_PLUGIN_ROOT}/seed-reviews.sh`, `<evidence>` is `${CLAUDE_PLUGIN_ROOT}/evidence.sh`, and `<from>` is each `--from <old path>` the person's message carries, passed on as written, to every call of the script.

1. Run `git rev-parse --show-toplevel`; its output is `<root>`. When it fails, say this is not a git repository and stop.
2. Run `sh "<script>" list "<root>" <from>`. When it prints that no reviews were found, say so, mention `--from <old path>` for a repository that was moved, and stop. When it fails, show its message and stop.
3. Show the preview: one line per review, with its number, its identifier (date and time), its findings count or "No findings.", and "already seeded" where it says so. Say that every review with findings that is not seeded is chosen by default, and give the number of runs of `classify` (model sonnet), from the last line of the list.
4. Ask which to seed, with AskUserQuestion when available: all those chosen (recommended), or a list of numbers to leave out or to take. One question. Stop when none is chosen. Wait for the answer.
5. For each chosen review, in order, and finishing one before the next:
   1. Run `sh "<script>" show "<root>" N <from>`. Its first line is the identifier; the rest is the report. When it fails, say so and go on to the next review.
   2. Start `playbook-agents:classify` with the findings of the report, `<root>`, the identifier, and the review's date: the identifier's first ten characters, or today for one that starts with `undated`.
6. Run `sh "<evidence>" count "<root>/docs/wiki"` and show its lines.

## Output

- The reviews seeded, by number and identifier, and those left out or failed.
- The rows added, summed from the answers of `classify`.
- The kinds that `count` marks "ready", to consolidate at the close of a work.
- That nothing was committed.
