# Spec of the work skill-overrides

Status: Accepted (skill-overrides-2)

Learned: 2026-11-25

Delivery: one branch and one pull request per work (delivery-versioning-2).

## What and why

`plugins/playbook/scripts/startup-context.sh` reports "user skills: 20 descriptions" on the owner's machine while `/context` lists 2 user skills (audit-2026-11-24-13). Two causes, both fixed here (skill-overrides-1):

- The script ignores the setting `skillOverrides`. skills.md: `"user-invocable-only"` and `"off"` hide the skill from Claude, `"name-only"` lists its name only, and an absent key means `"on"`. Plugin skills are not affected by it.
- The script counts the skills under `~/.claude/skills/synced/` as user skills. skills.md: "Claude Code downloads your account's skills into `~/.claude/skills/synced/`"; they are named `anthropic-skills:<name>`, and `/skills` and `/context` show them under "claude.ai sync", apart from the personal skills.

## What changes

1. **Overrides.** The project and user skill rows skip a skill whose override is `off` or `user-invocable-only`, and count only the characters of its name when it is `name-only`. The override of a key is read from the settings files the script already reads, the first file that sets that key deciding, as for the other settings of the script. A synced skill also matches the key `anthropic-skills:<name>`, as the owner's settings write it.
2. **Synced skills.** The user row no longer reads `~/.claude/skills/synced/`. A new row `claude.ai sync skills: <n> descriptions` reads it, with level `user` and the same overrides.
3. The plugin rows do not change.

## Out of scope

- The setting `syncClaudeAiSkills`.
- Managed settings and `--settings` as sources of `skillOverrides`.

## Check

- `tests/startup-context_test.sh` covers: a user skill with `off`, one with `user-invocable-only`, one with `name-only`, one with no key; a synced skill hidden by its `anthropic-skills:` key and one shown; the user row not counting synced skills.
- `sh tests/check-wiki_test.sh`, `sh tests/hooks_test.sh`, `sh plugins/playbook/scripts/check-wiki.sh docs/playbook`, `shellcheck`, and `claude plugin validate .`.
- On the owner's machine, the script's user row says 2 descriptions and the claude.ai sync row says 1, as `/context` shows.

## Units

| Unit | What | Check | State |
|------|------|-------|-------|
| U1 | Points 1 to 3 above, with their tests | The checks above | Done |
