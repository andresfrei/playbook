# release

The skill `/playbook:release` sets a new version of the project, commits it, and drafts the release notes. Tagging, pushing, and publishing are left to the owner.

## When it runs

- The owner runs `/playbook:release` (optionally with a version) or asks for a release, or says yes when [close](close.md) recommends a version. Never because the work looks ready.

## What it reads

- The line `Versioning:` of `docs/playbook/technology.md`, or else the manifest files of the project's technology, to find where the version is declared. When the line says never, it stops and tells the owner.
- The current version and the last tag (`git describe --tags --abbrev=0`), and the changes since that tag.

## What it writes

- On a branch, the new version in each file that declares it, committed as `chore: release <version>`.
- The release notes, drafted and shown: what changed, and for a MAJOR version how to move from the one before.

## What it asks the owner

- To confirm the version. Given none, it proposes one by Semantic Versioning (MAJOR breaks an existing use, MINOR adds, PATCH fixes), with the number each kind gives.
- It then tells the owner the commands left to run or approve: push the branch, open and merge the pull request, `git tag v<version>` on the merge, `git push origin v<version>`, and `gh release create v<version>` with the notes. The [ask](ask.md) hook asks before the push, pull request, merge, and release.

## Connects to

- [close](close.md), which recommends the version and runs this skill on a yes.
- [ask](ask.md) and [wiki](wiki.md).

Source: [plugins/playbook/skills/release/SKILL.md](../../plugins/playbook/skills/release/SKILL.md)
