# Definition of the work review-trigger

What this work must make true: when the writing agent commits a change that R20 calls risky, the agent `review` has read it first, and that no longer depends on the writing agent remembering R20 (review-trigger-1).

## The problem

R20, in `plugins/playbook-agents/rules.md`, says: "A change is risky when a mistake is hard to notice or undo: stored data, security, an interface others use, concurrency, delivery, untested code. Have the `review` agent read it before delivery." It is a written rule, loaded at the start of each session; the writing agent decides whether it applies.

The work review-evidence counted, from the transcripts of this repository's sessions, 37 commits risky by R20; `review` ran before 10 of them ([review-evidence measurements](../review-evidence/measurements.md), U1). When it runs, it finds the defects seeded in six real diffs and reports almost no finding that is not real (same page, U4). So the gap is in how often it runs, not in what it finds (review-evidence-17).

Anthropic's documentation advises a hook for what must happen every time, since an instruction in `CLAUDE.md` or a rule is advice the agent may weigh ([review-evidence research](../review-evidence/research.md), C4).

## What exists today

Checked by reading the files on 2026-11-17:

- R20 lives in `plugins/playbook-agents/rules.md`, which the hook `plugins/playbook-agents/hooks/session-start.sh` loads at the start of a session.
- `plugins/playbook-wiki/hooks/hooks.json` runs two hooks before a `Bash` call of `git`: `commit-check-hook.sh`, which runs the check of the wiki before a commit that changes `docs/wiki/` and denies the call when the check fails; and `merge-step-hook.sh`, which shows the decisions to compare before a merge. Each prints nothing and exits 0 when it cannot parse its input: it never blocks a command by its own error.
- `playbook-agents` has one hook, at the start of a session, and none before a commit.
- The agent `review` is in `plugins/playbook-agents/agents/review.md`; the skill `review-change`, in `plugins/playbook-agents/skills/review-change/`.

## Who has it

Anyone who installs `playbook-agents`, the owner first: they rely on `review` to read a risky change the writing agent may have got wrong.

## What the work must do

- Make the agent `review` read a change R20 calls risky before it is committed, without depending on the writing agent remembering R20 (Decided: review-trigger-1).
- Count again, as review-evidence-U1 did, how many risky commits had `review` before them (Decided: review-trigger-1).
- Apply in every project that installs `playbook-agents`, with no list of risky paths of one repository (Decided: review-trigger-2).
- Let the writing agent judge whether a change is risky: at the commit it is reminded of R20, shown what the commit changes, and told whether `review` ran in the session (Decided: review-trigger-3).
- Hold the first commit call of a change when `review` has not run in the session, so the reminder comes before the commit; the agent calls `review`, or tries the same commit again and it runs. Never stop the person, and hold the agent once per commit (Decided: review-trigger-4).

## What the work must not do

Decided (review-trigger-5):

- Change what `review` or `review-change` does when it runs: review-evidence measured it and kept it (review-evidence-17).
- Add a check that polices the person: the agent points out the situation and the person decides.
- Copy anything from another tool or project, as review-evidence-2 said for the work before.

## Coverage of the topics

| Topic | Coverage |
|-------|----------|
| The problem, and who has it | Covered: above |
| Who uses it | Covered: the writing agent, which commits; the agent `review`; the owner, who reads the findings |
| Main flows | Covered: the writing agent tries to commit; with no `review` in the session the call is held with the reminder; the agent calls `review` or tries again; the commit runs (review-trigger-4) |
| What it must do | Covered: review-trigger-1 to -4 |
| What it must not do | Covered: review-trigger-5 |
| Qualities | Partly covered: it never blocks a command by its own error, as the hooks of `playbook-wiki` do (review-trigger-5); the cost of a review on each risky commit, Open in Q4 |
| Limits | Covered: no paid run without the owner asking, as in review-evidence-5 (review-trigger-5) |
| Outside systems | Covered: Claude Code's hooks; no other |
| Volume | Covered: the commits of a session; 37 risky in 108 found in this repository's transcripts |
| Who runs and maintains it | Covered: the owner |
| Business rules and vocabulary | Covered: "risky" is R20's list, applied by the writing agent at the commit (review-trigger-3) |
