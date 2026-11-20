# Definition of the work ask-before-irreversible

What this work must make true: with `playbook-agents` installed, Claude Code does not push, open or merge a pull request, or publish a release without the person confirming that action at that moment (ask-before-irreversible-1); and the playbook proposes, for each repository, permission rules and the sandbox for what cannot be undone there (ask-before-irreversible-7).

## The problem

R14 says push, pull requests, and merges are the owner's decisions (`docs/wiki/01-product/rules.md`). Today it is only a written rule: an agent that reads a "yes" loosely, or a subagent that never saw the conversation, can push or merge, and nothing stops it. A push to a shared branch, a merge, or a published release cannot be undone without leaving a trace for others. Rule 3 of the guide the owner brought, "what cannot be undone is forbidden", is the one rule of that guide the playbook does not enforce.

The guide's rule 3 asks for more than R14: a `deny` list in `.claude/settings.json` for what cannot be undone, such as `Read(./.env)`, and the sandbox, because a rule sees the command and not what the command does inside. That list depends on each repository (R16).

## Who has it

A person with the playbook who lets agents work for long stretches, often in a permission mode that does not ask before each command, and in worktrees.

## What is known

Read in code.claude.com/docs on 2026-11-19 (hooks, permissions, permission-modes):

- Permission rules are checked deny, then ask, then allow, and an ask or deny rule applies when any part of a chained command matches. A plugin cannot ship permission rules; they live only in user, project, local, and managed settings.
- The rule `Bash(git push *)` does not match `git -C <dir> push`, the form agents use in worktrees.
- A plugin can ship a `PreToolUse` hook that returns `permissionDecision` `ask`, `deny`, `allow`, or `defer`. When several hooks answer, `deny` wins over `defer`, `defer` over `ask`, and `ask` over `allow`.
- The tool calls of a subagent run the same `PreToolUse` hooks as the main conversation, with `agent_id` and `agent_type` in the input.
- Auto mode still shows the prompts that an ask rule or a hook forces.
- Not stated by the documentation: whether a hook's `ask` shows a prompt in `bypassPermissions` or `acceptEdits` mode. It is to be measured in stage 2.
- In a run with `-p`, a call that needs approval is refused unless something approves it.
- The sandbox is off by default, applies to shell commands only, and does not block reading files unless `filesystem.denyRead` names them.
- `playbook-agents` already has a `PreToolUse` hook on `Bash(git *)`, `review-before-commit.sh`, which holds the first attempt of a code commit (`plugins/playbook-agents/hooks/hooks.json`).

## Coverage of the topics

| Topic | Coverage |
|-------|----------|
| The problem and who has it | Covered |
| Who uses it and what they do | Covered: the person, who answers the prompt |
| Main flows | Covered: a permission prompt, or a refusal where no prompt is shown (ask-before-irreversible-3) |
| What it must do | Covered: the actions of R14 (ask-before-irreversible-2), also those of subagents (ask-before-irreversible-5) |
| What it must not do, and what waits | Partly covered: the hook stops only the actions of R14 (ask-before-irreversible-2); the rest of rule 3 is proposed per repository (ask-before-irreversible-7), ask-before-irreversible-Q5 to -Q7 |
| Qualities | Covered: it works in every mode (ask-before-irreversible-3) |
| Limits | Covered: a plugin ships hooks, not permission rules |
| Outside systems | Covered: git and the GitHub CLI `gh` |
| Volume | Does not apply |
| Who runs and maintains it | Covered: it ships in `playbook-agents` |
| Business rules, states, vocabulary | Covered: the prompt is shown every time (ask-before-irreversible-4) |
