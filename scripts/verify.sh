#!/bin/sh
# Checks the three plugins against the limits and the format in
# docs/wiki/01-product/style-guide.md, and validates their manifests.
# Usage: sh scripts/verify.sh [repository root]
# Exits 0 when every check passes, 1 otherwise.
set -u

root=${1:-$(cd "$(dirname "$0")/.." && pwd)}
plugins="$root/plugins"
agents_plugin="$plugins/playbook-agents"
wiki_plugin="$plugins/playbook-wiki"

max_contract_words=250     # L1, the contract of playbook-wiki
max_rules_words=400        # L1, the rules of playbook-agents
max_skill_body_words=700   # L2
max_description_chars=250  # L3
max_wiki_startup_words=350    # L4, playbook-wiki
max_agents_startup_words=620  # L4, playbook-agents

failures=0
fail() {
  printf 'FAIL %s\n' "$1"
  failures=$((failures + 1))
}

count_words() { wc -w | tr -d ' '; }
count_chars() { wc -m | tr -d ' '; }

# Prints the lines between the two "---" lines that open a skill file.
front_matter() {
  awk 'NR == 1 { if ($0 != "---") exit; next } $0 == "---" { exit } { print }' "$1"
}

# Prints a skill file without its front matter.
body() {
  awk 'NR == 1 && $0 == "---" { inside = 1; next }
       inside && $0 == "---" { inside = 0; next }
       !inside { print }' "$1"
}

# Manifests.
if command -v claude >/dev/null 2>&1; then
  for target in "$root" "$plugins/playbook" "$plugins/playbook-wiki" "$agents_plugin"; do
    if ! output=$(claude plugin validate "$target" 2>&1); then
      fail "claude plugin validate $target"
      printf '%s\n' "$output"
    fi
  done
else
  fail "the claude command is not installed, so the manifests were not validated"
fi

# L1: the contract of playbook-wiki and the rules of playbook-agents.
wiki_words=0
if [ -f "$wiki_plugin/contract.md" ]; then
  contract_words=$(count_words < "$wiki_plugin/contract.md")
  wiki_words=$contract_words
  if [ "$contract_words" -gt "$max_contract_words" ]; then
    fail "L1 contract.md has $contract_words words, limit $max_contract_words"
  fi
  # The hook for a subagent passes the contract as a JSON string, and it
  # escapes no control character but the end of a line.
  controls=$(LC_ALL=C tr -d '\n' < "$wiki_plugin/contract.md" | LC_ALL=C tr -cd '[:cntrl:]' | wc -c | tr -d ' ')
  if [ "$controls" -gt 0 ]; then
    fail "contract.md holds $controls control character(s), which the hook for a subagent cannot pass on"
  fi
else
  fail "L1 contract.md is missing"
fi
agents_words=0
if [ -f "$agents_plugin/rules.md" ]; then
  rules_words=$(count_words < "$agents_plugin/rules.md")
  agents_words=$rules_words
  if [ "$rules_words" -gt "$max_rules_words" ]; then
    fail "L1 rules.md has $rules_words words, limit $max_rules_words"
  fi
else
  fail "L1 rules.md is missing"
fi

