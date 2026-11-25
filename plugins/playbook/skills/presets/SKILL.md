---
name: presets
description: Saves a preset (signal files, permission rules, skills, and agents) from the current project, and applies a saved preset to another project of the same stack, asking the owner at each step.
---

## When to use

- The owner runs `/playbook:presets` or asks to save or apply a preset. Never by itself.

## Steps

0. Check `jq` is on PATH (`command -v jq`). When it is missing, say so and stop, writing nothing. Get the project's root with `root=$(git rev-parse --show-toplevel 2>/dev/null || pwd)`. Ask the owner whether to save or apply, unless the request says it.
1. **Save** (presets-6). Ask the preset's name when not given.
   - Read the rules of `$root/.claude/settings.json` (allow, ask, deny), the folders of `$root/.claude/skills/`, and the files of `$root/.claude/agents/`. Propose those that belong to the stack, plus the signal files that reveal it, such as `wrangler.toml` (presets-7).
   - The owner confirms each kind with AskUserQuestion, one question at a time, the recommended option first; `multiSelect` is fine to confirm a list. At least one signal file is needed.
   - Show what will be written, then run `sh "${CLAUDE_PLUGIN_ROOT}/scripts/presets.sh" save NAME "$root" ITEM...`, with its keyword before each item, repeated: `signal wrangler.toml allow 'Bash(wrangler deploy)' allow 'Bash(wrangler dev)' skill deploy`. The keywords are `signal`, `allow`, `ask`, `deny`, `skill`, and `agent`. The preset lands in `~/.claude/playbook/presets/NAME/` (presets-3). When the script refuses (the name exists, a file is missing), say why and stop.
2. **Apply** (presets-5).
   - List the presets that fit with `sh "${CLAUDE_PLUGIN_ROOT}/scripts/presets.sh" detect "$root"`; when the owner wants another, list `~/.claude/playbook/presets/`. The owner picks one.
   - Show the rules, skills, and agents it will write, then run `sh "${CLAUDE_PLUGIN_ROOT}/scripts/presets.sh" apply NAME "$root"`.
   - When it refuses for a conflict (a skill or agent already in the project with different content), show each conflict and ask the owner, per item, whether to overwrite. Only on a yes, rerun with `overwrite skill:S` or `overwrite agent:A` for those items. Never overwrite without the owner's yes.
   - Tell the owner the files copied into `$root/.claude/` are to be committed in the project.
3. Never remove a rule. MCP servers and propagation of a preset's changes are out of scope.

## Output

- What was written and where (the preset, or the rules, skills, and agents in the project), and what was left as it was.
