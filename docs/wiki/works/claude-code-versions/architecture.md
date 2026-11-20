# Architecture of the work claude-code-versions

## The problem

This repository's plugins depend on Claude Code features that change from one release to the next. The owner wants to ask for an evaluation and get, for the versions not yet read, what to optimize or check, without reading the same versions twice (claude-code-versions-1, -5).

## Requirements and assumptions

- The evaluation changes no file but the record (claude-code-versions-5).
- The record lives in `03-technology/claude-code-versions.md` and moves when every proposal is answered (claude-code-versions-3, -4).
- Assumed: the changelog stays one Markdown file with `## X.Y.Z` headings, newest first.

## Shape

Decided (claude-code-versions-7): one project skill run by the main session, which hands the reading to a read-only agent.

| Module | Responsible for | Does not |
|--------|-----------------|----------|
| Skill `evaluate-cli-releases` (claude-code-versions-11) | Reads the record and `claude --version`; stops when they match; fetches the changelog and keeps the sections after the record (N2, N3); gives them to `explore` with the list of paths below; shows the table; records the owner's answers and moves the record | Change hooks, plugins, agents, or skills |
| Agent `explore` | Reads the sections and the paths, returns one row per entry that touches the repository: version, change, what it touches, proposal | Write any file |
| Page `03-technology/claude-code-versions.md` | Holds the last version evaluated, the evaluations, and the pending proposals | |

Paths `explore` reads: `plugins/*/hooks/`, `plugins/*/.claude-plugin/`, `.claude-plugin/marketplace.json`, `plugins/*/agents/`, `plugins/*/skills/`, `plugins/*/commands/`, `.claude/`, `codex/`, and the pages of `docs/wiki/03-technology/`.

## Outside systems

Claude Code's `CHANGELOG.md` on GitHub. Without it, the evaluation stops and the record stays as it was.

## Risks

- The changelog changes its format: the extraction prints nothing or everything. The skill stops when no `## <recorded version>` heading is found.
- A long range fills the agent's context: the skill evaluates at most a set number of versions at once and says the range left.

## Trade-offs

- A skill, not a script that judges: judging what an entry means for the repository needs a model; the script part is one `curl` and one `awk`.
- `explore` costs one agent call, and keeps about a thousand changelog lines out of the session.

## Discarded

- A hook that runs at every session start: the owner asked for an evaluation on request.
- WebFetch: it returns the changelog paraphrased, not verbatim.

## Evolution

Moving it up to `playbook-agents` for every project needs a new decision (claude-code-versions-2).
