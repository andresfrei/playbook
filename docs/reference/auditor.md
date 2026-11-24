# auditor

The agent `auditor` is a read-only explorer of one part of the audit: wiki, setup, or tools.

## When it runs

- From the skill [audit](audit.md), one `auditor` per part chosen. With no argument the three run in one message.
- Its tools are Read, Glob, Grep, and Bash. It does not load the project's `CLAUDE.md`.

## What it reads

- The brief, which names the part, the steps to follow, and the format of the findings.
- The files that part covers, read as files. It runs only commands that read.

## What it writes

- Nothing: it changes no file.
- It returns findings only. A finding between two sources gives both quotes, each with file and line. A finding of one source gives its quote with file and line, and the number or the limit. It says when a side is inferred rather than read. When nothing is found, it says "no findings".

## What it asks the owner

- Nothing. The main session asks, after all explorers have ended.

## Connects to

- [audit](audit.md), which runs it and crosses its findings.
- [wiki](wiki.md) and [rules](rules.md).

Source: [plugins/playbook/agents/auditor.md](../../plugins/playbook/agents/auditor.md)
