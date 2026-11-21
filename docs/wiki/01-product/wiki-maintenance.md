# Wiki maintenance

How a project's wiki stays small and current as the project advances, and how a definition the owner changes reaches the next session. It holds what was measured on 2026-11-14, the changes proposed, and the order of the work. The owner decided that this is corrected, that the product maintains the wiki by itself, the order, the reduced scope, and that a changed definition must be followed the next time (D133 to D137 in [decisions.md](../works/history/decisions.md)). The owner accepted the rules and the texts under "Decided" as written (D138). They are built and merged into `main` on 2026-11-14; see "Built".

A project's wiki is created by the skill `prepare-project`; its format is in [`plugins/playbook-wiki/skills/prepare-project/references/1-wiki.md`](../../../plugins/playbook-wiki/skills/prepare-project/references/1-wiki.md). A change to that file reaches every project. A change to this wiki alone does not.

## What was measured

### The four wikis

Counted with `wc -w` on 2026-11-14, on the owner's machine.

| Project | Pages | Words | README | "Where work stands" | Rows in `decisions.md` |
|---|---|---|---|---|---|
| playbook | 32 | 52,564 | 1,832 | 1,053 | 153 |
| torneo-pro | 22 | 20,856 | 431 | no such section | 90 |
| huellitas-id | 18 | 14,403 | 751 | no such section | no such file |
| radar | 8 | 5,244 | 805 | 548 | 27 |

- playbook and radar follow the product's format. torneo-pro and huellitas-id were written before it.
- radar is not a git repository. huellitas-id had a commit and an uncommitted change on 2026-11-14.

### Three defects

1. **The state section grows and is never cut.** `1-wiki.md` defines "Where work stands" as "the date, what is decided, and the next steps in order", and `prepare-project` says "After each change, update 'Where work stands'". Neither says what leaves the section. radar's section copies its 27 decisions one by one; playbook's tells the history of three finished phases. Rewritten to say only the current state, radar's takes 70 words in place of 548, and playbook's 123 in place of 1,053.
2. **`decisions.md` records events next to choices.** Of the 132 `D` rows of playbook, sorted by their opening words, 22 say that a unit was accepted, 17 that a stage was closed or a plan accepted, and 5 that something was pushed or removed afterwards. The other 88 are choices or rules of the owner.
3. **A decision's row repeats what its page says.** The decision text has a median of 56 words in playbook, with 60 of 132 rows over 60 words. In radar the median is 26.

### How the wiki is read and what it costs

From the transcripts of twelve sessions of this project and their subagents, on 2026-11-14. Usage is weighted at API prices: 1 for input, 1.25 for a cache write, 0.1 for a cache read, 5 for output. Reads are sorted by the file a command names, so the figures are approximate.

- `decisions.md` was read whole once and consulted by search about 225 times. `README.md` was read whole 14 times.
- Reading the wiki is about 1.7% of the usage. Writing `README.md` and `decisions.md` is another 1.7%: 185 writes, 8.4% of all output.
- Everything proposed here saves between 0.7% and 1.3% of the usage. This project is nearly all wiki work, so that is a ceiling. The reason to do it is not usage.

### A changed definition, link by link

The owner's case: a structural change, such as how the filters of an application work, is asked for and built, and a later session builds it the old way. Six things must happen for the later session to do it right. Read in the product's text on 2026-11-14:

| # | What must happen | Covered | Where |
|---|---|---|---|
| 1 | The request is recognized as a change of a definition, not a one-off | Partly | `references/6-execution.md`, step 3, inside a unit of a prepared project. Rule R8 says it for the stack only. Nothing for a small task |
| 2 | The decision is recorded with the owner's words | Yes | Rule R7; `1-wiki.md`: "A decision that replaces an earlier one names it" |
| 3 | The page that states the definition is rewritten | Partly | Stage 1 says "update the pages it affects"; stage 6 says only "record the decision in the wiki" |
| 4 | Someone decides what happens to the code that follows the old definition | No | Nowhere |
| 5 | The next session reads the definition before it builds | Partly | `avoid-generic-design` looks for the project's design system, for visual work only. The `write` and `review` agents do not name the wiki |
| 6 | A review finds work that follows the old definition | No | `review-change` compares the change with what it is meant to do, not with what the project decided |

