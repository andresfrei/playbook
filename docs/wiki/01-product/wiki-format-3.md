# Wiki format 3

A proposal for the next format of a project's wiki: four changes to the format, C1 to C4, and one to the product's `review` agent, C5, that make a changed definition reach the next session through the structure of the wiki and a check, and not only through instructions. C1, C2, C3, C4a, C4b, C5, and who writes the project's instruction file are Decided, and C4c is not taken (D155 to D162). Nothing is built. The owner asked on 2026-11-15 to have it recorded as Proposed, to decide it point by point.

It continues [wiki-maintenance.md](wiki-maintenance.md), which holds the six links a changed definition needs, the rules G1 to G3, and the doctor. Read that page first for those terms.

## Where it comes from

On 2026-11-15 the owner asked whether anything from the community would improve the playbook, and its wiki above all. Four projects were looked at. The figures are from `gh repo view` on 2026-11-15. Only the README of OpenSpec was read; the others are known by their GitHub description.

| Project | Stars | Licence | What its description says |
|---|---|---|---|
| [obra/superpowers](https://github.com/obra/superpowers) | 318,076 | MIT | "An agentic skills framework & software development methodology that works." |
| [github/spec-kit](https://github.com/github/spec-kit) | 149,937 | MIT | "Toolkit to help you get started with SDD or any other process!" |
| [Fission-AI/OpenSpec](https://github.com/Fission-AI/OpenSpec) | 74,923 | MIT | "Spec-driven development (SDD) for AI coding assistants." |
| [bmad-code-org/BMAD-METHOD](https://github.com/bmad-code-org/BMAD-METHOD) | 55,402 | Other | "Breakthrough Method for Agile Ai Driven Development" |

What OpenSpec does, read in its README on 2026-11-15:

- `openspec/specs/` holds what the system does today.
- A change is a folder, `openspec/changes/<name>/`, with `proposal.md`, `specs/`, `design.md`, and `tasks.md`. Its `specs/` holds only what the change adds to the specs, under headings such as `## ADDED Requirements`.
- Archiving the change moves the folder to `openspec/changes/archive/` and updates the specs: its example prints "Specs updated."

One idea is taken from it: a change of a definition is not closed until the page that states the definition says the new one, and what is still pending is written where it is read. The rest is not taken; see "Left out".

## What was measured

### Rule G3 is not kept

G3 says that the text of a decision states the choice in at most 60 words and links to the page that holds the detail (D138). [style-guide.md](style-guide.md) says what enforces it: "Nothing".

Counted on 2026-11-15 on the 17 rows of [decisions.md](../decisions.md) written after D138, D139 to D154 and TD22. The words are the pieces of the third column separated by spaces; a link is the text `](` in that column.

| Row | Words | Link | Row | Words | Link |
|---|---|---|---|---|---|
| D139 | 53 | yes | D148 | 88 | no |
| D140 | 36 | no | D149 | 31 | no |
| D141 | 52 | yes | D150 | 112 | no |
| D142 | 54 | yes | D151 | 71 | no |
| D143 | 40 | yes | D152 | 149 | no |
| D144 | 50 | yes | D153 | 65 | no |
| D145 | 69 | no | TD22 | 117 | no |
| D146 | 92 | no | D154 | 140 | no |
| D147 | 64 | no | | | |

- 10 of the 17 rows have more than 60 words, and 12 have no link.
- The first six rows keep the limit. From D145 on, ten of eleven do not.
- D145 to D152 are about publishing the repository. The page table of [README.md](../README.md) lists no page on that topic, so each row holds its own detail.

### Link 5 is still partly covered

Link 5 is "The next session reads the definition before it builds". [wiki-maintenance.md](wiki-maintenance.md) leaves it partly covered and says, under "Not verified", that nothing makes the next session open the page that states a definition. Read on 2026-11-15:

- `plugin/skills/prepare-project/SKILL.md` and its six reference files do not name `CLAUDE.md` or `AGENTS.md` (`grep -i`, no result). So a prepared project has an instruction to read its wiki only when the owner wrote one. This repository has it, in its `CLAUDE.md`, written by hand.
- `plugin/agents/write.md` does not name the wiki.
- `plugin/rules.md` is at 499 words of 500 (`wc -w`), so the instruction does not fit there without removing something.

### The answer about the old code has no place

The rule of `write-docs` for a changed definition makes the agent ask what happens to the code that follows the old definition: "changed now, changed when it is next touched, or listed as debt". Neither that skill nor `plugin/skills/prepare-project/references/1-wiki.md` says where the answer is written or where debt is listed.

### The review has no way to find the page

Step 2 of `review-change` says "read the page that states what is Decided for the part the change touches". Nothing in a wiki says which page states what is Decided for a path, so the reader finds it by searching for words.

## The changes

Five changes. Each can be accepted, changed, or declined on its own, except that C2 needs C1. Each says its status; a change with none is Proposed.

### C1 — The page table says which code each page governs

Decided: the owner accepted it as written on 2026-11-15 (D155). Not built.

The page table of a wiki's `README.md` gains a third column, "Code it governs".

Text for the `README.md` section of `1-wiki.md`, in place of item 5:

> 5. A table of the pages: each page, what it contains, and the code it governs: the paths, from the project's root, whose behaviour the page defines. Leave the cell empty for a page that defines no code. Prefer a folder to a list of files.

An example row:

```text
| Page | Content | Code it governs |
| [01-product/filters.md](01-product/filters.md) | How the filters of a list work | `src/components/filters/` |
```

It answers "The review has no way to find the page", and it is what C2 reads.

### C2 — The page is read before the code is changed

Decided: the owner accepted the three texts as written on 2026-11-15 (D156). Not built.

Three texts.

In the project's instruction file, which every session of the project loads:

> Read `docs/wiki/README.md` first. Before you change code, read the page that its page table names for the paths you change.

In the body of `plugin/agents/write.md`:

> When the repository has `docs/wiki/`, read the page that its `README.md` names for the paths you change, before you change them.

In step 2 of `review-change`, in place of its last sentence:

> When the repository has `docs/wiki/`, find in the page table of its `README.md` the pages that govern the paths the change touches, and read them.

It answers link 5. Who writes the first text is decided under "The project's instruction file".

### C3 — The code left on the old definition is listed in the page

Decided: the owner accepted the three texts as written on 2026-11-15 (D158). Not built.

A new section of `1-wiki.md`, "A page that states a definition":

> The page says only the current definition. When the owner changes it and code stays on the old one, the page lists that code under the heading `## Code on the old definition`: one table with the path, the decision that changed the definition, and what the owner chose, "changed when next touched" or "debt". Remove a row when its code is changed, and the heading when the table is empty.

A sentence added to the rule of `write-docs` for a changed definition, after "or listed as debt.":

> List the code left on the old definition in that page, under "Code on the old definition".

A kind of defect added to `review-change`:

> a path the change touches that the wiki lists as changed when next touched, and that the change leaves on the old definition;

It answers "The answer about the old code has no place". The reason it matters: code that still shows the old way is next to the code a session is asked to change, and the page is the only place that can say which code not to follow. This reason is an argument, not a measurement.

### C4 — The check fails on two more things

C4a and C4b are Decided (D160, D161). C4c is not taken (D162). Not built.

`check-wiki.sh` today fails on two things: a "Where work stands" of more than 250 words, and a relative link that does not resolve. Three more were proposed. C4a and C4b are taken, and C4c is not:

| # | It fails when | Answers |
|---|---|---|
| C4a | A path in the column "Code it governs", or under a heading "Code on the old definition", does not exist in the project | A map that points to code that was moved or deleted |
| C4b | A row of `decisions.md` written after the wiki reached format 3 has more than 60 words of decision text | G3 is not kept |
| C4c | Such a row has no link to a page of the wiki | G3 is not kept |

- Rows written before format 3 are not checked and not changed. To tell them apart, `wiki-format.sh mark` records how many rows `decisions.md` holds when the wiki reaches format 3, in a file of its own next to `docs/wiki/.format`. This assumes that rows are only added at the end, as `1-wiki.md` implies and as this wiki does.
- Why C4c is not taken: C4b already moves the detail to a page, where the link follows; a short decision that is complete in its row, such as D149, needs no page; and a check that any link satisfies invites links that say nothing. G3 still asks for the link as a written rule. C4c can be added after the pilot, when long rows with no page keep appearing.
- The check still runs only when a unit or a stage is closed (D140).
- C4b counts the text of the decision only. The owner's words, in the last column, are not counted.
- Expected limit of C4a: a path that holds a space or an unusual character may be reported as missing, as happens today with the target of a link.

### C5 — The `review` agent loads the review skill

Decided for Claude Code only (D159). Not built. It changes the product's `review` agent, not the format of a wiki; it is here because it is what makes C2 and C3 reach every review.

The problem: rule R20 says "Have the `review` agent read it before delivery", and the agent can be called directly. The rules of a review, with the texts of C2 and C3, are in the skill `review-change`. The agent receives them only when the skill is what starts it.

The change:

- One line in the front matter of `plugin/agents/review.md`: `skills: review-change`.
- `scripts/verify.sh` accepts that key in an agent file and fails when the skill it names is not in `plugin/skills/`.

Read in Claude Code's documentation on 2026-11-15 ([sub-agents](https://code.claude.com/docs/en/sub-agents.md), the row `skills` of the front matter table): "Skills to preload into the subagent's context at startup. The full skill content is injected, not only the description." The same page lists the fields a plugin's agent does not support, `hooks`, `mcpServers`, and `permissionMode`; `skills` is not among them.

Tried on 2026-11-15 with Claude Code 2.1.325. A copy of the plugin with only this agent and this skill, renamed `pbtrial`, was loaded with `--plugin-dir` in an empty repository, with the model `haiku` for the session and the agent. A rule with a trial word was added to the copy of the skill, and the agent was asked for the word and told to answer "UNKNOWN" when it had none.

| What was run | Result |
|---|---|
| The agent called directly, with no `skills` key, as it is today | "UNKNOWN": the agent does not receive the skill |
| The same with `skills: review-change` | The trial word |
| The same with `skills: pbtrial:review-change`, the name with the plugin's prefix | The trial word |
| The skill invoked, which starts the same agent, with and without the key | The trial word both times. The skill naming the agent and the agent naming the skill cause no error |
| `skills: no-such-skill` | "UNKNOWN", with no error or warning. This is why `verify.sh` checks the name |
| `claude plugin validate` on the copy with the key | "Validation passed" |

Not taken: one sentence about the wiki repeated in the body of the agent. It keeps one rule in two places, and a review called directly would still lack the other rules of the skill.

opencode: nothing changes there, and the gap stays. The fields `scripts/verify.sh` allows in `opencode/agents/` do not include `skills`, and the body of the agent, which is what the two tools share, does not change. The owner is not using opencode for now (D159). At build, check that `scripts/set-models.sh` does not copy the new key into `opencode/agents/review.md`.

### Changes in the product

| # | File | Change | Words |
|---|---|---|---|
| 1 | `plugin/skills/prepare-project/references/1-wiki.md` | Item 5 of C1, the section of C3, and the step that D157 adds to stage 1 | 1,118 today; a reference file has no limit |
| 2 | `plugin/skills/prepare-project/scripts/check-wiki.sh`, with its tests in `scripts/verify_test.sh` | C4 | |
| 3 | `plugin/skills/write-docs/SKILL.md` | The sentence of C3 | Body from 673 to 690, limit 700 |
| 4 | `plugin/skills/review-change/SKILL.md` | The sentence of C2 and the kind of defect of C3 | Body from 494 to 523, limit 700 |
| 5 | `plugin/agents/write.md` | The sentence of C2 | 21 words more; the file has 100 with its front matter, and a body stays "under about 150 words" ([style-guide.md](style-guide.md)) |
| 6 | `plugin/skills/doctor/` | The format number becomes 3 in `scripts/wiki-format.sh`, which also records the count of rows; a new `references/format-3.md`; one line in the list of references of `SKILL.md` | |
| 7 | [style-guide.md](style-guide.md) | What enforces the limit of 60 words, and the `skills` key in the format of an agent file | |
| 8 | `plugin/agents/review.md` | The line `skills: review-change` (C5) | The body and the description do not change |
| 9 | `scripts/verify.sh`, with its tests in `scripts/verify_test.sh` | It accepts the `skills` key of an agent and fails when the skill named does not exist (C5) | |

Nothing changes in `plugin/rules.md` or in a description, so what loads at session start stays at 790 words of 800 (`sh scripts/verify.sh` on 2026-11-15: "verify passed: 790 words loaded at session start, limit 800"). The body of `prepare-project/SKILL.md` is at its limit, 700 words, and is not changed.

### The doctor

No new doctor is needed. The one built for format 2 (D139, D141) does one format at a time from a file of repair instructions, and the notice at session start appears by itself in every project whose marker is behind.

What `references/format-3.md` would hold:

1. For each page of the page table, propose the paths it governs, read from the repository. The owner accepts or corrects them. Write the column.
2. Ask the owner whether a definition changed in the past left code on the old one. Write what the owner names, as C3 says. Do not search the code for it.
3. Write the two sentences of C2 in the project's instruction file, as "The project's instruction file" says.
4. Run `wiki-format.sh mark`, which records the count of rows and writes the marker when the check passes.

The repair adds text and moves none. No row of `decisions.md` changes.

A wiki at format 1 does format 2 and then format 3 in the same run. A wiki written before `prepare-project` existed still adopts the format through "Project already started", as `format-2.md` says.

### What it would improve

| Improvement | Evidence |
|---|---|
| Link 5 goes from partly covered to covered: a session is told to read the page, and the page table says which one | Read in the product's text. Not tried in a session |
| The owner's answer about the old code is written where the next session reads it | Read in the product's text: today it has no place |
| The review finds the page by looking it up | Read in `review-change` |
| The limit of 60 words of G3 is kept from format 3 on | Measured: 10 of the last 17 rows are over the limit |
| A review that rule R20 asks for follows the rules of `review-change` | Tried: without C5 the agent called directly does not receive the skill |

It does not reduce usage. Reading the wiki is about 1.7% of the usage, and everything in [wiki-maintenance.md](wiki-maintenance.md) saves between 0.7% and 1.3%.

### Left out

| What | Why |
|---|---|
| A folder for each change, with a proposal, a design, and a list of tasks, as OpenSpec has | A plan with units and its progress table already does that job (stage 5 and stage 6 of `prepare-project`) |
| Requirements written as "SHALL" with scenarios | The format of a product page is the owner's and is not in question |
| Installing OpenSpec, Spec Kit, Superpowers, or BMAD-METHOD | Each brings its own method, which would cover the same jobs as the product's skills (D6) |
| What D136 left out | Nothing measured here changes that |
| C4c, a check that the row of every new decision has a link | D162; the reasons are under C4 |
| A fork of Engram, which the owner raised on 2026-11-15 | Not proposed. The product keeps Engram (D25). Memory is not where the measured problem is: the links that fail are in the wiki. A fork is a second product to maintain, a Go program with its own releases |

### Order of the work

Decided (D163): the same order as D135.

1. The owner decides the changes and Q52. Done (D155 to D162).
2. They are built in the product, on the branch `feat/wiki-format-3`, with tests. The `review` agent reads the build before the owner does, and nothing is pushed until the owner asks.
3. This wiki is the pilot, repaired with the doctor.
4. radar, then torneo-pro and huellitas-id when work on each resumes.

## The project's instruction file

Decided: D157, which answers Q52. Not built.

- `prepare-project` writes the two sentences of the first text of C2, in stage 1 and after asking the owner, because the file is outside `docs/wiki/`.
- It writes them in `CLAUDE.md`. It writes them in `AGENTS.md` too only when the owner says the project is used with opencode, which reads `AGENTS.md` only ([03-technology/phase-3.md](../03-technology/phase-3.md)).
- It creates the file when it is missing. In a file that exists it adds the two sentences and changes nothing else.
- In a project that already has a wiki, the doctor does the same when it brings the wiki to format 3.
- The text goes in `1-wiki.md`, because the body of `prepare-project/SKILL.md` is at its limit.

Not taken: the owner writing the sentences by hand in each project, which depends on remembering it.

## Not verified

- No session was run with any of this. That a session told to read the page does read it, and builds the new way, is not shown.
- No project of the owner was searched for a real case of a changed definition built the old way. This is still as [wiki-maintenance.md](wiki-maintenance.md) left it.
- That an agent follows nearby code over a page it did not read is the argument for C3. It was not measured.
- The READMEs of Superpowers, Spec Kit, and BMAD-METHOD were not read. Articles that compare them were seen only as search summaries and are not used as evidence here.
- OpenSpec was read, not installed or run.
- C5 was tried with the model `haiku` and a question, not with the agent's own model and effort on a real review.
- Whether the skill's text is loaded twice when the skill starts the agent, once as the task and once preloaded. The body of the skill has 494 words.
- C5 in opencode, where it is not applied.
- The words of the 17 rows were counted by splitting the third column at spaces. A row whose text holds the character `|` would be counted wrong; none was seen.
- Whether rows of `decisions.md` are only ever added at the end in the wikis of radar, torneo-pro, and huellitas-id. C4b depends on it.
- How the check tells a path from other code text in a table cell is a detail of the build, not designed here.
