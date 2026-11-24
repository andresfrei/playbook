---
name: audit
description: Audit what sets up Claude in a project, on the owner's request. On its first run it adopts the project. Then `auditor` agents read the wiki against the code, what loads into context against the documentation's limits, and the tools for collisions; one table of findings follows, for the owner to resolve. Argument: wiki, setup, or tools runs that part alone; none runs all.
argument-hint: "[wiki|setup|tools]"
---

## When to use

- The owner runs `/playbook:audit` or asks for an audit, or says yes when you offer one: when the session start recommends it, before a release, when `close` suggests it, or after installing or removing a tool (agent-runs-skills-1).
- The argument picks the parts (one-audit-9): `wiki`, `setup`, or `tools` runs that part alone, with one explorer; with no argument, run all three.

## Rules

- Explore first, propose after (one-audit-6). The explorers are read-only; the owner is asked only when all of them have ended.
- Change nothing tied to a finding until the owner resolves it. Fix what the check lists when it is light, such as a broken link, and, when the wiki part ran, write the line "Last audit" without asking.
- The wiki part reports only contradictions: a statement of a shared page that the code, another page, or a newer decision says otherwise. Skip style and wording. The setup part also reports the limits of the documentation that a piece passes, and proposals to load content on demand.
- Quote both sides with file and line. Say when a side is inferred rather than read.
- Suggest; the owner decides. Turn off or remove no tool unless the owner says so.
- What belongs to the project changes on the owner's yes, with Claude Code's own commands and settings. The level of a piece is the one `startup-context.sh` gives: the project's `MEMORY.md` belongs to the project, though it lives under `~/.claude/projects/`. What belongs to the user's level, such as `~/.claude/CLAUDE.md` or `~/.claude/skills/`, is checked and proposed for, and changed only when the owner asks for it explicitly (one-audit-5).
- Say nothing of a tool that does not collide, and keep no list of tools in the wiki: Claude Code knows what is on.
- Ask one question at a time, with a recommendation, then stop and wait. Ask it with `AskUserQuestion` when available, one question per dialog, recommended option first; ask in text a question that has no options to offer.

## Steps

1. **First run.** When `docs/playbook/README.md` is missing, or has no line that starts with `Last audit:`, read [first-run.md](first-run.md) and do its steps first, in the main session, before any explorer. It writes files, so no explorer does it. After it, go on with step 2 for all three parts, whatever the argument, so that the adoption leaves the tools in order too (one-audit-11).
2. **Explore.** Launch the `auditor` agent for each part chosen (one-audit-8): with no argument, the three in ONE message (wiki, setup, tools); with an argument, only that one. Each brief names the part, copies its steps from the part below, and asks for findings in this form: a finding between two sources with both quotes, each with file and line; a finding of one source with its quote, file and line, and the number or the limit. The brief of the setup explorer also asks it to return the table of `/context` verbatim, apart from the findings: it is not a finding. Wait until all of them have ended.
3. **Cross.** Join the findings, remove duplicates, and keep the rest. For each finding, search `docs/playbook/works/*/decisions.md` for a decision that already resolves it; the explorers do not read decisions, the main session crosses. When its quote is the same, the finding stays in the one table with "Already decided: <ID>" and is not asked; when the quote changed, it is a new finding (audit-decided-1). When an explorer failed, say so, go on with the others' findings, and offer to run that part again.
4. **Show.** One table with every finding: the part, the quote or quotes with file and line, the number or the limit, and your recommendation. Say why a finding is dropped; hide none. A finding marked "Already decided" is shown, not asked. When nothing was found, say so in one line. After the table, when the setup part ran, show its table of categories from `/context`; when the setup part did not run, or its `/context` failed, advise the owner to run `/context` (context-measure-1).
5. **Ask.** Resolve each finding with the owner, one at a time, as the part says. Skip those marked "Already decided". When the owner leaves a finding as it is, record it as a decision: in the open work's `decisions.md`, or in `docs/playbook/works/audit-<date>/decisions.md` when none is open; the decision quotes the finding with its file, as the explorer gave it (audit-decided-1).
6. **Apply.** Make the light fixes, and the changes the owner said yes to. When the wiki part ran (no argument, `wiki`, or a first run), write in `docs/playbook/README.md` one line that starts with `Last audit:`, as `Last audit: <date>, after work <last closed work>. Contradictions: <found>, <resolved>.`, replacing the previous one, without asking. Run `sh "${CLAUDE_PLUGIN_ROOT}/scripts/check-wiki.sh" docs/playbook` again.

## Wiki part

The explorer:

1. Runs `sh "${CLAUDE_PLUGIN_ROOT}/scripts/check-wiki.sh" docs/playbook` and lists what it reports; it fixes nothing.
2. For each shared page (`docs/playbook/*.md`), reads each statement and checks it against the code: versions against the manifests, rules of the product against the behaviour, technology against the dependencies. Checks it also against the other pages and the newest decision on the same subject.
3. **Definitions.** Checks that the wiki defines each item below, in `docs/playbook/README.md`, `product.md`, `technology.md`, or the line `Checks` of the project's `CLAUDE.md`. Reports each item missing. An item marked Open on its page is not reported (delivery-versioning-1, -3, session-cost-7):
   - the product and its owner;
   - the technology and its versions;
   - how a change is checked;
   - the versioning policy: the line `Versioning:` of `technology.md`;
   - the default way of delivery: the line `Delivery default:` of `technology.md`.

   An item stays on this list only while a skill of the playbook reads it.