The product guarantees link 2, the one that weighs least: the change lands in the file that is never read whole, while the page and the code may still show the old way.

## Decided

Accepted by the owner as written (D138).

### Rules for the wiki

| # | Rule | Answers |
|---|---|---|
| G1 | "Where work stands" says only the current state, in at most 250 words: the date and the last decision; the phase and stage that are open, or that none is; what waits for the owner, as links; the next steps in order; one line for each finished phase, with a link to the page that holds what it left. It never holds the text of a decision, what a finished unit did, or a measurement | Defect 1 |
| G2 | A decision is a choice the owner made between alternatives, or a rule the owner set. That includes an authorization given before an action, the closing of a stage or a phase, and the acceptance of a plan. The acceptance of a unit is written in the plan's progress table, with the date and the owner's words, and is not a row of `decisions.md`. Something done after a decision, such as a push or a cleanup, is not a row either | Defect 2 |
| G3 | The text of a decision states the choice in at most 60 words and links to the page that holds the detail. Evidence and reasons live in that page | Defect 3 |

- The limit of G1 is twice the larger of the two sections rewritten above. It is adjusted, if needed, when the rules are applied to this wiki.
- The link of G3 is also how decisions are found by topic: searching `decisions.md` for a page's name returns the decisions about it.
- The rows already written are not changed or renumbered: other pages cite them by number.

### When a definition changes

Three texts, accepted word for word.

Rule R8 in [`plugins/playbook-agents/rules.md`](../../../plugins/playbook-agents/rules.md), in place of the present one, which speaks only of the stack:

> R8. When a request differs from what is Decided, say so and ask: an exception, or a change of the definition? Never change it silently.

A rule in the skill `write-docs`, which is the skill that changes a wiki in any project:

> When the owner changes a definition, rewrite the page that states it so that it says only the new one. Record the decision and name the one it replaces. Ask what happens to the code that follows the old definition: changed now, changed when it is next touched, or listed as debt. When the change is for every project, it belongs to the playbook, not to this project.

A kind of defect in the skill `review-change`:

> behaviour that differs from what the project's wiki says is Decided for the part the change touches;

They cover links 1, 3, 4, and 6. Link 5 stays partly covered.

### The check

A script inside the folder of `prepare-project`, in plain shell, with tests. It fails when "Where work stands" has more than 250 words, or when a relative link in a page of `docs/wiki/` does not resolve.

### When the wiki is maintained

| Moment | What is done |
|---|---|
| A unit is closed | "Where work stands" is rewritten to the current state; what the unit did, and its acceptance, stay in the plan's progress table. The check runs, and the unit is not delivered while it fails |
| A stage is closed | The same, and the stage table is updated |
| A phase is closed | What the phase left moves to the page of that phase; the entry point keeps one line with a link |

### Changes in the product

| # | File | Change |
|---|---|---|
| 1 | `plugin/rules.md` | R8 as above. The file goes from 492 to 499 words, with a limit of 500; what loads at session start goes from 776 to 783, with a limit of 800 |
| 2 | `plugin/skills/prepare-project/references/1-wiki.md` | The definition of "Where work stands" becomes G1; the section on `decisions.md` gains G2 and G3 |
| 3 | `plugin/skills/prepare-project/SKILL.md` | Step 5 says "rewrite", not "update", and step 6 names the check, so that it runs before a stage is closed. The body goes from 696 to 700 words, the limit |
| 4 | `plugin/skills/prepare-project/references/6-execution.md` | The three moments; the acceptance of a unit goes to the progress table; step 3 points to the rule of `write-docs` |
| 5 | `plugin/skills/write-docs/SKILL.md` | The rule above. The body goes from 584 to 653 words of 700 |
| 6 | `plugin/skills/review-change/SKILL.md` | The kind of defect above, and a sentence in step 2 that tells the reader to read the page that states what is Decided. The body goes from 457 to 494 words of 700 |
| 7 | A script in `plugin/skills/prepare-project/`, with its tests | The check |
| 8 | [style-guide.md](style-guide.md) and [rules.md](rules.md) | The two new limits, and where the new R8 comes from |

### Changes in the wikis

