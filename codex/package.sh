#!/bin/sh
# Assemble a self-contained local Codex marketplace in a new directory.
set -eu
: "${1:?Usage: sh codex/package.sh NEW_DIRECTORY}"
src=$(cd "$(dirname "$0")" && pwd)
wiki=$src/../plugins/playbook-wiki
mkdir -- "$1"
dest=$(cd "$1" && pwd)
plugin=$dest/plugins/playbook-wiki
mkdir -p "$dest/.agents/plugins" "$plugin/.codex-plugin" "$plugin/hooks"
cp "$src/marketplace.json" "$dest/.agents/plugins/marketplace.json"
cp "$src/playbook-wiki/plugin.json" "$plugin/.codex-plugin/plugin.json"
cp "$src/playbook-wiki/hooks.json" "$plugin/hooks/hooks.json"
cp "$src/playbook-wiki/session-start.py" "$wiki/contract.md" "$wiki/merge-step.sh" "$wiki/check-wiki.sh" "$plugin/"
cp "$wiki/hooks/contract-for-subagent.sh" "$wiki/hooks/commit-check-hook.sh" "$src/playbook-wiki/merge-review.py" "$wiki/hooks/merge-step-hook.sh" "$wiki/hooks/git-hook-lib.sh" "$plugin/hooks/"

doctor=$plugin/skills/doctor
source_doctor=$wiki/skills/doctor
mkdir -p "$doctor/agents" "$doctor/scripts" "$doctor/references"
cp "$src/playbook-wiki/doctor/openai.yaml" "$doctor/agents/"
sed '/^disable-model-invocation: true$/d' "$source_doctor/SKILL.md" > "$doctor/SKILL.md"
for reference in "$source_doctor"/references/*.md; do
  sed 's/CLAUDE\.md/AGENTS.md/g' "$reference" > "$doctor/references/${reference##*/}"
done
sed 's/CLAUDE\.md/AGENTS.md/g' "$wiki/format.md" > "$plugin/format.md"
sed 's/CLAUDE\.md/AGENTS.md/g' "$wiki/skeleton.md" > "$plugin/skeleton.md"
sed 's| (/playbook-wiki:doctor)| (select doctor in /skills)|' \
  "$source_doctor/scripts/wiki-format.sh" > "$doctor/scripts/wiki-format.sh"

prepare=$plugin/skills/prepare-project
source_prepare=$wiki/skills/prepare-project
mkdir -p "$prepare/references" "$plugin/skills/write-docs"
# The backticks are literal Markdown in the shared skill.
# shellcheck disable=SC2016
sed 's/Use `AskUserQuestion` when available/Ask in the conversation or use the available question tool/' \
  "$source_prepare/SKILL.md" > "$prepare/SKILL.md"
for reference in "$source_prepare"/references/*.md; do
  sed 's/CLAUDE\.md/AGENTS.md/g' "$reference" > "$prepare/references/${reference##*/}"
done
cp "$wiki/skills/write-docs/SKILL.md" "$plugin/skills/write-docs/"

agents=$dest/plugins/playbook-agents
source_agents=$src/../plugins/playbook-agents
mkdir -p "$agents/.codex-plugin" "$agents/hooks"
cp "$src/playbook-agents/plugin.json" "$agents/.codex-plugin/plugin.json"
cp "$src/playbook-agents/hooks.json" "$agents/hooks/hooks.json"
cp "$src/playbook-agents/session-start.py" "$source_agents/rules.md" "$agents/"
cp -R "$source_agents/skills" "$agents/skills"
# /playbook-agents:config sets Claude Code's agents only (setup-commands-7).
rm -rf "$agents/skills/config"
sed '/^context: fork$/d; /^agent: playbook-agents:review$/d; /## When to use/i\
When invoked in the main session, delegate the change to the review agent if delegation is available. Inside review, perform the steps directly.\
' "$source_agents/skills/review-change/SKILL.md" > "$agents/skills/review-change/SKILL.md"
cp "$source_agents/hooks/hook-lib.sh" "$agents/hooks/"
sed 's/CLAUDE_PLUGIN_DATA/PLUGIN_DATA/g' "$source_agents/hooks/review-before-commit.sh" > "$agents/hooks/review-before-commit.sh"
sed 's/CLAUDE_PLUGIN_DATA/PLUGIN_DATA/g; s/playbook-agents:review/review/g' "$source_agents/hooks/review-ran.sh" > "$agents/hooks/review-ran.sh"
python3 "$src/playbook-agents/package-roles.py" "$source_agents/agents" "$agents/roles"
