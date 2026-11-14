# Overview

## What it is

An installable product: a clean ecosystem for building software with an AI coding agent. (Decided: D24.) It keeps Engram for memory and CodeGraph for the map of the code, and improves the part gentle-ai covers today and the skills. (Decided: D25, D26.) It targets Claude Code first. (Decided: D27.)

It is built in two phases (Decided: D30):

| Phase | What happens | gentle-ai |
|-------|--------------|-----------|
| 1 | The skills are improved and installed from this repository | Stays in use for execution, review, and the skills its instructions call by name |
| 2 | The product gets its own methodology layer | Replaced (D28) |

At its centre is a methodology that makes an AI coding agent the software builder for a software engineer, for projects already started and for projects started from zero. (Decided: D21.) It lives in one repository and applies to all of the owner's projects. (Decided: D1, D2.)

Its purpose is a clean mind for the agent: the agent reads only what the task in front of it needs, and what it reads is unambiguous. (Decided: D20.)

Two layers, with different owners (Decided: D22):

| Layer | Decided by | Contains |
|-------|-----------|----------|
| Methodology | The owner | How a project is prepared and built: the stages, who decides, what must exist before code |
| Form | What works best for the agent | How rules and skills are structured, split, named, stored, and loaded |

## Measured starting point

On 2026-11-13 every Claude Code session starts with about 13,500 words of generated global instructions (610 lines) plus the descriptions of 43 installed skills (about 2,000 words), before the owner's first message. Verified by counting the files.

## What it contains

Three things (Decided: D40):

- **Rules** — one short document with the general working rules, written by the owner. Today those rules exist only inside a file that gentle-ai generates.
- **Skills** — the clean set of general skills, in the standard `SKILL.md` format.
- **Installer** — a way to make rules and skills available to each agent tool from this repository, so it stays the only source.

## What it is not

- Not a place for the rules of one project, product, or client. Those live in that project. (Decided: D2.)
- Not a fork or overlay of gentle-ai. (Decided: D5.)
- Not a workflow engine, a CLI, or a framework. (Decided: D40. The installation chosen in stage 2 must respect this: Q21.)

## Principles

| Principle | Status |
|-----------|--------|
| One job, one skill. Two skills never cover the same job. | Decided: D6 |
| Simple before complete. A rule or skill earns its place by being used. | Decided: D40 |
| Independent of the tool that runs it. | Decided: D3 |
| Removal happens at the source that installs a skill, not in the installed copy. | Decided: D40 |

## Who uses it

The owner, through Claude Code with Anthropic's models. The product is adapted to that; other tools are considered only when it is ready, and only if needed. (Decided: D57, which replaces the part of D11 about staying free of anything exclusive to one tool.)

For now it is optimized for the owner's own work and use. A piece that exists only to serve other tools or other users does not earn a place today. (Decided: D52.)