| Wiki | Change |
|---|---|
| playbook, the pilot | "Where work stands" goes from 1,053 words to about 123; the history of the three phases moves to their pages. The `review` agent reads the result |
| radar | From 548 words to about 70. A copy is made first, because it has no git history |
| torneo-pro, huellitas-id | They adopt the format when work on each resumes, through "Project already started" in `1-wiki.md` |

Applying the rules to a wiki moves text and does not rewrite it.

### What improves

| Improvement | Evidence |
|---|---|
| The owner's case goes from one link covered of six to five | Read in the product's text; it matches what the owner reports |
| A state section about nine times shorter | Measured by rewriting both sections |
| One row in five fewer in `decisions.md`, and shorter rows | Measured on the 132 rows of playbook |
| 0.7% to 1.3% less usage | Estimated from twelve sessions; a ceiling |

### Left out (D136)

A script that looks decisions up, an index in JSON, decisions split into files by category, a date after which a page is marked for review, and a hook that starts an agent to reorder the wiki. None pays for itself with what was measured. The lookup script is taken up again if finding decisions is still a problem after the pilot.

### Order of the work (D135)

1. The owner decides the texts on this page. Done (D138).
2. They are built in the product, on a branch, with tests. Done and merged.
3. They are applied to this wiki, the pilot. Done on 2026-11-14 with the doctor: commit `5524dba`.
4. They are applied to the wiki of radar.
5. torneo-pro and huellitas-id, when work on each resumes.

## The doctor

Now: the skill `doctor` is `migrate` (decision-index-5). It brings any older wiki straight to the present format, 6, and repairs a wiki that fails its check (decision-index-2). It keeps no reference for an older format: it reads the present `format.md` and the older wiki, rewrites it, and runs the check until it passes (decision-index-10). It runs in the agent `wiki-writer`, and only the owner starts it (decision-index-12, decision-index-13). `playbook-wiki` reads and writes only the present format, and a skill that writes a wiki stops on an older one (decision-index-2). The marker and the notice below stand, pointing to `migrate`. The rest of this section is the design as built on 2026-11-14 for format 2, kept as a record; its repair instructions and references were deleted (decision-index-10).

The owner decided that each wiki is repaired in its own project by that project's agent, guided by the product, and that a file in the wiki says whether there is anything to resolve (D139), so that nothing reads the documentation to check it all the time (D140). The owner then chose the format number and accepted the rest as proposed (D141). It is built and merged with the rest; see "Built".

### Pieces

