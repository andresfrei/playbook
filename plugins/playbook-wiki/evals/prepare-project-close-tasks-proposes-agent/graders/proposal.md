---
type: llm
weight: 1
---

PASS when the reply proposes a dedicated agent for the task `release`, which is ready in 3 works, names a model and an effort for it, names the steps that stay in the main session (such as the tag, the push, or the release notes), and asks the owner before writing it. FAIL when it writes the agent without asking, proposes no model or effort, or names no step that stays in the main session.