The main session, after the table, in step 5:

- For a missing definition, proposes to define it, one at a time; the owner may leave it Open, marked Open on its page.
- For each contradiction, asks the owner to resolve it, one at a time:
  - The code is right: record the owner's answer as a decision, in the open work's `decisions.md` or, when none is open, in `docs/playbook/works/audit-<date>/decisions.md`. In the same edit, update the page, write "Replaced by <ID>" at the start of the old decision's cell, and move the page's citation to the new ID.
  - The wiki is right: the code has a bug; propose the fix, to be built as any change.
  - Not known: mark the statement Open on the page.
- When a kind of contradiction was found before, such as a version bumped without `technology.md`, proposes the line that prevents it, as `close` does in its learning step.

## Setup part

The explorer runs `sh "${CLAUDE_PLUGIN_ROOT}/scripts/startup-context.sh"` in the project and reads the files it lists. It also runs `claude -p "/skill-doctor"` in the project, a command that reads, and reports the skills the report flags as loaded but never used, with no threshold of its own (one-audit-3). It also runs `claude -p "/context"` in the project, a command that reads, and returns its table of categories (system prompt, tools, MCP, custom agents, memory files, skills) and its lists of memory files, skills, and custom agents with their tokens. These numbers are not findings: no threshold of its own (one-audit-3, context-measure-1). Each finding says the level the script's table gives its piece: project, user, or plugin. For each piece it reports (one-audit-3, one-audit-5):

1. **Collisions between pieces**, with both quotes: an instruction that another file negates, a generated file whose source no longer exists, two memory lines that each say they are read first.
2. **A limit of the documentation passed**, with the number: 200 lines per `CLAUDE.md`, 200 lines or 25KB of `MEMORY.md`, the session-start hook's budget. The playbook sets no threshold of its own.
3. **Content that applies only sometimes**, with a proposal of the documentation's way to load it on demand: a skill, `paths:` in a rule, a `CLAUDE.md` in a subfolder, or a memory topic file.
4. **Skills never used**, one finding per source of the report that has them (claude.ai sync, user, project, plugin), each listing the skills, their context cost, and the report's verdict line as the quote. The level follows the source: a plugin's skills are plugin, a project's are project, the rest are user (skill-usage-1, skill-usage-2).

When either report fails (`/skill-doctor` or `/context`), such as on Claude Code before v2.1.252 or in a session that skips feature flags, the explorer says so and the part goes on.

These are not findings: a `[[link]]` in a memory file that matches no file (memory allows it), and an instruction of the project's `CLAUDE.md` that differs from a rule of the plugin when it is a delegation, as R6 says, since the project's rules win (audit-decided-1).

The main session asks about each finding, one at a time, and applies the answer: a piece of the project changes on the owner's yes; a piece of the user's level is proposed for and changed only when the owner asks for it explicitly.

For skills never used of the user, the project, or claude.ai sync, it proposes hiding them from this project's listing with the menu `/skills`, which writes `skillOverrides` to `.claude/settings.local.json`; the state `user-invocable-only` takes a skill out of the listing and keeps `/name`. For a plugin's skill it proposes `/plugin`, since plugin skills are not affected by `skillOverrides`. One finding at a time: hide all, pick which, or leave them; a "leave it" is recorded like any other (audit-decided-1).

## Tools part

The explorer:

1. Lists what is on for this repository: the plugins, with `claude plugin list`; the MCP servers and their status, with `claude mcp list`; `.mcp.json`; the skills, agents, and hooks under `.claude/`; and the rules files of other coding tools. Leaves out the playbook and what Claude Code has built in.
2. Reads what each one says it does: its description, its instructions, and its hooks. A tool collides when it:
   - keeps the project's decisions or knowledge somewhere other than the wiki;
   - defines, closes, audits, or releases work in its own way, as a skill with the job of one of the playbook's;
   - gives instructions that contradict the playbook's rules or the project's;
   - asks or blocks at the same moments, such as a hook on commit or push.
3. Reports each collision with the quote of what the tool does, what of the playbook it collides with, and a suggestion: turn it off for this repository, keep both with the jobs split, or leave it. Reports each server that does not connect.

The main session asks the owner about each collision, one at a time, and applies the answer. A split of jobs is a line in the project's `CLAUDE.md` and, when the project has a wiki, a decision: in the open work's `decisions.md`, or in `docs/playbook/works/audit-<date>/decisions.md` when none is open.

## Output

- The check's result, the one table of findings (contradictions, definitions missing, limits passed, on-demand proposals, skills never used, tools that collide, servers that do not connect), a note for each part that failed, how the owner resolved each, what changed and in which file, the lines proposed, and the line "Last audit".
- The table of categories from `/context` when the setup part ran; otherwise the advice to run `/context`.
