# Playbook wiki

The source of truth for this repository: what the product is, the decisions behind it, and the work in progress. It holds only what the code does not say; for how the code is built, read the code.

Project owner: Andres Frei.

Every statement is Decided (a row of a work's `decisions.md`, with the decider's words), Proposed (waiting for the owner), or Open.

## The product

Playbook is a Claude Code plugin that helps a person build software fast with Claude: it defines each change with the person before code, records their decisions in their words, and learns from its own mistakes (basics-2, basics-4). [product.md](product.md) says what it does.

## Open work

[one-audit](works/one-audit/spec.md): one skill, `audit`, replaces the two audit skills of the wiki and the tools and checks the whole setup of a project, the wiki, `CLAUDE.md`, rules, memory, skills, agents, and MCP servers, for collisions and for context cost by Claude Code's documentation (one-audit-1 to -10). U1 to U3 are built; next: close the work. The last closed, [ask-to-clear](works/ask-to-clear/spec.md).

Last audit: 2026-11-22, after work builder-load. Contradictions: 5 found, 5 resolved.

## Pages

| Page | What it holds |
|------|---------------|
| [product.md](product.md) | What the product does, for whom, and the rules decided |
| [technology.md](technology.md) | Each technology, why it was chosen, and the Claude Code version last evaluated (audit-2026-11-22-2) |
| [skills.md](skills.md) | The skill the agent uses for each job of this repository |
| `works/<work>/` | Per work: `spec.md`, its definition and units, and `decisions.md` |
| [works/history/decisions.md](works/history/decisions.md) | The decisions from before works (`D#`, `TD#`) |

The works before `basics` keep their older format as history; their links may point to pages that git keeps.
