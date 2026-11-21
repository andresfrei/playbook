---
name: release
description: Release a new version of the project. Sets the version, commits, and drafts the release notes; tagging, pushing, and publishing are left to the owner.
disable-model-invocation: true
argument-hint: "[version]"
---

## Steps

1. Find where the project declares its version, as `docs/playbook/technology.md` says, or else the manifest files of its technology. Read the current version and the last tag with `git describe --tags --abbrev=0`.
2. Take the version from `$ARGUMENTS`, or propose one by Semantic Versioning from the changes since the last tag: MAJOR breaks an existing use, MINOR adds, PATCH fixes. Ask the owner to confirm it.
3. On a branch, change the version in each file that declares it, and commit `chore: release <version>`.
4. Draft the release notes: what changed, in a few lines per change, and for a MAJOR version how to move from the one before. Show them.
5. Tell the owner the commands left, which are theirs to run or approve: push the branch, open and merge the pull request, then `git tag v<version>` on the merge, `git push origin v<version>`, and `gh release create v<version>` with the notes.

## Output

- The version, the files changed, the commit, the notes, and the commands left for the owner.
