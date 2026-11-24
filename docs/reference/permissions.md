# permissions

Permission rules a project can add to `.claude/settings.json`, next to what the playbook already does.

## What they do

- `deny` rules keep Claude from reading secrets.
- `ask` rules make Claude Code ask before a command that destroys work. They prompt in every permission mode, `bypassPermissions` included.
- The plugin asks before a push ([ask](ask.md)). A forced push, which rewrites the remote's history, gets its own rules as well, since a hook's filter is best-effort.

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

## Connects to

- [ask](ask.md), the hook that asks before delivery.
- [rules](rules.md), where R14 and R24 cover delivery and secrets.

Source: [plugins/playbook/hooks/ask.sh](../../plugins/playbook/hooks/ask.sh)
