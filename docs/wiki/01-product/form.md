# Form

How the playbook is structured and stored. D22 leaves this to what works best for the agent. F1–F10 are Decided (D23). F11 and F12 are Decided (D36); they cover methodologies and memories, which the owner said were missing. Each principle states the problem it removes, taken from the 2026-11-13 audit and the tooling evaluation.

| # | Principle | Problem it removes |
|---|-----------|--------------------|
| F1 | **Small always-loaded core.** Only rules that apply to every task are loaded in every session. Everything else is loaded when the task calls for it. | About 15,500 words load before the first message today; most do not apply to the task at hand |
| F2 | **One fact, one place.** A rule is written once and referenced elsewhere, never copied. | The 400-line rule lives in five places that disagree |
| F3 | **One job, one skill, one trigger.** No two skills answer the same request. | Four skills fire for "start a project" |
| F4 | **One word, one meaning.** Each term in the glossary names one thing across all rules and skills. | "Stage" means two things inside one skill |
| F5 | **State on disk, with one entry point.** Each project has one index file that says what is decided, what is open, and what comes next. The agent never depends on remembering a conversation. | A brief that existed only in a conversation |
| F6 | **Explicit status.** Every statement is Decided, Proposed, or Open. The agent does not infer which. | Proposed stacks treated as decisions |
| F7 | **Instructions, not explanations.** Runtime text is imperative and checkable. History, rationale, and examples live in separate files that are read only when needed. | Skills two to six times over the size limit |
| F8 | **Checkable endings.** Every stage and task ends on a condition that can be observed, not on a judgement. | A workflow whose phases were never defined |
| F9 | **Nothing that cannot run.** A rule or skill that depends on a missing command, tool, or file is removed, not kept "for later". | A skill family routing to a command that does not exist |
| F10 | **Enforce with tools where possible.** What a check, a hook, or a script can guarantee is not left to prose. | Rules restated in several skills to make them stick |
| F11 | **One store per kind of memory.** Project truth lives in the project's repository. Recall across projects lives in the memory tool. A fact is never copied from one to the other, only pointed to. | Project state spread over five kinds of store |
| F12 | **Methodology stated once.** One always-loaded page names the workflow for each situation (prepare a project, join a started project, execute a task, review a change) and points to its detail, which loads on demand. | The same delegation rules written twice in the global instructions; review detail loaded in every session |
