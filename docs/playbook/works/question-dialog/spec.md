# Spec of the work question-dialog

Status: Accepted (question-dialog-2).

Delivery: one branch and one pull request per work (delivery-versioning-2).

## What and why (question-dialog-1)

R3 tells every session to ask one question at a time, with a recommendation. Only the skill `define` names Claude Code's question dialog, `AskUserQuestion`; the rule and the other four skills that ask (`close`, `audit-wiki`, `audit-tools`, `audit-learning`) do not, so their questions arrive as text the owner answers by typing. The dialog is easier to answer and the tool already exists.

Claude Code's documentation, read on 2026-11-22:

- tools-reference.md: "Claude uses `AskUserQuestion` to ask you multiple-choice questions when it needs a decision or a clarification."
- best-practices.md, on asking Claude to interview you: "Claude comes back with multiple-choice questions about the parts you haven't pinned down".
- agent-sdk/user-input.md: "each `AskUserQuestion` call supports 1-4 questions with 2-4 options each". One call can hold four questions, so the rule says one question per dialog, and a question with no options to offer cannot use it.
- The tool is not always there. sub-agents.md lists `AskUserQuestion` among the tools its first filter "removes ... from every subagent". hooks.md: "A `-p` run offers `AskUserQuestion` only when it has a permission host". A run of `claude -p` on 2026-11-22 listed no `AskUserQuestion` among its tools.

## What changes

1. **`rules.md`, R3** (question-dialog-1): "Ask one question at a time, with a recommendation, then stop and wait. Ask it with `AskUserQuestion` when available, one question per dialog, recommended option first; ask in text a question that has no options to offer."
2. **The five skills that repeat R3 in their rules** carry the same sentence: `define`, which today names the tool in other words, and `close`, `audit-wiki`, `audit-tools`, and `audit-learning` (question-dialog-2).

## Out of scope

- The agents `builder` and `reviewer`: Claude Code removes the tool from every subagent, and they report to the main session.
- A fallback of our own for `claude -p`: there the question is asked in text, as today.
- The hooks that ask before heavy actions: those are Claude Code's permission prompts, not questions of the agent.

## Check

- `check-wiki.sh`, the tests, `shellcheck`, and `claude plugin validate .` pass.
- The rules and this repository's wiki README still fit together in the session start (9,000 characters).
- Live, in a throwaway repository, run with `claude -p --plugin-dir plugins/playbook`: the session start holds the new R3, and a request that needs the owner's choice gets one question in text with a recommendation, since the run does not offer the tool.
- Interactive, run by the owner with `claude --plugin-dir plugins/playbook`: a request that needs a choice between options gets one dialog with the recommended option first.

## Units

| Unit | What | Check | State |
|------|------|-------|-------|
| 1 | Changes 1 and 2 | All the checks | Done |
