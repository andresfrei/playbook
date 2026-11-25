---
name: permissions
description: A wizard that asks the owner, one question at a time, about attribution and allow, ask, and deny permission rules, and writes the accepted ones into Claude Code's settings.
---

## When to use

- The owner runs `/playbook:permissions` or asks for it, or says yes when `audit` offers it once on adopting a project (permissions-wizard-4). Never by itself.

## Steps

0. Check `jq` is on PATH (`command -v jq`). When it is missing, say so and stop, writing nothing.
1. Ask four questions in order: attribution, allow, ask, deny. Each is ONE question with AskUserQuestion, the recommended option first. Before each, show what the target file already holds (read `~/.claude/settings.json` for attribution, the project's `.claude/settings.json` for rules), and propose only what is missing. When nothing is missing, skip the question and say so.
   - **Attribution.** Commits and pull requests apart. Both off is `none`; only one is `commit` or `pr`.
   - **Allow.** Narrow rules from the project's files (`package.json` scripts, `Makefile` targets, test scripts) and the checks in its `CLAUDE.md`, such as `Bash(npm run test)` or `Bash(sh tests/foo_test.sh)`. Never bare `Bash` or `Bash(*)`.
   - **Ask.** `Bash(git reset --hard*)`, `Bash(git clean *)`, `Bash(rm -rf *)`, `Bash(rm -fr *)`, and the forced push variants `Bash(git push -f*)`, `Bash(git push * -f*)`, `Bash(git push *--force*)`.
   - **Deny.** `Read(./.env)`, `Read(./.env.*)`, `Read(./secrets/**)`, and the `Edit(...)` rules for the same paths; key files such as `*.pem` or `*.key` only when the project has them. Keep it that narrow.
2. Before writing, show each line and the file it goes to (permissions-wizard-3). Write only what the owner accepted, with `sh "${CLAUDE_PLUGIN_ROOT}/scripts/settings-write.sh"`:
   - Rules, to the project's `.claude/settings.json`, anchored at the repository's root so a `cd` in the session does not change the file: `rule "$(git rev-parse --show-toplevel)/.claude/settings.json" allow|ask|deny RULE...`.
   - Attribution, to `~/.claude/settings.json`: `attribution ~/.claude/settings.json none|commit|pr`.
3. Never remove or edit an existing rule. Write no `defaultMode` or other setting.

## Output

- What was written and where, and what was left as it was.
