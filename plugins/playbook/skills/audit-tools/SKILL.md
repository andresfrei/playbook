---
name: audit-tools
description: Check the tools a repository has on, such as plugins, MCP servers, skills, agents, and hooks, for collisions with the playbook and its way of working with the wiki, on the owner's request. Suggests a way out for each collision and applies the owner's answer.
disable-model-invocation: true
---

## When to use

- The owner runs `/playbook:audit-tools`, such as after installing or removing a tool. The first run of `audit-wiki` does these steps too.

## Rules

- Suggest; the owner decides. Turn off or remove no tool unless the owner says so.
- Change settings for this repository only, never for the whole machine, with Claude Code's own commands and settings.
- Say nothing of a tool that does not collide, and keep no list of tools in the wiki: Claude Code knows what is on.
- Ask one question at a time, with a recommendation, then stop and wait.

## Steps

1. List what is on for this repository: the plugins, with `claude plugin list`; the MCP servers and their status, with `claude mcp list`; `.mcp.json`; the skills, agents, and hooks under `.claude/`; and the rules files of other coding tools. Leave out the playbook and what Claude Code has built in.
2. Read what each one says it does: its description, its instructions, and its hooks. A tool collides when it:
   - keeps the project's decisions or knowledge somewhere other than the wiki;
   - defines, closes, audits, or releases work in its own way, as a skill with the job of one of the playbook's;
   - gives instructions that contradict the playbook's rules or the project's;
   - asks or blocks at the same moments, such as a hook on commit or push.
3. Show a table: the tool, the quote of what it does, what of the playbook it collides with, and your suggestion: turn it off for this repository, keep both with the jobs split, or leave it. Add each server that does not connect. When nothing collides, say so in one line and stop.
4. Ask the owner about each collision, one at a time, and apply the answer. A split of jobs is a line in the project's `CLAUDE.md` and, when the project has a wiki, a decision: in the open work's `decisions.md`, or in `docs/playbook/works/audit-<date>/decisions.md` when none is open.

## Output

- The tools that collide, the suggestion and the owner's answer for each, what changed and in which file, and the servers that do not connect.
