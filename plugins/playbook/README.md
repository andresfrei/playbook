# playbook

This optional setup plugin gives Claude Code the `/playbook:init` command. Use it to choose what runs in a single repository or across your projects. You can also install the wiki directly. Codex offers its own [installer](../../codex/README.md).

## Setup flow

```mermaid
flowchart TD
    start["Run /playbook:init"] --> scan["Inspect enabled plugins and skills"]
    scan --> choice{"Choose components"}
    choice -->|Wiki only| scope["Choose repository or user scope"]
    choice -->|Wiki and agents| language["Choose the agent language"]
    language --> scope
    scope --> conflicts["Resolve overlapping skills if found"]
    conflicts --> apply["Apply the selection"]
    apply --> next["Start a new session"]
```

Run the command again to change your selection. See the [Claude Code guide](../../docs/claude-code.md) for installation and the [init skill](skills/init/SKILL.md) for the exact prompts and settings.
