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

migrate=$plugin/skills/migrate
source_migrate=$wiki/skills/migrate
mkdir -p "$migrate/agents" "$migrate/scripts"
cp "$src/playbook-wiki/migrate/openai.yaml" "$migrate/agents/"
# Codex runs no skill in a forked agent: migrate runs in the session, which follows wiki-writer.md.
# shellcheck disable=SC2016
sed '/^disable-model-invocation: true$/d; /^context: fork$/d; /^agent: playbook-wiki:wiki-writer$/d; /^## When to use$/i\
In Codex the session runs these steps itself, in the order given here, and follows `wiki-writer.md` at the wiki plugin root for how it writes and reports.\
' \
  "$source_migrate/SKILL.md" > "$migrate/SKILL.md"
sed 's/CLAUDE\.md/AGENTS.md/g' "$wiki/format.md" > "$plugin/format.md"
sed 's/CLAUDE\.md/AGENTS.md/g' "$wiki/skeleton.md" > "$plugin/skeleton.md"
sed 's| (/playbook-wiki:migrate)| (select migrate in /skills)|g' \
  "$source_migrate/scripts/wiki-format.sh" > "$migrate/scripts/wiki-format.sh"
# The agent wiki-writer is not a Codex profile: its steps are a file the session reads.
sed '1,/^---$/d; s/[$]{CLAUDE_PLUGIN_ROOT}/<wiki plugin root>/g; s/CLAUDE\.md/AGENTS.md/g' \
  "$wiki/agents/wiki-writer.md" > "$plugin/wiki-writer.md"

prepare=$plugin/skills/prepare-project
source_prepare=$wiki/skills/prepare-project
mkdir -p "$prepare/references" "$plugin/skills/write-docs"
# The backticks are literal Markdown in the shared skill. Codex substitutes no
# skill variable: a skill's folder is written as the folder of the skill.
# shellcheck disable=SC2016
sed 's/Use `AskUserQuestion` when available/Ask in the conversation or use the available question tool/; s/[$]{CLAUDE_SKILL_DIR}/<this skill'"'"'s folder>/g' \
  "$source_prepare/SKILL.md" > "$prepare/SKILL.md"
for reference in "$source_prepare"/references/*.md; do
  sed 's/CLAUDE\.md/AGENTS.md/g; s/Hand the shared pages to the agent `playbook-wiki:wiki-writer`, with a brief/Follow `wiki-writer.md` at the wiki plugin root yourself, with a brief/; s/ it writes what the work decided/ write what the work decided/' "$reference" > "$prepare/references/${reference##*/}"
done
cp "$src/playbook-wiki/working-agents.md" "$prepare/references/working-agents.md"
sed 's/[$]{CLAUDE_SKILL_DIR}/<this skill'"'"'s folder>/g' "$wiki/skills/write-docs/SKILL.md" > "$plugin/skills/write-docs/SKILL.md"

agents=$dest/plugins/playbook-agents
source_agents=$src/../plugins/playbook-agents
mkdir -p "$agents/.codex-plugin" "$agents/hooks"
cp "$src/playbook-agents/plugin.json" "$agents/.codex-plugin/plugin.json"
cp "$src/playbook-agents/hooks.json" "$agents/hooks/hooks.json"
cp "$src/playbook-agents/session-start.py" "$source_agents/rules.md" "$agents/"
cp "$source_agents/evidence.sh" "$source_agents/evidence-rules.md" "$source_agents/tasks.sh" "$agents/"
sed '1,/^---$/d; s/[$]{CLAUDE_PLUGIN_ROOT}/<agents plugin root>/g' \
  "$source_agents/agents/classify.md" > "$agents/record-findings.md"
mkdir "$agents/skills"
for skill in avoid-generic-design keep-minimal review-change write-skill; do
  cp -R "$source_agents/skills/$skill" "$agents/skills/"
done
sed '/^context: fork$/d; /^agent: playbook-agents:review$/d; /## When to use/i\
When invoked in the main session, delegate the change to the review agent if delegation is available. Inside review, perform the steps directly.\
' "$source_agents/skills/review-change/SKILL.md" > "$agents/skills/review-change/SKILL.md"
cp "$source_agents/hooks/hook-lib.sh" "$agents/hooks/"
sed 's/CLAUDE_PLUGIN_DATA/PLUGIN_DATA/g' "$source_agents/hooks/review-before-commit.sh" > "$agents/hooks/review-before-commit.sh"
sed 's/CLAUDE_PLUGIN_DATA/PLUGIN_DATA/g; s/playbook-agents:review/review/g' "$source_agents/hooks/review-ran.sh" > "$agents/hooks/review-ran.sh"
python3 "$src/playbook-agents/package-roles.py" "$source_agents/agents" "$agents/roles"
