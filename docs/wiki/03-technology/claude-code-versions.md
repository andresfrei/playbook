# Claude Code versions

The Claude Code version this repository was last evaluated against, the evaluations made, and the proposals left for later (claude-code-versions-3, claude-code-versions-4). The project skill `.claude/skills/evaluate-cli-releases/` reads and writes this page when the owner asks to evaluate Claude Code (claude-code-versions-5, claude-code-versions-11).

Last version evaluated: 2.1.330

## How an evaluation runs

The record and the evaluation serve only this repository; they move up to the playbook only by a new decision (claude-code-versions-2).

1. Read the last version evaluated above and the installed version with `claude --version`.
2. Fetch the changelog with `curl`, keep the versions after the record with `awk`, and hand them to `explore`; no new dependency (claude-code-versions-7).
3. Cross each entry with what the repository uses and show a table of proposals: optimize, check, or nothing (claude-code-versions-5).
4. The evaluation changes no file but this page (claude-code-versions-5). The record moves to the version evaluated when the owner has answered every proposal; proposals left for later go under Pending (claude-code-versions-4).

## Evaluations

| Date | Versions read | Proposals | Where each went |
|------|---------------|-----------|-----------------|
| 2026-11-20 | 2.1.326 to 2.1.330 | None: `explore` returned 10 entries that touch the repository; reading each file showed every one already favours it or touches nothing it uses (claude-code-versions-12) | |

## Pending

| Version | Change | What it touches | Proposal | Left on |
|---------|--------|-----------------|----------|---------|
