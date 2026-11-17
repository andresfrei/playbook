# Definition of version-on-close

## The problem

A work can reach a project's main branch with no version and no release, because nothing asks for one. In this repository the hook of wiki-check-on-commit would have reached `main` with no version 2.1.0. This repository has its own rule, github-release-2, in its `CLAUDE.md`; other projects that use `playbook-wiki` have none.

## Decided

- When `prepare-project` closes a work in a project that publishes versions, it recommends whether the work needs a new version and which one, and asks. It is written in the closing step of stage 6 (version-on-close-1).
- A project publishes versions when git has at least one tag that is a version, such as `v1.2.0` or `1.2.0` (version-on-close-2).
- The recommendation follows the project's own written rule of versions, and otherwise Semantic Versioning (version-on-close-3).
- On a yes, the agent records the version chosen in the work and lists the release steps as next steps: the version in the project's files, the tag, and the release on the forge. It makes the release only when the person asks for it (version-on-close-5, which replaces version-on-close-4).

## Open

Nothing. The questions are in [questions.md](questions.md).

## Topics

| Topic | Coverage | What is missing |
|-------|----------|-----------------|
| The problem, and who has it | Covered | Above. Anyone with `playbook-wiki` on a project that tags its versions |
| Main flows | Covered | Close the work, recommend, ask; on a yes, record the version and list the release steps |
| What it must do | Covered | version-on-close-1 to version-on-close-3, version-on-close-5 |
| What it must not do | Covered | Ask in a project with no version tag. Make a release the person did not ask for |
| Limits | Covered | git only (D173) |
| Outside systems | Covered | git only |
| Qualities, volume, who runs it, vocabulary | Not applicable | The skill's text only, maintained by the owner (D179) |
