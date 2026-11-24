# reviewer

The agent `reviewer` is a read-only second reader of a change: it checks the change against its spec from a context that did not write it.

## When it runs

- On a risky change before delivery: stored data, security, an interface others use, concurrency, delivery, or untested code. [close](close.md) runs it for a risky change, The rules ask for it on a risky change (R20).
- Its tools are Read, Glob, and Grep.

## What it reads

- The brief: the spec (or the request) and a file that holds the diff.
- The spec and the diff, then the files the diff touches, as far as it needs.

## What it writes

- Nothing: it changes no file.
- It reports only gaps that affect correctness: a requirement not met, a case that fails, data lost, a security hole, a broken interface. For each, the file and line, the failing case (input or state, then the wrong result), and how sure it is. It skips style. When nothing affects correctness, it says "no findings".

## What it asks the owner

- Nothing.

## Connects to

- [close](close.md), which runs it and shows its findings.
- [builder](builder.md), whose work it may read, and [build-mode](build-mode.md).
- [rules](rules.md).

Source: [plugins/playbook/agents/reviewer.md](../../plugins/playbook/agents/reviewer.md)
