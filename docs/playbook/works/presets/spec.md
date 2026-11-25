# Spec of the work presets

Status: Accepted (presets-9)

Delivery: one branch and one pull request per work (delivery-versioning-2).

## What and why

The owner works on many projects with near-identical setup, several of them on the same stack (Cloudflare, with its CLI already logged in), and sets each one up again by hand. A preset is a bundle the owner saves once from a project already set up and applies to another project of the same stack (presets-1, presets-2).

What is common to every project does not belong in a preset but in `~/.claude/settings.json`: settings.md says that when the same list key is set in more than one file, "Claude Code combines the lists instead of picking one".

## What it does

A preset lives in `~/.claude/playbook/`, outside every repository, so uninstalling the plugin keeps it (presets-3). It holds (presets-4, presets-7):

- its signal files, such as `wrangler.toml`;
- `allow`, `ask`, and `deny` rules;
- skills and agents.

A new skill `presets` has two jobs (presets-6):

1. **Save.** From the current project, it proposes the rules of `.claude/settings.json`, the skills of `.claude/skills/`, and the agents of `.claude/agents/` that belong to the stack, and the signal files that reveal it; the owner confirms each, and the preset is written under a name the owner gives.
2. **Apply.** It writes the preset's rules into the project's `.claude/settings.json` through `settings-write.sh`, which adds without duplicating and never removes, and copies its skills and agents into the project's `.claude/`, to be committed there (presets-5). A skill or agent of the same name already in the project is never overwritten without the owner's yes. The project's path and the preset are recorded in the registry of `~/.claude/playbook/` (presets-8).

The wizard `permissions`, before its questions, lists the presets whose signal files all exist in the project and offers to apply each one (presets-6). Detection is a script that checks those files, with no judgment of Claude (presets-7).

## Out of scope

- Propagation of a change in a preset to the projects that use it, and discovery of presets across the owner's repositories: later works, built on the registry (presets-1).
- MCP servers in a preset (presets-4).
- Presets shipped by the plugin (presets-2).
- Removing a preset from a project, or rules from a settings file.

## Check

- An offline test of the script: save writes a preset; detect lists only the presets whose signal files all exist; apply adds the rules once, copies skills and agents, refuses to overwrite one already there, and records the project in the registry; a second apply changes nothing.
- The checks of `CLAUDE.md`, with `reference_test.sh` finding the skill's page.
- A live check in two throwaway repositories with `wrangler.toml`: in the first, `/playbook:presets` saves a preset `cloudflare`; in the second, `/playbook:permissions` offers it, and applying it writes the rules and copies the skill. The live check's files in `~/.claude/playbook/` are removed after.

## Units

| Unit | What | Check | State |
|------|------|-------|-------|
| 1 | A script `presets.sh` that saves, detects, applies, and records a preset, and its offline test | `sh tests/presets_test.sh`; `shellcheck` on both | Done |
| 2 | The skill `presets`, its page in `docs/reference/`, and the README tables | `sh tests/reference_test.sh`; `claude plugin validate .`; the live check of save and apply | Pending |
| 3 | The wizard `permissions` detects and offers the presets that fit | The live check of the offer in the second repository | Pending |
