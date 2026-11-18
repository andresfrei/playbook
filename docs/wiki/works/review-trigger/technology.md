# Technology of review-trigger

What the work needs from its technology, from [definition.md](definition.md), and what is proposed for each need. Stage 2. No new dependency: Claude Code's hooks, `sh`, `sed`, `awk`, and `git`, as the hooks of `playbook-wiki` already use.

## What was checked

On 2026-11-17, on Claude Code 2.1.327:

- [Hooks reference](https://code.claude.com/docs/en/hooks.md):
  - Every hook gets `session_id`, `transcript_path`, and `cwd`; a hook that fires inside a subagent also gets `agent_id` and `agent_type`.
  - SubagentStop "Runs when a Claude Code subagent has finished responding", with `agent_type` as the value its matcher filters. For a plugin's subagent, `agent_type` is "the plugin-scoped identifier such as `my-plugin:reviewer`", matched exactly with `^my-plugin:reviewer$`.
  - On PreToolUse, `permissionDecision` `"deny"` stops the call and its `permissionDecisionReason` is "shown to Claude"; `"ask"` shows it to the user instead. When several PreToolUse hooks decide, "precedence is `deny` > `defer` > `ask` > `allow`".
  - The transcript "is written asynchronously and may lag the in-memory conversation", and its format is not documented as a contract.
  - A command hook times out after 600 seconds by default.
- [Plugin components](https://code.claude.com/docs/en/plugins/components.md): `${CLAUDE_PLUGIN_DATA}` is "the plugin's persistent data directory", resolving to `~/.claude/plugins/data/<id>/`, "created when first referenced", and given to every hook process. A plugin's `hooks/hooks.json` has the shape of the `hooks` object of `settings.json`.
- In this repository: `plugins/playbook-wiki/hooks/hooks.json` already registers a SubagentStart hook and two PreToolUse hooks on `Bash` with `"if": "Bash(git *)"`. `commit-check-hook.sh` already denies a `git commit` call with a reason to the agent, and `git-hook-lib.sh` parses the hook's JSON and finds the `git commit` in a command.

## Needs already met

| # | Need | Choice | Source |
|---|------|--------|--------|
| N1 | Run before a commit, in every project that installs the plugin | A PreToolUse hook on `Bash` with `"if": "Bash(git *)"`, as `playbook-wiki` does | TD28, review-trigger-2 |
| N2 | Stop a call and tell the agent why | `permissionDecision` `"deny"` with `permissionDecisionReason`, as `commit-check-hook.sh` does | wiki-check-on-commit-3, review-trigger-4 |
| N3 | Never block a command by its own error | Print nothing and exit 0 when the input cannot be parsed or a file is missing, as the hooks of `playbook-wiki` do | review-trigger-5 |

## New needs

| # | Need | Choice | Status |
|---|------|--------|--------|
| N4 | Know that `review` ran | A SubagentStop hook with the matcher `^playbook-agents:review$` writes a mark for the session, `${CLAUDE_PLUGIN_DATA}/review/<session_id>`. The PreToolUse hook reads it. The transcript is not read: its format is no contract, and it may lag | Decided (review-trigger-7) |
| N5 | Which reviews count for a commit | A review since the last commit of the session. The first commit the mark lets through writes the repository and `HEAD` into it; commits run while they match, and once `HEAD` moves the mark is removed. Any move of `HEAD` counts as a commit | Decided (review-trigger-6, review-trigger-15) |
| N6 | Hold one commit only once | The hook writes `${CLAUDE_PLUGIN_DATA}/held/<session_id>` with the repository, `HEAD`, and the commit's command when it holds; that command then runs on every try until `HEAD` moves | Decided (review-trigger-7, review-trigger-15) |
| N7 | What the agent is shown | R20's sentence, read from the plugin's `rules.md`; what the commit changes, `git status --short`, at most 20 lines; and what to do: call `review`, or try the same commit again when the change is not risky | Decided (review-trigger-7) |
| N11 | Let a commit of the wiki alone run | When every path of `git status --porcelain --untracked-files=all` is under `docs/wiki/`, both paths of a rename or copy included, the hook prints nothing; the same reading as `commit-check-hook.sh`. Only when nothing but `cd` and `git add` without `-f` runs before the commit in the same call, since the hook reads the status before the call runs | Decided (review-trigger-14) |
| N8 | Parse the hook's input and find a `git commit` | `plugins/playbook-agents/hooks/hook-lib.sh`: copies of `json_string` and `json_lines` from `plugins/playbook-wiki/hooks/git-hook-lib.sh`, and `commit_dir`, the commit part of its `git_parse`, since a project may install `playbook-agents` without `playbook-wiki` | Decided (review-trigger-7, review-trigger-15) |
| N9 | Tests | Cases in `scripts/verify_test.sh` that feed the hooks their JSON and check the decision, as for `commit-check-hook.sh` (R11) | Decided (review-trigger-7) |
| N10 | Count again | The method of review-evidence-U1, on the transcripts of the sessions after the change is installed | Decided (review-trigger-7) |

## Architecture

The plugin `playbook-agents` gets two hooks, next to `hooks/session-start.sh`:

| Path | What it does | Need |
|------|--------------|------|
| `plugins/playbook-agents/hooks/review-ran.sh` | On SubagentStop of `playbook-agents:review`: writes the session's mark | N4 |
| `plugins/playbook-agents/hooks/review-before-commit.sh` | On a `git commit`: lets a commit of the wiki alone run; with a mark, lets commits run until `HEAD` moves; with none, holds the call once with the reminder, and lets the same commit run on the next tries until `HEAD` moves | N5 to N7, N11 |
| `plugins/playbook-agents/hooks/hook-lib.sh` | The parsing both hooks source | N8 |
| `plugins/playbook-agents/hooks/hooks.json` | Registers both | N1 |

Flow:

1. The writing agent runs `git commit`. With no mark, the hook writes `held/<session_id>` and denies the call with the reminder.
2. The agent calls `review`; when it finishes, the SubagentStop hook writes the mark. Or the agent judges the change not risky.
3. The agent runs the commit again. The hook finds the mark, or the same command on the same `HEAD` in `held/`, and lets it run. When the commit happens, `HEAD` moves, and the next commit needs another review.

Risks:

- A version of Claude Code that does not run SubagentStop from a plugin, or names the agent otherwise: every commit is held once, and nothing is lost. Reduced by a trial in stage 6 that reads the mark after a real call of `review`.
- `${CLAUDE_PLUGIN_DATA}` unset, as when the plugin is loaded with `--plugin-dir`: the hook does nothing (N3).
- A file per session stays in `${CLAUDE_PLUGIN_DATA}`: a few bytes each. Reduced by removing the files older than seven days when a mark is written.

Trade-offs:

- One extra try for each commit that is not risky, in a session with no `review`, against a review that comes before the commit.
- A copy of two functions of `git-hook-lib.sh` in the other plugin, against a dependency between the plugins.

Discarded:

- Reading the transcript to find a call of `review`: not a contract, and it may lag.
- `"ask"`: it stops the person, which review-trigger-4 rules out.
- Letting the commit run and reminding after it: ruled out by review-trigger-4.

## Not verified

- That a SubagentStop hook in a plugin's `hooks/hooks.json` runs: the documentation says the file has the shape of the settings, and a SubagentStart hook of `playbook-wiki` does run. Checked by the trial in stage 6.
- That `session_id` is the same in the main session and in a hook fired inside a subagent: the documentation does not say. It matters when the agent `write` commits.
