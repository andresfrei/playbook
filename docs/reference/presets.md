# presets

The skill `/playbook:presets` saves a preset from the current project and applies a saved preset to another project of the same stack. A preset is a bundle of signal files (such as `wrangler.toml`), `allow`, `ask`, and `deny` rules, skills, and agents. It needs `jq`.

## When it runs

- The owner runs `/playbook:presets` or asks to save or apply a preset. Never by itself.

## What it reads

- To save: the project's `.claude/settings.json` rules, `.claude/skills/`, `.claude/agents/`, and the files that reveal the stack.
- To apply: the presets in `~/.claude/playbook/presets/`, and those whose signal files all exist in the project, which `presets.sh detect` lists with no judgment of Claude.
- `jq` must be on PATH; when it is missing, the skill says so and stops, writing nothing.

## What it writes

- Saving writes `~/.claude/playbook/presets/NAME/`: `signals`, `rules.json`, `skills/`, and `agents/`. It lives outside every repository, so uninstalling the plugin keeps it.
- Applying adds the rules to the project's `.claude/settings.json` through `settings-write.sh`, copies the skills and agents into the project's `.claude/`, to be committed there, and records the project and the preset in `~/.claude/playbook/registry.json`. A second apply changes nothing.
- It only adds: it never removes a rule, and a skill or agent already in the project with different content is overwritten only when the owner says yes.

## What it asks the owner

- To save: the preset's name, then each kind to confirm (signal files, rules, skills, agents), one question at a time.
- To apply: which preset, and, for each conflict, whether to overwrite.
- What will be written is shown before writing.

## Out of scope

- MCP servers in a preset, propagation of a change in a preset to the projects that use it, and presets shipped by the plugin.

## Connects to

- [permissions](permissions.md), the wizard that offers the presets that fit, using `presets.sh detect`.
- `settings-write.sh`, which adds the rules without duplicating.

Source: [plugins/playbook/skills/presets/SKILL.md](../../plugins/playbook/skills/presets/SKILL.md), [plugins/playbook/scripts/presets.sh](../../plugins/playbook/scripts/presets.sh), and [plugins/playbook/scripts/settings-write.sh](../../plugins/playbook/scripts/settings-write.sh)
