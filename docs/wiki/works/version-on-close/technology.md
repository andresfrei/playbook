# Technology of version-on-close

What the work needs from its technology, from [definition.md](definition.md). Stage 2. No new dependency: the step is text in `prepare-project`, and the agent runs git.

| # | Need | Choice | Status |
|---|------|--------|--------|
| N1 | Know whether the project has a version tag (version-on-close-2) | `git tag --list`, read by the agent, looking for a tag of the form `v1.2.0` or `1.2.0` | Proposed |
| N2 | Know what the work brings, to recommend a version (version-on-close-3) | The work's decisions and the commits of its branch since it left the main branch, which the closing step already reads | Proposed |
| N3 | Find the project's own rule of versions (version-on-close-3) | The shared pages and the project's `CONTRIBUTING.md`, when it exists, as the agent reads any definition; no file is required | Proposed |

## Architecture

One more item in the closing step of stage 6, `plugins/playbook-wiki/skills/prepare-project/references/6-execution.md`, before the step at the merge. No script, hook, or file changes. A reference file is read only when its stage is current, so the step loads only when a work closes.

Not applicable: data, outside systems beyond git, and risks beyond a wrong recommendation, which the person corrects when asked.
