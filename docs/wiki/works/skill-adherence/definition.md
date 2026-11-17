# Definition of the work skill-adherence

What this work must make true: a skill of the playbook loads when a request calls for it, and what it returns reaches the owner as its Output says. It takes the three questions the work skill-triggering left open, [skill-triggering-Q5 to -Q7](../skill-triggering/questions.md) (skill-adherence-1).

## The problem

The work skill-triggering ran the cases of four skills with `claude plugin eval`, three runs per arm, in three measurements: U2, U5, and U6. What each run showed is in [../skill-triggering/measurements.md](../skill-triggering/measurements.md). Three faults remained:

| Question taken | Fault seen | Case |
|----------------|------------|------|
| skill-triggering-Q5 | The skill does not load when the agent can do a small task itself: `keep-minimal` loaded in 1 of 3 runs of a request that holds the whole change in its text; `review-change` loaded in 0 of 3 for "Review my uncommitted changes before I commit them" in U2 and U5, and in 3 of 3 in U6 | `keep-minimal-triggers`, `review-change-off-by-one` |
| skill-triggering-Q6 | `prepare-project` ends its answer with more than one question in 2 of 3 runs, with its gotcha | `prepare-project-new-project-stage-one` |
| skill-triggering-Q7 | The forked agent of `review-change` adds a section and does not say "No findings." plainly, and the session rewrites its report, though the description asks to show it unchanged | `review-change-clean-commit` |

In two cases the skill did not load, yet the agent did what the skill defines: `keep-minimal-add-feature` in U2 scored as without the plugin, and `prepare-project-no-code-before-stage-six` wrote no code in the six runs with the plugin. That is not a fault: a case of behaviour passes on its behaviour, and only the cases of triggering count whether the skill loads (Decided: skill-adherence-2).

## Who has it

The person who installs the playbook. When `review-change` is rewritten before it reaches them, they read the session's judgement instead of the skill's report; when `prepare-project` asks two questions, they answer two things at once, against R3.

## What the work must do

Decided: a skill's cases of triggering load it in 3 of 3 runs, or not at all for a case of not triggering; a case of behaviour passes on its behaviour (skill-adherence-2).

- Find the cause of each fault from the traces already kept, before changing a skill or running anything paid (Decided: skill-adherence-3). What they show is in [traces.md](traces.md).
- For skill-triggering-Q7: change the Output of `review-change` and its cases, drop "show its report unchanged" from its description, and record the session's relay of a fork's result as Claude Code's (Decided: skill-adherence-4).
- For skill-triggering-Q6: give the gotcha of `prepare-project` an example from another domain, and make its case not depend on the sandbox (Decided: skill-adherence-5).
- For skill-triggering-Q5: the case `keep-minimal-triggers` names a change in the repository; the description of `keep-minimal` stays (Decided: skill-adherence-6).

## What the work must not do

Decided:

- Raise the limit of a description, 250 characters, or of a body, 700 words (skill-best-practices-1).
- Run a paid evaluation without the owner asking (skill-triggering-3), or above USD 3 per skill in a run (skill-adherence-7).

## Coverage of the topics

| Topic | Coverage |
|-------|----------|
| The problem, and who has it | Covered: above |
| Who uses it | Covered: the person who installs the playbook, and the agent that loads the skills |
| Main flows | Covered: a request that should load a skill; a forked skill whose report the session relays; a run of the cases |
| What it must do | Covered: skill-adherence-2 to -6 |
| What it must not do | Covered: skill-adherence-7 |
| Qualities | Covered: the limits of [../../01-product/style-guide.md](../../01-product/style-guide.md) stay |
| Limits | Covered: the cost, skill-adherence-7; the traces were read before a reboot, skill-adherence-3 |
| Outside systems | Covered: `claude plugin eval`, Claude Code's relay of a forked skill, and Anthropic's models |
| Volume | Covered: three skills, `keep-minimal`, `review-change`, `prepare-project`, and the agent `review` |
| Who runs and maintains it | Covered: the owner |
| Business rules and vocabulary | Covered: the terms of the style guide and of [../../03-technology/skill-evaluation.md](../../03-technology/skill-evaluation.md) |

## Not verified

- Whether Claude Code can pass a forked skill's result to the owner unchanged: its documentation names no such option ([technology.md](technology.md)).
