# Definition of the work work-delivery

What this work must make true: before a work prepared with `prepare-project` is implemented, the agent asks how the work is delivered, and the answer is a decision the execution follows (work-delivery-1).

## The problem

Stage 5 of `prepare-project` asks how a unit is delivered, but its questions assume that every unit reaches the main branch ([current-state.md](current-state.md)). It never asks which branch people test changes on, or where a work's units integrate. In a project already started it proposes the delivery the repository's history shows.

What happened in another project of the owner, Genesis, on 2026-11-17 and 2026-11-18, as reported by the session that ran it: stage 5 proposed the existing habit, each unit to the shared test branch `staging` by its own pull request, and the owner accepted it. Fourteen units and one fix unit reached `staging` one by one over about 24 hours. The test branch held a half-built work, and the owner's check in the browser, run after the last unit, found eight defects that needed one more unit.

It also goes against the format of a wiki, `plugins/playbook-wiki/format.md`: "A work is what one branch carries from its start to its merge."

## Who has it

The person who leads a work prepared with `playbook-wiki`, and the people who test on a shared branch.

## Where the idea comes from

gentle-ai's skill `chained-pr`, read on 2026-11-18 in https://github.com/Gentleman-Programming/gentle-ai (`internal/assets/skills/chained-pr/`), asks once for a delivery strategy when a pull request would pass 400 changed lines: stacked pull requests to the main branch, or a "feature branch chain", where a branch holds the whole feature, a draft tracker pull request shows its progress, and each slice is a numbered child branch. The owner keeps the moment of asking, not gentle-ai's rule (work-delivery-1). Its 400-line gate stays dropped: a pull request size is a planning guide, not a cap (D14).

## What the work must do

Decided:

- Ask, before implementation, how the work is delivered, and record the answer as a decision (work-delivery-1).
- Assume no branch and no workflow. Read the project's own skill for delivery first, when there is one, and take it into account (work-delivery-2).
- Live as step 5 of stage 5 (Plan), replacing its three delivery questions (work-delivery-4).
- Offer three ways of integrating, each with what it costs: one pull request for the whole work; a work branch with a draft tracker pull request; each unit straight to the test branch, only when each unit can be tested alone (work-delivery-5).
- Treat the history and the project's skill as sources, not the proposal. When a proposal would leave an unfinished work where people test, name the risk, recommend a way that keeps that branch whole, and let the owner decide; no hard rule (work-delivery-6).
- Ask where the work is tested, assuming none: its own branch, deployed for instance from a worktree to a homelab, checked before any merge; a shared test branch, checked after the merge to it; or nowhere apart, with only tests and CI. In stage 6, deliver each unit as decided and close the work after the owner's check in that place; its fixes are units of the same work (work-delivery-8, which replaces work-delivery-7).
- Recommend by default branches named `<type>/<work>`, with the types of conventional commits, and numbered child branches `<type>/<work>-01-<slice>` when the work is split. The project's own convention takes precedence (work-delivery-3).

Decided with the wiki (work-delivery-10):

- It reads from the repository which branch is production and confirms it with the owner.
- Two evaluation cases: a started repository whose history merges each unit into its test branch, where the agent recommends a work branch and names the risk; and a new project with only `main`, where the agent asks where changes are tested before recommending.

## What the work must not do

- Name a branch such as `staging` or `main` as the default of every project (work-delivery-2).
- Add a rule about delivery to `plugins/playbook-agents/rules.md` (work-delivery-9).
- Bring back a size gate for pull requests (D14).
- Copy gentle-ai's skill or its structure (D31).
- Add a seventh stage (work-delivery-4, D8).

## Coverage of the topics

| Topic | Coverage |
|-------|----------|
| Problem and who has it | Covered |
| Users | Covered: the person who leads a work |
| Main flow | Covered: step 5 of stage 5 (work-delivery-4) |
| What it must do | Covered: work-delivery-1 to -9 |
| What it must not do | Covered |
| Qualities | Covered: the skill stays within the limits of `write-skill` |
| Limits | Covered: D8, D14, D31 |
| Outside systems | Covered: git and the project's forge; the agent opens no pull request without the owner (R14) |
| Volume, operation | Not applicable: a change to a skill's text |
| Vocabulary | Covered: "work branch", "test branch", and "tracker pull request" go into the glossary when the work closes |

## Not verified

- The Genesis account comes from the story the session in that project wrote; the repository of Genesis was not read for this page.
