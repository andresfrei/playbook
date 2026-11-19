# Technology of the work repeated-corrections

What the work needs from its technology, from [definition.md](definition.md), and what answers each need. The hook facts were checked on 2026-11-19 in https://code.claude.com/docs/en/hooks, sections SubagentStart, SubagentStop, and PostToolUse.

## Needs

| ID | Need | From | Proposed answer | Status |
|----|------|------|-----------------|--------|
| N1 | Give `write` and `review` the rules before they start | repeated-corrections-9, -14 | A `SubagentStart` hook of `playbook-agents`, matcher `^playbook-agents:(write\|review)$`, prints the rules as `additionalContext`, as `playbook-wiki` already does with the contract. Its input holds no task text, so each rule says when it applies and the subagent judges | Proposed |
| N2 | Take the report of `review` when it ends, in the foreground or the background | repeated-corrections-9, -14 | The `SubagentStop` hook of `review`, which already exists (`review-ran.sh`), saves `last_assistant_message` in a queue under `CLAUDE_PLUGIN_DATA`, one file per review. No model, no network | Proposed |
| N3 | Classify the evidence and consolidate | repeated-corrections-10, -11, -12 | A new agent with the model `sonnet` in `models.conf`, which reads the queue, applies the criteria, and writes the page. When it runs is repeated-corrections-Q5 | Open |
| N4 | Keep the kinds, evidence, and rules of a project, and count them | repeated-corrections-6, -15 | One page of the project's wiki in Markdown tables; a POSIX `sh` and `awk` script counts distinct reviews per kind and level | Proposed |
| N5 | Keep the general rules in the playbook | repeated-corrections-15 | One file in `plugins/playbook-agents/`, read by the hook of N1 with the project's rules | Proposed |

## Facts that shape the answers

- `SubagentStart` input: `agent_id`, `agent_type`, and the common fields; no prompt. Its `additionalContext` is added "to the subagent's context at the start of its conversation".
- `SubagentStop` input: `agent_type`, `agent_transcript_path`, and `last_assistant_message`, "the text content of the subagent's final response". Its output does not reach the main agent; the documentation sends that to `PostToolUse` on `Agent`.
- `PostToolUse` on `Agent` gives the main agent `additionalContext`, but only "when a foreground Agent call completes". A review in the background returns its report later, with no hook; in the sample of [measurements.md](measurements.md), half of the reports were of that kind. So the report is taken at `SubagentStop`, which fires in both cases.
