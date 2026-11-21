#!/bin/bash
set -eu
c=commit
git init -q -b main .
git config user.email eval@example.com
git config user.name "Andres Frei"
mkdir -p skills/changelog
cat > skills/changelog/SKILL.md <<'MD'
---
name: changelog
description: Write the changelog of a release. Use it when the owner asks for the changelog; it lists the commits since the last tag.
---

## When to use

- The owner asks for the changelog of the next release.

## Rules

- When the repository has no tag, stop and report it. Do not guess a starting point.

## Steps

1. Find the last tag with `git describe --tags --abbrev=0`.
2. List the commits since it with `git log <tag>..HEAD --oneline`.
3. Write them as bullets in CHANGELOG.md.

## Output

- The bullets written and the tag they start from.
MD
git add -A
git $c -q -m "feat: scaffold"
