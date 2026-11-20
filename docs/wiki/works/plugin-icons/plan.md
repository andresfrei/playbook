# Plan of the work plugin-icons

## Progress

| Unit | Status | Evidence | Done on | Owner's words |
|------|--------|----------|---------|---------------|
| plugin-icons-U1 | Done | Both SVGs equal their sources in design.md; both PNGs are 512 × 512, made with `convert -background none`; `claude plugin validate` passes for `plugins/playbook-wiki` and `plugins/playbook-agents`; `sh scripts/verify.sh` passes | 2026-11-20 | |

## Units

| ID | Unit | Delivers | Changes | Ends when | Waits for | Accepted by |
|----|------|----------|---------|-----------|-----------|-------------|
| plugin-icons-U1 | The icons | The SVGs of [design.md](design.md) at `.claude-plugin/icon.svg` of each plugin, and their 512 px PNGs made with `convert -background none icon.svg icon.png` (plugin-icons-2) | `plugins/playbook-wiki/.claude-plugin/icon.svg`, `plugins/playbook-wiki/.claude-plugin/icon.png`, `plugins/playbook-agents/.claude-plugin/icon.svg`, `plugins/playbook-agents/.claude-plugin/icon.png` | Each SVG equals its source in [design.md](design.md); each PNG is 512 × 512; `claude plugin validate` passes for both plugins; `sh scripts/verify.sh` passes | none | Evidence: the design is already accepted (plugin-icons-6) |

## Batches

| Batch | Units | Shared |
|-------|-------|--------|
| 1 | plugin-icons-U1 | no |

- Most `write` agents at once: 1. The unit is built directly in this worktree.
- Worktree preparation: none.

## How the work is delivered

Decided (plugin-icons-7), as readme-redesign-13: the unit is a commit on `feat/plugin-icons`; one pull request to `main`, which the owner merges. Tested nowhere apart beyond the unit's checks.

## Left out

- The submission to the plugin directory, which waits for a Verified organization (plugin-directory-9).
- An icon for `playbook`, which is not submitted (plugin-directory-1).
