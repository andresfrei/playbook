# Spec of the work dialog-learning

Status: Accepted (dialog-learning-6)

Delivery: one branch and one pull request per work (delivery-versioning-2).

## What and why

The agent asks the owner hundreds of questions, and nothing learns from the answers. `audit-learning` reads only `decisions.md`, and going ahead with a step is not a decision (R7), so the answers that repeat most never reach it; its criterion, the same thing in two different works (cross-work-learning-5), does not fit them either, as they repeat inside one work and across projects. The work session-driver-12 of the playbot repository left this to playbook.

Measured on 2026-11-27 over the 958 answered dialogs of three projects (lexicon, viba, playbook):

- The owner took the recommended option in 86%, and between 77% and 97% in twelve of fourteen types. That share alone does not say what can be delegated: "what the product does" had 87% and "close here and go on in a clean session" 97%, but the first is 252 different questions and the second is one question asked 100 times.
- What teaches is the 14% that departed. Of the 57 answers in the owner's own words, 32 were an idea that was not among the options, 11 a fact the agent did not have, 6 a question back, 5 a correction of form, and 3 a request to think more. The version number took the recommended option 13 times of 21: there the recommendation needs a better criterion, not a delegation.
- The dialog's header is free text: 590 distinct headers in 958 dialogs, and the same question came out as "Sesión", "Siguiente", and "Seguir". Classifying them took a reader.

- Decided (dialog-learning-1): every question dialog names its type in its `header`, and `audit-learning` reads the owner's answers by type, above all the ones that departed from the recommendation.
- Decided (dialog-learning-3): the type is one of fourteen fixed English words, copied as they are whatever the reply language: Session, Accept, Delivery, Load, Record, Finding, Remote, Setup, Product, Technical, Design, Scope, Problem, Clarify. The question and its options stay in the owner's language.
- Decided (dialog-learning-2): the plugin keeps one line per answered dialog in its data folder on the owner's machine, outside every repository. A hook writes it when the owner answers; the agent never writes it during a work, and it has no levels, thresholds, or columns in the wiki. The dialogs answered before the hook existed are imported once from Claude Code's transcripts.
- Decided (dialog-learning-4): a delegation may also be a line of `~/.claude/CLAUDE.md`, for every project of the owner; `audit-learning` proposes it there when the same answer repeats across projects.
- Decided (dialog-learning-5): this work covers a session with a person at the terminal; a session driven by another one is the work `driven-mode`.
- Decided (dialog-learning-6): `audit-learning` keeps its trigger, offered by `close` when a whole work closes or started by the owner (cross-work-learning-4), and adds a second reading after the works: the answered dialogs. It shows one table by type: times asked, share that took the first option, which R3 makes the recommended one, and in how many projects. The table counts every project on the machine; the departures it lists are those of the project it runs in.
- Decided (dialog-learning-6): no number decides (cross-work-learning-10). `audit-learning` proposes a delegation for a type only when its questions are one question asked again and again, the first option was taken almost every time, and a wrong answer is undone by git (light, R18). It never proposes one for Delivery or Remote, which a hook asks anyway (R14, R24). The table shows the counts and the owner decides.
- Decided (dialog-learning-6): what a departure becomes. A fact the agent did not have: a line for the project's wiki or its `CLAUDE.md`. A recommendation that missed more than once on the same question: a correction of the rule or the skill that makes it. An idea of the owner that was not among the options: nothing to write; the table shows how many there were, as the sign that questions came before the picture was shared.
- Decided (dialog-learning-6): the first run. When the history was never imported, `audit-learning` imports it before reading. A line whose header is not one of the fourteen words, which is all the history and later any dialog that broke the rule, is classified before the table by reading, one subagent per batch of 300, never by keywords (dialog-learning-7); the share of such lines among the new ones says whether the rule holds.
- Decided (dialog-learning-6): the lines hold the text of questions and answers of every project, so they stay on the machine and no skill copies them into a repository. Uninstalling the plugin deletes its data folder unless the owner passes `--keep-data` (plugins-reference.md); the plugin's README says so.

## Out of scope

