# Definition of the work decision-review

## The problem

`docs/wiki/decisions.md` holds 241 decisions, 208 of product (D#) and 33 technical (TD#), taken from 2026-11-13 on. Since then the product moved through four phases and 24 works, and Claude Code shipped many versions. Some decisions may be replaced by a later one that does not say so, may no longer match the code, or may rest on a Claude Code limit that no longer holds. Building on such a decision repeats an old mistake (decision-review-1).

## Scope

The 241 decisions of `docs/wiki/decisions.md`. The decisions inside `works/` are history: what is in force from them lives in the shared pages and in those 241 (decision-review-2).

## Classes

Each decision gets one class (decision-review-2):

| Class | Means | Example |
|-------|-------|---------|
| Valid | The code and Claude Code do what it says | |
| Replaced, not marked | A later decision changed it, and it does not say so | D11, "the first version serves Claude Code only", while Codex is supported |
| Outdated | The code no longer does what it says, or Claude Code changed what it relied on | A decision that avoided a feature Claude Code did not have then |
| Doubtful | Reading does not settle it; it needs the owner | |

## The flow

1. Read-only agents share the 241 decisions; each compares its decisions with the code, the shared pages, and Claude Code's current documentation, and returns a class and evidence for each.
2. The main session verifies every finding that is not Valid by reading its evidence, and drops what does not hold.
3. The owner gets a report and decides each decision that is not Valid: replace it with a new decision, mark it as replaced, or confirm it.
4. Each answer is recorded; the wiki is updated at the close.

## What it must not do

Change any decision, page, or code during the review (R18). Changes come only from the owner's answers.

## Topics that do not apply

Users beyond the owner, qualities, budget, law, volume, and outside systems beyond Claude Code's public documentation.
