# Playbook wiki

The source of truth for this repository: what the product is, the decisions behind it, and the work in progress. It holds only what the code does not say; for how the code is built, read the code.

Project owner: Andres Frei.

Every statement is Decided (a row of a work's `decisions.md`, with the decider's words), Proposed (waiting for the owner), or Open.

## The product

Playbook is a Claude Code plugin that helps a person build software fast with Claude: it defines each change with the person before code, records their decisions in their words, and learns from its own mistakes (basics-2, basics-4). [product.md](product.md) says what it does.

## Open work

Open work: [dialog-learning](works/dialog-learning/spec.md), every question dialog names its type in its header, a hook keeps each answer on the owner's machine, and `audit-learning` reads the answers by type to propose a delegation, a corrected recommendation, or a fact for the wiki (dialog-learning-6).

Next step: close the work dialog-learning with `close`; its five units are built, and the live check of the unit learn passed on 2026-11-28 (import, classification by reading in batches, the table, the delegation for Session proposed and none for Delivery or Remote). The hook writes into the installed plugin's data folder only after a release, so the first run of `/playbook:audit-learning` with the installed plugin should import before 2026-12-04, when Claude Code starts deleting the owner's oldest transcripts.

To define after it: the work `driven-mode`, playbook knows when another session drives it, as a bot of playbot, and asks in text (dialog-learning-5).

Last audit: 2026-11-26, after work presets. Contradictions: 0 found, 0 resolved.

## Pages

| Page | What it holds |
|------|---------------|
| [product.md](product.md) | What the product does, for whom, and the rules decided |
| [technology.md](technology.md) | Each technology, why it was chosen, and the Claude Code version last evaluated (audit-2026-11-22-2) |
| [skills.md](skills.md) | The skill the agent uses for each job of this repository |
| `works/<work>/` | Per work: `spec.md`, its definition and units, and `decisions.md` |
| [works/history/decisions.md](works/history/decisions.md) | The decisions from before works (`D#`, `TD#`) |

The works before `basics` keep their older format as history; their links may point to pages that git keeps.
