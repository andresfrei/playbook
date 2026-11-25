# permissions

The skill `/playbook:permissions` is a wizard that offers the saved [presets](presets.md) that fit the project, then asks the owner, one question at a time, about attribution and allow, ask, and deny permission rules, and writes the accepted ones into Claude Code's settings. It needs `jq`.

## When it runs

- The owner runs `/playbook:permissions` or asks for it, or says yes when [audit](audit.md) offers it once on adopting a project. Never by itself.

## What it reads

- `~/.claude/settings.json` for attribution, and the project's `.claude/settings.json` for rules, to propose only what is missing.
- For allow rules, the project's `package.json` scripts, `Makefile` targets, test scripts, and the checks in its `CLAUDE.md`.
- The presets in `~/.claude/playbook/presets/` whose signal files all exist in the project, found by `presets.sh detect`, with no judgment of Claude.
- `jq` must be on PATH; when it is missing, the skill says so and stops, writing nothing.

## What it writes

- Rules (allow, ask, deny) into the project's `.claude/settings.json`, and attribution into `~/.claude/settings.json`, through `settings-write.sh`. It only adds: it never removes or edits an existing rule, and sets no `defaultMode` or other setting.
- A preset the owner accepts, through `presets.sh apply`: its rules into the project's `.claude/settings.json`, and its skills and agents copied into the project's `.claude/`, to be committed. A skill or agent already there with different content is overwritten only on the owner's yes.
- Each line and its file are shown before writing.

## What it asks the owner

- Before the questions, for each preset that fits, whether to apply it. With none, nothing is said about presets.
- Four questions, one at a time, in order: attribution (commits and pull requests apart), allow, ask, and deny. A question with nothing missing is skipped and said so.
- Allow rules are narrow, such as `Bash(npm run test)`; never bare `Bash` or `Bash(*)`.

## What the rules do

- `deny` rules keep Claude from reading or editing secrets.
- `ask` rules make Claude Code ask before a command that destroys work. They prompt in every permission mode, `bypassPermissions` included.
- The plugin asks before a push ([ask](ask.md)). A forced push, which rewrites the remote's history, gets its own rules as well, since a hook's filter is best-effort.

The default ask and deny rules it proposes:

```json
{
  "permissions": {
    "deny": ["Read(./.env)", "Read(./.env.*)", "Read(./secrets/**)"],
    "ask": [
      "Bash(git reset --hard*)", "Bash(git clean *)", "Bash(rm -rf *)", "Bash(rm -fr *)",
      "Bash(git push -f*)", "Bash(git push * -f*)", "Bash(git push *--force*)"
    ]
  }
}
```

The deny rules also come as `Edit(...)` rules for the same paths, and key files such as `*.pem` or `*.key` are added only when the project has them.

## Connects to

- [presets](presets.md), the skill that saves a preset and applies one.
- [audit](audit.md), which offers it once on adoption.
- [ask](ask.md), the hook that asks before delivery.
- [rules](rules.md), where R14 and R24 cover delivery and secrets.

Source: [plugins/playbook/skills/permissions/SKILL.md](../../plugins/playbook/skills/permissions/SKILL.md), [plugins/playbook/scripts/settings-write.sh](../../plugins/playbook/scripts/settings-write.sh), and [plugins/playbook/scripts/presets.sh](../../plugins/playbook/scripts/presets.sh)
