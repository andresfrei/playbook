# Codex support execution plan

Approved under [codex-support-12](decisions.md). The existing adaptation is the starting point described in [current state](current-state.md). The units complete the [installer design](technology.md) and the public README task.

## Units

| ID | Unit | Deliverable and ending condition | Accepted by |
|----|------|---------------------------------|-------------|
| codex-support-U1 | Agent defaults | Generate and parse all three TOML profiles. Verify their models and efforts against codex-support-4 and run the repository checks. | Evidence |
| codex-support-U2 | One-command installation | Implement the Python entry point and tests. In separate clean profiles, the wiki selection installs the wiki alone and the full selection adds agents with the approved defaults. Both report the applicable hook trust steps. A rerun preserves custom role files, MCP settings and terminal preferences. A simulated partial failure identifies the failed step and a retry completes. | Evidence |
| codex-support-U3 | Installed behaviour | Exercise the packaged plugins through Codex in a disposable repository. Record contract loading, skill discovery, denial and retry of an invalid then corrected wiki commit, a merge requiring comparison, and a delegated review followed by a code commit. Verify the Claude repository checks still pass. | Evidence |
| codex-support-U4 | Public README | After verifying the installer, shorten the introduction and provide distinct Claude and Codex installation paths. Move detailed material to linked guides, check links and commands, and ask the owner to review readability. | Judgement |

## Progress

| Unit | Status | Evidence | Done on | Owner acceptance |
|------|--------|----------|---------|------------------|
| codex-support-U1 | Done | Packaged and parsed all three TOML profiles against codex-support-4. Repository and wiki checks passed. | 2026-11-18 | |
| codex-support-U2 | Done | Three installer integration tests passed with isolated profiles, including retry, concurrent publication, preserved settings, an alternate profile filename and a malformed profile. | 2026-11-18 | |
| codex-support-U3 | Done | Codex CLI 0.170.0 with a local scripted Responses provider and temporary profile loaded the contract, discovered skills, blocked an invalid wiki commit, committed the repair, and blocked a merge naming the shared page. A delegated review completed and the following code commit passed. Hook trust was enabled for the fixture invocation. Claude verify.sh, all verify_test.sh cases and ShellCheck passed. | 2026-11-18 | |
| codex-support-U4 | Done | Revised after owner feedback under codex-support-13. The README explains the working method, traces a real work, maps the repository and links both client guides. Local guide links resolve, the documented Codex command passed in isolated profiles and Claude CLI help confirms its installation commands. Each plugin guide includes a workflow diagram. The owner accepted the revised cover and banner. | 2026-11-18 | “si esta bien, proximos pasos?” |

## Delivery

Under codex-support-12, build the four units sequentially on the current work branch, `feat/codex-support`, then deliver the work through one pull request into `main`. The repository has used feature branches merged by pull request. The order lets the final guide describe commands that have passed the installed checks. Push, merge and release remain owner decisions. Changes to the Claude implementation and installation of personal MCP or terminal preferences are outside this plan.
