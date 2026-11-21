# What others say about reviewing code

The concepts third parties use to make a code reviewer do its job, studied on 2026-11-17 before this work opened, with the evidence for each and how strong it is. Nothing here is copied into the playbook: a concept becomes a change only when this work's measurement justifies it (review-evidence-2).

## Concepts

| # | Concept | Who states it | Evidence and its strength | The validator today |
|---|---------|---------------|---------------------------|---------------------|
| C1 | The reviewer is a context that did not write the change | Anthropic, [Best practices for Claude Code](https://code.claude.com/docs/en/best-practices.md): "A fresh reviewer does help, because it hasn't seen your reasoning" | Moderate. [Cross-Context Review, arXiv 2603.12123](https://arxiv.org/abs/2603.12123): 30 artifacts, 150 injected errors; a review in a fresh session (F1 28.6%) beats a second review in the same session (21.7%, Holm-adjusted p=0.004), but in its revised version it is not significantly ahead of one same-session review (27.1%, p=0.26) or a context-aware subagent (23.8%, p=0.057) | Has it: `review-change` forks into the agent `review` (`context: fork`) |
| C2 | Ask only for defects that make the change wrong, and skip style | Anthropic, same page: "A reviewer that's asked to find problems will always find *something*" | Strong. [arXiv 2607.03316](https://arxiv.org/abs/2607.03316), 31,073 CodeRabbit reviews and the developers' answers in 239 repositories: 36.4% accepted; secondary sources report 56.3% rejected, with false positives as the main reason | Has it: a finding needs a concrete failing case; style and preference are left out |
| C3 | Review against the specification, not for bugs in general | Anthropic, same page, "Review against your spec" | Recommendation of the vendor, no measurement found | Has it: the skill reads the wiki pages that govern the paths the change touches |
| C4 | What must happen every time is enforced by a hook, not written as a rule | Anthropic, same page: a rule in `CLAUDE.md` is a guideline, and "Claude is allowed to decide a guideline doesn't apply" | Recommendation of the vendor, no measurement found | Gap: R20 in `plugins/playbook-agents/rules.md` is a written rule; nothing measures how often the agent applies it |
| C5 | A read-only reviewer is enforced by its tools, not by its prompt | Anthropic, same page: give the reviewer `tools: Read, Grep, Glob` | Recommendation of the vendor, no measurement found | Partial: `plugins/playbook-agents/agents/review.md` has `Bash`, which `git diff` needs; reading only is asked in the skill's text |
| C6 | Review quality falls as the diff grows | A study cited at second hand: F1 from 0.800 on diffs of 10 to 50 lines to 0.043 on 150 to 600 lines | Weak: not read in its source | Unknown: several merged pull requests of this repository change more than 400 lines |
| C7 | A separate step verifies each finding before it is reported | Anthropic's Code Review ([docs](https://code.claude.com/docs/en/code-review.md)); CodeRabbit ([architecture](https://docs.coderabbit.ai/overview/architecture)) | Vendor claims: Anthropic reports fewer than 1% of findings marked incorrect, in its own use | Partial: the same agent that finds a defect drops the ones it cannot show, in one pass |
| C8 | A review is gated by the risk of what changed, not by its size | gentle-ai's review, [organic-rdd.md](https://github.com/Gentleman-Programming/gentle-ai/blob/main/docs/architecture/organic-rdd.md) | Practice of one project, no measurement found | Has it in text: R20 lists what makes a change risky |

## How a reviewer is measured

- No independent benchmark of a general-purpose AI reviewer was found. Published rankings reverse with who runs them: [Tenki](https://tenki.cloud/benchmarks/code-reviewer), [Martian, through Morph](https://www.morphllm.com/comparisons/coderabbit-vs-greptile), [TT Lab, 2026-07-17](https://ttlab.hopto.org/blog/2026-07-17-ai-code-review-measured-evidence?lang=en).
- The method these sources share: seed known defects, then count how many the reviewer finds (recall) and how many of its findings are real (precision). Recall alone can be raised by reporting more, so both are counted.

## Not verified

- The 56.3% rejection rate of arXiv 2607.03316: read in secondary sources, not in the paper.
- The F1 figures of C6: read in a secondary source, not in the study.
- The writer and reviewer pattern beyond what the best-practices page says: secondary guides only.
