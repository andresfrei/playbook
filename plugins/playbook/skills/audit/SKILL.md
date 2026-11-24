---
name: audit
description: Audit what sets up Claude in a project, on the owner's request. The wiki part reads the wiki against itself and the code and, on its first run, adopts the project by building the playbook's wiki and rules from the knowledge it already holds; the setup part checks what loads into context; the tools part checks the plugins, MCP servers, skills, agents, and hooks for collisions with the playbook. Reports each finding with its quotes for the owner to resolve. Argument: wiki, setup, or tools runs that part alone; none runs all.
argument-hint: "[wiki|setup|tools]"
---

## When to use

- The owner runs `/playbook:audit` or asks for an audit, or says yes when you offer one: when the session start recommends it, before a release, when `close` suggests it, or after installing or removing a tool (agent-runs-skills-1).
- The argument picks the parts (one-audit-9): `wiki`, `setup`, or `tools` runs that part alone; with no argument, run all the parts, in that order.

## Rules

- Change nothing tied to a contradiction until the owner resolves it. Fix what the check lists when it is light, such as a broken link, and write the line "Last audit" without asking.
- Report only contradictions: a statement of a shared page that the code, another page, or a newer decision says otherwise. Skip style and wording.
- Quote both sides with file and line. Say when a side is inferred rather than read.
- Suggest; the owner decides. Turn off or remove no tool unless the owner says so.
- What belongs to the project changes on the owner's yes, with Claude Code's own commands and settings. What belongs to the user's level, such as `~/.claude/`, is checked and proposed for, and changed only when the owner asks for it explicitly (one-audit-5).
- Say nothing of a tool that does not collide, and keep no list of tools in the wiki: Claude Code knows what is on.
- Ask one question at a time, with a recommendation, then stop and wait. Ask it with `AskUserQuestion` when available, one question per dialog, recommended option first; ask in text a question that has no options to offer.

## Wiki part

0. When `docs/playbook/README.md` is missing, or has no line that starts with `Last audit:`, this is the first run: read [first-run.md](first-run.md) and do its steps first.
1. Run `sh "${CLAUDE_PLUGIN_ROOT}/scripts/check-wiki.sh" docs/playbook`. Fix what is light, such as a broken link, and list the rest.
2. For each shared page (`docs/playbook/*.md`), read each statement and check it against the code: versions against the manifests, rules of the product against the behaviour, technology against the dependencies. Check it also against the other pages and the newest decision on the same subject.
3. **Definitions.** Check that the wiki defines each item below, in `docs/playbook/README.md`, `product.md`, `technology.md`, or the line `Checks` of the project's `CLAUDE.md`. Report each item missing with a proposal to define it, one at a time; the owner may leave it Open, marked Open on its page, and then it is not reported again (delivery-versioning-1, -3, session-cost-7):
   - the product and its owner;
   - the technology and its versions;
   - how a change is checked;
   - the versioning policy: the line `Versioning:` of `technology.md`;
   - the default way of delivery: the line `Delivery default:` of `technology.md`.

   An item stays on this list only while a skill of the playbook reads it.
4. Show a table: the page's quote, the other side's quote, and your recommendation.
5. Ask the owner to resolve each contradiction, one at a time:
   - The code is right: record the owner's answer as a decision, in the open work's `decisions.md` or, when none is open, in `docs/playbook/works/audit-<date>/decisions.md`. In the same edit, update the page, write "Replaced by <ID>" at the start of the old decision's cell, and move the page's citation to the new ID.
   - The wiki is right: the code has a bug; propose the fix, to be built as any change.
   - Not known: mark the statement Open on the page.
6. When a kind of contradiction was found before, such as a version bumped without `technology.md`, propose the line that prevents it, as `close` does in its learning step.
7. Write in `docs/playbook/README.md` one line that starts with `Last audit:`, as `Last audit: <date>, after work <last closed work>. Contradictions: <found>, <resolved>.`, replacing the previous one, without asking. Run the check again.
8. On the first run, do the steps of the tools part below, so that the adoption leaves the tools in order too.

## Setup part

Not built yet (one-audit U3). Placeholder: when the owner asks for this part, say so in one line and go on with the other parts.

## Tools part

1. List what is on for this repository: the plugins, with `claude plugin list`; the MCP servers and their status, with `claude mcp list`; `.mcp.json`; the skills, agents, and hooks under `.claude/`; and the rules files of other coding tools. Leave out the playbook and what Claude Code has built in.
2. Read what each one says it does: its description, its instructions, and its hooks. A tool collides when it:
   - keeps the project's decisions or knowledge somewhere other than the wiki;
   - defines, closes, audits, or releases work in its own way, as a skill with the job of one of the playbook's;
   - gives instructions that contradict the playbook's rules or the project's;
   - asks or blocks at the same moments, such as a hook on commit or push.
3. Show a table: the tool, the quote of what it does, what of the playbook it collides with, and your suggestion: turn it off for this repository, keep both with the jobs split, or leave it. Add each server that does not connect. When nothing collides, say so in one line and stop.
4. Ask the owner about each collision, one at a time, and apply the answer. A split of jobs is a line in the project's `CLAUDE.md` and, when the project has a wiki, a decision: in the open work's `decisions.md`, or in `docs/playbook/works/audit-<date>/decisions.md` when none is open.

## Output

- The check's result, the table of contradictions, the definitions missing, how the owner resolved each, the lines proposed, and the line "Last audit".
- The tools that collide, the suggestion and the owner's answer for each, what changed and in which file, and the servers that do not connect.