# Adds the words of a description to the load of the plugin that holds it.
# add_startup <path relative to plugins/> <words>
add_startup() {
  case $1 in
    playbook-wiki/*) wiki_words=$((wiki_words + $2)) ;;
    playbook-agents/*) agents_words=$((agents_words + $2)) ;;
    # The start plugin loads nothing until the person starts it (D184).
    *) fail "the description of $1 loads at session start; only playbook-wiki and playbook-agents may load one" ;;
  esac
}

# The hooks of playbook-wiki: the contract at session start and for each
# subagent, and the merge step before a git merge.
hooks_json="$wiki_plugin/hooks/hooks.json"
hooks_start=$(awk '/"SessionStart"/ { inside = 1 }
                   /"SubagentStart"/ { inside = 0 }
                   inside' "$hooks_json" 2>/dev/null)
hooks_subagent=$(awk '/"SubagentStart"/ { inside = 1 }
                      /"SessionStart"|"PreToolUse"/ { inside = 0 }
                      inside' "$hooks_json" 2>/dev/null)
hooks_merge=$(awk '/"PreToolUse"/ { inside = 1 }
                   /"SessionStart"|"SubagentStart"/ { inside = 0 }
                   inside' "$hooks_json" 2>/dev/null)
# The text in single quotes is what hooks.json holds; Claude Code expands it.
# shellcheck disable=SC2016
case $hooks_start in
  *'${CLAUDE_PLUGIN_ROOT}/contract.md'*) ;;
  *) fail "hooks.json of playbook-wiki does not print contract.md under SessionStart" ;;
esac
# shellcheck disable=SC2016
case $hooks_subagent in
  *'${CLAUDE_PLUGIN_ROOT}/hooks/contract-for-subagent.sh'*) ;;
  *) fail "hooks.json of playbook-wiki does not run contract-for-subagent.sh under SubagentStart" ;;
esac
[ -f "$wiki_plugin/hooks/contract-for-subagent.sh" ] ||
  fail "hooks/contract-for-subagent.sh of playbook-wiki is missing"
# shellcheck disable=SC2016
case $hooks_merge in
  *'${CLAUDE_PLUGIN_ROOT}/hooks/merge-step-hook.sh'*) ;;
  *) fail "hooks.json of playbook-wiki does not run merge-step-hook.sh under PreToolUse" ;;
esac
case $hooks_merge in
  *'"matcher": "Bash"'*) ;;
  *) fail "hooks.json of playbook-wiki does not set \"matcher\": \"Bash\" under PreToolUse" ;;
esac
case $hooks_merge in
  # Bash(git merge *) would miss "git -C <dir> merge", seen in the trial of U35.
  *'"if": "Bash(git *)"'*) ;;
  *) fail "hooks.json of playbook-wiki does not set an \"if\" of Bash(git *) under PreToolUse, so the hook would miss a merge or run for every Bash call" ;;
esac
[ -f "$wiki_plugin/hooks/merge-step-hook.sh" ] ||
  fail "hooks/merge-step-hook.sh of playbook-wiki is missing"

# L2 and L3: each skill of each plugin.
for skill in "$plugins"/*/skills/*/SKILL.md; do
  [ -f "$skill" ] || continue
  name=${skill#"$plugins"/}

  matter=$(front_matter "$skill")
  keys=$(printf '%s\n' "$matter" | sed 's/:.*//' | tr '\n' ' ')
  case "$keys" in
    "name description ") ;;
    "name description context agent ")
      [ "$(printf '%s\n' "$matter" | sed -n 's/^context: *//p')" = "fork" ] ||
        fail "context of $name must be fork" ;;
    "name description disable-model-invocation ")
      [ "$(printf '%s\n' "$matter" | sed -n 's/^disable-model-invocation: *//p')" = "true" ] ||
        fail "disable-model-invocation of $name must be true" ;;
    *) fail "front matter of $name must hold name and description, or those two followed by context and agent, or by disable-model-invocation, in that order, one line each" ;;
  esac

  description=$(printf '%s\n' "$matter" | sed -n 's/^description: *//p' |
    sed 's/^"\(.*\)"$/\1/')
  description_chars=$(printf '%s' "$description" | count_chars)
  if [ "$description_chars" -gt "$max_description_chars" ]; then
    fail "L3 description of $name has $description_chars characters, limit $max_description_chars"
  fi
  # Claude Code keeps the description of a skill that only the owner starts
  # out of the session, so it does not count toward L4.
  case "$keys" in
    *disable-model-invocation*) ;;
    *) add_startup "$name" "$(printf '%s' "$description" | count_words)" ;;
  esac

  body_words=$(body "$skill" | count_words)
  if [ "$body_words" -gt "$max_skill_body_words" ]; then
    fail "L2 body of $name has $body_words words, limit $max_skill_body_words"
  fi
done

