# playbook

This optional setup plugin gives Claude Code the `/playbook:init` command. Use it to choose what runs in a single repository or across your projects. You can also install the wiki directly. Codex offers its own [installer](../../codex/README.md).

## Setup flow

```mermaid
flowchart TD
    start["Run /playbook:init"] --> scan["Inspect enabled plugins, skills, and the wiki"]
    scan --> on{"Already on here?"}
    on -->|Keep| wiki
    on -->|Change, or not on| choice{"Choose components"}
    choice -->|Wiki only| scope["Choose repository or user scope"]
    choice -->|Wiki and agents| language["Choose the agent language"]
    language --> scope
    scope --> conflicts["Resolve overlapping skills if found"]
    conflicts --> apply["Apply the selection"]
    apply --> wiki{"Repository without a wiki?"}
    wiki -->|Yes, add one| skeleton["Write the wiki's skeleton"]
    wiki -->|No| next["Start a new session"]
    skeleton --> next
```

Run the command again to see what is on and keep it or change it. A pair of skills you settled with "Keep both" is not asked again: the choice is kept under `playbook.keepBoth` in your Claude Code settings. See the [Claude Code guide](../../docs/claude-code.md) for installation and the [init skill](skills/init/SKILL.md) for the exact prompts and settings.
