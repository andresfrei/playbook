# Playbook wiki

The source of truth for this repository: what the product is, the decisions behind it, and the work in progress. It holds only what the code does not say; for how the code is built, read the code.

Project owner: Andres Frei.

Every statement is Decided (a row of a work's `decisions.md`, with the decider's words), Proposed (waiting for the owner), or Open.

## The product

Playbook is a Claude Code plugin that helps a person build software fast with Claude: it defines each change with the person before code, records their decisions in their words, and learns from its own mistakes (basics-2, basics-4). [product.md](product.md) says what it does.

## Open work

[cross-work-learning](works/cross-work-learning/spec.md): a skill `audit-learning` reads the decisions of the works not yet learned from, finds what repeats across works, and proposes a delegation, a rule, a skill, or an agent (cross-work-learning-1 to -7). Next: unit 1, the skill, its offer in `close`, the README, and `product.md`.

Before it: the last two, [plugin-update](works/plugin-update/spec.md), the README tells users to turn on Claude Code's auto-update instead of a notice of our own (plugin-update-1); and [agent-runs-skills](works/agent-runs-skills/spec.md), the agent offers `audit-wiki`, `audit-tools`, and `release` and runs them on the owner's yes (agent-runs-skills-1). Before it, [build-mode](works/build-mode/spec.md): a personal `Build mode: main | builder` line chooses whether the main session or the agent `builder` on Sonnet builds each unit (build-mode-1 to -6). Before it, [delivery-versioning](works/delivery-versioning/spec.md) and [session-cost](works/session-cost/spec.md) were released together as 5.1.0 (tag `v5.1.0`).

Last audit: 2026-11-22, after work delivery-versioning. Contradictions: 0 found, 0 resolved.

## Pages

| Page | What it holds |
|------|---------------|
| [product.md](product.md) | What the product does, for whom, and the rules decided |
| [technology.md](technology.md) | Each technology, why it was chosen, its version, and the Claude Code version last evaluated |
| [skills.md](skills.md) | The skill the agent uses for each job of this repository |
| `works/<work>/` | Per work: `spec.md`, its definition and units, and `decisions.md` |
| [works/history/decisions.md](works/history/decisions.md) | The decisions from before works (`D#`, `TD#`) |

The works before `basics` keep their older format as history; their links may point to pages that git keeps.
