# Playbook wiki

The source of truth for this repository: what the product is, the decisions behind it, and the work in progress. It holds only what the code does not say; for how the code is built, read the code.

Project owner: Andres Frei.

Every statement is Decided (a row of a work's `decisions.md`, with the decider's words), Proposed (waiting for the owner), or Open.

## The product

Playbook is a Claude Code plugin that helps a person build software fast with Claude: it defines each change with the person before code, records their decisions in their words, and learns from its own mistakes (basics-2, basics-4). [product.md](product.md) says what it does.

## Open work

[works/basics/](works/basics/spec.md): rebuild the playbook to its minimum, released as 5.0.0. Unit U1 is done; U2, the plugin `playbook`, is next.

## Pages

| Page | What it holds |
|------|---------------|
| [product.md](product.md) | What the product does, for whom, and the rules decided |
| [technology.md](technology.md) | Each technology, why it was chosen, its version, and the Claude Code version last evaluated |
| [skills.md](skills.md) | The skill the agent uses for each job of this repository |
| `works/<work>/` | Per work: `spec.md`, its definition and units, and `decisions.md` |
| [works/history/decisions.md](works/history/decisions.md) | The decisions from before works (`D#`, `TD#`) |

The works before `basics` keep their older format as history; their links may point to pages that git keeps.