| Piece | What it is | Status |
|---|---|---|
| Format number | A whole number kept in the product. It rises only when a change to the format of a wiki needs every wiki to do something. Format 1 is the wiki as `prepare-project` created it until 2026-11-13; format 2 is the rules of this page | Decided (D141). The other choice was the version of the plugin, which has no scheme yet (TD3, and the open question about the plugin's version in [open-questions.md](open-questions.md)) and changes with every rule or skill, whether or not a wiki must do anything |
| Marker | The file `docs/wiki/.format`: one line with the number of the format the wiki was brought to. Only the script `wiki-format.sh mark` writes it, and only when the check passes: the doctor runs it after a repair, and `prepare-project` when it creates a wiki. No wiki has it today | Decided (D139, D141, D142) |
| Notice at session start | The plugin's session-start hook compares the two numbers. It prints nothing when the project has no `docs/wiki/` or when the numbers are equal, and one line that recommends the doctor when the marker is missing or behind. It never repairs | Decided (D139, D141) |
| The doctor | A skill that only the owner starts. It runs the check, reads the repair instructions from the wiki's format to the product's, proposes the repairs to the owner, applies what the owner accepts, runs the check again, and writes the marker | Decided (D139, D141). It is a skill of its own because repairing a wiki is a job no other skill does (rule R17) |
| Repair instructions | One reference file for each step of format, read only by the doctor. For format 2: rewrite "Where work stands", move the history to the plan pages, leave the rows of `decisions.md` as they are. A wiki written before the product's format adopts it through "Project already started" | Decided (D141) |
| The count at closing | `check-wiki.sh`, when a unit or a stage is closed, as built | Decided (D140) |

### Read in Claude Code's documentation on 2026-11-14

- A skill with `disable-model-invocation: true` in its front matter: "Description not in context, full skill loads when invoked" ([skills](https://code.claude.com/docs/en/skills.md), table under "Control who invokes a skill"). So the doctor adds no words to what loads at session start, which is at 790 of 800.
- For a session-start hook, "Claude Code adds plain-text stdout as context that Claude can see and act on", and the hook's process receives `CLAUDE_PROJECT_DIR` and `CLAUDE_PLUGIN_ROOT` ([hooks](https://code.claude.com/docs/en/hooks.md)). So the notice needs no model call.
- `${CLAUDE_SKILL_DIR}` in a skill's text becomes the folder of that skill ([skills](https://code.claude.com/docs/en/skills.md)). It is not used here: opencode reads the same skill files (D108), and whether it replaces that variable is not known.

### What it changes

- In the product: the hook, the doctor skill with its repair instructions, and `scripts/verify.sh`, which today rejects a third key in a skill's front matter and counts every description toward the limit at session start.
- In the order of the work: steps 3 to 5 become one. Each wiki is repaired by the doctor in a session of its own project. This wiki is the first, and the test of the instructions.

### Not verified

- opencode: the plugin installs no hook there, so there is no notice at session start. A session of opencode with the doctor was not tried.
- The hook in a real session of Claude Code: it was run by hand with the two variables set, not by Claude Code.
- A session started in a subfolder of a project, and Windows.
- Whether a hook of a plugin can run a script of its own folder in a project the owner has not trusted.

## Built

Built on the branch `feat/wiki-maintenance`, in the worktree `~/dev/playbook-worktrees/wiki-maintenance`, on 2026-11-14, and merged into `main` the same day, when the owner said so, as a fast-forward of six commits. Pushed on 2026-11-14, and the worktree and the branch removed afterwards (D144).

### What differs from the table of changes as it was accepted

| File | Difference | Why |
|---|---|---|
| `plugin/skills/prepare-project/SKILL.md` | Step 6 names the check; the body is at 700 words, the limit | The reference file of a stage is the only one read during that stage, and the check must also run when stages 1 to 5 are closed |
| `plugin/skills/review-change/SKILL.md` | A sentence in step 2: read the page that states what is Decided | The new kind of defect cannot be looked for without reading the page |
| `plugin/skills/write-docs/SKILL.md` | The description and "When to use" name a changed definition; the description has 240 characters of 250 | Outside a unit of a plan, nothing else leads the agent from rule R8 to the rule about a changed definition |
| `plugin/skills/prepare-project/references/5-plan.md` | The progress table also holds the date and the owner's words of the acceptance | The acceptance of a unit left `decisions.md` and had no place |
| `plugin/skills/prepare-project/references/1-wiki.md` | It gives the heading of the section, `## Where work stands` | The check finds the section by its heading |
| `plugin/skills/write-skill/references/style-guide.md` | The layout of a skill lists a `scripts/` folder | The check is the first script inside a skill |

### What was run

In the worktree, after the corrections:

| Command | Result |
|---|---|
| `sh scripts/verify.sh` | "verify passed: 790 words loaded at session start, limit 800" |
| `sh scripts/verify_test.sh` | 88 cases, "all cases passed"; twenty of them test the check |
| `wc -w plugin/rules.md` | 499 |
| `check-wiki.sh docs/wiki` on this wiki | Fails: "Where work stands" has 1,140 words. No broken link |
| The same on radar | Fails: 548 words. No broken link |
| The same on torneo-pro and on huellitas-id | Passes, with the note that there is no "Where work stands" section. No broken link |

The two failures are the expected ones: they are what steps 3 and 4 of the order of the work correct.

### The doctor, as built

| File | What it holds |
|---|---|
| `plugin/skills/doctor/SKILL.md` | The skill, with `disable-model-invocation: true`: it changes only `docs/wiki/`, proposes before it changes, moves text and does not rewrite it, and never writes the marker by hand |
| `plugin/skills/doctor/references/format-2.md` | How a wiki reaches format 2 |
| `plugin/skills/doctor/scripts/wiki-format.sh` | `status` gives the notice or nothing; `hook` is `status` for the project of the session; `mark` writes `docs/wiki/.format` only when the wiki has a "Where work stands" section and the check passes. The format number, 2, is in this file and nowhere else |
| `plugin/hooks/hooks.json` | A second command at session start, `wiki-format.sh hook`. The script reads the project from the environment, so the path of the project is never part of the command |
| `scripts/verify.sh` | It accepts `disable-model-invocation: true` as the third key of a skill's front matter and does not count that skill's description toward the limit at session start |

Run in the worktree:

| Command | Result |
|---|---|
| `sh scripts/verify.sh` | "verify passed: 790 words loaded at session start, limit 800"; `claude plugin validate` accepts the new skill and the hook |
| `sh scripts/verify_test.sh` | 116 cases, "all cases passed"; 28 are for the doctor: 25 for the marker and the hook, 3 for the front matter |
| The hook's command, with the project set to this repository, to radar, and to torneo-pro | One line each: "The wiki of this project has no format marker, and the playbook is at wiki format 2. Tell the owner, and recommend running the doctor skill (/playbook:doctor). Do not repair the wiki unasked." |
| The same with a folder that has no `docs/wiki/` | Nothing, exit 0 |

Not run in the worktree: the doctor itself on a wiki. Its first run was the repair of this wiki, in a new session, because a session loads the plugin when it starts. That run, on 2026-11-14, took "Where work stands" from 1,176 words to 124, and `wiki-format.sh mark` printed "marked docs/wiki as wiki format 2": commit `5524dba`.

### The review of the doctor

The `review` agent read the doctor's commit and reported seven findings. Six are corrected:

- `mark` said it had marked a wiki when it could not write the file. It now fails.
- `mark` wrote format 2 on a wiki that had never adopted the format, because the check passes a wiki with no "Where work stands" section. It now refuses such a wiki.
- The repair instructions removed a sentence whenever `decisions.md` had a row with its number, which could lose a reason or a measurement held nowhere else. They now remove only what the row or its page already holds.
- Two rules of the skill could not both be followed in a project without git, and a marker with an unexpected content left the agent without an instruction.
- The instructions add a heading to the plan page of an earlier phase, which `1-wiki.md` forbids in general. They now say that this is the one exception.
- One test passed with the hook under the wrong event.

The seventh changed what D141 accepted, so the owner decided it (D142): nothing but the doctor wrote the marker, so a wiki that `prepare-project` creates from now on, already in format 2, would get the notice in every session. Stage 1 of `prepare-project` now runs `wiki-format.sh mark` when it has created the wiki.

The review agent also read in opencode's program that it maps `disable-model-invocation` to "autoinvoke: false", which supports leaving the doctor's description out of the count for that tool too. It was not tried in a session of opencode.

### The review

The `review` agent read the first commit and reported ten findings. Corrected: the check passed when the heading had text after its title, when it was one level smaller, or when the lines ended in a carriage return; the count stopped at a heading inside a code block and did not stop at a larger heading; a code block could be closed by the wrong marker; a wiki directory that is a link was not read; the steps named the script in a way that could not be run; the phase's page was not named; and one test passed with a broken script. The other differences in the table above come from the review too.

Left as it is, and written in the script's header: a reference-style link (`[text][id]`) is not checked, and a link whose target holds a space, a parenthesis, or a percent-encoded character is reported as broken even when the file exists. The pages of a wiki are named in lowercase with hyphens, so such a target should not appear.

`avoid-generic-design` cites R8 for "Never change the stack silently". The new R8 still covers it, because the stack is Decided, so that skill is not changed.

## Not verified

- The check on the tools of BSD or macOS. It was run with the GNU tools of this machine, and the `review` agent ran it under dash, busybox, and mawk.
- The paid evaluation of the skills, which says whether `write-docs` still loads when it should and only then, after its description changed.
- Whether opencode gives a skill the path of its own folder, as Claude Code does when it loads one (seen on 2026-11-14 with `write-docs`). Until it is tested, the check is known to work in Claude Code only.
- The sorting of the 132 rows was done by the opening words of each row, not by reading each one.
- Whether 250 words are enough for a project with several units open at once. Both sections rewritten belong to projects with no unit in progress.
- No project of the owner was searched for a concrete case of a changed definition built the old way. The six links are read from the product's text.
- Link 5: nothing here makes the next session open the page that states a definition. A definition that lives in the code, such as a shared component, is the surest form, and that is each project's choice.
