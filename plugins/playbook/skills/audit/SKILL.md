---
name: audit
description: Audit the project's wiki against itself, the code, and the tools the repository has on, on the owner's request; on its first run, adopt the project by building the playbook's wiki and rules from the knowledge it already holds. Reports each contradiction with both quotes for the owner to resolve.
disable-model-invocation: true
---

## When to use

- The owner runs `/playbook:audit`, such as when the session start recommends it, before a release, or when `close` suggests it.

## Rules

- Change nothing tied to a contradiction until the owner resolves it. Fix what the check lists when it is light, such as a broken link, and write the line "Last audit" without asking.
- Report only contradictions: a statement of a shared page that the code, another page, or a newer decision says otherwise. Skip style and wording.
- Quote both sides with file and line. Say when a side is inferred rather than read.
- Ask one question at a time, with a recommendation, then stop and wait.
- The owner decides which tools the repository uses. Turn off or remove none unless the owner asks, and name in the wiki only tools the repository has.

## Steps

0. When `docs/playbook/README.md` is missing, or has no line that starts with `Last audit:`, this is the first run: read [first-run.md](first-run.md) and do its steps first.
1. Run `sh "${CLAUDE_PLUGIN_ROOT}/scripts/check-wiki.sh" docs/playbook`. Fix what is light, such as a broken link, and list the rest.
2. For each shared page (`docs/playbook/*.md`), read each statement and check it against the code: versions against the manifests, rules of the product against the behaviour, technology against the dependencies. Check it also against the other pages and the newest decision on the same subject.
3. Check the tools. List what is on for this repository: the plugins, with `claude plugin list`; the MCP servers and their status, with `claude mcp list`; `.mcp.json`; and the skills and agents under `.claude/`. Leave out the playbook and what Claude Code has built in. Compare the list with `docs/playbook/skills.md`, which says what the agent uses for each job:
   - A tool that is on and the page does not name: ask whether the repository uses it. On a yes, add a row: the job, the tool, and when to use it. On a no, leave it out and offer to turn it off for this repository only: a plugin with `claude plugin disable <name>@<marketplace> --scope local`, a skill with `"<name>": "off"` under `skillOverrides` in `.claude/settings.local.json`, an MCP server by the owner in `/mcp`.
   - A tool the page names that is missing, or a server that does not connect: a contradiction; quote the row and the status.
   - Two tools the page gives the same job: ask which does what.

   Recommend as Claude Code's documentation does: a command-line tool before an MCP server for the same job; a server nobody uses turned off, since it adds its tool names to every session; a tool every person on the project needs at project scope, in `.mcp.json` or installed with `--scope project`.
4. Show a table: the page's quote, the other side's quote, and your recommendation.
5. Ask the owner to resolve each contradiction, one at a time:
   - The code is right: record the owner's answer as a decision, in the open work's `decisions.md` or, when none is open, in `docs/playbook/works/audit-<date>/decisions.md`. In the same edit, update the page, write "Replaced by <ID>" at the start of the old decision's cell, and move the page's citation to the new ID.
   - The wiki is right: the code has a bug; propose the fix, to be built as any change.
   - Not known: mark the statement Open on the page.
6. When a kind of contradiction was found before, such as a version bumped without `technology.md`, propose the line that prevents it, as `close` does in its learning step.
7. Write in `docs/playbook/README.md` one line that starts with `Last audit:`, as `Last audit: <date>, after work <last closed work>. Contradictions: <found>, <resolved>.`, replacing the previous one, without asking. Run the check again.

## Output

- The check's result, the tools found and what the owner decided for each, the table of contradictions, how the owner resolved each, the lines proposed, and the line "Last audit".
