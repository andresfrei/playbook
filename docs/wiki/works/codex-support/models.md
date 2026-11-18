# Codex agent model trials

The Claude configuration assigns Haiku to explore, Sonnet to write and Opus to review. The Codex generator sets the reasoning effort and inherits the model. See the [Claude configuration](../../../../plugins/playbook-agents/models.conf) and [Codex generator](../../../../codex/playbook-agents/package-roles.py).

On 2026-11-18 three named subagents were started from the installed Codex profiles. The table records the model and effort in the turn context of each child session.

| Agent | Task | Runtime model | Effort |
|-------|------|---------------|--------|
| explore | Locate the role generation call | gpt-6.2-astra | medium |
| write | Write and verify a text file in a temporary directory | gpt-6.2-astra | medium |
| review | Inspect model inheritance in the generator and installed profiles | gpt-6.2-astra | high |

These smoke tests establish which model each role runs in the owner's current setup. The follow-up trial below informed the installer defaults recorded in [codex-support-4](decisions.md).

## Candidate model trial on 2026-11-18

Four fresh subagent sessions used explicit model and effort overrides. The installed profiles still inherit the parent model.

| Task | Model and effort | Observed outcome |
|------|------------------|------------------|
| Map the review hook from packaging through commit retries and wiki-only changes | Sol 6.2 low | Correctly located registration, review mark, HEAD-based retry and wiki exemption. Also located the independent wiki validator. Completed in 26.2 seconds. |
| Same prompt and checkout | Astra 6.2 medium | Correctly located registration, mark, retry and wiki exemption. Completed in 21.2 seconds. |
| Write an isolated Python profile-copy command | Sol 6.2 medium | Three executable tests passed, covering initial installation, reruns, symlinks and concurrent writers. |
| Review the resulting command against its requirements | Astra 6.2 high | Static review found no defect against the Linux requirements and identified the dependency on hard-link support at the destination. |

Exploration times are single-turn durations from the child session records. Both agents worked in parallel. The writer prototype lived in a temporary directory. The parent independently ran the three tests. This trial did not measure billing, detect known seeded defects, or establish typical latency.