- Answering a dialog in the owner's place. A `PreToolUse` hook can do it ("supply it via `updatedInput` to answer programmatically", hooks.md); that belongs to playbot's bots.
- Changing ask-to-clear-1 by hand. If the first run proposes the delegation for Session and the owner accepts it, that is its own decision then.
- A hook that types "seguí" after `/clear`: `SessionStart` fires on `clear`, but supplying the first message is documented for `-p` runs only.
- A session driven by another session, such as a bot of playbot, which cannot open a dialog and asks in text: the work `driven-mode`, defined after this one (dialog-learning-5). Until it is built, the hook sees only the dialog that playbot relays to the owner, and counts it under playbot's folder.
- Questions asked in text, with no dialog (R3): the hook does not see them.
- Charts, trends over time, or any count kept apart from the lines themselves.

## Technology

Pages of Claude Code's documentation read on 2026-11-27, from `https://code.claude.com/docs/en/`.

| Need | Technology | Why |
|------|------------|-----|
| Know each answer when it is given | A `PostToolUse` hook with the matcher `AskUserQuestion` | hooks.md: `PostToolUse` "Matches on tool name, same values as PreToolUse", which lists `AskUserQuestion`; its input "includes both `tool_input`, the arguments sent to the tool, and `tool_response`, the result it returned" |
| Keep the lines | `${CLAUDE_PLUGIN_DATA}`, already used by `session-start.sh` | plugins-reference.md: "`~/.claude/plugins/data/<id>/`, created on first reference and kept across plugin updates" |
| The answers given before the hook | Claude Code's transcripts, read once | sessions.md: "The entry format is internal to Claude Code and changes between versions, so scripts that parse these files directly can break on any release"; so the import runs once, says so when it finds transcripts and no dialog, and nothing else reads them |
| Read the lines | `jq`, in the script the skill runs | Already the plugin's tool for its skills (presets-6); without it the skill says so and reads only the works |

- Decided (dialog-learning-6): the hook stores its input as it arrives, with the time, and parses nothing. It needs no `jq`, so hooks stay plain shell (audit-2026-11-25-1), and it does not depend on a shape the documentation leaves open.
- Seen in the live check of the unit capture, on 2026-11-27: `tool_response` for `AskUserQuestion` holds `questions` (each with `question`, `header`, `options` with `label` and `description`, and `multiSelect`), `answers` (an object from each question's text to the label chosen), and `annotations`; `tool_input` holds the same `answers` and `annotations`. hooks.md says only that "The exact schema for both depends on the tool", so the table reads `answers` and treats the shape as subject to change.

Skills: none needed; hooks and shell scripts are already this repository's technology.

## Check

On the owner's machine, with the plugin loaded from this branch: the owner answers a dialog and its line is in the data folder. `/playbook:audit-learning` imports the history, classifies it, and shows the table by type with the departures of this project. It proposes the delegation for Session at the owner's level, with its counts, and proposes none for Delivery or Remote. A second run imports nothing again. Every test passes, and `rules.md` with this repository's README stays under 9,000 characters.

## Units

Each unit fits one short session and has its own check. `rules` changes no file that `capture` changes, and neither uses what the other builds.

| Unit | What it delivers | Check | Status |
|------|------------------|-------|--------|
| capture | A hook writes one line per answered dialog in the plugin's data folder (dialog-learning-2). | Offline: a fixture of the hook's input gives one line with the time in a temporary data folder; with no data folder it writes nothing; it always exits 0, so it never blocks an answer. Live: in a session started with `--plugin-dir`, the owner answers one dialog and the line holds its header, its options, and the answer; the spec's Open line is closed with what was seen. | Done |
| rules | R3, and the four skills that repeat it, say the header is the question's type and list the fourteen words (dialog-learning-3); R6 names `~/.claude/CLAUDE.md` (dialog-learning-4). | Offline: the sentence is the same in `rules.md`, `define`, `close`, `audit`, and `audit-learning`; the tests of the hooks and of the reference pass with the 9,000 budget. | Done |
| import | A script imports once the answered dialogs of Claude Code's transcripts into the same file (dialog-learning-2). | Offline: fixture transcripts give their lines; a second run adds none; transcripts with no dialog in them end with a message that names the format, not with an empty success. | Done |
| table | A script reads the lines of both origins and prints the table by type and the departures of one project. | Offline: a fixture with lines of the hook and of the import gives the counts by type, the share that took the first option, the number of projects, the lines with a header outside the list as untyped, and the departures with the question, the options, and the answer. | Done |
| learn | `audit-learning` imports on its first run, has untyped lines classified, shows the table, and proposes as the three Proposed lines say; the plugin's README says where the lines live. | Live: the work's check above. | Done |