# A skill reads no Markdown file inside another skill: what two skills share
# lives at the plugin's own level, such as playbook-wiki/format.md.
shared_reads=$(find "$plugins" -path '*/skills/*' -name '*.md' -not -path '*/evals/*' | sort |
  while IFS= read -r file; do
    rest=${file#"$plugins"/*/skills/}
    own=${rest%%/*}
    grep -o '\.\./[a-z0-9-]*/[^ `"]*\.md' "$file" | sed 's|^\(\.\./\)*||; s|/.*||' | sort -u |
      while IFS= read -r other; do
        [ "$other" != "$own" ] && [ -d "${file%/skills/*}/skills/$other" ] &&
          printf '%s reads a file inside the skill %s; move what they share to the plugin'"'"'s own level\n' "${file#"$plugins"/}" "$other"
      done
  done)
if [ -n "$shared_reads" ]; then
  printf '%s\n' "$shared_reads" | while IFS= read -r line; do printf 'FAIL %s\n' "$line"; done
  failures=$((failures + $(printf '%s\n' "$shared_reads" | wc -l)))
fi

# Models: each agent file matches plugins/playbook-agents/models.conf.
if ! output=$(sh "$root/scripts/set-models.sh" --check "$root" 2>&1); then
  fail "agent files differ from plugins/playbook-agents/models.conf"
  printf '%s\n' "$output"
fi

# The models check reads only the agents of playbook-agents, so an agent file
# anywhere else would have a model that models.conf does not set.
for agent in "$plugins"/*/agents/*.md; do
  [ -f "$agent" ] || continue
  case $agent in
    "$agents_plugin"/agents/*) ;;
    *) fail "${agent#"$plugins"/} is not in playbook-agents, so models.conf does not set its model" ;;
  esac
done

# An agent of Claude Code may preload skills with a "skills" line: names on
# that line, separated by commas, each with or without the plugin's prefix. Claude Code
# gives no error for a name it does not find, and the agent then runs without
# that skill, so each name must be a skill of the plugin of the agent.
for agent in "$plugins"/*/agents/*.md; do
  [ -f "$agent" ] || continue
  plugin=${agent%/agents/*}
  name=${agent#"$plugins"/}
  if front_matter "$agent" | grep -q '^skills:[[:space:]]*$'; then
    fail "$name has a skills line with no name on it; write the names on that line, separated by commas"
  fi
  for skill in $(front_matter "$agent" | sed -n 's/^skills: *//p' | tr ',' ' '); do
    [ -f "$plugin/skills/${skill##*:}/SKILL.md" ] ||
      fail "$name preloads the skill '$skill', which is not in ${plugin#"$root"/}/skills"
  done
done

# L3 and L4: each agent description.
for agent in "$plugins"/*/agents/*.md; do
  [ -f "$agent" ] || continue
  name=${agent#"$plugins"/}
  description=$(front_matter "$agent" | sed -n 's/^description: *//p' |
    sed 's/^"\(.*\)"$/\1/')
  description_chars=$(printf '%s' "$description" | count_chars)
  if [ "$description_chars" -gt "$max_description_chars" ]; then
    fail "L3 description of $name has $description_chars characters, limit $max_description_chars"
  fi
  add_startup "$name" "$(printf '%s' "$description" | count_words)"
done

# L4: everything each plugin loads at session start.
if [ "$wiki_words" -gt "$max_wiki_startup_words" ]; then
  fail "L4 playbook-wiki loads $wiki_words words at session start, limit $max_wiki_startup_words"
fi
if [ "$agents_words" -gt "$max_agents_startup_words" ]; then
  fail "L4 playbook-agents loads $agents_words words at session start, limit $max_agents_startup_words"
fi

if [ "$failures" -gt 0 ]; then
  printf '%s check(s) failed\n' "$failures"
  exit 1
fi
printf 'verify passed: playbook-wiki loads %s words at session start, limit %s; playbook-agents loads %s, limit %s\n' \
  "$wiki_words" "$max_wiki_startup_words" "$agents_words" "$max_agents_startup_words"
