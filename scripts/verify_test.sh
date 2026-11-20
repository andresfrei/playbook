#!/bin/sh
# Tests for scripts/verify.sh, scripts/set-models.sh, and the check of a
# project's wiki, plugins/playbook-wiki/check-wiki.sh. Each case builds a copy
# of the three plugins, or a small wiki, in a temporary directory, changes one thing,
# and checks the exit code and message.
# Usage: sh scripts/verify_test.sh
#
# Many cases pass a script in single quotes to sed or awk, where a $ must not
# be expanded by the shell.
# shellcheck disable=SC2016
set -u
# No case reads or writes the settings of the person running the tests.
unset CLAUDE_CONFIG_DIR CLAUDE_PROJECT_DIR

root=$(cd "$(dirname "$0")/.." && pwd)
tmp=$(mktemp -d)
[ -d "$tmp" ] || { printf 'could not make a temporary directory\n'; exit 1; }
trap 'rm -rf "$tmp"' EXIT
failed=0

# Prints n words on one line.
words() {
  awk -v n="$1" 'BEGIN { for (i = 0; i < n; i++) printf "word "; print "" }'
}

# Prints a string of n characters.
chars() {
  awk -v n="$1" 'BEGIN { for (i = 0; i < n; i++) printf "x"; print "" }'
}

# Creates a fresh copy of the plugins and its marketplace manifest.
fresh() {
  rm -rf "$tmp/repo"
  mkdir -p "$tmp/repo"
  cp -R "$root/.claude-plugin" "$root/plugins" "$tmp/repo/"
  mkdir "$tmp/repo/scripts"
  cp "$root/scripts/set-models.sh" "$tmp/repo/scripts/"
  # The real playbook-agents may sit at its limit of 620 words at session
  # start. Every case that adds a word of its own needs headroom that does not
  # depend on the real count, so the copy's description of write-skill is cut
  # to three words, in the copy only.
  ws="$tmp/repo/plugins/playbook-agents/skills/write-skill/SKILL.md"
  sed '3s/.*/description: Write a skill./' "$ws" > "$ws.new" && mv "$ws.new" "$ws"
}

# add_skill <name> <description> <body words> [extra front matter line]
# The skill goes to the plugin named in skill_plugin, playbook-agents by default.
add_skill() {
  dir="$tmp/repo/plugins/${skill_plugin:-playbook-agents}/skills/$1"
  mkdir -p "$dir"
  {
    printf -- '---\nname: %s\ndescription: %s\n' "$1" "$2"
    [ $# -ge 4 ] && printf '%s\n' "$4"
    printf -- '---\n'
    words "$3"
  } > "$dir/SKILL.md"
}

# expect <case name> <expected exit: pass|fail> [text the output must contain]
expect() {
  out=$(sh "$root/scripts/verify.sh" "$tmp/repo" 2>&1)
  code=$?
  ok=1
  if [ "$2" = pass ] && [ "$code" -ne 0 ]; then ok=0; fi
  if [ "$2" = fail ] && [ "$code" -eq 0 ]; then ok=0; fi
  if [ $# -ge 3 ] && ! printf '%s' "$out" | grep -q "$3"; then ok=0; fi
  if [ "$ok" -eq 1 ]; then
    printf 'ok    %s\n' "$1"
  else
    printf 'FAIL  %s (exit %s)\n%s\n' "$1" "$code" "$out"
    failed=$((failed + 1))
  fi
}

fresh
expect "skeleton passes" pass

fresh
add_skill at-limits "$(chars 250)" 700
expect "skill at the limits passes" pass

fresh
words 401 > "$tmp/repo/plugins/playbook-agents/rules.md"
expect "L1: rules file over 400 words fails" fail "L1 rules.md has 401 words"

fresh
rm "$tmp/repo/plugins/playbook-agents/rules.md"
expect "L1: missing rules file fails" fail "L1"

fresh
words 271 > "$tmp/repo/plugins/playbook-wiki/contract.md"
expect "L1: contract over 270 words fails" fail "L1 contract.md has 271 words"

fresh
words 270 > "$tmp/repo/plugins/playbook-wiki/contract.md"
words 400 > "$tmp/repo/plugins/playbook-agents/rules.md"
expect "L1: contract and rules at their limits pass" pass

fresh
rm "$tmp/repo/plugins/playbook-wiki/contract.md"
expect "L1: missing contract fails" fail "L1 contract.md is missing"

fresh
add_skill long-body "Short description." 701
expect "L2: skill body over 700 words fails" fail "L2"

fresh
add_skill long-description "$(chars 251)" 10
expect "L3: description over 250 characters fails" fail "L3"

fresh
add_skill bad--name "Short description." 10
expect "name: a double hyphen fails" fail "single hyphens"

fresh
add_skill Bad-name "Short description." 10
expect "name: a capital letter fails" fail "single hyphens"

fresh
add_skill "$(chars 64)" "Short description." 10
expect "name: 64 characters pass" pass

fresh
add_skill "$(chars 65)" "Short description." 10
expect "name: 65 characters fail" fail "65 characters, limit 64"

fresh
add_skill claude-helper "Short description." 10
expect "name: the word claude fails" fail "the word claude or anthropic"

fresh
add_skill my-anthropic "Short description." 10
expect "name: the word anthropic at the end fails" fail "the word claude or anthropic"

fresh
add_skill claudette "Short description." 10
expect "name: claude inside a word passes" pass

fresh
add_skill -lead "Short description." 10
expect "name: a leading hyphen fails" fail "single hyphens"

fresh
add_skill trail- "Short description." 10
expect "name: a trailing hyphen fails" fail "single hyphens"

fresh
add_skill quoted "Short description." 10
sed 's/^name: quoted$/name: "quoted" /' "$tmp/repo/plugins/playbook-agents/skills/quoted/SKILL.md" > "$tmp/skill.md"
cp "$tmp/skill.md" "$tmp/repo/plugins/playbook-agents/skills/quoted/SKILL.md"
expect "name: quoted, with a trailing space, passes" pass

# add_ref <skill> <file> <lines> [text of the first line]
add_ref() {
  dir="$tmp/repo/plugins/playbook-agents/skills/$1/references"
  mkdir -p "$dir"
  {
    [ $# -ge 4 ] && printf '%s\n' "$4"
    awk -v n="$3" 'BEGIN { for (i = 0; i < n; i++) print "line" }'
  } > "$dir/$2"
}

fresh
add_skill with-refs "Short description." 10
add_ref with-refs one.md 5 "Read two.md next."
add_ref with-refs two.md 5
expect "references: a reference naming another fails" fail "names two.md, another reference file"

fresh
add_skill with-refs "Short description." 10
add_ref with-refs one.md 101
expect "references: over 100 lines with no Contents fails" fail "101 lines and does not open with"

fresh
add_skill with-refs "Short description." 10
add_ref with-refs one.md 100 "## Contents"
add_ref with-refs two.md 100
expect "references: Contents, or 100 lines, pass" pass

fresh
add_skill with-refs "Short description." 10
add_ref with-refs one.md 5 "Read references/two.md next."
add_ref with-refs two.md 5
expect "references: a reference naming another by its path fails" fail "names two.md"

fresh
add_skill with-refs "Short description." 10
add_ref with-refs one.md 5 "See data.md and 5-a.md for the data."
add_ref with-refs a.md 5
expect "references: a name inside a longer name passes" pass

fresh
add_skill with-refs "Short description." 10
add_ref with-refs one.md 100 "## Usage"
printf '```markdown\n## Contents\n```\n' >> "$tmp/repo/plugins/playbook-agents/skills/with-refs/references/one.md"
expect "references: Contents only inside a code block fails" fail "does not open with"

fresh
add_skill with-refs "Short description." 10
add_ref with-refs one.md 100
printf 'last' >> "$tmp/repo/plugins/playbook-agents/skills/with-refs/references/one.md"
expect "references: 101 lines, the last with no newline, fail" fail "101 lines"

fresh
words 400 > "$tmp/repo/plugins/playbook-agents/rules.md"
for i in 1 2 3 4 5 6 7 8; do
  add_skill "skill-$i" "$(words 40 | cut -c1-200)" 10
done
expect "L4: playbook-agents over 620 words at session start fails" fail "L4 playbook-agents loads"

fresh
skill_plugin=playbook-wiki add_skill wiki-skill "$(words 40 | cut -c1-200)" 10
skill_plugin=playbook-wiki add_skill wiki-skill-2 "$(words 40 | cut -c1-200)" 10
expect "L4: playbook-wiki over 370 words at session start fails" fail "L4 playbook-wiki loads"

fresh
skill_plugin=playbook-wiki add_skill wiki-skill "$(words 40 | cut -c1-200)" 10 "disable-model-invocation: true"
expect "L4: a skill of playbook-wiki that only the owner starts is not counted" pass

fresh
sed 's/contract\.md/other.md/' "$tmp/repo/plugins/playbook-wiki/hooks/hooks.json" > "$tmp/hooks.json"
cp "$tmp/hooks.json" "$tmp/repo/plugins/playbook-wiki/hooks/hooks.json"
expect "hooks: hooks.json without the contract under SessionStart fails" fail "does not print contract.md under SessionStart"

fresh
sed 's/contract-for-subagent\.sh/other.sh/' "$tmp/repo/plugins/playbook-wiki/hooks/hooks.json" > "$tmp/hooks.json"
cp "$tmp/hooks.json" "$tmp/repo/plugins/playbook-wiki/hooks/hooks.json"
expect "hooks: hooks.json without the subagent script under SubagentStart fails" fail "does not run contract-for-subagent.sh under SubagentStart"

fresh
rm "$tmp/repo/plugins/playbook-wiki/hooks/contract-for-subagent.sh"
expect "hooks: a missing subagent script fails" fail "contract-for-subagent.sh of playbook-wiki is missing"

fresh
sed 's|/contract\.md|/hooks/contract.md|' "$tmp/repo/plugins/playbook-wiki/hooks/hooks.json" > "$tmp/hooks.json"
cp "$tmp/hooks.json" "$tmp/repo/plugins/playbook-wiki/hooks/hooks.json"
expect "hooks: the contract named at a path where it is not fails" fail "does not print contract.md under SessionStart"

fresh
sed 's|/hooks/contract-for-subagent\.sh|/contract-for-subagent.sh|' "$tmp/repo/plugins/playbook-wiki/hooks/hooks.json" > "$tmp/hooks.json"
cp "$tmp/hooks.json" "$tmp/repo/plugins/playbook-wiki/hooks/hooks.json"
expect "hooks: the subagent script named at a path where it is not fails" fail "does not run contract-for-subagent.sh under SubagentStart"

fresh
sed 's/merge-step-hook\.sh/other.sh/' "$tmp/repo/plugins/playbook-wiki/hooks/hooks.json" > "$tmp/hooks.json"
cp "$tmp/hooks.json" "$tmp/repo/plugins/playbook-wiki/hooks/hooks.json"
expect "hooks: hooks.json without the merge script under PreToolUse fails" fail "does not run merge-step-hook.sh under PreToolUse"

fresh
rm "$tmp/repo/plugins/playbook-wiki/hooks/merge-step-hook.sh"
expect "hooks: a missing merge script fails" fail "merge-step-hook.sh of playbook-wiki is missing"

fresh
sed 's|/hooks/merge-step-hook\.sh|/merge-step-hook.sh|' "$tmp/repo/plugins/playbook-wiki/hooks/hooks.json" > "$tmp/hooks.json"
cp "$tmp/hooks.json" "$tmp/repo/plugins/playbook-wiki/hooks/hooks.json"
expect "hooks: the merge script named at a path where it is not fails" fail "does not run merge-step-hook.sh under PreToolUse"

fresh
sed 's/commit-check-hook\.sh/other.sh/' "$tmp/repo/plugins/playbook-wiki/hooks/hooks.json" > "$tmp/hooks.json"
cp "$tmp/hooks.json" "$tmp/repo/plugins/playbook-wiki/hooks/hooks.json"
expect "hooks: hooks.json without the commit script under PreToolUse fails" fail "does not run commit-check-hook.sh under PreToolUse"

fresh
rm "$tmp/repo/plugins/playbook-wiki/hooks/commit-check-hook.sh"
expect "hooks: a missing commit script fails" fail "commit-check-hook.sh of playbook-wiki is missing"

fresh
rm "$tmp/repo/plugins/playbook-wiki/hooks/git-hook-lib.sh"
expect "hooks: a missing shared hook library fails" fail "git-hook-lib.sh of playbook-wiki is missing"

fresh
sed 's/review-ran\.sh/other.sh/' "$tmp/repo/plugins/playbook-agents/hooks/hooks.json" > "$tmp/hooks.json"
cp "$tmp/hooks.json" "$tmp/repo/plugins/playbook-agents/hooks/hooks.json"
expect "hooks: hooks.json of playbook-agents without the mark script fails" fail "does not run review-ran.sh under SubagentStop"

fresh
sed 's/"\^playbook-agents:review\$"/"review"/' "$tmp/repo/plugins/playbook-agents/hooks/hooks.json" > "$tmp/hooks.json"
cp "$tmp/hooks.json" "$tmp/repo/plugins/playbook-agents/hooks/hooks.json"
expect "hooks: a SubagentStop matcher that is not exact fails" fail "under SubagentStop"

fresh
sed 's/review-before-commit\.sh/other.sh/' "$tmp/repo/plugins/playbook-agents/hooks/hooks.json" > "$tmp/hooks.json"
cp "$tmp/hooks.json" "$tmp/repo/plugins/playbook-agents/hooks/hooks.json"
expect "hooks: hooks.json of playbook-agents without the hold script fails" fail "does not run review-before-commit.sh under PreToolUse"

fresh
sed 's/"if": "Bash(git \*)"/"if": "Bash(git commit *)"/' "$tmp/repo/plugins/playbook-agents/hooks/hooks.json" > "$tmp/hooks.json"
cp "$tmp/hooks.json" "$tmp/repo/plugins/playbook-agents/hooks/hooks.json"
expect "hooks: a hold hook with a narrower if fails" fail "playbook-agents does not set \"matcher\": \"Bash\" and an"

fresh
sed 's/ask-before-delivery\.sh/other.sh/' "$tmp/repo/plugins/playbook-agents/hooks/hooks.json" > "$tmp/hooks.json"
cp "$tmp/hooks.json" "$tmp/repo/plugins/playbook-agents/hooks/hooks.json"
expect "hooks: hooks.json of playbook-agents without the delivery hook fails" fail "does not run ask-before-delivery.sh"

fresh
sed 's/"matcher": "Bash"/"matcher": "Read"/' "$tmp/repo/plugins/playbook-agents/hooks/hooks.json" > "$tmp/hooks.json"
cp "$tmp/hooks.json" "$tmp/repo/plugins/playbook-agents/hooks/hooks.json"
expect "hooks: a delivery hook without the Bash matcher fails" fail "does not run ask-before-delivery.sh"

fresh
sed 's/agent-models\.sh/other.sh/' "$tmp/repo/plugins/playbook-agents/hooks/hooks.json" > "$tmp/hooks.json"
cp "$tmp/hooks.json" "$tmp/repo/plugins/playbook-agents/hooks/hooks.json"
expect "hooks: hooks.json of playbook-agents without the model hook fails" fail "does not run agent-models.sh"

fresh
sed 's/"matcher": "Agent"/"matcher": "Task"/' "$tmp/repo/plugins/playbook-agents/hooks/hooks.json" > "$tmp/hooks.json"
cp "$tmp/hooks.json" "$tmp/repo/plugins/playbook-agents/hooks/hooks.json"
expect "hooks: a model hook without the Agent matcher fails" fail "does not run agent-models.sh"

fresh
sed 's/rules-for-subagent\.sh/other.sh/' "$tmp/repo/plugins/playbook-agents/hooks/hooks.json" > "$tmp/hooks.json"
cp "$tmp/hooks.json" "$tmp/repo/plugins/playbook-agents/hooks/hooks.json"
expect "hooks: hooks.json of playbook-agents without the rules hook fails" fail "does not run rules-for-subagent.sh under SubagentStart"

fresh
sed 's/"\^playbook-agents:(write|review)\$"/"write"/' "$tmp/repo/plugins/playbook-agents/hooks/hooks.json" > "$tmp/hooks.json"
cp "$tmp/hooks.json" "$tmp/repo/plugins/playbook-agents/hooks/hooks.json"
expect "hooks: a SubagentStart matcher that is not exact fails" fail "under SubagentStart"

for f in review-ran.sh review-before-commit.sh ask-before-delivery.sh agent-models.sh hook-lib.sh rules-for-subagent.sh; do
  fresh
  rm "$tmp/repo/plugins/playbook-agents/hooks/$f"
  expect "hooks: a missing $f of playbook-agents fails" fail "hooks/$f of playbook-agents is missing"
done

fresh
sed 's/"matcher": "Bash"/"matcher": "Read"/' "$tmp/repo/plugins/playbook-wiki/hooks/hooks.json" > "$tmp/hooks.json"
cp "$tmp/hooks.json" "$tmp/repo/plugins/playbook-wiki/hooks/hooks.json"
expect "hooks: a PreToolUse group without the Bash matcher fails" fail 'matcher.*Bash.*under PreToolUse'

fresh
grep -v '"if": "Bash(git \*)"' "$tmp/repo/plugins/playbook-wiki/hooks/hooks.json" > "$tmp/hooks.json"
cp "$tmp/hooks.json" "$tmp/repo/plugins/playbook-wiki/hooks/hooks.json"
expect "hooks: a PreToolUse hook without the git condition fails" fail 'does not set an .if. of Bash(git \*)'

fresh
awk '/"if": "Bash\(git \*\)"/ && ++n == 2 { sub(/Bash\(git \*\)/, "Bash(git commit *)") } { print }' "$tmp/repo/plugins/playbook-wiki/hooks/hooks.json" > "$tmp/hooks.json"
cp "$tmp/hooks.json" "$tmp/repo/plugins/playbook-wiki/hooks/hooks.json"
expect "hooks: a commit hook with a narrower git condition fails" fail 'for both the merge and the commit hooks'

fresh
printf 'A form feed: \014\n' >> "$tmp/repo/plugins/playbook-wiki/contract.md"
expect "L1: a contract with a control character fails" fail "contract.md holds 1 control character"

fresh
skill_plugin=playbook add_skill starter-skill "Short description." 10
expect "L4: a skill the model can load in the start plugin fails" fail "only playbook-wiki and playbook-agents may load one"

fresh
skill_plugin=playbook add_skill starter-skill "Short description." 10 "disable-model-invocation: true"
expect "L4: a skill only the person starts in the start plugin passes" pass

fresh
printf 'Read `../../prepare-project/references/1-wiki.md`.\n' >> "$tmp/repo/plugins/playbook-wiki/skills/doctor/references/format-3.md"
expect "skills: a reference file that reads a file of another skill fails" fail "reads a file inside the skill prepare-project"

fresh
printf 'Read `../../../format.md`.\n' >> "$tmp/repo/plugins/playbook-wiki/skills/doctor/references/format-3.md"
expect "skills: a reference file that reads the plugin's format passes" pass

fresh
add_skill extra-key "Short description." 10 "license: MIT"
expect "front matter with a third key fails" fail "front matter"

fresh
add_skill forked "Short description." 10 "context: fork
agent: playbook-agents:review"
expect "front matter with context and agent passes" pass

fresh
add_skill forked-model "Short description." 10 "context: fork
agent: playbook-agents:review
model: opus"
expect "front matter with context, agent, and model fails" fail "front matter"

fresh
add_skill owner-only "Short description." 10 "disable-model-invocation: true"
expect "front matter with disable-model-invocation: true passes" pass

fresh
add_skill owner-only "Short description." 10 "disable-model-invocation: false"
expect "front matter with disable-model-invocation other than true fails" fail "disable-model-invocation of"

fresh
words 400 > "$tmp/repo/plugins/playbook-agents/rules.md"
for i in 1 2 3 4 5 6 7 8; do
  add_skill "skill-$i" "$(words 40 | cut -c1-200)" 10 "disable-model-invocation: true"
done
expect "L4: the description of a skill only the owner starts is not counted" pass

fresh
add_skill agent-only "Short description." 10 "agent: playbook-agents:review"
expect "front matter with agent and no context fails" fail "front matter"

fresh
add_skill inline "Short description." 10 "context: inline
agent: playbook-agents:review"
expect "front matter with a context other than fork fails" fail "context of"

# expect_models <case name> <expected exit: pass|fail> <text the output must contain> [args]
# Runs set-models.sh on the copy in --check mode, or with the given arguments.
expect_models() {
  name=$1; want=$2; text=$3; shift 3
  [ $# -eq 0 ] && set -- --check
  out=$(sh "$root/scripts/set-models.sh" "$@" "$tmp/repo" 2>&1)
  code=$?
  ok=1
  if [ "$want" = pass ] && [ "$code" -ne 0 ]; then ok=0; fi
  if [ "$want" = fail ] && [ "$code" -eq 0 ]; then ok=0; fi
  if [ -n "$text" ] && ! printf '%s' "$out" | grep -q "$text"; then ok=0; fi
  if [ "$ok" -eq 1 ]; then
    printf 'ok    %s\n' "$name"
  else
    printf 'FAIL  %s (exit %s)\n%s\n' "$name" "$code" "$out"
    failed=$((failed + 1))
  fi
}

fresh
expect_models "models: matching tree passes --check" pass ""

fresh
sed 's/^model: .*/model: opus/' "$tmp/repo/plugins/playbook-agents/agents/explore.md" > "$tmp/x" &&
  mv "$tmp/x" "$tmp/repo/plugins/playbook-agents/agents/explore.md"
expect_models "models: hand-edited model fails --check" fail "explore.md"
expect_models "models: --check changes nothing" fail "explore.md" --check
grep -q '^model: opus' "$tmp/repo/plugins/playbook-agents/agents/explore.md" ||
  { printf 'FAIL  models: --check changed a file\n'; failed=$((failed + 1)); }
sh "$root/scripts/set-models.sh" "$tmp/repo" >/dev/null 2>&1
expect_models "models: --check passes after the rewrite" pass ""

fresh
rm "$tmp/repo/plugins/playbook-agents/agents/review.md"
expect_models "models: configured agent without a file fails" fail "review.md"

fresh
cp "$tmp/repo/plugins/playbook-agents/agents/write.md" "$tmp/repo/plugins/playbook-agents/agents/extra.md"
expect_models "models: agent file absent from the configuration fails" fail "extra.md"

fresh
sed 's/^explore .*/explore  gpt  medium/' "$tmp/repo/plugins/playbook-agents/models.conf" > "$tmp/x" &&
  mv "$tmp/x" "$tmp/repo/plugins/playbook-agents/models.conf"
expect_models "models: invalid model is rejected" fail "gpt"

fresh
sed 's/^explore .*/explore  haiku  extreme/' "$tmp/repo/plugins/playbook-agents/models.conf" > "$tmp/x" &&
  mv "$tmp/x" "$tmp/repo/plugins/playbook-agents/models.conf"
expect_models "models: invalid effort is rejected" fail "extreme"

fresh
sed 's/^explore .*/explore  haiku  medium  extra/' "$tmp/repo/plugins/playbook-agents/models.conf" > "$tmp/x" &&
  mv "$tmp/x" "$tmp/repo/plugins/playbook-agents/models.conf"
expect_models "models: a fourth field is rejected" fail "more than three fields"

fresh
sed 's/^description: .*/description: '"$(chars 251)"'/' "$tmp/repo/plugins/playbook-agents/agents/write.md" > "$tmp/x" &&
  mv "$tmp/x" "$tmp/repo/plugins/playbook-agents/agents/write.md"
expect "L3: agent description over 250 characters fails" fail "L3 description of playbook-agents/agents/write.md"

# check <case name> <command...>: the case passes when the command succeeds.
check() {
  name=$1; shift
  if "$@"; then
    printf 'ok    %s\n' "$name"
  else
    printf 'FAIL  %s\n' "$name"
    failed=$((failed + 1))
  fi
}

absent() { [ ! -e "$1" ] && [ ! -L "$1" ]; }

# The check of a project's wiki.
check_wiki="$root/plugins/playbook-wiki/check-wiki.sh"

# fresh_wiki: a wiki at format 4 with an entry point and one page, each
# linking to the other. The table of pages names no code.
fresh_wiki() {
  rm -rf "$tmp/wiki"
  mkdir -p "$tmp/wiki/01-product"
  {
    printf '# Wiki\n\nProject owner: Ana.\n\n## Pages\n\n| Page | Content | Code it governs |\n|---|---|---|\n'
    printf '| [Overview](01-product/overview.md) | The product | |\n'
  } > "$tmp/wiki/README.md"
  printf '5\n' > "$tmp/wiki/.format"
  printf '# Overview\n\nBack to the [entry point](../README.md).\n' > "$tmp/wiki/01-product/overview.md"
}

# expect_wiki <case name> <expected exit: pass|fail> [text the output must contain] [wiki directory]
expect_wiki() {
  out=$(sh "$check_wiki" "${4:-$tmp/wiki}" 2>&1)
  code=$?
  ok=1
  if [ "$2" = pass ] && [ "$code" -ne 0 ]; then ok=0; fi
  if [ "$2" = fail ] && [ "$code" -eq 0 ]; then ok=0; fi
  if [ $# -ge 3 ] && [ -n "$3" ] && ! printf '%s' "$out" | grep -q -F "$3"; then ok=0; fi
  if [ "$ok" -eq 1 ]; then
    printf 'ok    %s\n' "$1"
  else
    printf 'FAIL  %s (exit %s)\n%s\n' "$1" "$code" "$out"
    failed=$((failed + 1))
  fi
}

fresh_wiki
printf 'See the [plan](../06-plan/plan.md).\n' >> "$tmp/wiki/01-product/overview.md"
expect_wiki "wiki: a link to a missing page fails and names both" fail "01-product/overview.md links to ../06-plan/plan.md"

fresh_wiki
printf 'See [the top](../README.md#where-work-stands), [here](#overview), [a site](https://example.com/a.md), and [mail](mailto:a@example.com).\n' >> "$tmp/wiki/01-product/overview.md"
expect_wiki "wiki: anchors and addresses with a scheme are not checked as files" pass

fresh_wiki
printf 'Write a link as `[text](missing.md)`.\n\n```text\n[text](also-missing.md)\n```\n' >> "$tmp/wiki/01-product/overview.md"
expect_wiki "wiki: a link inside code is not checked" pass

fresh_wiki
printf 'Two on one line: [a](../README.md) and [b](gone.md).\n' >> "$tmp/wiki/01-product/overview.md"
expect_wiki "wiki: the second link of a line is checked too" fail "links to gone.md"

fresh_wiki
rm "$tmp/wiki/README.md"
expect_wiki "wiki: a wiki without an entry point fails" fail "has no README.md"

fresh_wiki
rm -rf "$tmp/my wiki"
mv "$tmp/wiki" "$tmp/my wiki"
expect_wiki "wiki: a path with a space is read whole" pass "check-wiki passed" "$tmp/my wiki"
printf 'See [b](gone.md).\n' >> "$tmp/my wiki/01-product/overview.md"
expect_wiki "wiki: a broken link under a path with a space is found" fail "links to gone.md" "$tmp/my wiki"

fresh_wiki
printf '~~~text\n```\n~~~\n\nSee [b](gone.md).\n' >> "$tmp/wiki/01-product/overview.md"
expect_wiki "wiki: a code block ends only at the marker that opened it" fail "links to gone.md"

fresh_wiki
printf 'See [a](gone.md) and [b](lost.md).\n' >> "$tmp/wiki/01-product/overview.md"
expect_wiki "wiki: each broken link counts as one failure" fail "2 check(s) failed"

fresh_wiki
printf 'See [b](gone.md).\n' >> "$tmp/wiki/01-product/overview.md"
rm -f "$tmp/linked"
ln -s "$tmp/wiki" "$tmp/linked"
expect_wiki "wiki: a wiki directory that is a link is read" fail "links to gone.md" "$tmp/linked"

# The paths a wiki names as code, read from the project's root.
# fresh_project: a project with a folder and a file of code, and a wiki in
# docs/wiki whose table of pages names no code.
fresh_project() {
  rm -rf "$tmp/project"
  mkdir -p "$tmp/project/docs" "$tmp/project/src/filters"
  printf 'code\n' > "$tmp/project/src/filters/list.ts"
  fresh_wiki
  mv "$tmp/wiki" "$tmp/project/docs/wiki"
  project_wiki="$tmp/project/docs/wiki"
}
# governs <cell>: adds a row to the table of pages with that last cell.
governs() {
  printf '| [Overview](01-product/overview.md) | The filters | %s |\n' "$1" >> "$project_wiki/README.md"
}

fresh_project
governs '`src/filters/`, `src/filters/list.ts`'
expect_wiki "paths: a folder and a file that exist pass" pass "" "$project_wiki"

fresh_project
governs '`src/sorting/`'
expect_wiki "paths: a path that does not exist fails and names the page and the path" fail "README.md names the path src/sorting/, which does not exist" "$project_wiki"

fresh_project
governs '`src/filters/` and `src/gone.ts`'
expect_wiki "paths: the second path of a cell is checked too" fail "names the path src/gone.ts" "$project_wiki"

fresh_project
governs '`src/a/`, `src/b/`'
expect_wiki "paths: each missing path counts as one failure" fail "2 check(s) failed" "$project_wiki"

fresh_project
printf '| [Overview](01-product/overview.md) | Built with `no-such-tool` | `src/filters/` |\n' >> "$project_wiki/README.md"
expect_wiki "paths: code text in another column is not read as a path" pass "" "$project_wiki"

fresh_project
printf '\n| Code it governs | Page |\n|---|---|\n| `src/gone/` | [Overview](01-product/overview.md) |\n' >> "$project_wiki/README.md"
expect_wiki "paths: the column is found wherever it is in the table" fail "names the path src/gone/" "$project_wiki"

fresh_project
printf '\nSee `src/gone/`.\n\n| Page | Content |\n|---|---|\n| `src/gone/` | No such column here |\n' >> "$project_wiki/README.md"
expect_wiki "paths: a later table without the column is not read" pass "" "$project_wiki"

fresh_project
printf '\n```text\n| Page | Code it governs |\n| An example | `src/gone/` |\n```\n' >> "$project_wiki/README.md"
expect_wiki "paths: a table inside a code block is not read" pass "" "$project_wiki"

fresh_project
printf '\n## Code on the old definition\n\n| Path | Decision | What the owner chose |\n|---|---|---|\n| `src/filters/list.ts` | `D41` | Debt |\n' >> "$project_wiki/01-product/overview.md"
expect_wiki "paths: listed old code that exists passes, and its other cells are not paths" pass "" "$project_wiki"

fresh_project
printf '\n## Code on the old definition\n\n| Path | Decision |\n|---|---|\n| `src/old.ts` | D41 |\n' >> "$project_wiki/01-product/overview.md"
expect_wiki "paths: listed old code that is gone fails and names the page" fail "01-product/overview.md names the path src/old.ts" "$project_wiki"

fresh_project
printf '\n## Code on the old definition\n\nNone.\n\n## Notes\n\n| Tool | Use |\n|---|---|\n| `no-such-tool` | None |\n' >> "$project_wiki/01-product/overview.md"
expect_wiki "paths: the next heading ends the list of old code" pass "" "$project_wiki"

fresh_project
rm -rf "$tmp/store"
mkdir "$tmp/store"
mv "$project_wiki" "$tmp/store/wiki"
ln -s "$tmp/store/wiki" "$project_wiki"
governs '`src/filters/`'
expect_wiki "paths: under a wiki directory that is a link, a path is read from the project that links to it" pass "" "$project_wiki"
governs '`src/gone/`'
expect_wiki "paths: under a wiki directory that is a link, a missing path fails" fail "names the path src/gone/" "$project_wiki"

fresh_project
printf '\n| Page | Content | Code it governs\n|---|---|---\n| x | y | `src/gone/`\n' >> "$project_wiki/README.md"
expect_wiki "paths: the column is found in a table whose rows do not end in a bar" fail "names the path src/gone/" "$project_wiki"

fresh_project
printf '\n| Page | Code it governs |\n|---|---|\n| An example | `src/gone/` |\n' >> "$project_wiki/01-product/overview.md"
expect_wiki "paths: the column is read in the entry point only" pass "" "$project_wiki"

fresh_project
printf '\n## Code on the old definition\n\n### Filters\n\n| Path | Decision |\n|---|---|\n| `src/old.ts` | D41 |\n' >> "$project_wiki/01-product/overview.md"
expect_wiki "paths: a smaller heading does not end the list of old code" fail "names the path src/old.ts" "$project_wiki"

fresh_project
governs '`src/filters/`'
awk '{ printf "%s\r\n", $0 }' "$project_wiki/README.md" > "$tmp/readme" && mv "$tmp/readme" "$project_wiki/README.md"
expect_wiki "paths: a table whose lines end in a carriage return is read" pass "" "$project_wiki"

fresh_project
state_readme=$project_wiki/README.md
printf '# Wiki\n\nProject owner: Ana.\n\n## Pages\n\n| Page | Content |\n|---|---|\n| [Overview](01-product/overview.md) | Built with `no-such-tool` |\n' > "$state_readme"
expect_wiki "paths: a wiki whose table of pages has no such column passes as before" pass "" "$project_wiki"
check "column: a table of pages without the column is reported" sh -c '! sh "$1" --column "$2"' sh "$check_wiki" "$project_wiki"

fresh_project
check "column: a table of pages with the column is found" sh "$check_wiki" --column "$project_wiki"
printf '# Wiki\n\n## Where work stands\n\nNothing open.\n\n```text\n| Page | Content | Code it governs |\n```\n' > "$project_wiki/README.md"
check "column: a column inside a code block is not one" sh -c '! sh "$1" --column "$2"' sh "$check_wiki" "$project_wiki"

# The rows of decisions.md.
# decision <id> <words of the decision> [words of the owner]: prints one row.
decision() {
  printf '| %s | 2026-01-01 | %s | "%s" |\n' "$1" "$(words "$2")" "$(words "${3:-1}")"
}
# decisions: starts decisions.md of the wiki in $tmp/wiki with its heading.
decisions() {
  printf '# Decisions\n\n| ID | Date | Decision | Owner'"'"'s words |\n|---|---|---|---|\n' > "$tmp/wiki/decisions.md"
}

fresh_wiki
decisions
{ decision D1 200; decision TD1 90; } >> "$tmp/wiki/decisions.md"
printf '5\n' > "$tmp/wiki/.format"
expect_wiki "decisions: the rows of the top-level decisions.md are history and are not read" pass

# The works of a wiki: a folder for each work, with identifiers that carry the
# work's name.
# mkwork <name> <date of <name>-1> <date of <name>-2>: a work in $project_wiki
# that passes the check, and the shared page that cites its first decision.
mkwork() {
  d=$project_wiki/works/$1
  mkdir -p "$d"
  printf '# %s\n\n## Where work stands\n\nNothing open.\n\n## Pages\n\n| Page | Content | Code it governs |\n|---|---|---|\n| [Decisions](decisions.md) | What was decided | `src/filters/` |\n' "$1" > "$d/README.md"
  {
    printf '# Decisions\n\n| ID | Date | Decision | Who decided | Their words | Shared page |\n|---|---|---|---|---|---|\n'
    printf '| %s-1 | %s | Rule one of %s | Ana | "yes" | `01-product/%s.md` |\n' "$1" "$2" "$1" "$1"
    printf '| %s-2 | %s | Rule two of %s | Ana | "go" | None |\n' "$1" "$3" "$1"
  } > "$d/decisions.md"
  printf '# Questions\n\n| ID | Question | Recommendation | Blocks |\n|---|---|---|---|\n| %s-Q1 | Which one? | The first | Unit 1 |\n' "$1" > "$d/questions.md"
  printf '# Plan\n\n| Unit | Status |\n|---|---|\n| %s-U1 | Built |\n| %s-U2 | Not started |\n\n## Units\n\n| Unit | Ending condition |\n|---|---|\n| %s-U1 | It runs |\n| %s-U2 | It ships |\n' "$1" "$1" "$1" "$1" > "$d/plan.md"
  printf '# %s\n\nThe rule of the work (%s-1).\n' "$1" "$1" > "$project_wiki/01-product/$1.md"
}
# fresh_works: two works, with decisions in an order that is not the order of their dates.
fresh_works() {
  fresh_project
  mkwork auth 2026-03-05 2026-01-10
  mkwork billing 2026-02-01 2026-03-05
}
# edit <file> <sed script>
edit() {
  sed "$2" "$1" > "$tmp/x" && mv "$tmp/x" "$1"
}

fresh_works
expect_wiki "works: two works that follow the format pass" pass "" "$project_wiki"

fresh_works
mv "$project_wiki/works/auth" "$project_wiki/works/Auth_x"
expect_wiki "works: a folder with a name that is not lowercase letters, digits, and hyphens fails" fail "FAIL works/Auth_x: the name of the folder" "$project_wiki"

fresh_works
mv "$project_wiki/works/auth" "$project_wiki/works/auth--x"
expect_wiki "works: a name with two hyphens in a row fails" fail "FAIL works/auth--x: the name of the folder" "$project_wiki"

fresh_works
rm "$project_wiki/works/auth/README.md"
expect_wiki "works: a work without README.md fails" fail "FAIL works/auth has no README.md" "$project_wiki"

fresh_works
edit "$project_wiki/works/auth/decisions.md" 's/^| auth-2 /| billing-3 /'
expect_wiki "works: a decision of another work fails and names both" fail "FAIL works/auth/decisions.md: billing-3 carries the work billing, but the folder is auth" "$project_wiki"

fresh_works
edit "$project_wiki/works/auth/decisions.md" 's/^| auth-2 /| auth-Q1 /'
expect_wiki "works: a question identifier in decisions.md fails" fail "FAIL works/auth/decisions.md: auth-Q1 has the wrong letter" "$project_wiki"

fresh_works
edit "$project_wiki/works/auth/questions.md" 's/^| auth-Q1 /| auth-2 /'
expect_wiki "works: a decision identifier in questions.md fails" fail "FAIL works/auth/questions.md: auth-2 has the wrong letter" "$project_wiki"

fresh_works
edit "$project_wiki/works/auth/plan.md" 's/^| auth-U2 | Not started/| auth-U02 | Not started/'
expect_wiki "works: a unit with a leading zero in plan.md fails" fail "FAIL works/auth/plan.md: auth-U02 is not an identifier" "$project_wiki"

fresh_works
printf '\n| Date | What |\n|---|---|\n| 2026-01-10 | started |\n| node-18 | runtime |\n| auth-3 | a decision named in a note |\n' >> "$project_wiki/works/auth/plan.md"
expect_wiki "works: a table of dates and names in plan.md passes" pass "" "$project_wiki"

fresh_works
edit "$project_wiki/works/auth/plan.md" 's/^| auth-U2 | Not started/| billing-U2 | Not started/'
expect_wiki "works: a unit of another work in plan.md fails" fail "FAIL works/auth/plan.md: billing-U2 carries the work billing, but the folder is auth" "$project_wiki"

fresh_works
edit "$project_wiki/works/auth/plan.md" 's/^| auth-U2 | Not started/| Unit 2 | Not started/'
expect_wiki "works: a plan row whose first cell is not an identifier is not checked" pass "" "$project_wiki"

fresh_works
edit "$project_wiki/works/auth/decisions.md" 's/^| auth-2 /| Two /'
expect_wiki "works: a cell in decisions.md that is not an identifier fails" fail "FAIL works/auth/decisions.md: Two is not an identifier" "$project_wiki"

fresh_works
edit "$project_wiki/works/auth/decisions.md" 's/^| auth-2 /| auth-02 /'
expect_wiki "works: a counter with a leading zero fails" fail "FAIL works/auth/decisions.md: auth-02 is not an identifier" "$project_wiki"

fresh_works
edit "$project_wiki/works/auth/decisions.md" 's/^| auth-2 /| auth-0 /'
expect_wiki "works: a counter of zero fails" fail "FAIL works/auth/decisions.md: auth-0 is not an identifier" "$project_wiki"

fresh_works
edit "$project_wiki/works/auth/decisions.md" 's/^| auth-2 /| auth-1 /'
expect_wiki "works: an identifier repeated in a table fails" fail "FAIL works/auth/decisions.md: auth-1 is repeated" "$project_wiki"

fresh_works
expect_wiki "works: the same unit in two tables of plan.md is not a repeat" pass "" "$project_wiki"

fresh_works
edit "$project_wiki/works/auth/plan.md" 's/^| auth-U2 | Not started/| auth-U1 | Not started/'
expect_wiki "works: a unit repeated in one table of plan.md fails" fail "FAIL works/auth/plan.md: auth-U1 is repeated" "$project_wiki"

fresh_works
edit "$project_wiki/works/auth/decisions.md" 's|`01-product/auth.md`|`01-product/gone.md`|'
expect_wiki "works: a shared page that does not exist fails" fail "FAIL works/auth/decisions.md: the shared page 01-product/gone.md of auth-1 is not a file" "$project_wiki"

fresh_works
printf '# auth\n\nA rule with no citation.\n' > "$project_wiki/01-product/auth.md"
expect_wiki "works: a shared page that does not cite the identifier fails" fail "FAIL works/auth/decisions.md: the shared page 01-product/auth.md does not cite auth-1" "$project_wiki"

fresh_works
printf '# auth\n\nA rule (auth-10) and one (xauth-1) and one (auth-1-b).\n' > "$project_wiki/01-product/auth.md"
expect_wiki "works: a page that cites auth-10, xauth-1, and auth-1-b does not cite auth-1" fail "does not cite auth-1" "$project_wiki"

fresh_works
printf '# auth\n\nA rule, auth-1, and another.\n' > "$project_wiki/01-product/auth.md"
expect_wiki "works: an identifier between a comma and a comma is a whole word" pass "" "$project_wiki"

fresh_works
printf '# auth\n\nauth-1\n' > "$project_wiki/01-product/auth.md"
expect_wiki "works: an identifier that is the whole line is a whole word" pass "" "$project_wiki"

fresh_works
edit "$project_wiki/works/auth/decisions.md" 's|`01-product/auth.md`|`works/auth/README.md`|'
expect_wiki "works: a shared page under works/ fails" fail "FAIL works/auth/decisions.md: the shared page works/auth/README.md of auth-1 is under works/" "$project_wiki"

fresh_works
edit "$project_wiki/works/auth/decisions.md" 's|`01-product/auth.md`|`01-product/auth.md`, `01-product/billing.md`|'
expect_wiki "works: of two shared pages, the one that does not cite the identifier fails" fail "the shared page 01-product/billing.md does not cite auth-1" "$project_wiki"

fresh_works
edit "$project_wiki/works/auth/decisions.md" 's/| None |$/| NONE  |/'
expect_wiki "works: none is read without regard to case" pass "" "$project_wiki"

fresh_works
edit "$project_wiki/works/auth/decisions.md" 's/| None |$/| nothing |/'
expect_wiki "works: a shared page that is neither none nor a code span fails" fail "FAIL works/auth/decisions.md: the shared page of auth-2 is neither none nor a path" "$project_wiki"

fresh_works
edit "$project_wiki/works/auth/decisions.md" 's/| None |$/| |/'
expect_wiki "works: an empty shared page fails" fail "the shared page of auth-2 is neither none" "$project_wiki"

fresh_works
edit "$project_wiki/works/auth/decisions.md" 's/| "go" | None |$/| "go" |/'
expect_wiki "works: a decision without the sixth column fails" fail "FAIL works/auth/decisions.md: the row of auth-2 has 5 columns and no shared-page column" "$project_wiki"

fresh_works
edit "$project_wiki/works/auth/decisions.md" "s/^| auth-2 | 2026-01-10 | Rule two of auth/| auth-2 | 2026-01-10 | $(words 61)/"
expect_wiki "works: a decision over 60 words fails" fail "FAIL works/auth/decisions.md: the decision of auth-2 has 61 words, limit 60" "$project_wiki"

fresh_works
edit "$project_wiki/works/auth/decisions.md" "s/^| auth-2 | 2026-01-10 | Rule two of auth/| auth-2 | 2026-01-10 | $(words 60)/"
expect_wiki "works: a decision of 60 words passes" pass "" "$project_wiki"

fresh_works
edit "$project_wiki/works/auth/README.md" "s/Nothing open\./$(words 251)/"
expect_wiki "works: a work's state section over 250 words fails" fail "FAIL works/auth/README.md: \"Where work stands\" has 251 words, limit 250" "$project_wiki"

fresh_works
edit "$project_wiki/works/auth/README.md" "s/Nothing open\./$(words 250)/"
expect_wiki "works: a work's state section of 250 words passes" pass "" "$project_wiki"

fresh_works
edit "$project_wiki/works/auth/README.md" '/Where work stands/,/^$/d'
edit "$project_wiki/works/auth/README.md" '/^Nothing open\.$/d'
expect_wiki "works: a work without a state section passes" pass "" "$project_wiki"

fresh_works
edit "$project_wiki/works/auth/README.md" 's|src/filters/|src/gone/|'
expect_wiki "works: a path that a work's README names and that is gone fails" fail "works/auth/README.md names the path src/gone/" "$project_wiki"

# BSD find, as on macOS, prints "<dir>//<file>" for "find <dir>/".
mkdir -p "$tmp/bsd-find"
printf '#!/bin/sh\nroot=${1%%/}/\n%s "$@" | awk -v r="$root" '"'"'index($0, r) == 1 { $0 = r "/" substr($0, length(r) + 1) } { print }'"'"'\n' "$(command -v find)" > "$tmp/bsd-find/find"
chmod +x "$tmp/bsd-find/find"
out=$(PATH="$tmp/bsd-find:$PATH" sh "$check_wiki" "$project_wiki" 2>&1)
check "works: with the paths of BSD find, a gone path in a work's README still fails" sh -c 'printf "%s" "$1" | grep -q "names the path src/gone/"' sh "$out"

fresh_works
printf '# Notes\n\n| Page | Code it governs |\n|---|---|\n| An example | `src/gone/` |\n' > "$project_wiki/works/auth/notes.md"
expect_wiki "works: the column of code is read in the README of a work only" pass "" "$project_wiki"

fresh_works
mkdir "$project_wiki/works/auth/notes"
printf '\n| Page | Code it governs |\n|---|---|\n| An example | `src/gone/` |\n' > "$project_wiki/works/auth/notes/README.md"
expect_wiki "works: a README deeper in a work is not the work's README" pass "" "$project_wiki"

fresh_works
printf '\n## Code on the old definition\n\n| Path | Decision | What was chosen |\n|---|---|---|\n| `src/old.ts` | auth-1 | Debt |\n' >> "$project_wiki/works/auth/README.md"
expect_wiki "works: old code that is gone, listed in a page of a work, fails" fail "works/auth/README.md names the path src/old.ts" "$project_wiki"

fresh_works
printf 'See [the plan](gone.md).\n' >> "$project_wiki/works/auth/README.md"
expect_wiki "works: a broken link in a page of a work fails" fail "works/auth/README.md links to gone.md" "$project_wiki"

fresh_works
printf '# Notes\n\nSee [the plan](gone.md).\n' > "$project_wiki/works/auth/notes.md"
expect_wiki "works: a broken link in a page of a work that is not its README fails" fail "works/auth/notes.md links to gone.md" "$project_wiki"

fresh_works
printf '\n| Name | Value |\n|---|---|\n| auth-1 | again |\n```text\n| auth-1 | again |\n```\n' >> "$project_wiki/works/auth/questions.md"
expect_wiki "works: a table of questions.md with a row of the wrong letter fails" fail "FAIL works/auth/questions.md: auth-1 has the wrong letter" "$project_wiki"
check "works: a row inside a code block right after a table is not read" test "$(sh "$check_wiki" "$project_wiki" | grep -c 'auth-1 has the wrong letter')" = 1

fresh_works
printf '| <work>-<n> | <date> | A template in a code block | <who> | <words> | none |\n' > "$tmp/template-row"
awk -v row="$(cat "$tmp/template-row")" '{ print } /^\|---/ && !done { print "```text"; print "| ID | Date | Decision | Who | Words | Page |"; print "|---|---|---|---|---|---|"; print row; print "```"; done = 1 }' "$project_wiki/works/auth/decisions.md" > "$tmp/x" && mv "$tmp/x" "$project_wiki/works/auth/decisions.md"
expect_wiki "works: a template table inside a code block in decisions.md is not read" pass "" "$project_wiki"

fresh_works
printf '\nA table of another kind:\n\n| ID | Question | Recommendation | Blocks |\n|---|---|---|---|\n| auth-Q1 | Again | No | None |\n' >> "$project_wiki/works/auth/questions.md"
expect_wiki "works: an identifier repeated in a second table is not a repeat" pass "" "$project_wiki"

fresh_works
printf '\n| ID | Question | Recommendation | Blocks |\n| auth-Q1 | Again | No | None |\n' >> "$project_wiki/works/auth/questions.md"
expect_wiki "works: a table line that follows no separator line is not a row" pass "" "$project_wiki"

fresh_works
rm -rf "$project_wiki/works/auth/questions.md" "$project_wiki/works/auth/plan.md"
expect_wiki "works: a work without questions.md and plan.md passes" pass "" "$project_wiki"

fresh_works
edit "$project_wiki/works/auth/decisions.md" 's/^| auth-2 /| auth-1 /'
edit "$project_wiki/works/billing/decisions.md" 's/^| billing-2 /| billing-1 /'
out=$(sh "$check_wiki" "$project_wiki" 2>&1)
check "works: each failure is counted" sh -c 'printf "%s\n" "$1" | grep -q -F "2 check(s) failed"' sh "$out"

# --decisions: the decisions of every work, by date, then work, then number.
fresh_works
printf '| auth-10 | 2026-01-10 | Rule ten of auth | Ana | "ok" | none |\n' >> "$project_wiki/works/auth/decisions.md"
printf '2026-01-10 auth-2 Rule two of auth\n2026-01-10 auth-10 Rule ten of auth\n2026-02-01 billing-1 Rule one of billing\n2026-03-05 auth-1 Rule one of auth\n2026-03-05 billing-2 Rule two of billing\n' > "$tmp/expected"
sh "$check_wiki" --decisions "$project_wiki" > "$tmp/actual" 2>&1
check "works: --decisions prints the decisions of both works by date, work, and number" cmp -s "$tmp/expected" "$tmp/actual"
check "works: --decisions exits 0" sh -c 'sh "$1" --decisions "$2" >/dev/null' sh "$check_wiki" "$project_wiki"

fresh_works
edit "$project_wiki/works/auth/README.md" "s/Nothing open\./$(words 400)/"
rm "$project_wiki/01-product/auth.md"
check "works: --decisions checks nothing and exits 0" sh -c 'sh "$1" --decisions "$2" >/dev/null' sh "$check_wiki" "$project_wiki"

fresh_project
check "works: --decisions prints nothing for a wiki without works" test -z "$(sh "$check_wiki" --decisions "$project_wiki")"

fresh_works
printf '\n```text\n| auth-5 | 2026-01-01 | In a code block | Ana | "x" | none |\n```\n' >> "$project_wiki/works/auth/decisions.md"
check "works: --decisions skips a row inside a code block" test "$(sh "$check_wiki" --decisions "$project_wiki" | wc -l | tr -d ' ')" = 4

fresh_works
awk '{ print } /^\| auth-1 / { print "```text"; print "| auth-6 | 2026-01-01 | In a code block | Ana | x | none |"; print "```" }' "$project_wiki/works/auth/decisions.md" > "$tmp/x" && mv "$tmp/x" "$project_wiki/works/auth/decisions.md"
check "works: --decisions skips a code block right after a row" test "$(sh "$check_wiki" --decisions "$project_wiki" | grep -c auth-6)" = 0

check "works: --decisions on a missing directory fails" sh -c '! sh "$1" --decisions "$2" >/dev/null 2>&1' sh "$check_wiki" "$tmp/no-such-wiki"

fresh_works
rm "$project_wiki/README.md"
check "works: --decisions needs no README.md" test "$(sh "$check_wiki" --decisions "$project_wiki" | wc -l | tr -d ' ')" = 4

fresh_works


# Format 5: the columns Kind and Answer, at the end of a row of decisions.md.
# kind_rows <first number> <count> <kind> <answer>: appends rows of the work
# auth, in its decisions.md, with a seventh and an eighth cell. A cell given
# as - is left empty.
kind_rows() {
  awk -v first="$1" -v count="$2" -v kind="$3" -v answer="$4" 'BEGIN {
    if (kind == "-") kind = ""
    if (answer == "-") answer = ""
    for (i = 0; i < count; i++)
      printf "| auth-%d | 2026-04-01 | Row %d | Ana | \"yes\" | none | %s | %s |\n", first + i, first + i, kind, answer
  }' >> "$project_wiki/works/auth/decisions.md"
}
# kind_case <case name> <pass|fail> <kind> <answer> [text the output must contain]
kind_case() {
  fresh_works
  kind_rows 10 1 "$3" "$4"
  expect_wiki "format 5: $1" "$2" "${5:-}" "$project_wiki"
}
for kind in definition technology plan open-work close-stage close-work commit merge-push version consolidate other; do
  kind_case "the kind $kind is accepted" pass "$kind" "as recommended"
done
kind_case "an unknown kind fails and names the row and the value" fail "made-up" "as recommended" "FAIL works/auth/decisions.md: the kind of auth-10 is made-up"
kind_case "a kind in capitals fails" fail "Definition" "as recommended" "the kind of auth-10 is Definition"
for answer in "as recommended" changed rejected delegated; do
  kind_case "the answer $answer is accepted" pass definition "$answer"
done
kind_case "an unknown answer fails and names the row and the value" fail definition "approved" "FAIL works/auth/decisions.md: the answer of auth-10 is approved"
kind_case "an estimated kind and answer are accepted" pass "plan (estimated)" "changed (estimated)"
kind_case "an estimated unknown kind fails" fail "made-up (estimated)" "changed" "the kind of auth-10 is made-up (estimated)"
kind_case "an estimated answer that is not a value fails" fail "plan (estimated)" "approved (estimated)" "the answer of auth-10 is approved (estimated)"
kind_case "a suffix with no space before it fails" fail "plan(estimated)" "changed" "the kind of auth-10 is plan(estimated)"
kind_case "the suffix alone fails" fail "(estimated)" "changed" "the kind of auth-10 is (estimated)"
kind_case "the suffix alone as an answer fails" fail plan "(estimated)" "the answer of auth-10 is (estimated)"
kind_case "a suffix after two spaces fails" fail "plan  (estimated)" "changed" "the kind of auth-10 is plan  (estimated)"
kind_case "empty kind and answer are accepted" pass - -
kind_case "an empty answer with a kind is accepted" pass commit -
kind_case "an empty kind with an answer is accepted" pass - rejected
fresh_works
printf '| auth-10 | 2026-04-01 | Row ten | Ana | "yes" | none | plan |\n' >> "$project_wiki/works/auth/decisions.md"
expect_wiki "format 5: a row with seven columns passes" pass "" "$project_wiki"
fresh_works
printf '| auth-10 | 2026-04-01 | Row ten | Ana | "yes" | none |\n' >> "$project_wiki/works/auth/decisions.md"
expect_wiki "format 5: a row with six columns passes" pass "" "$project_wiki"
fresh_works
printf '| auth-10 | 2026-04-01 | Row ten | agent, by auth-7 | "yes" | none | close-stage | delegated |\n' >> "$project_wiki/works/auth/decisions.md"
expect_wiki "format 5: a decision of the agent under a delegation passes" pass "" "$project_wiki"

fresh_works
printf '| auth-10 | 2026-04-01 | Row ten | Ana | "yes" | none | plan | changed | extra |\n' >> "$project_wiki/works/auth/decisions.md"
expect_wiki "format 5: a row with nine columns fails and says so" fail "the row of auth-10 has 9 columns, more than the eight" "$project_wiki"

# The measurement: sh check-wiki.sh --delegations.
# deleg_case <case name> <expected output>: the output of the mode on the
# wiki in $project_wiki, which must exit 0.
deleg_case() {
  out=$(sh "$check_wiki" --delegations "$project_wiki" 2>&1)
  code=$?
  if [ "$code" -eq 0 ] && [ "$out" = "$2" ]; then
    printf 'ok    %s\n' "$1"
  else
    printf 'FAIL  %s (exit %s)\n%s\n' "$1" "$code" "$out"
    failed=$((failed + 1))
  fi
}
fresh_works
kind_rows 10 13 close-stage "as recommended"
kind_rows 30 1 close-stage changed
deleg_case "delegations: a kind with 14 answers and 92% as recommended qualifies" "close-stage: 14 answers, 92% as recommended, 0 rejected"

fresh_works
kind_rows 10 10 close-stage "as recommended"
deleg_case "delegations: a kind with exactly 10 answers, all as recommended, qualifies" "close-stage: 10 answers, 100% as recommended, 0 rejected"

fresh_works
kind_rows 10 9 close-stage "as recommended"
deleg_case "delegations: a kind with 9 answers does not qualify" ""

fresh_works
kind_rows 10 8 plan "as recommended"
kind_rows 30 2 plan changed
deleg_case "delegations: a kind at exactly 80% qualifies" "plan: 10 answers, 80% as recommended, 0 rejected"

fresh_works
kind_rows 10 7 plan "as recommended"
kind_rows 30 3 plan changed
deleg_case "delegations: a kind at 70% does not qualify" ""

fresh_works
kind_rows 10 20 commit "as recommended"
kind_rows 40 1 commit rejected
deleg_case "delegations: a kind with one rejected does not qualify" ""

fresh_works
kind_rows 10 8 definition "as recommended (estimated)"
kind_rows 30 4 definition "as recommended"
kind_rows 40 5 definition -
kind_rows 50 3 other -
deleg_case "delegations: estimated answers count and empty answers are skipped" "definition: 12 answers, 100% as recommended, 0 rejected"

fresh_works
kind_rows 10 10 plan "as recommended (estimated)"
deleg_case "delegations: the suffix is taken off the answer" "plan: 10 answers, 100% as recommended, 0 rejected"

fresh_works
kind_rows 10 10 "plan (estimated)" "as recommended (estimated)"
kind_rows 30 1 "plan (estimated)" "changed"
deleg_case "delegations: the suffix is taken off the kind, so it joins its plain kind" "plan: 11 answers, 90% as recommended, 0 rejected"

fresh_works
kind_rows 10 199 commit "as recommended"
kind_rows 300 1 commit changed
deleg_case "delegations: the percentage is rounded down, 199 of 200 is 99%" "commit: 200 answers, 99% as recommended, 0 rejected"

fresh_works
kind_rows 10 10 technology "as recommended"
kind_rows 30 40 technology delegated
deleg_case "delegations: the answer delegated is not counted" "technology: 10 answers, 100% as recommended, 0 rejected"

fresh_works
kind_rows 10 9 version "as recommended"
kind_rows 30 5 version delegated
deleg_case "delegations: delegated rows do not complete the count of 10" ""

fresh_works
kind_rows 10 6 plan "as recommended"
mkwork billing 2026-02-01 2026-03-05
printf '| billing-10 | 2026-04-01 | Row | Ana | "yes" | none | plan | as recommended |\n| billing-11 | 2026-04-01 | Row | Ana | "yes" | none | plan | as recommended |\n| billing-12 | 2026-04-01 | Row | Ana | "yes" | none | plan | as recommended |\n| billing-13 | 2026-04-01 | Row | Ana | "yes" | none | plan | as recommended |\n' >> "$project_wiki/works/billing/decisions.md"
deleg_case "delegations: the rows of every work are counted together" "plan: 10 answers, 100% as recommended, 0 rejected"

fresh_works
kind_rows 10 10 close-stage "as recommended"
kind_rows 30 10 commit "as recommended"
kind_rows 50 11 definition "as recommended"
deleg_case "delegations: each kind that qualifies has a line, in the order of the list of kinds" "definition: 11 answers, 100% as recommended, 0 rejected
close-stage: 10 answers, 100% as recommended, 0 rejected
commit: 10 answers, 100% as recommended, 0 rejected"

fresh_works
kind_rows 10 10 consolidate "as recommended"
deleg_case "delegations: the kind consolidate is counted like the others" "consolidate: 10 answers, 100% as recommended, 0 rejected"

fresh_works
kind_rows 10 10 close-stage "as recommended"
kind_rows 30 10 consolidate "as recommended"
kind_rows 50 10 other "as recommended"
deleg_case "delegations: consolidate comes before other in the order of the list of kinds" "close-stage: 10 answers, 100% as recommended, 0 rejected
consolidate: 10 answers, 100% as recommended, 0 rejected
other: 10 answers, 100% as recommended, 0 rejected"

fresh_works
kind_rows 10 10 close-stage "as recommended"
rm "$project_wiki/README.md" "$project_wiki/.format"
deleg_case "delegations: it needs no README.md and no marker" "close-stage: 10 answers, 100% as recommended, 0 rejected"

fresh_project
deleg_case "delegations: a wiki without works prints nothing" ""

fresh_works
deleg_case "delegations: works with rows of six columns print nothing" ""

check "delegations: a missing directory fails" sh -c '! sh "$1" --delegations "$2" >/dev/null 2>&1' sh "$check_wiki" "$tmp/no-such-wiki"
# The gate of the check, the format the playbook is at, and the passed message.
present=$(sh "$check_wiki" --format)
check "gate: --format prints 5" test "$present" = 5
check "gate: --format exits 0 and takes no wiki" sh -c 'sh "$1" --format >/dev/null' sh "$check_wiki"

# expect_gate <case name> <marker content as printf format, or NONE> <expected found>
# The output must be exactly the one line of the gate, even with a broken link.
expect_gate() {
  fresh_wiki
  printf 'See [b](gone.md).\n' >> "$tmp/wiki/01-product/overview.md"
  # shellcheck disable=SC2059
  if [ "$2" = NONE ]; then rm -f "$tmp/wiki/.format"; else printf "$2" > "$tmp/wiki/.format"; fi
  out=$(sh "$check_wiki" "$tmp/wiki" 2>&1)
  code=$?
  want="FAIL $tmp/wiki is at wiki format $3, and the playbook is at 5. Bring it there with the doctor (/playbook-wiki:doctor)."
  if [ "$code" -eq 1 ] && [ "$out" = "$want" ]; then
    printf 'ok    %s\n' "$1"
  else
    printf 'FAIL  %s (exit %s)\n%s\n' "$1" "$code" "$out"
    failed=$((failed + 1))
  fi
}
expect_gate "gate: a wiki without a marker fails with the one line that names the doctor" NONE none
expect_gate "gate: a marker at 3 fails with the one line" '3\n' 3
expect_gate "gate: a marker that is not a number reads as none" 'x\n' none
expect_gate "gate: an empty marker reads as none" '' none
expect_gate "gate: a marker that ends in a carriage return is read" '3\r\n' 3

fresh_wiki
printf '6\n' > "$tmp/wiki/.format"
expect_wiki "gate: a marker above the playbook's format passes the gate" pass "check-wiki passed"

fresh_wiki
printf 'See [b](gone.md).\n' >> "$tmp/wiki/01-product/overview.md"
printf '6\n' > "$tmp/wiki/.format"
expect_wiki "gate: past the gate the other checks run" fail "links to gone.md"

fresh_wiki
rm "$tmp/wiki/.format"
check "gate: --column does not read the marker" sh "$check_wiki" --column "$tmp/wiki"
check "gate: --decisions does not read the marker" sh "$check_wiki" --decisions "$tmp/wiki"

fresh_project
expect_wiki "passed: a wiki without works says 0 works" pass "check-wiki passed: wiki format 5, 0 works" "$project_wiki"
fresh_works
expect_wiki "passed: a wiki with two works says 2 works" pass "check-wiki passed: wiki format 5, 2 works" "$project_wiki"

# The README.md of the project at format 4: an owner, no state, no stage table.
readme_case() {
  fresh_wiki
  printf '%b' "$2" > "$tmp/wiki/README.md"
  expect_wiki "readme: $1" "$3" "$4"
}
pages='## Pages\n\n| Page | Content | Code it governs |\n|---|---|---|\n| [Overview](01-product/overview.md) | The product | |\n'
readme_case "a README with an owner and no state passes" "# Wiki\n\nProject owner: Ana.\n\n$pages" pass "check-wiki passed"
readme_case "a README without the owner line fails" "# Wiki\n\n$pages" fail "README.md has no line \"Project owner: <name>\""
readme_case "an owner line without a name fails" "# Wiki\n\nProject owner: \n\n$pages" fail "has no line \"Project owner"
readme_case "an owner line inside a code block does not count" "# Wiki\n\n\`\`\`text\nProject owner: Ana.\n\`\`\`\n\n$pages" fail "has no line \"Project owner"
readme_case "a Where work stands heading outside the history fails" "# Wiki\n\nProject owner: Ana.\n\n## Where work stands\n\nNothing.\n\n$pages" fail "has the heading \"Where work stands\" outside"
readme_case "a Where work stands heading at a smaller level fails too" "# Wiki\n\nProject owner: Ana.\n\n### Where work stands (2026-11-14)\n\n$pages" fail "has the heading \"Where work stands\" outside"
readme_case "a Where work stands heading inside a code block is not read" "# Wiki\n\nProject owner: Ana.\n\n\`\`\`text\n## Where work stands\n\`\`\`\n\n$pages" pass "check-wiki passed"
readme_case "a stage table outside the history fails" "# Wiki\n\nProject owner: Ana.\n\n| Stage | Status | Closed on |\n|---|---|---|\n| 1 Wiki | Closed | 2026-01-01 |\n\n$pages" fail "has a stage table outside"
readme_case "a stage table inside a code block is not read" "# Wiki\n\nProject owner: Ana.\n\n\`\`\`text\n| Stage | Status |\n|---|---|\n\`\`\`\n\n$pages" pass "check-wiki passed"
readme_case "a table of pages whose first cell is another word is not a stage table" "# Wiki\n\nProject owner: Ana.\n\n$pages" pass "check-wiki passed"
history='\n## Phases before format 4\n\n### Where work stands\n\nOld.\n\n| Stage | Status | Closed on |\n|---|---|---|\n| 1 Wiki | Closed | 2026-01-01 |\n'
readme_case "the section Phases before format 4 may hold a state heading and a stage table" "# Wiki\n\nProject owner: Ana.\n\n$pages$history" pass "check-wiki passed"
readme_case "the history section ends at the next heading of level 2" "# Wiki\n\nProject owner: Ana.\n\n$pages$history\n## Later\n\n| Stage | Status |\n|---|---|\n| 3 | Open |\n" fail "has a stage table outside"
readme_case "the history section does not end at a smaller heading" "# Wiki\n\nProject owner: Ana.\n\n$pages$history\n### Sub\n\n| Stage | Status |\n|---|---|\n| 3 | Open |\n" pass "check-wiki passed"
fresh_works
printf '\n| Stage | Status | Closed on |\n|---|---|---|\n| 1 Wiki | Open | |\n' >> "$project_wiki/works/auth/README.md"
expect_wiki "readme: a stage table and a state section in a work's README pass" pass "check-wiki passed" "$project_wiki"
# The marker of a wiki's format.
wiki_format="$root/plugins/playbook-wiki/skills/doctor/scripts/wiki-format.sh"
product_format=$present

# expect_format <case name> <command> <expected exit code> <text the output must contain, or "" for no output>
expect_format() {
  out=$(sh "$wiki_format" "$2" "$tmp/wiki" 2>&1)
  code=$?
  ok=1
  [ "$code" -eq "$3" ] || ok=0
  if [ -z "$4" ]; then
    [ -z "$out" ] || ok=0
  else
    printf '%s' "$out" | grep -q -F "$4" || ok=0
  fi
  if [ "$ok" -eq 1 ]; then
    printf 'ok    %s\n' "$1"
  else
    printf 'FAIL  %s (exit %s)\n%s\n' "$1" "$code" "$out"
    failed=$((failed + 1))
  fi
}

check "format: wiki-format.sh holds no format of its own" sh -c '! grep -q "^format=[0-9]" "$1"' sh "$wiki_format"

rm -rf "$tmp/wiki"
expect_format "format: a project without a wiki gets no notice" status 0 ""

fresh_wiki
rm "$tmp/wiki/.format"
expect_format "format: a wiki without a marker gets a notice that names the doctor" status 0 "has no format marker"
expect_format "format: the notice says not to repair unasked" status 0 "Do not repair the wiki unasked"

fresh_wiki
printf '3\n' > "$tmp/wiki/.format"
expect_format "format: a marker at 3 gets the behind line with both numbers" status 0 "is at wiki format 3, and the playbook is at 5"
expect_format "format: the behind line names the doctor" status 0 "/playbook-wiki:doctor"

fresh_wiki
expect_format "format: a marker at 5 gets no notice" status 0 ""

fresh_wiki
printf '%s\n' "$((product_format + 1))" > "$tmp/wiki/.format"
expect_format "format: a marker ahead of the playbook gets no notice" status 0 ""

fresh_wiki
printf 'valid\n' > "$tmp/wiki/.format"
expect_format "format: a marker that is not a number counts as missing" status 0 "has no format marker"

fresh_wiki
printf '%s\r\n' "$product_format" > "$tmp/wiki/.format"
expect_format "format: a marker that ends in a carriage return is read" status 0 ""

# A wiki that fails the check: the marker it had comes back as it was.
fresh_wiki
printf 'See [b](gone.md).\n' >> "$tmp/wiki/01-product/overview.md"
rm "$tmp/wiki/.format"
expect_format "format: mark writes nothing when the check fails" mark 1 "The marker was not written"
check "format: no marker exists after a failed mark" absent "$tmp/wiki/.format"

fresh_wiki
printf 'See [b](gone.md).\n' >> "$tmp/wiki/01-product/overview.md"
printf '3\r\n' > "$tmp/wiki/.format"
cp "$tmp/wiki/.format" "$tmp/marker-before"
expect_format "format: a failed mark reports the failure" mark 1 "links to gone.md"
check "format: a failed mark puts the older marker back byte for byte" cmp -s "$tmp/marker-before" "$tmp/wiki/.format"
check "format: a failed mark leaves no copy of the marker" absent "$tmp/wiki/.format.saved"

fresh_wiki
printf '3\n' > "$tmp/wiki/.format"
expect_format "format: mark brings a wiki at 3 that passes to 5" mark 0 "marked $tmp/wiki as wiki format $product_format"
check "format: the marker holds the playbook's format" test "$(cat "$tmp/wiki/.format")" = "$product_format"
expect_format "format: after mark there is no notice" status 0 ""

# A wiki of format 3: a top-level decisions.md and a count of rows.
fresh_wiki
printf '3\n' > "$tmp/wiki/.format"
decisions
{ decision D1 200; decision D2 200; } >> "$tmp/wiki/decisions.md"
printf '2\n' > "$tmp/wiki/.unchecked-decisions"
cp "$tmp/wiki/decisions.md" "$tmp/decisions-before"
expect_format "format: mark succeeds on a wiki of format 3 with long rows in decisions.md" mark 0 "as wiki format $product_format"
check "format: mark deletes .unchecked-decisions" absent "$tmp/wiki/.unchecked-decisions"
check "format: the marker is 5 after mark" test "$(cat "$tmp/wiki/.format")" = 5
check "format: decisions.md is byte-identical after mark" cmp -s "$tmp/decisions-before" "$tmp/wiki/decisions.md"

fresh_wiki
printf '3\n' > "$tmp/wiki/.format"
printf '2\n' > "$tmp/wiki/.unchecked-decisions"
printf 'See [b](gone.md).\n' >> "$tmp/wiki/01-product/overview.md"
expect_format "format: a failed mark fails for the broken link" mark 1 "The marker was not written"
check "format: a failed mark keeps .unchecked-decisions" test -f "$tmp/wiki/.unchecked-decisions"

fresh_wiki
rm "$tmp/wiki/.format"
check "format: the README of the sample has no Where work stands section" sh -c '! grep -q "Where work stands" "$1"' sh "$tmp/wiki/README.md"
expect_format "format: mark succeeds on a README without a Where work stands section" mark 0 "as wiki format $product_format"

rm -rf "$tmp/wiki"
expect_format "format: mark fails when there is no wiki" mark 3 "has no README.md"
out=$(sh "$wiki_format" mark "$tmp/wiki" 2>/dev/null)
check "format: a failed mark prints nothing on standard output" test -z "$out"

out=$(sh "$wiki_format" 2>&1); code=$?
check "format: without a command it prints the usage and exits 2" test "$code" -eq 2
out=$(sh "$wiki_format" --help 2>/dev/null); code=$?
check "format: --help prints the usage on standard output and exits 0" sh -c 'test "$1" -eq 0 && printf "%s" "$2" | grep -q "Exit codes"' sh "$code" "$out"
out=$(sh "$wiki_format" 2>/dev/null)
check "format: a wrong call prints nothing on standard output" test -z "$out"

fresh_wiki
rm "$tmp/wiki/.format"
mkdir "$tmp/wiki/.format"
expect_format "format: mark fails when the marker cannot be written" mark 4 "could not write"

fresh_wiki
out=$(TMPDIR="$tmp/no-such-dir" sh "$wiki_format" mark "$tmp/wiki" 2>&1); code=$?
check "format: mark works when the temporary folder cannot be written" sh -c 'test "$1" -eq 0 && test "$(cat "$2")" = 5' sh "$code" "$tmp/wiki/.format"
check "format: mark leaves no copy of the marker in the wiki" absent "$tmp/wiki/.format.saved"

fresh_wiki
printf '3\n' > "$tmp/wiki/.format"
printf 'stale\n' > "$tmp/wiki/.format.saved"
sh "$wiki_format" mark "$tmp/wiki" >/dev/null 2>&1; code=$?
check "format: mark replaces a copy left by an earlier run, and deletes it" sh -c 'test "$1" -eq 0 && test "$(cat "$2")" = 5 && test ! -e "$3"' sh "$code" "$tmp/wiki/.format" "$tmp/wiki/.format.saved"

fresh_wiki
rm "$tmp/wiki/.format"
printf 'stale\n' > "$tmp/wiki/.format.saved"
sh "$wiki_format" mark "$tmp/wiki" >/dev/null 2>&1; code=$?
check "format: mark deletes a copy left by an earlier run when there is no marker" sh -c 'test "$1" -eq 0 && test "$(cat "$2")" = 5 && test ! -e "$3"' sh "$code" "$tmp/wiki/.format" "$tmp/wiki/.format.saved"

fresh_wiki
printf '3\n' > "$tmp/wiki/.format"
mkdir "$tmp/wiki/.format.saved"
out=$(sh "$wiki_format" mark "$tmp/wiki" 2>&1); code=$?
check "format: mark exits 4 and keeps the marker when an old copy cannot be removed" sh -c 'test "$1" -eq 4 && printf "%s" "$2" | grep -q "could not remove" && test "$(cat "$3")" = 3' sh "$code" "$out" "$tmp/wiki/.format"
rmdir "$tmp/wiki/.format.saved"

if [ "$(id -u)" -ne 0 ]; then
  fresh_wiki
  printf '3\n' > "$tmp/wiki/.format"
  chmod a-w "$tmp/wiki"
  out=$(sh "$wiki_format" mark "$tmp/wiki" 2>&1); code=$?
  chmod u+w "$tmp/wiki"
  check "format: mark exits 4 and keeps the marker when it cannot copy it" sh -c 'test "$1" -eq 4 && printf "%s" "$2" | grep -q "could not keep a copy" && test "$(cat "$3")" = 3' sh "$code" "$out" "$tmp/wiki/.format"
fi

fresh_wiki
printf '99999999999999999999\n' > "$tmp/wiki/.format"
expect_format "format: a number too long to compare counts as missing" status 0 "has no format marker"

fresh_wiki
rm "$tmp/wiki/.format"
awk '{ gsub(/ \| Code it governs/, ""); print }' "$tmp/wiki/README.md" > "$tmp/readme" && mv "$tmp/readme" "$tmp/wiki/README.md"
expect_format "format: mark refuses a wiki whose table of pages names no code column" mark 3 "has no column \"Code it governs\""
check "format: a wiki without the column is left without a marker" absent "$tmp/wiki/.format"

fresh_wiki
rm "$tmp/wiki/.format"
printf '# Wiki\n\nProject owner: Ana.\n\n```text\n| Page | Content | Code it governs |\n```\n' > "$tmp/wiki/README.md"
expect_format "format: mark refuses a wiki whose only code column is inside a code block" mark 3 "has no column"

# The ending condition of the doctor: a wiki of format 3 is brought to 4 by
# the steps of the doctor, and its decisions.md is not touched.
fresh_wiki
printf '3\n' > "$tmp/wiki/.format"
{
  printf '# Wiki\n\nWhat the project is.\n\n## Where work stands\n\nLast decision D12. Stage 3 is open. Next: the plan.\n\n'
  printf '## Stages\n\n| Stage | Status | Closed on |\n|---|---|---|\n| 1 Wiki | Closed | 2026-01-01 |\n| 2 Technology | Closed | 2026-02-01 |\n| 3 Skills | Open | |\n\n'
  printf '## Pages\n\n| Page | Content | Code it governs |\n|---|---|---|\n| [Overview](01-product/overview.md) | The product | |\n'
} > "$tmp/wiki/README.md"
decisions
{ decision D11 200; decision D12 30; } >> "$tmp/wiki/decisions.md"
printf '2\n' > "$tmp/wiki/.unchecked-decisions"
cp "$tmp/wiki/decisions.md" "$tmp/decisions-before"
expect_format "doctor: a copy of a wiki at format 3 gets the behind line" status 0 "is at wiki format 3, and the playbook is at $product_format"
out=$(sh "$check_wiki" "$tmp/wiki" 2>&1)
check "doctor: the check refuses it until it is brought up" sh -c 'printf "%s" "$1" | grep -q -F "is at wiki format 3"' sh "$out"

# Left out, the steps leave the wiki in format 3 in the README: mark refuses it.
expect_format "doctor: mark refuses the wiki when the steps are left out" mark 1 "The marker was not written"
out=$(sh "$wiki_format" mark "$tmp/wiki" 2>&1)
check "doctor: it names the missing owner, the state, and the stage table" sh -c 'printf "%s" "$1" | grep -q "no line \"Project owner" && printf "%s" "$1" | grep -q "heading \"Where work stands\"" && printf "%s" "$1" | grep -q "stage table outside"' sh "$out"
check "doctor: the marker is still 3 after the refused mark" test "$(cat "$tmp/wiki/.format")" = 3
check "doctor: .unchecked-decisions is kept after the refused mark" test -f "$tmp/wiki/.unchecked-decisions"
check "doctor: decisions.md is untouched by the refused mark" cmp -s "$tmp/decisions-before" "$tmp/wiki/decisions.md"

# The steps: an owner in the README, a work with the state and the stage table
# of the phase that is open, the closed stages kept under a heading of history.
readme=$tmp/wiki/README.md
mkdir -p "$tmp/wiki/works/skills"
{
  printf '# skills\n\nThe skills phase, led by Ana.\n\nStatus: Open\n\n'
  awk '/^## Where work stands/ { p = 1 } /^## Stages/ { p = 0 } p' "$readme"
  printf '## Stage table\n\n| Stage | Status | Closed on |\n|---|---|---|\n| 3 Skills | Open | |\n'
} > "$tmp/wiki/works/skills/README.md"
{
  printf '# Wiki\n\nWhat the project is.\n\nProject owner: Ana.\n\n'
  printf '## Pages\n\n| Page | Content | Code it governs |\n|---|---|---|\n| [Overview](01-product/overview.md) | The product | |\n\n'
  printf '## Phases before format 4\n\n| Stage | Status | Closed on |\n|---|---|---|\n| 1 Wiki | Closed | 2026-01-01 |\n| 2 Technology | Closed | 2026-02-01 |\n'
} > "$readme"
expect_format "doctor: mark succeeds once the steps are applied" mark 0 "as wiki format $product_format"
expect_format "doctor: the wiki has no notice after mark" status 0 ""
check "doctor: the marker is 5" test "$(cat "$tmp/wiki/.format")" = 5
check "doctor: .unchecked-decisions is gone" absent "$tmp/wiki/.unchecked-decisions"
check "doctor: decisions.md is byte-identical" cmp -s "$tmp/decisions-before" "$tmp/wiki/decisions.md"
check "doctor: the state moved to the work" grep -q 'Stage 3 is open' "$tmp/wiki/works/skills/README.md"
check "doctor: the project README no longer holds the state" sh -c '! grep -q "Where work stands" "$1"' sh "$readme"
expect_wiki "doctor: the brought-up wiki passes the check with one work" pass "wiki format 5, 1 works"


# An interrupted mark puts the old marker back. The check is a stand-in, in a
# copy of the plugin, that sends TERM to the script that runs it.
standin=$tmp/standin
rm -rf "$standin"
mkdir -p "$standin/skills/doctor/scripts" "$standin/tmpdir"
cp "$wiki_format" "$standin/skills/doctor/scripts/wiki-format.sh"
cat > "$standin/check-wiki.sh" <<'STANDIN'
case ${1:-} in
  --format) echo 5 ;;
  --column) exit 0 ;;
  *) kill -TERM "$PPID"; sleep 1; exit 0 ;;
esac
STANDIN
interrupted="$standin/skills/doctor/scripts/wiki-format.sh"

fresh_wiki
printf '3\r\n' > "$tmp/wiki/.format"
cp "$tmp/wiki/.format" "$tmp/marker-before"
TMPDIR="$standin/tmpdir" sh "$interrupted" mark "$tmp/wiki" >/dev/null 2>&1
code=$?
check "interrupt: a TERM during the check makes mark fail" test "$code" -ne 0
check "interrupt: the old marker is back byte for byte" cmp -s "$tmp/marker-before" "$tmp/wiki/.format"
check "interrupt: the saved copy is deleted" absent "$tmp/wiki/.format.saved"

fresh_wiki
rm "$tmp/wiki/.format"
TMPDIR="$standin/tmpdir" sh "$interrupted" mark "$tmp/wiki" >/dev/null 2>&1
check "interrupt: when there was no marker, the new one is removed" absent "$tmp/wiki/.format"
check "interrupt: the stand-in alone writes a marker when it is not interrupted" sh -c 'sed "s/kill -TERM \"\$PPID\"; //" "$1/check-wiki.sh" > "$1/ok.sh" && cp "$1/ok.sh" "$1/check-wiki.sh" && sh "$2" mark "$3" >/dev/null && test "$(cat "$3/.format")" = 5' sh "$standin" "$interrupted" "$tmp/wiki"

# A marker that is a symbolic link is not written through.
fresh_wiki
rm "$tmp/wiki/.format"
ln -s "$tmp/no-such-target" "$tmp/wiki/.format"
expect_format "link: mark refuses a dangling link and names it" mark 3 "FAIL $tmp/wiki/.format is a symbolic link; replace it with a file. The marker was not written."
check "link: the dangling link is untouched" sh -c 'test -L "$1" && test ! -e "$2"' sh "$tmp/wiki/.format" "$tmp/no-such-target"
expect_format "link: status reads through a dangling link as a missing marker" status 0 "has no format marker"

fresh_wiki
rm "$tmp/wiki/.format"
printf '3\n' > "$tmp/target"
ln -s "$tmp/target" "$tmp/wiki/.format"
expect_format "link: mark refuses a link to a file" mark 3 "is a symbolic link"
check "link: the file behind the link is untouched" test "$(cat "$tmp/target")" = 3
expect_format "link: status reads through a link to a file" status 0 "is at wiki format 3"

# The hook: the command the plugin runs at session start, for the project of
# the session.
hook=$(awk '/"SessionStart"/ { inside = 1 }
            /"(SessionEnd|Stop|PreToolUse|PostToolUse|UserPromptSubmit)"/ { inside = 0 }
            inside' "$root/plugins/playbook-wiki/hooks/hooks.json" |
  sed -n 's/.*"command": "\(sh .*wiki-format.sh.*\)".*/\1/p' | sed 's/\\"/"/g')
check "format: the plugin runs the notice at session start" test -n "$hook"

fresh_wiki
rm "$tmp/wiki/.format"
rm -rf "$tmp/my project"
mkdir -p "$tmp/my project/docs"
mv "$tmp/wiki" "$tmp/my project/docs/wiki"
out=$(CLAUDE_PLUGIN_ROOT="$root/plugins/playbook-wiki" CLAUDE_PROJECT_DIR="$tmp/my project" sh -c "$hook" 2>&1)
check "format: the hook gives the notice for the project of the session" sh -c 'printf "%s" "$1" | grep -q -F "has no format marker"' sh "$out"

printf '%s\n' "$product_format" > "$tmp/my project/docs/wiki/.format"
out=$(CLAUDE_PLUGIN_ROOT="$root/plugins/playbook-wiki" CLAUDE_PROJECT_DIR="$tmp/my project" sh -c "$hook" 2>&1); code=$?
check "format: the hook prints nothing and exits 0 for a wiki at the playbook's format" test -z "$out" -a "$code" -eq 0

out=$(CLAUDE_PLUGIN_ROOT="$root/plugins/playbook-wiki" sh -c 'unset CLAUDE_PROJECT_DIR; '"$hook" 2>&1); code=$?
check "format: the hook prints nothing and exits 0 when the session names no project" test -z "$out" -a "$code" -eq 0

# A notice of a SessionStart hook is one JSON object: systemMessage for the
# person, additionalContext for the agent.
# notice_field <person|agent> <text>: the object has that shape, and the field
# named holds the text.
notice_field() {
  printf '%s' "$out" | grep -Eq '^\{"systemMessage":"[^"]+","hookSpecificOutput":\{"hookEventName":"SessionStart","additionalContext":"[^"]+"\}\}$' || return 1
  case $1 in
    person) field=$(printf '%s' "$out" | sed -n 's/^{"systemMessage":"\([^"]*\)","hookSpecificOutput".*/\1/p') ;;
    agent) field=$(printf '%s' "$out" | sed -n 's/.*"additionalContext":"\([^"]*\)"}}$/\1/p') ;;
  esac
  printf '%s' "$field" | grep -Fq "$2"
}
# startup_only <script>: hooks.json names the script once, in a SessionStart
# group whose matcher is startup.
startup_only() {
  [ "$(grep -c "$1" "$root/plugins/playbook-wiki/hooks/hooks.json")" -eq 1 ] &&
    awk -v script="$1" '
      /"matcher":/ { pending = $0 }
      /"hooks": \[/ { group = pending; pending = "" }
      index($0, script) { found = (group ~ /"startup"/) }
      END { exit !found }' "$root/plugins/playbook-wiki/hooks/hooks.json"
}
hook_run() { out=$(CLAUDE_PLUGIN_ROOT="$root/plugins/playbook-wiki" CLAUDE_PROJECT_DIR="$tmp/my project" sh -c "$hook" 2>&1); code=$?; }
check "format: the plugin runs the format notice on startup only" startup_only wiki-format.sh
rm "$tmp/my project/docs/wiki/.format"; hook_run
check "format: the person is told the wiki has no format marker" notice_field person "This project's wiki has no format marker"
check "format: the person is told to run the doctor" notice_field person "Run /playbook-wiki:doctor"
check "format: the agent gets the line of status and is told not to repair unasked" notice_field agent "The wiki of this project has no format marker"
check "format: the agent is told not to repair unasked" notice_field agent "Do not repair the wiki unasked"
check "format: the hook exits 0 with a notice" [ "$code" -eq 0 ]
printf '3\n' > "$tmp/my project/docs/wiki/.format"; hook_run
check "format: the person is told both formats of a wiki behind" notice_field person "This project's wiki is at format 3, and the playbook is at $product_format."
check "format: the agent gets the line of status for a wiki behind" notice_field agent "The wiki of this project is at wiki format 3, and the playbook is at $product_format."
printf '%s\n' "$((product_format + 1))" > "$tmp/my project/docs/wiki/.format"; hook_run
check "format: the person is told the playbook is older than a wiki ahead" notice_field person "newer than the playbook's $product_format: the playbook installed is older than the wiki"
check "format: the agent is told not to mark or migrate a wiki ahead" notice_field agent "Do not mark or migrate the wiki"
check "format: the hook's notice for a wiki ahead does not send to the doctor" sh -c '! printf "%s" "$1" | grep -Fq "doctor"' sh "$out"
out=$(sh "$wiki_format" status "$tmp/my project/docs/wiki" 2>&1)
check "format: status still prints nothing for a wiki ahead" test -z "$out"
printf '%s\n' "$product_format" > "$tmp/my project/docs/wiki/.format"

# The version notice: a hook at session start compares the installed version
# with the marketplace's local copy, from files under a fake plugins folder.
version_hook="$root/plugins/playbook-wiki/hooks/version-check.sh"
check "version: the plugin runs the version notice on startup only" startup_only version-check.sh

# vc_layout <installed> <available>: a marketplace from Git, with each version
# written in its manifest; an empty version writes no manifest.
vc_layout() {
  rm -rf "$tmp/vc"
  vc_root="$tmp/vc/plugins/cache/playbook/playbook-wiki/$1"
  mkdir -p "$vc_root/.claude-plugin" "$tmp/vc/plugins/marketplaces/playbook/plugins/playbook-wiki/.claude-plugin"
  printf '{\n  "name": "playbook-wiki",\n  "version": "%s"\n}\n' "$1" > "$vc_root/.claude-plugin/plugin.json"
  if [ -n "$2" ]; then
    printf '{\n  "name": "playbook-wiki",\n  "version": "%s"\n}\n' "$2" > "$tmp/vc/plugins/marketplaces/playbook/plugins/playbook-wiki/.claude-plugin/plugin.json"
  fi
}
vc_run() { out=$(CLAUDE_PLUGIN_ROOT="$vc_root" sh "$version_hook" 2>&1); code=$?; }
vc_silent() { [ -z "$out" ] && [ "$code" -eq 0 ]; }

vc_layout 2.6.0 3.0.0; vc_run
check "version: the person is told of an older installed version" notice_field person "The playbook is at 2.6.0, and 3.0.0 is available"
check "version: the agent is told and asked not to update unasked" notice_field agent "Do not update a plugin unasked"
check "version: the notice exits 0" [ "$code" -eq 0 ]
vc_layout 2.9.9 2.10.0; vc_run
check "version: versions compare number by number, 2.10.0 after 2.9.9" sh -c 'printf "%s" "$1" | grep -Fq "2.10.0 is available"' sh "$out"
vc_layout 3.0.0 3.0.0; vc_run
check "version: an equal version prints nothing" vc_silent
vc_layout 3.1.0 3.0.0; vc_run
check "version: a newer installed version prints nothing" vc_silent
vc_layout 3.0.0 2.5.0; vc_run
check "version: an older copy prints nothing, though one of its numbers is higher" vc_silent
vc_layout 3.0.0 3.1; vc_run
check "version: an available version that is not three numbers prints nothing" vc_silent
vc_layout 3.0 3.0.0; vc_run
check "version: an installed version that is not three numbers prints nothing" vc_silent
vc_layout 2.6.0 3.0.0
sed '/"version"/d' "$vc_root/.claude-plugin/plugin.json" > "$tmp/x" && mv "$tmp/x" "$vc_root/.claude-plugin/plugin.json"; vc_run
check "version: an installed manifest without a version prints nothing" vc_silent
vc_layout 2.6.0 3.0.0
mv "$tmp/vc/plugins/cache/playbook" "$tmp/vc/plugins/cache/my\"mp"
mv "$tmp/vc/plugins/marketplaces/playbook" "$tmp/vc/plugins/marketplaces/my\"mp"
vc_root="$tmp/vc/plugins/cache/my\"mp/playbook-wiki/2.6.0"; vc_run
check "version: a marketplace name with a quote prints nothing" vc_silent
vc_layout 3.0.0 ""; vc_run
check "version: a copy without the plugin's manifest prints nothing" vc_silent
vc_layout 2.6.0 3.0.0; rm -rf "$tmp/vc/plugins/marketplaces"; vc_run
check "version: no copy and no record of the marketplace prints nothing" vc_silent

# A marketplace from Git with no copy under marketplaces/, though Claude Code
# records it: nothing to compare.
vc_layout 2.0.0 3.0.0
rm -rf "$tmp/vc/plugins/marketplaces"
printf '{"playbook": {"installLocation": "%s"}}\n' "$tmp/vc/elsewhere" > "$tmp/vc/plugins/known_marketplaces.json"; vc_run
check "version: a copy missing under marketplaces/ prints nothing, whatever the record says" vc_silent

vc_layout 2.6.0 3.0.0
out=$(CLAUDE_PLUGIN_ROOT="$root/plugins/playbook-wiki" sh "$version_hook" 2>&1); code=$?
check "version: a plugin loaded in place, from a folder marketplace or --plugin-dir, prints nothing" vc_silent
out=$(env -u CLAUDE_PLUGIN_ROOT sh "$version_hook" 2>&1); code=$?
check "version: no CLAUDE_PLUGIN_ROOT prints nothing" vc_silent
check "version: the hook connects to no network" sh -c '! grep -Eq "curl|wget|ls-remote|https?://" "$1"' sh "$version_hook"

# The skills an agent preloads.
fresh
check "skills: the review agent preloads the review skill" grep -q '^skills: review-change$' "$tmp/repo/plugins/playbook-agents/agents/review.md"
expect "skills: an agent that preloads a skill of the plugin passes" pass

fresh
sed 's/^skills: .*/skills: playbook-agents:review-change, keep-minimal/' "$tmp/repo/plugins/playbook-agents/agents/review.md" > "$tmp/x" &&
  mv "$tmp/x" "$tmp/repo/plugins/playbook-agents/agents/review.md"
expect "skills: several names, with or without the plugin's prefix, pass" pass

fresh
sed 's/^skills: .*/skills: review-changes/' "$tmp/repo/plugins/playbook-agents/agents/review.md" > "$tmp/x" &&
  mv "$tmp/x" "$tmp/repo/plugins/playbook-agents/agents/review.md"
expect "skills: a name that is not a skill of the plugin fails" fail "agents/review.md preloads the skill 'review-changes'"

fresh
mv "$tmp/repo/plugins/playbook-agents/skills/review-change" "$tmp/repo/plugins/playbook-agents/skills/review-diff"
expect "skills: renaming a skill that an agent preloads fails" fail "preloads the skill 'review-change'"

fresh
awk '/^skills: / { print "skills:"; print "  - no-such-skill"; next } { print }' "$tmp/repo/plugins/playbook-agents/agents/review.md" > "$tmp/x" &&
  mv "$tmp/x" "$tmp/repo/plugins/playbook-agents/agents/review.md"
expect "skills: names written as a list under the line fail" fail "has a skills line with no name on it"

# Each plugin is walked.
fresh
skill_plugin=playbook-wiki add_skill wiki-long "$(chars 251)" 10
expect "plugins: a description over the limit in playbook-wiki fails" fail "L3 description of playbook-wiki/skills/wiki-long"

fresh
skill_plugin=playbook-agents add_skill agents-long "$(chars 251)" 10
expect "plugins: a description over the limit in playbook-agents fails" fail "L3 description of playbook-agents/skills/agents-long"

fresh
skill_plugin=playbook-wiki add_skill wiki-big "Short description." 701
expect "plugins: a body over the limit in playbook-wiki fails" fail "L2 body of playbook-wiki/skills/wiki-big"

fresh
sed 's/^skills: .*/skills: prepare-project/' "$tmp/repo/plugins/playbook-agents/agents/review.md" > "$tmp/x" &&
  mv "$tmp/x" "$tmp/repo/plugins/playbook-agents/agents/review.md"
expect "plugins: an agent that preloads a skill of another plugin fails" fail "preloads the skill 'prepare-project'"

fresh
mkdir -p "$tmp/repo/plugins/playbook-wiki/agents"
cp "$tmp/repo/plugins/playbook-agents/agents/explore.md" "$tmp/repo/plugins/playbook-wiki/agents/extra.md"
expect "plugins: an agent outside playbook-agents fails" fail "playbook-wiki/agents/extra.md is not in playbook-agents"

fresh
expect "agents and skills together still pass" pass

# The subagent script: prints the contract as one line of JSON.
subagent_script="$root/plugins/playbook-wiki/hooks/contract-for-subagent.sh"
frame_start='{"hookSpecificOutput":{"hookEventName":"SubagentStart","additionalContext":"'
frame_end='"}}'

# Gives back the text inside the frame of one line of output, with the escapes decoded.
decode() {
  awk 'BEGIN { start = "{\"hookSpecificOutput\":{\"hookEventName\":\"SubagentStart\",\"additionalContext\":\"" }
       { line = substr($0, length(start) + 1); line = substr(line, 1, length(line) - 3)
         for (i = 1; i <= length(line); i++) {
           c = substr(line, i, 1)
           if (c == "\\") {
             i++; d = substr(line, i, 1)
             if (d == "n") c = "\n"; else if (d == "t") c = "\t"; else if (d == "r") c = "\r"; else c = d
           }
           printf "%s", c
         } }'
}

# no_bare_quote <file>: once the frame and the escaped backslashes and quotes
# are taken out, no double quote is left.
no_bare_quote() {
  awk -v start="$frame_start" '{ line = substr($0, length(start) + 1); line = substr(line, 1, length(line) - 3)
         gsub(/\\\\/, "", line); gsub(/\\"/, "", line)
         if (index(line, "\"") > 0) exit 1 }' "$1"
}

# starts_with and ends_with <file> <text>: the first characters of a file and the last of its last line.
starts_with() { [ "$(head -c "${#2}" "$1")" = "$2" ]; }
ends_with() { awk -v e="$2" '{ line = $0 } END { exit substr(line, length(line) - length(e) + 1) != e }' "$1"; }

# subagent_run <contract file>: runs the script on a copy of the plugin
# that holds that contract, and keeps its output in $tmp/subagent.out.
subagent_run() {
  rm -rf "$tmp/sub"
  mkdir -p "$tmp/sub/hooks"
  cp "$subagent_script" "$tmp/sub/hooks/"
  cp "$1" "$tmp/sub/contract.md"
  sh "$tmp/sub/hooks/contract-for-subagent.sh" > "$tmp/subagent.out"
}

subagent_run "$root/plugins/playbook-wiki/contract.md"
check "subagent: the output is one line" test "$(wc -l < "$tmp/subagent.out" | tr -d ' ')" -eq 1
check "subagent: the output starts with the frame" starts_with "$tmp/subagent.out" "$frame_start"
check "subagent: the output ends with the frame" ends_with "$tmp/subagent.out" "$frame_end"
decode < "$tmp/subagent.out" > "$tmp/subagent.text"
check "subagent: decoding the output gives back the contract" cmp -s "$tmp/subagent.text" "$root/plugins/playbook-wiki/contract.md"

printf 'He said "stop".\nA path C:\\dir\\file and a\ttab.\r\nEnd.\n' > "$tmp/odd.md"
subagent_run "$tmp/odd.md"
check "subagent: a contract with a quote, a backslash, a tab, and a carriage return is one line" test "$(wc -l < "$tmp/subagent.out" | tr -d ' ')" -eq 1
decode < "$tmp/subagent.out" > "$tmp/subagent.text"
check "subagent: a contract with a quote, a backslash, a tab, and a carriage return decodes back" cmp -s "$tmp/subagent.text" "$tmp/odd.md"
check "subagent: no quote is left unescaped inside the frame" no_bare_quote "$tmp/subagent.out"

rm "$tmp/sub/contract.md"
out=$(sh "$tmp/sub/hooks/contract-for-subagent.sh" 2>&1); code=$?
check "subagent: a missing contract prints nothing and exits 0" test -z "$out" -a "$code" -eq 0

# The merge step: lists the decisions and the shared pages to compare before a merge.
step_script="$root/plugins/playbook-wiki/merge-step.sh"
hook_script="$root/plugins/playbook-wiki/hooks/merge-step-hook.sh"

# git_in <dir> <git arguments>: runs git quietly in a sample repository.
git_in() { d=$1; shift; git -C "$d" "$@" >/dev/null 2>&1; }

# row <id> <date> <decision> <shared page or none>: one row of a decisions table.
row() {
  if [ "$4" = none ]; then page=none; else page="\`$4\`"; fi
  printf '| %s | %s | %s | Ana | "ok" | %s |\n' "$1" "$2" "$3" "$page"
}

# commit_in <dir> <message>: stages everything and commits.
commit_in() { git_in "$1" add -A && git_in "$1" commit -m "$2"; }

# sample <dir> <what main adds after the branch starts: full|decision|none|top>
# Builds a repository whose branch feat/rbac adds the decision rbac-1 and
# changes users.md, and whose main then adds what the second argument says.
sample() {
  rm -rf "$1"
  mkdir -p "$1/docs/wiki/01-product" "$1/docs/wiki/works/old"
  git_in "$1" init -b main
  git_in "$1" config user.name Test
  git_in "$1" config user.email test@example.com
  git_in "$1" config commit.gpgsign false
  printf '# Wiki\n' > "$1/docs/wiki/README.md"
  printf '# Users\n' > "$1/docs/wiki/01-product/users.md"
  printf '| ID | Date | Decision | Owner'"'"'s words |\n|----|------|----------|---------------|\n| D1 | 2026-01-01 | First. | "x" |\n' > "$1/docs/wiki/decisions.md"
  {
    printf '| ID | Date | Decision | Who decided | Their words | Shared page |\n|----|------|----------|-------------|-------------|-------------|\n'
    row old-1 2026-01-02 "An old choice." none
  } > "$1/docs/wiki/works/old/decisions.md"
  commit_in "$1" base
  git_in "$1" checkout -b feat/rbac
  mkdir -p "$1/docs/wiki/works/rbac"
  {
    printf '| ID | Date | Decision | Who decided | Their words | Shared page |\n|----|------|----------|-------------|-------------|-------------|\n'
    row rbac-1 2026-02-01 "Roles are fixed." 01-product/users.md
  } > "$1/docs/wiki/works/rbac/decisions.md"
  printf 'Roles are fixed (rbac-1).\n' >> "$1/docs/wiki/01-product/users.md"
  commit_in "$1" rbac
  git_in "$1" checkout main
  case $2 in
    full | decision)
      mkdir -p "$1/docs/wiki/works/billing"
      {
        printf '| ID | Date | Decision | Who decided | Their words | Shared page |\n|----|------|----------|-------------|-------------|-------------|\n'
        if [ "$2" = full ]; then
          row billing-1 2026-02-02 "Plans are monthly." 01-product/users.md
        else
          row billing-1 2026-02-02 "Plans are monthly." none
        fi
      } > "$1/docs/wiki/works/billing/decisions.md"
      [ "$2" = full ] && printf 'Plans are monthly (billing-1).\n' >> "$1/docs/wiki/01-product/users.md"
      commit_in "$1" billing ;;
    top)
      printf '| D7 | 2026-02-03 | Seven wins. | "y" |\n' >> "$1/docs/wiki/decisions.md"
      commit_in "$1" top ;;
  esac
}

# step <arguments>: runs the merge step and keeps its output and exit code.
step() { out=$(sh "$step_script" "$@" 2>&1); code=$?; }

# has_line <text>: the output of the last step holds that line, whole.
has_line() { printf '%s\n' "$out" | grep -Fxq -- "$1"; }

# nothing: the last step printed nothing and exited 0.
nothing() { [ -z "$out" ] && [ "$code" -eq 0 ]; }

sample "$tmp/mr" full
step feat/rbac "$tmp/mr"
expected='Decisions that reached main since feat/rbac started:
- billing-1: Plans are monthly. (01-product/users.md)

Decisions this merge brings:
- rbac-1: Roles are fixed. (01-product/users.md)

Shared pages both changed:
- docs/wiki/01-product/users.md

Read these decisions against each other with the person, and settle a contradiction with a new decision that names both.'
check "merge: both sides with a decision and a shared page print the three lists and the last line" test "$out" = "$expected" -a "$code" -eq 0

sample "$tmp/mr_none" none
step feat/rbac "$tmp/mr_none"
check "merge: main without a change in the wiki prints nothing" nothing

sample "$tmp/mr_dec" decision
step feat/rbac "$tmp/mr_dec"
check "merge: a decision on main and no shared page on both sides prints list 1 and 2" has_line "- billing-1: Plans are monthly." -a "$code" -eq 0
check "merge: list 2 holds the decision the merge brings" has_line "- rbac-1: Roles are fixed. (01-product/users.md)"
check "merge: an empty list 3 is shown as none" test "$(printf '%s\n' "$out" | grep -A1 '^Shared pages both changed:$' | tail -n 1)" = "- none"

sample "$tmp/mr_top" top
step feat/rbac "$tmp/mr_top"
check "merge: a row of the top-level decisions.md added on main appears in list 1" has_line "- D7: Seven wins."
check "merge: the first row of the top-level decisions.md is not listed" test -z "$(printf '%s\n' "$out" | grep '^- D1:')"

sample "$tmp/mr_ours" none
git_in "$tmp/mr_ours" checkout feat/rbac
step main "$tmp/mr_ours"
check "merge: merging a main that did not move prints nothing, since one side alone contradicts nothing" nothing

sample "$tmp/mr_sync" decision
git_in "$tmp/mr_sync" checkout feat/rbac
step main "$tmp/mr_sync"
check "merge: the heading names the current branch" has_line "Decisions that reached feat/rbac since main started:"

step feat/missing "$tmp/mr"
check "merge: a ref that does not exist prints nothing" nothing
mkdir -p "$tmp/plain"
step feat/rbac "$tmp/plain"
check "merge: a directory that is not a repository prints nothing" nothing
step feat/rbac "$tmp/does-not-exist"
check "merge: a directory that does not exist prints nothing" nothing
rm -rf "$tmp/nowiki"
mkdir "$tmp/nowiki"
git_in "$tmp/nowiki" init -b main
git_in "$tmp/nowiki" config user.name Test
git_in "$tmp/nowiki" config user.email test@example.com
printf 'x\n' > "$tmp/nowiki/f"
commit_in "$tmp/nowiki" one
git_in "$tmp/nowiki" branch other
step other "$tmp/nowiki"
check "merge: a repository without docs/wiki prints nothing" nothing
rm -rf "$tmp/unrelated"
sample "$tmp/unrelated" full
git_in "$tmp/unrelated" checkout --orphan lone
git_in "$tmp/unrelated" commit -m lone --allow-empty
step feat/rbac "$tmp/unrelated"
check "merge: a ref with no merge base prints nothing" nothing

out=$(sh "$step_script" 2>&1); code=$?
check "merge: no argument is a usage error with exit 2" test "$code" -eq 2 -a -n "$out"

sample "$tmp/with space/repo" full
step feat/rbac "$tmp/with space/repo"
check "merge: a repository path with a space works" has_line "- billing-1: Plans are monthly. (01-product/users.md)"
out=$(cd "$tmp/with space/repo" && sh "$step_script" feat/rbac 2>&1); code=$?
check "merge: the default directory is the current one" has_line "- rbac-1: Roles are fixed. (01-product/users.md)"

# The hook: reads the JSON of a Bash call and asks the person when there is a list.
hook_start='{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"ask","permissionDecisionReason":"'

# unescape: decodes the escaped text on stdin, as a JSON string would.
unescape() {
  awk '{ line = $0
         for (i = 1; i <= length(line); i++) {
           c = substr(line, i, 1)
           if (c == "\\") {
             i++; d = substr(line, i, 1)
             if (d == "n") c = "\n"; else if (d == "t") c = "\t"; else if (d == "r") c = "\r"; else c = d
           }
           printf "%s", c
         } }'
}

# hook_run <cwd> <command as JSON-escaped text>: runs the hook on a Bash call.
hook_run() {
  out=$(printf '{"session_id":"s","cwd":"%s","tool_name":"Bash","tool_input":{"command":"%s","description":"d"}}' "$1" "$2" | sh "$hook_script" 2>&1)
  code=$?
}

# hook_json: the output of the hook is one line of valid JSON that asks and
# gives the same list as reason and as context. The list is kept in $tmp/hook.text.
hook_json() {
  [ "$(printf '%s\n' "$out" | wc -l | tr -d ' ')" -eq 1 ] || return 1
  case $out in "$hook_start"*) ;; *) return 1 ;; esac
  reason=$(printf '%s\n' "$out" | sed -e 's/^{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"ask","permissionDecisionReason":"//' -e 's/","additionalContext":".*$//')
  context=$(printf '%s\n' "$out" | sed -e 's/^.*","additionalContext":"//' -e 's/"}}$//')
  [ "$reason" = "$context" ] || return 1
  # no double quote is left once the escaped backslashes and quotes are taken out
  printf '%s\n' "$reason" | sed -e 's/\\\\//g' -e 's/\\"//g' | grep -q '"' && return 1
  printf '%s\n' "$reason" | unescape > "$tmp/hook.text"
}

# hook_lists <text>: the decoded list holds that text.
hook_lists() { grep -Fq -- "$1" "$tmp/hook.text"; }

hook_run "$tmp/mr" 'git merge feat/rbac'
check "merge hook: git merge asks, with valid JSON" hook_json -a "$code" -eq 0
check "merge hook: the reason holds the decision that reached main" hook_lists "- billing-1: Plans are monthly."
check "merge hook: the reason holds the last line" hook_lists "settle a contradiction with a new decision that names both."

hook_run "$tmp/mr" 'git merge --no-ff -m \"Merge rbac\" feat/rbac'
check "merge hook: options and a double-quoted message before the ref" hook_json
hook_run "$tmp/mr" "git merge -m 'x' feat/rbac"
check "merge hook: a single-quoted message before the ref" hook_json
hook_run "$tmp/mr" 'git merge -m\"x y\" feat/rbac'
check "merge hook: -m joined to its message" hook_json
hook_run "$tmp/mr" 'git merge --message=\"x y\" -s ort feat/rbac'
check "merge hook: --message=text and a strategy that takes the next token" hook_json
hook_run "$tmp" 'git -C mr merge feat/rbac'
check "merge hook: git -C dir merge uses dir from the cwd" hook_json
hook_run "$tmp" 'git -C \"$PWD/mr\" merge feat/rbac'
check "merge hook: git -C with a quoted directory that does not exist prints nothing" test -z "$out" -a "$code" -eq 0
hook_run "$tmp" 'cd mr && git merge feat/rbac'
check "merge hook: cd dir && git merge uses dir from the cwd" hook_json
hook_run "$tmp/mr" 'echo hi; git merge feat/rbac | cat && echo done'
check "merge hook: only the segment with the merge is parsed" hook_json
hook_run "$tmp/mr" 'git merge --abort'
check "merge hook: --abort prints nothing" test -z "$out" -a "$code" -eq 0
hook_run "$tmp/mr" 'git merge --continue'
check "merge hook: --continue prints nothing" test -z "$out" -a "$code" -eq 0
hook_run "$tmp/mr" 'git merge --quit'
check "merge hook: --quit prints nothing" test -z "$out" -a "$code" -eq 0
hook_run "$tmp/mr" 'git merge -m \"only a message\"'
check "merge hook: a merge with no ref prints nothing" test -z "$out" -a "$code" -eq 0
hook_run "$tmp/mr" 'git merge -m \"say \\\"hi\\\" a\\\\b\" feat/rbac'
check "merge hook: a message with escaped quotes and backslashes still parses" hook_json
hook_run "$tmp/mr" 'echo \"git merge feat/rbac\" > /dev/null'
check "merge hook: a merge inside a quoted string is not a merge" test -z "$out" -a "$code" -eq 0
hook_run "$tmp/mr" 'git merge feat/missing'
check "merge hook: a ref that does not exist prints nothing" test -z "$out" -a "$code" -eq 0
hook_run "$tmp/mr_none" 'git merge feat/rbac'
check "merge hook: when the merge step prints nothing, the hook prints nothing" test -z "$out" -a "$code" -eq 0
hook_run "$tmp/plain" 'git merge feat/rbac'
check "merge hook: a directory that is not a repository prints nothing" test -z "$out" -a "$code" -eq 0

out=$(printf '{"cwd":"%s","tool_input":{"description":"d"}}' "$tmp/mr" | sh "$hook_script" 2>&1); code=$?
check "merge hook: input without a command field prints nothing" test -z "$out" -a "$code" -eq 0
out=$(printf 'not json at all' | sh "$hook_script" 2>&1); code=$?
check "merge hook: input that is not JSON prints nothing" test -z "$out" -a "$code" -eq 0
out=$(printf '' | sh "$hook_script" 2>&1); code=$?
check "merge hook: empty input prints nothing" test -z "$out" -a "$code" -eq 0

# The branch checked out in an earlier segment is the branch merged into.
sample "$tmp/mr_co" full
git_in "$tmp/mr_co" checkout feat/rbac
step feat/rbac "$tmp/mr_co" main
check "merge: a third argument names the branch merged into" has_line "- billing-1: Plans are monthly. (01-product/users.md)"
check "merge: the heading names that branch" has_line "Decisions that reached main since feat/rbac started:"
hook_run "$tmp/mr_co" 'git checkout main && git merge feat/rbac'
check "merge hook: git checkout main before the merge sets the branch merged into" hook_json
check "merge hook: that list holds the decision on main" hook_lists "- billing-1: Plans are monthly."
hook_run "$tmp/mr_co" 'git switch main; git merge feat/rbac'
check "merge hook: git switch main before the merge sets the branch merged into" hook_json
hook_run "$tmp/mr_co" 'git -C . checkout main && git merge feat/rbac'
check "merge hook: git -C . checkout main before the merge" hook_json
hook_run "$tmp/mr_co" 'git checkout -b newbranch && git merge feat/rbac'
check "merge hook: checkout -b before the merge prints nothing" test -z "$out" -a "$code" -eq 0
hook_run "$tmp/mr_co" 'git switch -c newbranch && git merge feat/rbac'
check "merge hook: switch -c before the merge prints nothing" test -z "$out" -a "$code" -eq 0

# git does not follow the person's configuration of diff.
sample "$tmp/mr_cfg" full
printf '#!/bin/sh\necho EXTERNAL DIFF\n' > "$tmp/ext.sh"
git_in "$tmp/mr_cfg" config color.diff always
git_in "$tmp/mr_cfg" config color.ui always
git_in "$tmp/mr_cfg" config diff.external "sh $tmp/ext.sh"
git_in "$tmp/mr_cfg" config diff.renames copies
git_in "$tmp/mr_cfg" config diff.noprefix true
step feat/rbac "$tmp/mr_cfg"
check "merge: color and an external diff in the configuration change nothing" test "$out" = "$expected"

# A page renamed on one side and edited on the other.
sample "$tmp/mr_ren" decision
git_in "$tmp/mr_ren" mv docs/wiki/01-product/users.md docs/wiki/01-product/people.md
git_in "$tmp/mr_ren" commit -m rename
step feat/rbac "$tmp/mr_ren"
check "merge: a page renamed on one side and edited on the other is listed under its old name" has_line "- docs/wiki/01-product/users.md"

# A lone "-" is the previous branch.
step - "$tmp/mr"
check "merge: a ref of - is the previous branch" has_line "- rbac-1: Roles are fixed. (01-product/users.md)"
check "merge: the heading names the previous branch" has_line "Decisions that reached main since feat/rbac started:"
hook_run "$tmp/mr" 'git merge -'
check "merge hook: git merge - asks" hook_json

# A leading ~ is the home directory.
saved_home=$HOME
HOME=$tmp; export HOME
hook_run "$tmp/plain" 'cd ~/mr && git merge feat/rbac'
check "merge hook: cd ~/dir" hook_json
hook_run "$tmp/plain" 'git -C ~/mr merge feat/rbac'
check "merge hook: git -C ~/dir" hook_json
HOME=$saved_home; export HOME

hook_run "$tmp/mr" 'GIT_MERGE_AUTOEDIT=no git merge feat/rbac'
check "merge hook: a leading environment assignment" hook_json
hook_run "$tmp/mr" 'A=1 B=\"x y\" git merge feat/rbac'
check "merge hook: two leading environment assignments" hook_json

# A cell with an escaped pipe is one cell.
sample "$tmp/mr_pipe" full
printf '| billing-3 | 2026-02-05 | Allow read \\| write. | Ana | "ok" | none |\n' >> "$tmp/mr_pipe/docs/wiki/works/billing/decisions.md"
commit_in "$tmp/mr_pipe" pipe
step feat/rbac "$tmp/mr_pipe"
check "merge: an escaped pipe in a decision does not split the row" has_line "- billing-3: Allow read | write."

# A list with a quote, a backslash, a tab, and a control character in a decision.
sample "$tmp/mr_odd" full
printf '| billing-2 | 2026-02-04 | Say "hi" to C:\\dir\tand\001stop. | Ana | "ok" | none |\n' >> "$tmp/mr_odd/docs/wiki/works/billing/decisions.md"
commit_in "$tmp/mr_odd" odd
hook_run "$tmp/mr_odd" 'git merge feat/rbac'
check "merge hook: a decision with a quote, a backslash, a tab, and a control character gives valid JSON" hook_json
check "merge hook: that decision decodes back, without the control character" hook_lists 'Say "hi" to C:\dir	andstop.'

# /playbook:init: plugins/playbook/skills/init/scripts/init.sh, with a stand-in
# for the claude command first on PATH. It logs its arguments and keeps the
# plugins in a state file, one line per plugin and scope: id|scope|enabled|path.
# Like the real command, `list` reports in each record whether the plugin is on
# in the folder it runs in: the local value for that folder, else the user one.
init_script="$root/plugins/playbook/skills/init/scripts/init.sh"

init_fresh() {
  rm -rf "$tmp/init"
  mkdir -p "$tmp/init/bin" "$tmp/init/home/.claude" "$tmp/init/repo"
  : > "$tmp/init/state"
  : > "$tmp/init/log"
  cat > "$tmp/init/bin/claude" <<'FAKE'
#!/bin/sh
sub=$2
[ "$sub" = list ] && printf 'list in %s\n' "$PWD" >> "$FAKE_LOG.list"
case "$2 $3" in "list "* | "marketplace list") ;; *) printf '%s\n' "$*" >> "$FAKE_LOG" ;; esac
if [ "${FAKE_FAIL:-}" = "$sub" ]; then
  echo "error: boom in $sub" >&2
  exit 3
fi
scope=
prev=
for arg in "$@"; do
  [ "$prev" = --scope ] && scope=$arg
  prev=$arg
done
path=
[ "$scope" = local ] && path=$PWD
# set_record <value> <arguments>: the record of the plugin at the scope, added
# when missing.
set_record() {
  awk -F '|' -v OFS='|' -v id="$4" -v scope="$scope" -v path="$path" -v value="$1" '
    $1 == id && $2 == scope && $4 == path { $3 = value; seen = 1 }
    { print }
    END { if (!seen) print id, scope, value, path }' "$FAKE_STATE" > "$FAKE_STATE.new"
  mv "$FAKE_STATE.new" "$FAKE_STATE"
}
case $sub in
  marketplace)
    [ -n "${FAKE_MARKET:-}" ] || { echo "[]"; exit 0; }
    printf '[\n  {\n    "name": "other",\n    "installLocation": "/elsewhere"\n  },\n  {\n    "name": "playbook",\n    "source": "directory",\n    "installLocation": "%s"\n  }\n]\n' "$FAKE_MARKET" ;;
  list)
    awk -F '|' -v here="$PWD" '
      { line[NR] = $0
        if ($2 == "user" && !($1 in localv)) effective[$1] = $3
        if ($2 == "local" && $4 == here) { localv[$1] = 1; effective[$1] = $3 } }
      END { print "["
        for (i = 1; i <= NR; i++) {
          split(line[i], f, "|")
          if (i > 1) print "  },"
          print "  {"
          printf "    \"id\": \"%s\",\n    \"scope\": \"%s\",\n", f[1], f[2]
          if (f[4] != "") printf "    \"projectPath\": \"%s\",\n", f[4]
          if (f[5] != "") printf "    \"readFromFolder\": \"%s\",\n", f[5]
          if (f[6] != "") printf "    \"installPath\": \"%s\",\n", f[6]
          printf "    \"enabled\": %s\n", (f[1] in effective) ? effective[f[1]] : "false" }
        if (NR) print "  }"
        print "]" }' "$FAKE_STATE" ;;
  install | enable) set_record true "$@" ;;
  disable) set_record false "$@" ;;
  configure) printf 'stdin: %s\n' "$(cat)" >> "$FAKE_LOG" ;;
esac
echo "done $sub"
FAKE
  chmod +x "$tmp/init/bin/claude"
}

# init_run <arguments of init.sh>: runs it in the repository with the stand-in.
# Sets init_out and init_code.
init_run() {
  init_out=$(cd "$tmp/init/repo" && env -u CLAUDE_PROJECT_DIR HOME="$tmp/init/home" FAKE_LOG="$tmp/init/log" \
    FAKE_STATE="$tmp/init/state" PATH="$tmp/init/bin:$PATH" sh "$init_script" "$@" 2>&1)
  init_code=$?
}

# init_log_is <case name> <expected log, one command per line>
init_log_is() {
  if [ "$(cat "$tmp/init/log")" = "$2" ]; then
    printf 'ok    %s\n' "$1"
  else
    printf 'FAIL  %s\nexpected:\n%s\nlogged:\n%s\n' "$1" "$2" "$(cat "$tmp/init/log")"
    failed=$((failed + 1))
  fi
}

# init_printed <case name>: every logged command is printed with "+ " before.
init_printed() {
  if [ "$(printf '%s\n' "$init_out" | grep '^+ ' | sed 's/^+ //; s/^printf .* | //')" = \
       "$(grep -v '^stdin: ' "$tmp/init/log" | sed 's/^/claude /')" ]; then
    printf 'ok    %s\n' "$1"
  else
    printf 'FAIL  %s\n%s\n' "$1" "$init_out"
    failed=$((failed + 1))
  fi
}

# init_ok <case name> <condition: true|false>
init_ok() {
  if [ "$2" = true ]; then
    printf 'ok    %s\n' "$1"
  else
    printf 'FAIL  %s (exit %s)\n%s\n' "$1" "$init_code" "$init_out"
    failed=$((failed + 1))
  fi
}

# init_state_has <case name> <line of the state file>
init_state_has() {
  init_ok "$1" "$(grep -qxF "$2" "$tmp/init/state" && echo true || echo false)"
}

w=playbook-wiki@playbook
a=playbook-agents@playbook
r=$tmp/init/repo

init_fresh
init_run apply wiki local
init_log_is "init: wiki at local installs the wiki" "plugin install $w --scope local"
init_printed "init: wiki at local prints the command with + before it ran"
init_ok "init: wiki at local exits 0" "$([ "$init_code" -eq 0 ] && echo true || echo false)"

init_fresh
init_run apply wiki user
init_log_is "init: wiki at user installs the wiki" "plugin install $w --scope user"
init_ok "init: wiki at user reads the list in /, where no project's settings apply" \
  "$([ "$(cat "$tmp/init/log.list")" = "list in /" ] && echo true || echo false)"

init_fresh
init_run apply all local
init_log_is "init: all at local installs the wiki by name, then the agents, and clears the language" "plugin install $w --scope local
plugin install $a --scope local
plugin configure $a --values-stdin
stdin: {\"language\":\"\"}"
init_printed "init: all at local prints each command with + before it ran"
init_ok "init: all reads no list" "$([ ! -f "$tmp/init/log.list" ] && echo true || echo false)"

init_fresh
init_run apply all user es
init_log_is "init: all with a language saves it from stdin" "plugin install $w --scope user
plugin install $a --scope user
plugin configure $a --values-stdin
stdin: {\"language\":\"es\"}"
init_printed "init: all with a language prints each command with + before it ran"

# Installed already, on or off: install again by name, which turns it on.
init_fresh
printf '%s|user|false|\n%s|user|true|\n' "$w" "$a" > "$tmp/init/state"
init_run apply all user
init_log_is "init: plugins already installed are installed again by name" "plugin install $w --scope user
plugin install $a --scope user
plugin configure $a --values-stdin
stdin: {\"language\":\"\"}"
init_state_has "init: the wiki is on after installing it again" "$w|user|true|"

# On here through this repository, off at user: all at user still installs.
init_fresh
printf '%s|user|false|\n%s|local|true|%s\n' "$a" "$a" "$r" > "$tmp/init/state"
init_run apply all user
init_state_has "init: all at user turns agents on at user when only this repository had it on" "$a|user|true|"

# From the whole product to the wiki alone.
init_fresh
printf '%s|local|true|%s\n%s|local|true|%s\n' "$w" "$r" "$a" "$r" > "$tmp/init/state"
init_run apply wiki local
init_log_is "init: wiki where agents is on disables agents at that scope" "plugin install $w --scope local
plugin disable $a --scope local"
init_printed "init: the disable is printed with + before it ran"
init_state_has "init: the wiki stays on after going to the wiki alone" "$w|local|true|$r"
init_state_has "init: agents is off after going to the wiki alone" "$a|local|false|$r"

init_fresh
printf '%s|user|true|\n' "$a" > "$tmp/init/state"
init_run apply wiki local
init_log_is "init: wiki at local turns off agents that are on here through user" "plugin install $w --scope local
plugin disable $a --scope local"
init_state_has "init: agents stays on at user" "$a|user|true|"

init_fresh
printf '%s|user|true|\n%s|local|false|%s\n' "$a" "$a" "$r" > "$tmp/init/state"
init_run apply wiki user
init_log_is "init: wiki at user turns agents off at user when this repository has it off" "plugin install $w --scope user
plugin disable $a --scope user"

init_fresh
printf '%s|user|false|\n%s|local|true|%s\n' "$a" "$a" "$r" > "$tmp/init/state"
init_run apply wiki user
init_log_is "init: wiki at user leaves agents alone when it is off at user" "plugin install $w --scope user"

init_fresh
printf '%s|local|true|/somewhere/else\n' "$a" > "$tmp/init/state"
init_run apply wiki local
init_log_is "init: agents on in another repository is left alone" "plugin install $w --scope local"

# A failing command stops with its output and exit 1.
init_fresh
FAKE_FAIL=install init_run apply all user es
init_ok "init: a failing claude command makes apply exit 1" \
  "$([ "$init_code" -eq 1 ] && echo true || echo false)"
init_ok "init: the output of the failing command is printed" \
  "$(printf '%s\n' "$init_out" | grep -q 'error: boom in install' && echo true || echo false)"
init_log_is "init: apply stops at the failing command" "plugin install $w --scope user"

init_fresh
FAKE_FAIL=configure init_run apply all user es
init_ok "init: a failing configure makes apply exit 1" \
  "$([ "$init_code" -eq 1 ] && echo true || echo false)"

init_fresh
FAKE_FAIL=list init_run apply wiki user
init_ok "init: apply exits 4 when the list cannot be read" \
  "$([ "$init_code" -eq 4 ] && echo true || echo false)"
init_log_is "init: apply runs no command when the list cannot be read" ""

# Bad arguments.
# init_bad <label> <arguments of init.sh>: exit 2, the usage, and no command.
init_bad() {
  label=$1
  shift
  init_fresh
  init_run "$@"
  init_ok "init: bad arguments exit 2 with the usage ($label)" \
    "$([ "$init_code" -eq 2 ] && printf '%s\n' "$init_out" | grep -q '^Usage:' && echo true || echo false)"
  init_log_is "init: bad arguments run no claude command ($label)" ""
}
init_bad "no argument"
init_bad "apply alone" apply
init_bad "apply with one argument" apply wiki
init_bad "an unknown product" apply some local

init_fresh
init_out=$(cd "$tmp/init/repo" && HOME="$tmp/init/home" PATH="$tmp/init/bin:$PATH" sh "$init_script" --help 2>/dev/null)
init_ok "init: --help prints the usage on standard output" \
  "$(printf '%s\n' "$init_out" | grep -q '^Usage:' && echo true || echo false)"
init_out=$(cd "$tmp/init/repo" && HOME="$tmp/init/home" PATH="$tmp/init/bin:$PATH" sh "$init_script" apply 2>/dev/null)
init_ok "init: a wrong call prints nothing on standard output" \
  "$([ -z "$init_out" ] && echo true || echo false)"

init_fresh
init_run --help
init_ok "init: --help prints the usage with the exit codes and exits 0" \
  "$([ "$init_code" -eq 0 ] && printf '%s\n' "$init_out" | grep -q '^Exit codes' && echo true || echo false)"

init_fresh
init_run apply all local 'a"b'
init_ok "init: a language with a quote says what is wrong" \
  "$([ "$init_code" -eq 2 ] && printf '%s\n' "$init_out" | grep -q 'must not hold a quote' && echo true || echo false)"
init_bad "an unknown scope" apply wiki project
init_bad "too many arguments" apply wiki local es extra
init_bad "scan with an argument" scan extra
init_bad "an unknown command" other
init_bad "a quote in the language" apply all user 'a"b'
init_bad "a backslash in the language" apply all user 'a\b'

# scan.
init_fresh
{
  printf '%s|user|true|\n' "$w"
  printf '%s|user|true|\n' "$a"
  printf '%s|local|false|%s\n' "$a" "$r"
  printf 'engram@engram|user|true|\n'
  printf 'figma@official|user|false|\n'
} > "$tmp/init/state"
printf 'rules\n' > "$tmp/init/home/.claude/CLAUDE.md"
init_run scan
init_ok "init: scan reports the wiki as on here" \
  "$(printf '%s\n' "$init_out" | grep -q "$w: on here" && echo true || echo false)"
init_ok "init: scan reports agents as off here when this repository has it off" \
  "$(printf '%s\n' "$init_out" | grep -q "$a: off here" && echo true || echo false)"
init_ok "init: scan lists each scope agents is installed at" \
  "$(printf '%s\n' "$init_out" | grep -q '    installed at scope user$' &&
     printf '%s\n' "$init_out" | grep -q "    installed at scope local for $r" && echo true || echo false)"
init_ok "init: scan lists another plugin that is on" \
  "$(printf '%s\n' "$init_out" | grep -q '^  engram@engram$' && echo true || echo false)"
init_ok "init: scan does not list a plugin that is off" \
  "$(printf '%s\n' "$init_out" | grep -q 'figma' && echo false || echo true)"
init_ok "init: scan reports a global CLAUDE.md" \
  "$(printf '%s\n' "$init_out" | grep -q "exists: $tmp/init/home/.claude/CLAUDE.md" && echo true || echo false)"

init_fresh
init_run scan
init_ok "init: scan reports no plugin, no other plugin, and no CLAUDE.md on a clean machine" \
  "$(printf '%s\n' "$init_out" | grep -c 'not installed\|  none' | grep -q '^4$' && echo true || echo false)"

init_fresh
FAKE_FAIL=list init_run scan
init_ok "init: scan exits 4 when the list cannot be read" \
  "$([ "$init_code" -eq 4 ] && echo true || echo false)"

init_fresh
mkdir "$tmp/init/config"
printf 'rules\n' > "$tmp/init/config/CLAUDE.md"
printf 'rules\n' > "$tmp/init/home/.claude/CLAUDE.md"
CLAUDE_CONFIG_DIR="$tmp/init/config" init_run scan
init_ok "init: scan with CLAUDE_CONFIG_DIR reports both global CLAUDE.md files" \
  "$(printf '%s\n' "$init_out" | grep -q "exists: $tmp/init/config/CLAUDE.md" &&
     printf '%s\n' "$init_out" | grep -q "exists: $tmp/init/home/.claude/CLAUDE.md" && echo true || echo false)"

# apply writes no file of its own and no CLAUDE.md.
init_fresh
init_run apply all local es
init_ok "init: apply creates no CLAUDE.md and no file in the repository or home" \
  "$([ -z "$(find "$tmp/init/repo" "$tmp/init/home" -type f)" ] && echo true || echo false)"

# skills: the skills the choice turns on, read from the marketplace's folder,
# and the skills that are not the product's.
# init_skill <folder> <front matter lines>: a SKILL.md with that front matter.
init_skill() {
  mkdir -p "$1"
  printf -- '---\n%s\n---\n\nBody.\n' "$2" > "$1/SKILL.md"
}
init_fresh_skills() {
  init_fresh
  m=$tmp/init/market
  init_skill "$m/plugins/playbook-wiki/skills/write-docs" 'name: write-docs
description: Write a README or a wiki page.'
  init_skill "$m/plugins/playbook-agents/skills/review-change" 'name: review-change
description: Review a change for defects.'
  init_skill "$tmp/init/repo/.claude/skills/docs-lite" 'name: docs-lite
description: >
  Write the docs
  of this project.'
  init_skill "$tmp/init/home/.claude/skills/my-review" "name: 'my-review'
description: \"Review my diff.\""
  mkdir -p "$tmp/init/home/.claude/skills/no-skill-file"
  init_skill "$tmp/init/home/.claude/skills/bare" 'license: MIT'
  init_skill "$tmp/init/other/skills/lint-it" 'name: lint-it
description: Lint the code.'
  init_skill "$tmp/init/off/skills/hidden" 'name: hidden
description: Never listed.'
  init_skill "$tmp/init/copy/skills/from-copy" 'name: from-copy
description: Read from the copy.'
  mkdir -p "$tmp/init/repo/.claude/skills/crlf"
  printf -- '---\r\nname: crlf\r\ndescription: Ends lines with CR.\r\n---\r\n' > "$tmp/init/repo/.claude/skills/crlf/SKILL.md"
  mkdir -p "$tmp/init/repo/.claude/skills/open"
  printf -- '---\nname: open\n\nbody\ndescription: From the body.\n' > "$tmp/init/repo/.claude/skills/open/SKILL.md"
  {
    printf 'tools@else|user|true||%s\n' "$tmp/init/other"
    printf 'offtool@else|user|false||%s\n' "$tmp/init/off"
    printf 'copytool@else|user|true|||%s\n' "$tmp/init/copy"
    printf '%s|user|true||%s\n' "$w" "$m/plugins/playbook-wiki"
  } > "$tmp/init/state"
}
init_has() {
  init_ok "$1" "$(printf '%s\n' "$init_out" | grep -qxF -- "$2" && echo true || echo false)"
}

init_fresh_skills
FAKE_MARKET=$m init_run skills wiki
init_ok "init: skills exits 0" "$([ "$init_code" -eq 0 ] && echo true || echo false)"
init_has "init: skills lists the wiki's skills from the marketplace's folder" "  playbook-wiki:write-docs — Write a README or a wiki page."
init_ok "init: skills for the wiki alone does not list the agents' skills" \
  "$(printf '%s\n' "$init_out" | grep -q 'review-change' && echo false || echo true)"
init_has "init: skills joins a description written over several lines" "  docs-lite — Write the docs of this project."
init_has "init: skills takes the quotes off a name and a description" "  my-review — Review my diff."
init_has "init: skills names a skill with no name by its folder" "  bare — "
init_ok "init: skills skips a folder with no SKILL.md" \
  "$(printf '%s\n' "$init_out" | grep -q 'no-skill-file' && echo false || echo true)"
init_has "init: skills lists the skills of another plugin that is on, with its name" "  tools:lint-it — Lint the code."
init_ok "init: skills does not list a plugin that is off" \
  "$(printf '%s\n' "$init_out" | grep -q 'hidden' && echo false || echo true)"
init_ok "init: skills does not list the product's plugin among the others" \
  "$(printf '%s\n' "$init_out" | grep -c 'write-docs' | grep -qx 1 && echo true || echo false)"
init_has "init: skills prints where the format of a wiki is" "The format of a wiki: $m/plugins/playbook-wiki/format.md"
init_log_is "init: skills runs no command that changes anything" ""

init_has "init: skills reads a plugin with no readFromFolder from its installPath" "  copytool:from-copy — Read from the copy."
init_has "init: skills reads a SKILL.md with CRLF line ends" "  crlf — Ends lines with CR."
init_has "init: skills takes nothing from front matter with no closing line" "  open — "

init_fresh_skills
mkdir -p "$tmp/init/repo/.claude"
printf '{\n  "skillOverrides": {\n    "docs-lite": "off"\n  }\n}\n' > "$tmp/init/repo/.claude/settings.local.json"
printf '{\n  "skillOverrides": {\n    "my-review": "off"\n  }\n}\n' > "$tmp/init/home/.claude/settings.json"
FAKE_MARKET=$m init_run skills wiki
init_has "init: skills marks a skill this repository sets off" "  docs-lite (off) — Write the docs of this project."
init_has "init: skills marks a skill the person sets off" "  my-review (off) — Review my diff."

init_fresh_skills
FAKE_MARKET=$m init_run skills all
init_has "init: skills for the whole product lists the agents' skills" "  playbook-agents:review-change — Review a change for defects."

init_fresh_skills
mkdir -p "$tmp/init/config/skills"
init_skill "$tmp/init/config/skills/configured" 'name: configured
description: In the configured folder.'
FAKE_MARKET=$m CLAUDE_CONFIG_DIR="$tmp/init/config" init_run skills wiki
init_has "init: skills reads the person's skills from CLAUDE_CONFIG_DIR" "  configured — In the configured folder."

init_fresh
rm -rf "$tmp/init/repo/.claude"
FAKE_MARKET=$tmp/init/empty init_run skills wiki
init_ok "init: skills prints none for each empty group" \
  "$(printf '%s\n' "$init_out" | grep -c '^  none$' | grep -qx 4 && echo true || echo false)"

# Keep both, and the wiki (setup-commands-5, setup-commands-6, setup-commands-8).
init_fresh_skills
mkdir -p "$tmp/init/repo/.claude"
printf '{"playbook":{"keepBoth":["tools:lint-it","crlf"]}}\n' > "$tmp/init/repo/.claude/settings.local.json"
printf '{\n  "playbook": {\n    "keepBoth": [\n      "my-review"\n    ]\n  }\n}\n' > "$tmp/init/home/.claude/settings.json"
FAKE_MARKET=$m init_run skills wiki
init_has "init: skills marks a skill of another plugin kept in this repository" "  tools:lint-it (kept) — Lint the code."
init_has "init: skills marks a skill of the person kept for every project" "  my-review (kept) — Review my diff."
init_has "init: skills marks a skill of the project kept in this repository" "  crlf (kept) — Ends lines with CR."
init_has "init: skills does not mark a skill that was not kept" "  docs-lite — Write the docs of this project."
init_has "init: skills prints where the skeleton of a wiki is" "The skeleton of a wiki: $m/plugins/playbook-wiki/skeleton.md"

init_fresh
init_run keep local my-review
init_ok "init: keep creates the repository's settings file" \
  "$([ "$init_code" -eq 0 ] && [ "$(cat "$r/.claude/settings.local.json")" = '{"playbook": {"keepBoth": ["my-review"]}}' ] && echo true || echo false)"
init_run keep local tools:lint-it
init_run keep local my-review
init_ok "init: keep adds a second name first and a name only once" \
  "$([ "$(cat "$r/.claude/settings.local.json")" = '{"playbook": {"keepBoth": ["tools:lint-it","my-review"]}}' ] && echo true || echo false)"
mkdir -p "$r/sub"
init_out=$(cd "$r/sub" && HOME="$tmp/init/home" CLAUDE_PROJECT_DIR="$r" PATH="$tmp/init/bin:$PATH" sh "$init_script" keep local other 2>&1); init_code=$?
init_ok "init: keep local from a subfolder writes the project's file" \
  "$([ "$init_code" -eq 0 ] && [ ! -e "$r/sub/.claude" ] && grep -q '"other"' "$r/.claude/settings.local.json" && echo true || echo false)"
printf '{\n  "theme": "dark",\n  "playbook": {"models": {"review": "opus"}},\n  "skillOverrides": {"x": "off"}\n}\n' > "$tmp/init/home/.claude/settings.json"
init_run keep user my-review
init_ok "init: keep user keeps every other key, in place" \
  "$([ "$(cat "$tmp/init/home/.claude/settings.json")" = "$(printf '{\n  "theme": "dark",\n  "playbook": {"keepBoth": ["my-review"],"models": {"review": "opus"}},\n  "skillOverrides": {"x": "off"}\n}')" ] && echo true || echo false)"
printf '{"playbook":{"keepBoth":[{"o":1}]}}\n' > "$tmp/init/home/.claude/settings.json"
init_run keep user z
init_ok "init: keep adds a comma before an element that is not a string" \
  "$([ "$(cat "$tmp/init/home/.claude/settings.json")" = '{"playbook":{"keepBoth":["z",{"o":1}]}}' ] && echo true || echo false)"
for text in '[1]' '{"playbook":"x"}' '{"playbook":{"keepBoth":"x"}}' '{"a":1' '{"a":1}x' '{"a":1,}' '{"a":1]' '{"a":[1}}' '{,"a":1}' '{"a":1,,"b":2}'; do
  printf '%s\n' "$text" > "$tmp/init/home/.claude/settings.json"
  init_run keep user z
  init_ok "init: keep leaves $text unchanged and exits 3" \
    "$([ "$init_code" -eq 3 ] && [ "$(cat "$tmp/init/home/.claude/settings.json")" = "$text" ] && echo true || echo false)"
done
init_run keep user 'a"b'
init_ok "init: keep refuses a name with a quote" "$([ "$init_code" -eq 2 ] && echo true || echo false)"
init_run keep elsewhere z
init_ok "init: keep refuses a scope that does not exist" "$([ "$init_code" -eq 2 ] && echo true || echo false)"
init_log_is "init: keep runs no claude command" ""

init_fresh
init_run scan
init_has "init: scan says the repository has no wiki" "Wiki of this repository: missing"
FAKE_MARKET=$tmp/init/market init_run scan
init_has "init: scan names the skeleton when the repository has no wiki" "The skeleton of a wiki: $tmp/init/market/plugins/playbook-wiki/skeleton.md"
mkdir -p "$r/docs/wiki"
printf '# Wiki\n' > "$r/docs/wiki/README.md"
FAKE_MARKET=$tmp/init/market init_run scan
init_has "init: scan names the wiki the repository has" "Wiki of this repository: $r/docs/wiki/README.md"
init_ok "init: scan names no skeleton when the repository has a wiki" \
  "$(printf '%s\n' "$init_out" | grep -q 'skeleton' && echo false || echo true)"

init_fresh
init_run skills wiki
init_ok "init: skills exits 3 when the marketplace is not added" \
  "$([ "$init_code" -eq 3 ] && echo true || echo false)"

init_fresh
FAKE_MARKET=$tmp/init/market FAKE_FAIL=marketplace init_run skills wiki
init_ok "init: skills exits 4 when the marketplaces cannot be read" \
  "$([ "$init_code" -eq 4 ] && echo true || echo false)"

init_bad "skills alone" skills
init_bad "skills of an unknown product" skills some
init_bad "skills with too many arguments" skills wiki extra

# The commit check: the check of the wiki runs before a commit that changes it.
commit_hook="$root/plugins/playbook-wiki/hooks/commit-check-hook.sh"

# wiki_repo <dir> <format marker or none>: a repository with a wiki that passes
# the check, committed.
wiki_repo() {
  rm -rf "$1"
  mkdir -p "$1/docs/wiki/works/w"
  git_in "$1" init -b main
  git_in "$1" config user.name Test
  git_in "$1" config user.email test@example.com
  git_in "$1" config commit.gpgsign false
  printf '# W\n\nProject owner: Ana.\n' > "$1/docs/wiki/README.md"
  printf '# w\n\n## Where work stands\n\nShort.\n' > "$1/docs/wiki/works/w/README.md"
  [ "$2" = none ] || printf '%s\n' "$2" > "$1/docs/wiki/.format"
  commit_in "$1" base
}

# break_wiki <dir>: makes "Where work stands" of the work hold 300 words.
break_wiki() {
  { printf '# w\n\n## Where work stands\n\n'; words 300; } > "$1/docs/wiki/works/w/README.md"
}

# commit_run <cwd> <command as JSON-escaped text>: runs the hook on a Bash call.
commit_run() {
  out=$(printf '{"session_id":"s","cwd":"%s","tool_name":"Bash","tool_input":{"command":"%s","description":"d"}}' "$1" "$2" | sh "$commit_hook" 2>&1)
  code=$?
}

# denied: the output is one line that denies and holds the check's failure.
denied() {
  [ "$code" -eq 0 ] || return 1
  [ "$(printf '%s\n' "$out" | wc -l | tr -d ' ')" -eq 1 ] || return 1
  case $out in
    '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"'*'"}}') ;;
    *) return 1 ;;
  esac
  printf '%s\n' "$out" | grep -Fq 'FAIL works/w/README.md: \"Where work stands\" has 300 words, limit 250' &&
    printf '%s\n' "$out" | grep -Fq 'the commit is stopped until it passes'
}

present_format=$(sh "$root/plugins/playbook-wiki/check-wiki.sh" --format)
wiki_repo "$tmp/cc" "$present_format"
break_wiki "$tmp/cc"
commit_run "$tmp/cc" 'git commit -m x'
check "commit hook: a failing wiki change stops git commit, with the check's output" denied
commit_run "$tmp/cc" 'git add -A && git commit -m x'
check "commit hook: a failing wiki change stops git add -A && git commit, nothing staged yet" denied
commit_run "$tmp" "cd $tmp/cc && git commit -m x"
check "commit hook: a failing wiki change stops cd <dir> && git commit" denied
commit_run "$tmp" "git -C $tmp/cc commit -m x"
check "commit hook: a failing wiki change stops git -C <dir> commit" denied
commit_run "$tmp/cc" 'git status'
check "commit hook: a command with no commit prints nothing" test -z "$out" -a "$code" -eq 0
commit_run "$tmp/cc" 'echo "git commit -m x"'
check "commit hook: a commit inside a quoted string prints nothing" test -z "$out" -a "$code" -eq 0

wiki_repo "$tmp/cc_ok" "$present_format"
printf '\nMore.\n' >> "$tmp/cc_ok/docs/wiki/works/w/README.md"
commit_run "$tmp/cc_ok" 'git commit -m x'
check "commit hook: a wiki that passes prints nothing" test -z "$out" -a "$code" -eq 0

# A committed wiki that fails, and a change outside docs/wiki/.
wiki_repo "$tmp/cc_same" "$present_format"
break_wiki "$tmp/cc_same"
commit_in "$tmp/cc_same" broken
printf 'x\n' > "$tmp/cc_same/other.txt"
commit_run "$tmp/cc_same" 'git add -A && git commit -m x'
check "commit hook: a commit with no change under docs/wiki/ prints nothing, even if the wiki fails" test -z "$out" -a "$code" -eq 0

wiki_repo "$tmp/cc_new" "$present_format"
printf '# n\n\n[x](missing.md)\n' > "$tmp/cc_new/docs/wiki/new.md"
commit_run "$tmp/cc_new" 'git commit -m x'
check "commit hook: a new file under docs/wiki/ counts as a change" test "$code" -eq 0 -a -n "$out"

wiki_repo "$tmp/cc_old" $((present_format - 1))
break_wiki "$tmp/cc_old"
commit_run "$tmp/cc_old" 'git commit -m x'
check "commit hook: a wiki below the format prints nothing" test -z "$out" -a "$code" -eq 0
wiki_repo "$tmp/cc_new5" $((present_format + 1))
break_wiki "$tmp/cc_new5"
commit_run "$tmp/cc_new5" 'git commit -m x'
check "commit hook: a failing wiki change above the format is stopped" denied
wiki_repo "$tmp/cc_long" 0000000004
break_wiki "$tmp/cc_long"
commit_run "$tmp/cc_long" 'git commit -m x'
check "commit hook: a format marker of ten digits or more prints nothing" test -z "$out" -a "$code" -eq 0
wiki_repo "$tmp/cc_nomark" none
break_wiki "$tmp/cc_nomark"
commit_run "$tmp/cc_nomark" 'git commit -m x'
check "commit hook: a wiki with no format marker prints nothing" test -z "$out" -a "$code" -eq 0
wiki_repo "$tmp/cc_nan" abc
break_wiki "$tmp/cc_nan"
commit_run "$tmp/cc_nan" 'git commit -m x'
check "commit hook: a format marker that is not a number prints nothing" test -z "$out" -a "$code" -eq 0

wiki_repo "$tmp/cc_nowiki" "$present_format"
git_in "$tmp/cc_nowiki" rm -r docs
commit_in "$tmp/cc_nowiki" nowiki
printf 'x\n' > "$tmp/cc_nowiki/a.txt"
commit_run "$tmp/cc_nowiki" 'git commit -m x'
check "commit hook: a repository with no docs/wiki/ prints nothing" test -z "$out" -a "$code" -eq 0
commit_run "$tmp/plain" 'git commit -m x'
check "commit hook: a directory that is not a repository prints nothing" test -z "$out" -a "$code" -eq 0

out=$(printf '{"cwd":"%s","tool_input":{"description":"d"}}' "$tmp/cc" | sh "$commit_hook" 2>&1); code=$?
check "commit hook: input without a command field prints nothing" test -z "$out" -a "$code" -eq 0
out=$(printf 'not json at all' | sh "$commit_hook" 2>&1); code=$?
check "commit hook: input that is not JSON prints nothing" test -z "$out" -a "$code" -eq 0
out=$(printf '' | sh "$commit_hook" 2>&1); code=$?
check "commit hook: empty input prints nothing" test -z "$out" -a "$code" -eq 0

# The hook of playbook-agents: the rules, and the language line when it is set.
hook_command=$(sed -n 's/^ *"command": "\(.*session-start\.sh.*\)"$/\1/p' "$root/plugins/playbook-agents/hooks/hooks.json" |
  sed 's/\\"/"/g')
hook_text() {
  # shellcheck disable=SC2016
  CLAUDE_PLUGIN_ROOT="$root/plugins/playbook-agents" sh -c "$hook_command"
}
rules_text=$(cat "$root/plugins/playbook-agents/rules.md")
init_out=$(CLAUDE_PLUGIN_OPTION_LANGUAGE=es hook_text)
init_ok "init: the hook prints the rules and the language line when a language is set" \
  "$([ "$init_out" = "$rules_text
Talk to the person in es." ] && echo true || echo false)"
init_out=$(CLAUDE_PLUGIN_OPTION_LANGUAGE="" hook_text)
init_ok "init: the hook prints only the rules when the language is empty" \
  "$([ "$init_out" = "$rules_text" ] && echo true || echo false)"
init_out=$(env -u CLAUDE_PLUGIN_OPTION_LANGUAGE sh -c "CLAUDE_PLUGIN_ROOT='$root/plugins/playbook-agents' sh -c '$hook_command'")
init_ok "init: the hook prints only the rules when no language is set" \
  "$([ "$init_out" = "$rules_text" ] && echo true || echo false)"

# The hold before a commit (review-trigger-4, review-trigger-6, review-trigger-7).
hold_hook="$root/plugins/playbook-agents/hooks/review-before-commit.sh"
ran_hook="$root/plugins/playbook-agents/hooks/review-ran.sh"
hold_data="$tmp/hold_data"
rm -rf "$tmp/hold" "$hold_data"
mkdir -p "$tmp/hold"
git_in "$tmp/hold" init -b main
git_in "$tmp/hold" config user.name Test
git_in "$tmp/hold" config user.email test@example.com
git_in "$tmp/hold" config commit.gpgsign false
printf 'a\n' > "$tmp/hold/a.sh"
commit_in "$tmp/hold" base
printf 'b\n' >> "$tmp/hold/a.sh"

# hold_run <session> <cwd> <command as JSON-escaped text>: runs the hold hook.
hold_run() {
  out=$(printf '{"session_id":"%s","cwd":"%s","tool_name":"Bash","tool_input":{"command":"%s","description":"d"}}' "$1" "$2" "$3" |
    CLAUDE_PLUGIN_DATA="$hold_data" sh "$hold_hook" 2>&1)
  code=$?
}
# ran_run <session> <agent type>: runs the mark hook on SubagentStop.
ran_run() {
  out=$(printf '{"session_id":"%s","hook_event_name":"SubagentStop","agent_id":"x","agent_type":"%s"}' "$1" "$2" |
    CLAUDE_PLUGIN_DATA="$hold_data" sh "$ran_hook" 2>&1)
  code=$?
}
# held: one line that denies, with R20 and what the commit changes.
held() {
  [ "$code" -eq 0 ] || return 1
  [ "$(printf '%s\n' "$out" | wc -l | tr -d ' ')" -eq 1 ] || return 1
  case $out in
    '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"'*'"}}') ;;
    *) return 1 ;;
  esac
  printf '%s\n' "$out" | grep -Fq 'R20. A change is risky' &&
    printf '%s\n' "$out" | grep -Fq ' M a.sh' &&
    printf '%s\n' "$out" | grep -Fq 'commit again and it will go through'
}
passes() { [ -z "$out" ] && [ "$code" -eq 0 ]; }
# held_any: one line that denies, whatever the changes listed.
held_any() {
  [ "$code" -eq 0 ] && printf '%s\n' "$out" | grep -Fq '"permissionDecision":"deny"'
}

hold_run s1 "$tmp/hold" 'git add -A && git commit -m x'
check "hold: a commit with no review since the last commit is held, with R20 and the changes" held
hold_run s1 "$tmp/hold" 'git add -A && git commit -m x'
check "hold: a commit on the same HEAD then runs" passes
hold_run s1 "$tmp/hold" 'git add -A && git commit -m x'
check "hold: the same commit runs again while HEAD has not moved, as after a failed commit" passes
hold_run s1 "$tmp/hold" 'git add -A && git commit -m y; git log --oneline | head -3'
check "hold: another command on the same HEAD runs, as when the agent adds commands to its try" passes
hold_run s2 "$tmp/hold" 'git add -A && git commit -m y'
check "hold: a hold of one session does not let another session through" held
hold_run s3 "$tmp" "git -C $tmp/hold commit -am x"
check "hold: git -C <dir> commit is held" held
hold_run s4 "$tmp" "cd $tmp/hold && git commit -am x"
check "hold: cd <dir> && git commit is held" held
hold_run s1 "$tmp/hold" 'git add -A && git commit -m y'
commit_in "$tmp/hold" y
printf 'c\n' >> "$tmp/hold/a.sh"
hold_run s1 "$tmp/hold" 'git add -A && git commit -m y'
check "hold: once HEAD moves, the same command is held again" held

rm -rf "$hold_data"
hold_run s1 "$tmp/hold" 'git commit -am x'
ran_run s1 playbook-agents:review
check "hold: review stopping writes the session's mark and prints nothing" test -z "$out" -a "$code" -eq 0 -a -f "$hold_data/review/s1"
hold_run s1 "$tmp/hold" 'git commit -am z'
check "hold: a commit after review runs" passes
hold_run s1 "$tmp/hold" 'git commit -am z'
check "hold: a commit after review runs again while HEAD has not moved, as after a failed commit" passes
commit_in "$tmp/hold" z
printf 'd\n' >> "$tmp/hold/a.sh"
hold_run s1 "$tmp/hold" 'git commit -am w'
check "hold: once HEAD moves, the next commit needs another review" held
check "hold: the mark is removed once HEAD moves" absent "$hold_data/review/s1"
git_in "$tmp/hold" worktree add -q "$tmp/hold_wt"
printf 'e\n' >> "$tmp/hold_wt/a.sh"
ran_run s11 playbook-agents:review
hold_run s11 "$tmp/hold" 'git commit -am v'
hold_run s11 "$tmp/hold_wt" 'git commit -am v'
check "hold: a mark used in one worktree does not let a commit in another through at the same HEAD" held

ran_run s5 playbook-agents:explore
check "hold: another agent stopping writes no mark" absent "$hold_data/review/s5"
ran_run s5 review
check "hold: an agent named review outside the plugin writes no mark" absent "$hold_data/review/s5"
ran_run '../s5' playbook-agents:review
check "hold: a session id with a slash writes nothing" absent "$tmp/s5"
mkdir -p "$hold_data/review"
: > "$hold_data/review/old"
touch -t 202001010000 "$hold_data/review/old"
mkdir -p "$hold_data/held"
: > "$hold_data/held/old"
touch -t 202001010000 "$hold_data/held/old"
ran_run s6 playbook-agents:review
check "hold: a mark older than seven days is removed when one is written" absent "$hold_data/review/old"
check "hold: a held commit older than seven days is removed when a mark is written" absent "$hold_data/held/old"

# The delivery hook (ask-before-irreversible-12, ask-before-irreversible-13).
deliv_hook="$root/plugins/playbook-agents/hooks/ask-before-delivery.sh"
# deliv_run <command as raw text>: runs the hook on a Bash call with that command.
deliv_run() {
  esc=$(printf '%s' "$1" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g')
  out=$(printf '{"session_id":"s","cwd":"/tmp","tool_name":"Bash","tool_input":{"command":"%s"}}' "$esc" | sh "$deliv_hook" 2>&1)
  code=$?
}
# asks: exactly one line that asks, with R14 as the reason.
asks() {
  [ "$code" -eq 0 ] || return 1
  [ "$(printf '%s\n' "$out" | wc -l | tr -d ' ')" -eq 1 ] || return 1
  [ "$out" = '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"ask","permissionDecisionReason":"R14: push, pull requests, merges, and releases are the owner'"'"'s decisions. Confirm this one."}}' ]
}
deliv_asks() {
  deliv_run "$1"
  check "delivery hook: asks on $1" asks
}
deliv_silent() {
  deliv_run "$1"
  check "delivery hook: silent on $1" passes
}
deliv_asks 'git push'
deliv_asks 'git -C /x push origin HEAD'
deliv_asks 'cd x && git push'
deliv_asks 'FOO=1 git push'
deliv_asks 'git push --tags'
deliv_asks 'git push --delete origin b'
deliv_asks 'git -c a=b push'
deliv_asks 'git --git-dir=/x/.git push'
deliv_asks 'gh pr create --fill'
deliv_asks 'gh pr merge 3'
deliv_asks 'gh release create v1'
deliv_asks 'gh release edit v1'
deliv_asks 'gh release delete v1'
deliv_asks "sh -c 'git push'"
deliv_asks 'bash -c "gh pr merge 1"'
deliv_asks 'eval git push'
deliv_asks 'git status; git push'
deliv_asks 'git status
git push'
deliv_asks "bash -c 'gh release create v1'"
# Shell keywords and wrappers before the command word.
deliv_asks 'for r in a b; do git push "$r" main; done'
deliv_asks 'if ! git push; then echo f; fi'
deliv_asks '! git push'
deliv_asks '{ git push; }'
deliv_asks 'time git push'
deliv_asks 'env GIT_SSH_COMMAND=x git push'
deliv_asks 'env -u X git push'
deliv_asks 'sudo git push'
deliv_asks 'sudo -u bob git push'
deliv_asks 'nohup git push'
deliv_asks 'command git push'
deliv_asks 'exec git push'
# The aliases of gh.
deliv_asks 'gh pr new'
deliv_asks 'gh release new v1'
# Options of the shell before -c, and of gh and git before the subcommand.
deliv_asks "bash -lc 'git push'"
deliv_asks "bash -o pipefail -c 'git push'"
deliv_asks "bash -euo pipefail -c 'git push'"
deliv_asks 'gh -R o/r pr merge 1'
deliv_asks 'git --git-dir /x/.git push'
# Each action inside each wrapper.
for deliv_action in 'git -C /x push' 'gh pr merge 1' 'gh release delete v1'; do
  deliv_asks "sh -c '$deliv_action'"
  deliv_asks "bash -c \"$deliv_action\""
  deliv_asks "eval $deliv_action"
done
# Known gap, accepted (architecture.md): the body of a heredoc is read as
# commands, so a line that looks like one asks. A false ask, never a missed one.
deliv_asks "git commit -F - <<'EOF'
subject
gh pr merge now asks
EOF"
deliv_silent 'git commit -m "push it"'
deliv_silent 'sudo git log'
deliv_silent 'env FOO=1 git log'
deliv_silent 'if true; then git status; fi'
deliv_silent 'echo git push'
deliv_silent 'git log'
deliv_silent 'git status'
deliv_silent 'gh pr view 1'
deliv_silent 'gh pr list'
deliv_silent 'gh release list'
deliv_silent 'gh release view v1'
deliv_silent 'git stash push'
deliv_silent 'ls'
deliv_silent "sh -c 'git log'"
out=$(printf '{"tool_input":{"command":""}}' | sh "$deliv_hook" 2>&1); code=$?
check "delivery hook: an empty command prints nothing" passes
out=$(printf '' | sh "$deliv_hook" 2>&1); code=$?
check "delivery hook: empty input prints nothing" passes
out=$(printf 'not json at all' | sh "$deliv_hook" 2>&1); code=$?
check "delivery hook: input that is not JSON asks" asks
out=$(printf '{"cwd":"/tmp","tool_input":{"description":"d"}}' | sh "$deliv_hook" 2>&1); code=$?
check "delivery hook: input without a command field asks" asks
rm -rf "$tmp/nolib2"
mkdir -p "$tmp/nolib2/hooks"
cp "$deliv_hook" "$tmp/nolib2/hooks/"
out=$(printf '{"tool_input":{"command":"ls"}}' | sh "$tmp/nolib2/hooks/ask-before-delivery.sh" 2>&1); code=$?
check "delivery hook: a missing hook-lib.sh asks" asks

# The classifier check of the same hook (repeated-corrections-17).
cls_t="$tmp/cls"
rm -rf "$cls_t"
mkdir -p "$cls_t"
printf '{"type":"assistant","message":{"content":[{"type":"tool_use","name":"Read","input":{"file_path":"a"}}]}}\n' > "$cls_t/none.jsonl"
printf '{"type":"assistant","message":{"content":[{"type":"tool_use","name":"Agent","input":{"description":"c",  "subagent_type" : "playbook-agents:classify","prompt":"x"}}]}}\n' > "$cls_t/with.jsonl"
printf '{"type":"user","message":{"content":"say \\"subagent_type\\": \\"playbook-agents:classify\\""}}\n' > "$cls_t/quoted.jsonl"
# cls_run <session> <agent type> <transcript> <last message as JSON text> [extra JSON fields]
cls_run() {
  out=$(printf '{"session_id":"%s","hook_event_name":"SubagentStop",%s"agent_id":"%s","agent_type":"%s","agent_transcript_path":"%s","last_assistant_message":"%s"}' \
    "$1" "${5:-}" "${cls_agent-a$1}" "$2" "$3" "$4" | CLAUDE_PLUGIN_DATA="$hold_data" sh "$ran_hook" 2>&1)
  code=$?
}
blocked() {
  [ "$code" -eq 0 ] || return 1
  [ "$(printf '%s\n' "$out" | wc -l | tr -d ' ')" -eq 1 ] || return 1
  case $out in
    '{"decision":"block","reason":"'*'playbook-agents:classify'*'"}') ;;
    *) return 1 ;;
  esac
  # The reason is a JSON string: no quote inside it but an escaped one.
  reason=${out#'{"decision":"block","reason":"'}
  reason=${reason%'"}'}
  case $(printf '%s' "$reason" | sed 's/\\"//g') in
    *\"*) return 1 ;;
  esac
  printf '%s' "$reason" | grep -Fq "then end with your full report again, findings included"
}
rm -rf "$hold_data"
cls_run c1 playbook-agents:review "$cls_t/none.jsonl" 'Finding 1: a.sh:3 \"quoted\"\nmore.'
check "classify: findings and no classifier block with a reason" blocked
check "classify: the mark is written when it blocks" test -f "$hold_data/review/c1"
cls_run c2 playbook-agents:review "$cls_t/quoted.jsonl" 'Finding 1: x'
check "classify: a transcript that only quotes the call as text still blocks" blocked
cls_run c3 playbook-agents:review "$cls_t/none.jsonl" 'Reviewed.\n\nNo findings.'
check "classify: No findings. passes" passes
cls_run c3b playbook-agents:review "$cls_t/none.jsonl" 'Commit A: No findings.\n\nCommit B:\nFinding 1: x.sh:3 breaks'
check "classify: No findings. inside another line, beside findings, still blocks" blocked
cls_run c3c playbook-agents:review "$cls_t/none.jsonl" 'Reviewed.\n  No findings.  \n'
check "classify: a line of No findings. with spaces around it passes" passes
check "classify: the mark is written with No findings." test -f "$hold_data/review/c3"
cls_run c4 playbook-agents:review "$cls_t/with.jsonl" 'Finding 1: x'
check "classify: a transcript with the classifier call passes" passes
check "classify: the mark is written when the classifier ran" test -f "$hold_data/review/c4"
cls_run c5 playbook-agents:review "$cls_t/none.jsonl" 'Finding 1: x' '"stop_hook_active":true,'
check "classify: stop_hook_active true passes" passes
check "classify: the mark is written when stop_hook_active is true" test -f "$hold_data/review/c5"
cls_run c6 playbook-agents:review "$cls_t/missing.jsonl" 'Finding 1: x'
check "classify: a missing transcript passes" passes
check "classify: the mark is written when the transcript is missing" test -f "$hold_data/review/c6"
cls_run c7 playbook-agents:explore "$cls_t/none.jsonl" 'Finding 1: x'
check "classify: another agent type passes" passes
cls_run c8 playbook-agents:review "$cls_t/none.jsonl" ''
check "classify: an empty last message passes" passes
cls_run c9 playbook-agents:review "$cls_t/none.jsonl" 'Finding 1: x' '"stop_hook_active" : false,'
check "classify: stop_hook_active false still blocks" blocked
cls_run c10 playbook-agents:review "$cls_t/none.jsonl" 'Finding 1: x'
check "classify: the first stop of a subagent blocks" blocked
check "classify: the block leaves a mark for that subagent" test -f "$hold_data/classify-asked/ac10"
cls_run c10 playbook-agents:review "$cls_t/none.jsonl" 'Finding 1: x' '"stop_hook_active" : false,'
check "classify: a second stop of the same subagent passes, stop_hook_active false" passes
cls_agent=ac10 cls_run c11 playbook-agents:review "$cls_t/none.jsonl" 'Finding 1: x'
check "classify: the same subagent in another session passes" passes
cls_run c12 playbook-agents:review "$cls_t/none.jsonl" 'Finding 1: x'
check "classify: another subagent still blocks" blocked
cls_agent='' cls_run c13 playbook-agents:review "$cls_t/none.jsonl" 'Finding 1: x'
check "classify: no agent_id passes" passes
cls_agent='a/../b' cls_run c14 playbook-agents:review "$cls_t/none.jsonl" 'Finding 1: x'
check "classify: an agent_id with a slash passes" passes

rm -rf "$tmp/hold_wiki"
mkdir -p "$tmp/hold_wiki/docs/wiki"
git_in "$tmp/hold_wiki" init -b main
git_in "$tmp/hold_wiki" config user.name Test
git_in "$tmp/hold_wiki" config user.email test@example.com
git_in "$tmp/hold_wiki" config commit.gpgsign false
printf 'a\n' > "$tmp/hold_wiki/docs/wiki/README.md"
printf 'a\n' > "$tmp/hold_wiki/a.sh"
commit_in "$tmp/hold_wiki" base
printf 'b\n' >> "$tmp/hold_wiki/docs/wiki/README.md"
printf 'n\n' > "$tmp/hold_wiki/docs/wiki/new page.md"
hold_run s12 "$tmp/hold_wiki" 'git add -A && git commit -m w'
check "hold: a commit that changes only docs/wiki/ runs without being held" passes
git_in "$tmp/hold_wiki" mv docs/wiki/README.md docs/README.md
hold_run s12 "$tmp/hold_wiki" 'git add -A && git commit -m w'
check "hold: a rename out of docs/wiki/ is held" held_any
git_in "$tmp/hold_wiki" mv docs/README.md docs/wiki/README.md
git_in "$tmp/hold_wiki" mv a.sh docs/wiki/a.sh
hold_run s15 "$tmp/hold_wiki" 'git add -A && git commit -m w'
check "hold: a rename of code into docs/wiki/ is held" held_any
git_in "$tmp/hold_wiki" mv docs/wiki/a.sh a.sh
hold_run s16 "$tmp/hold_wiki" 'printf x >> a.sh && git commit -am w'
check "hold: a wiki commit after a command that may change code is held" held_any
hold_run s18 "$tmp/hold_wiki" 'git add -f docs/wiki && git commit -m w'
check "hold: a wiki commit after git add -f is held" held_any
hold_run s19 "$tmp/hold_wiki" "cd $tmp/hold_wiki && git add docs/wiki && git commit -m w"
check "hold: a wiki commit after cd and git add runs" passes
printf 'q\n' > "$tmp/hold_wiki/docs/wiki/x -> y.md"
hold_run s17 "$tmp/hold_wiki" 'git add -A && git commit -m w'
check "hold: a wiki file whose name holds an arrow runs" passes
rm -f "$tmp/hold_wiki/docs/wiki/x -> y.md"
printf 'b\n' >> "$tmp/hold_wiki/a.sh"
hold_run s13 "$tmp/hold_wiki" 'git add -A && git commit -m w'
check "hold: a commit that changes the wiki and code is held" held_any
printf 'x\n' > "$tmp/hold_wiki/docs/wikipedia.md"
git_in "$tmp/hold_wiki" checkout -- a.sh
hold_run s14 "$tmp/hold_wiki" 'git add -A && git commit -m w'
check "hold: a path that only starts like docs/wiki is held" held_any

hold_run s7 "$tmp/hold" 'git status'
check "hold: a command with no commit prints nothing" passes
hold_run s7 "$tmp/hold" 'echo \"git commit -m x\"'
check "hold: a commit inside a quoted string prints nothing" passes
hold_run s7 "$tmp" 'git commit -m x'
check "hold: a directory that is not a repository prints nothing" passes
hold_run '' "$tmp/hold" 'git commit -m x'
check "hold: no session id prints nothing" passes
out=$(printf '{"session_id":"s8","cwd":"%s","tool_input":{"command":"git commit -m x"}}' "$tmp/hold" |
  env -u CLAUDE_PLUGIN_DATA sh "$hold_hook" 2>&1); code=$?
check "hold: no CLAUDE_PLUGIN_DATA prints nothing" passes
out=$(printf 'not json at all' | CLAUDE_PLUGIN_DATA="$hold_data" sh "$hold_hook" 2>&1); code=$?
check "hold: input that is not JSON prints nothing" passes
out=$(printf '' | CLAUDE_PLUGIN_DATA="$hold_data" sh "$ran_hook" 2>&1); code=$?
check "hold: the mark hook on empty input prints nothing" passes
rm -rf "$tmp/nolib"
mkdir -p "$tmp/nolib/hooks"
cp "$hold_hook" "$ran_hook" "$tmp/nolib/hooks/"
out=$(printf '{"session_id":"s10","cwd":"%s","tool_input":{"command":"git commit -m x"}}' "$tmp/hold" |
  CLAUDE_PLUGIN_DATA="$hold_data" sh "$tmp/nolib/hooks/review-before-commit.sh" 2>&1); code=$?
check "hold: a missing hook-lib.sh prints nothing and exits 0" passes
out=$(printf '{"session_id":"s10","agent_type":"playbook-agents:review"}' |
  CLAUDE_PLUGIN_DATA="$hold_data" sh "$tmp/nolib/hooks/review-ran.sh" 2>&1); code=$?
check "hold: the mark hook with a missing hook-lib.sh prints nothing and exits 0" passes
: > "$tmp/hold_file"
out=$(printf '{"session_id":"s9","cwd":"%s","tool_input":{"command":"git commit -m x"}}' "$tmp/hold" |
  CLAUDE_PLUGIN_DATA="$tmp/hold_file" sh "$hold_hook" 2>&1); code=$?
check "hold: a data folder that cannot be written prints nothing" passes

# The person's model of each agent (setup-commands-10).
models_hook="$root/plugins/playbook-agents/hooks/agent-models.sh"
rm -rf "$tmp/am"
mkdir -p "$tmp/am/proj/.claude" "$tmp/am/home"
# am_run <tool_input as JSON>: runs the model hook on an Agent call.
am_run() {
  out=$(printf '{"session_id":"s","cwd":"%s","tool_name":"Agent","tool_input":%s}' "$tmp/am/proj" "$1" |
    CLAUDE_CONFIG_DIR="$tmp/am/home" CLAUDE_PROJECT_DIR="$tmp/am/proj" sh "$models_hook" 2>&1)
  code=$?
}
# am_gives <updatedInput>: the hook printed exactly that input.
am_gives() {
  [ "$code" -eq 0 ] &&
    [ "$out" = "{\"hookSpecificOutput\":{\"hookEventName\":\"PreToolUse\",\"updatedInput\":$1}}" ]
}
review_call='{"description":"d","prompt":"say \"hi\" {x} [y]","subagent_type":"playbook-agents:review"}'
review_inner='"description":"d","prompt":"say \"hi\" {x} [y]","subagent_type":"playbook-agents:review"'

am_run "$review_call"
check "models hook: nothing set prints nothing" passes
printf '{"theme":"dark","playbook":{"models":{"review":"opus xhigh","explore":"haiku"}}}\n' > "$tmp/am/home/settings.json"
am_run "$review_call"
check "models hook: the person's value is added, every field kept" am_gives "{$review_inner,\"model\":\"opus\",\"effort\":\"xhigh\"}"
am_run '{"prompt":"p","subagent_type":"playbook-agents:explore"}'
check "models hook: a model without an effort" am_gives '{"prompt":"p","subagent_type":"playbook-agents:explore","model":"haiku"}'
am_run '{"prompt":"p","subagent_type":"playbook-agents:write"}'
check "models hook: an agent the person did not set prints nothing" passes
am_run '{"prompt":"p","subagent_type":"general-purpose"}'
check "models hook: another agent prints nothing" passes
am_run '{"prompt":"p","subagent_type":"playbook-agents:reviewer"}'
check "models hook: a name that only starts like the agent prints nothing" passes
printf '{\n  "permissions": {"allow": ["Bash(ls)"]},\n  "playbook": {\n    "models": {\n      "review": "fable low"\n    }\n  }\n}\n' > "$tmp/am/proj/.claude/settings.local.json"
am_run "$review_call"
check "models hook: the repository's value wins" am_gives "{$review_inner,\"model\":\"fable\",\"effort\":\"low\"}"
am_run '{"prompt":"p","subagent_type":"playbook-agents:explore"}'
check "models hook: an agent the repository does not set takes the person's value" am_gives '{"prompt":"p","subagent_type":"playbook-agents:explore","model":"haiku"}'
am_run '{"prompt":"p","subagent_type":"playbook-agents:review","model":"sonnet"}'
check "models hook: a model the call names is followed by the one set" am_gives '{"prompt":"p","subagent_type":"playbook-agents:review","model":"sonnet","model":"fable","effort":"low"}'
for bad in 'claude-opus-5-5 high' 'inherit' 'opus extreme' 'opus high extra' '*'; do
  printf '{"playbook":{"models":{"review":"%s"}}}\n' "$bad" > "$tmp/am/proj/.claude/settings.local.json"
  am_run "$review_call"
  check "models hook: the value '$bad' is ignored, with the person's not used either" passes
done
rm "$tmp/am/proj/.claude/settings.local.json"
printf '{"playbook":{"models":["review"]},"review":"opus"}\n' > "$tmp/am/home/settings.json"
am_run "$review_call"
check "models hook: a review key outside playbook/models is not read" passes
printf '{"playbook":{"models":{"review":"opus"}}}\n' > "$tmp/am/home/settings.json"
am_run '{}'
check "models hook: an input with no agent prints nothing" passes
out=$(printf 'not json' | CLAUDE_CONFIG_DIR="$tmp/am/home" sh "$models_hook" 2>&1); code=$?
check "models hook: input that is not JSON prints nothing" passes
rm -rf "$tmp/amlib"
mkdir -p "$tmp/amlib/hooks"
cp "$models_hook" "$tmp/amlib/hooks/"
out=$(printf '{"tool_input":%s}' "$review_call" | CLAUDE_CONFIG_DIR="$tmp/am/home" sh "$tmp/amlib/hooks/agent-models.sh" 2>&1); code=$?
check "models hook: a missing hook-lib.sh prints nothing and exits 0" passes

# /playbook-agents:config: its script (setup-commands-4, setup-commands-10).
config_script="$root/plugins/playbook-agents/skills/config/scripts/config.sh"
rm -rf "$tmp/cf"
mkdir -p "$tmp/cf/proj" "$tmp/cf/home"
# cf_run <arguments>: runs the script in the repository, with its own home.
cf_run() {
  out=$(cd "$tmp/cf/proj" && env -u CLAUDE_CODE_EFFORT_LEVEL -u CLAUDE_PROJECT_DIR CLAUDE_CONFIG_DIR="$tmp/cf/home" sh "$config_script" "$@" 2>&1)
  code=$?
}
cf_has() { printf '%s\n' "$out" | grep -Fxq -- "$1"; }
cf_local="$tmp/cf/proj/.claude/settings.local.json"
cf_user="$tmp/cf/home/settings.json"
tab=$(printf '\t')

cf_run show
check "config: show with nothing set gives each agent's file values" \
  cf_has "review${tab}opus${tab}high${tab}plugin default"
cf_run set local review fable low
check "config: set local creates the repository's file" [ "$code" -eq 0 -a -f "$cf_local" ]
check "config: the file it creates holds only the value" \
  [ "$(cat "$cf_local")" = '{"playbook": {"models": {"review": "fable low"}}}' ]
cf_run set local explore haiku
check "config: a second agent is added beside the first" \
  [ "$(cat "$cf_local")" = '{"playbook": {"models": {"explore": "haiku","review": "fable low"}}}' ]
cf_run set local review opus
check "config: a value set again is replaced" \
  [ "$(cat "$cf_local")" = '{"playbook": {"models": {"explore": "haiku","review": "opus"}}}' ]
printf '{\n  "theme": "dark",\n  "permissions": {"allow": ["Bash(ls)"]},\n  "playbook": {"other": [1, {"a": "b"}]}\n}\n' > "$cf_user"
cf_run set user write sonnet xhigh
check "config: set user keeps every other key, in place" \
  [ "$(cat "$cf_user")" = "$(printf '{\n  "theme": "dark",\n  "permissions": {"allow": ["Bash(ls)"]},\n  "playbook": {"models": {"write": "sonnet xhigh"},"other": [1, {"a": "b"}]}\n}')" ]
cf_run show
check "config: show names the repository as the source" cf_has "explore${tab}haiku${tab}medium${tab}this repository"
check "config: show names every project as the source" cf_has "write${tab}sonnet${tab}xhigh${tab}every project"
check "config: a model without an effort keeps the file's effort" cf_has "review${tab}opus${tab}high${tab}this repository"
printf '{"playbook":{"models":{"write":"gpt-6 high"}}}\n' > "$cf_user"
cf_run show
check "config: show marks an invalid value as ignored" \
  cf_has "write${tab}sonnet${tab}medium${tab}plugin default; ignored in every project: \"gpt-6 high\""
out=$(cd "$tmp/cf/proj" && CLAUDE_CODE_EFFORT_LEVEL=low CLAUDE_PROJECT_DIR="$tmp/cf/proj" CLAUDE_CONFIG_DIR="$tmp/cf/home" sh "$config_script" show 2>&1)
check "config: show warns when CLAUDE_CODE_EFFORT_LEVEL is set" cf_has "CLAUDE_CODE_EFFORT_LEVEL is set to low and overrides every effort above."
for bad in 'claude-opus-5-5' 'inherit' 'opus extreme'; do
  set -f
  # shellcheck disable=SC2086
  cf_run set user write $bad
  set +f
  check "config: set refuses '$bad'" [ "$code" -eq 2 ]
done
cf_run set user nobody opus
check "config: set refuses an agent that does not exist" [ "$code" -eq 2 ]
cf_run set elsewhere write opus
check "config: set refuses a scope that does not exist" [ "$code" -eq 2 ]
printf '{"playbook":{"models":{"write":"gpt-6"}}}\n' > "$cf_local"
printf '{"playbook":{"models":{"write":"opus high"}}}\n' > "$cf_user"
cf_run show
check "config: an invalid repository value stops at the plugin default, as the hook does" \
  cf_has "write${tab}sonnet${tab}medium${tab}plugin default; ignored in this repository: \"gpt-6\""
rm -f "$cf_local"
mkdir -p "$tmp/cf/proj/src"
out=$(cd "$tmp/cf/proj/src" && CLAUDE_PROJECT_DIR="$tmp/cf/proj" CLAUDE_CONFIG_DIR="$tmp/cf/home" sh "$config_script" set local review haiku low 2>&1); code=$?
check "config: set local from a subfolder writes the project's file" \
  [ "$code" -eq 0 -a -f "$cf_local" -a ! -e "$tmp/cf/proj/src/.claude" ]
rm -f "$cf_local"
for text in '[1]' '{"playbook":["x"]}' '{"playbook":{"models":"x"}}' '{"playbook":{"models":{"write":3}}}' '{"a": {"b": 1}' '{"a":1}garbage' '{"a":1}}' '{"a":1} {"b":2}' '{"a":1,}' '{"a":1]' '{"a":[1}}' '{"a":[1,]}' '{,"a":1}' '{"a":}'; do
  printf '%s\n' "$text" > "$cf_user"
  cf_run set user write opus
  check "config: set leaves $text unchanged and exits 3" [ "$code" -eq 3 -a "$(cat "$cf_user")" = "$text" ]
done
printf '{"playbook":{"models":{"write":"opus high"}}}\n' > "$cf_user"
check "config: the hook reads what set wrote" sh -c '
  printf "{\"cwd\":\"/none\",\"tool_input\":{\"prompt\":\"p\",\"subagent_type\":\"playbook-agents:write\"}}" |
    CLAUDE_CONFIG_DIR="$1" CLAUDE_PROJECT_DIR=/none sh "$2" | grep -Fq "\"model\":\"opus\",\"effort\":\"high\""' sh "$tmp/cf/home" "$models_hook"

# The evidence of repeated findings: plugins/playbook-agents/evidence.sh.
ev_script="$root/plugins/playbook-agents/evidence.sh"
ev_kh='| Kind | Level | Rule | Applies when | Source | Scope |\n|------|-------|------|--------------|--------|-------|\n'
ev_eh='| Kind | Level | Review | Date | Finding |\n|------|-------|--------|------|---------|\n'
ev_krow='| test-passes-when-broken | 2 | Break the code on purpose to see each new test fail. | a change with tests | 3 reviews, 2026-11-19 to 2026-12-02 | general |\n| missing-test | 1 | | a change with no test | | project |\n'
ev_erow='| missing-test | 1 | u1 | 2026-11-19 | A new function has no test. |\n'

# ev_page <dir> <kind rows> <evidence rows>: writes <dir>/evidence.md.
ev_page() {
  mkdir -p "$1"
  printf '# Evidence\n\n## Kinds\n\n'"$ev_kh"'%b\n## Evidence\n\n'"$ev_eh"'%b' "$2" "$3" > "$1/evidence.md"
}
# ev_run <mode> [dir]: runs the script; sets ev_out and ev_code.
ev_run() {
  ev_out=$(sh "$ev_script" "$@" 2>&1); ev_code=$?
}
# ev_check_case <name> <kind rows> <evidence rows> <expected: pass|text of the FAIL line>
ev_check_case() {
  rm -rf "$tmp/ev"
  ev_page "$tmp/ev" "$2" "$3"
  ev_run check "$tmp/ev"
  if [ "$4" = pass ]; then
    check "evidence check: $1" [ "$ev_code" -eq 0 ] && check "evidence check: $1 (prints a pass line)" sh -c 'printf "%s" "$1" | grep -q "evidence check passed"' sh "$ev_out"
  else
    check "evidence check: $1" sh -c '[ "$1" -eq 1 ] && printf "%s" "$2" | grep "^FAIL evidence.md: " | grep -Fq "$3"' sh "$ev_code" "$ev_out" "$4"
  fi
}

ev_check_case "a valid page passes" "$ev_krow" "$ev_erow" pass
ev_check_case "a page with no evidence rows passes" "$ev_krow" "" pass
ev_check_case "a cell may hold an escaped pipe" '| a-b | 2 | Use x \| y. | a change | none | general |\n' '| a-b | 2 | u1 | 2026-11-19 | One \| two. |\n' pass
ev_check_case "a duplicate kind fails" "$ev_krow$ev_krow" "" 'kind "missing-test" is repeated'
ev_check_case "a kind that is not kebab-case fails" '| Missing_Test | 1 | | x | | project |\n' "" 'kind "Missing_Test" is not kebab-case'
ev_check_case "a level of 0 in Kinds fails" '| a-b | 0 | | x | | project |\n' "" 'has level "0"'
ev_check_case "a level that is not a number in Kinds fails" '| a-b | two | | x | | project |\n' "" 'has level "two"'
ev_check_case "a level of 2 with no rule fails" '| a-b | 2 | | x | | project |\n' "" 'is at level 2 and has no rule'
ev_check_case "a bad level in Evidence fails" "$ev_krow" '| missing-test | 1.5 | u1 | 2026-11-19 | x |\n' 'evidence of "missing-test" has level "1.5"'
ev_check_case "a bad date fails" "$ev_krow" '| missing-test | 1 | u1 | 19-11-2026 | x |\n' 'has date "19-11-2026"'
ev_check_case "a date with month 13 fails" "$ev_krow" '| missing-test | 1 | u1 | 2026-13-01 | x |\n' 'has date "2026-13-01"'
ev_check_case "an unknown kind in Evidence fails" "$ev_krow" '| other-kind | 1 | u1 | 2026-11-19 | x |\n' 'evidence of kind "other-kind" has no row in Kinds'
ev_check_case "a bad scope fails" '| a-b | 1 | | x | | team |\n' "" 'scope "team"'
ev_check_case "an evidence row with no review fails" "$ev_krow" '| missing-test | 1 | | 2026-11-19 | x |\n' 'has no review'
ev_check_case "a row with the wrong number of cells fails" '| a-b | 1 | |\n' "" 'a row of Kinds has 3 cells'

rm -rf "$tmp/ev"; ev_page "$tmp/ev" "$ev_krow" "$ev_erow"
sed 's/| Applies when |/| When |/' "$tmp/ev/evidence.md" > "$tmp/ev/x" && mv "$tmp/ev/x" "$tmp/ev/evidence.md"
ev_run check "$tmp/ev"
check "evidence check: a bad header row of Kinds fails" sh -c '[ "$1" -eq 1 ] && printf "%s" "$2" | grep -Fq "FAIL evidence.md: the header row of Kinds"' sh "$ev_code" "$ev_out"
rm -rf "$tmp/ev"; ev_page "$tmp/ev" "$ev_krow" "$ev_erow"
sed 's/| Finding |/| Text |/' "$tmp/ev/evidence.md" > "$tmp/ev/x" && mv "$tmp/ev/x" "$tmp/ev/evidence.md"
ev_run check "$tmp/ev"
check "evidence check: a bad header row of Evidence fails" sh -c '[ "$1" -eq 1 ] && printf "%s" "$2" | grep -Fq "FAIL evidence.md: the header row of Evidence"' sh "$ev_code" "$ev_out"
rm -rf "$tmp/ev"; ev_page "$tmp/ev" "$ev_krow" "$ev_erow"
sed 's/^## Evidence$/## Findings/' "$tmp/ev/evidence.md" > "$tmp/ev/x" && mv "$tmp/ev/x" "$tmp/ev/evidence.md"
ev_run check "$tmp/ev"
check "evidence check: a missing heading fails" sh -c '[ "$1" -eq 1 ] && printf "%s" "$2" | grep -Fq "FAIL evidence.md: missing the heading \"## Evidence\""' sh "$ev_code" "$ev_out"
rm -rf "$tmp/ev"; mkdir -p "$tmp/ev"
ev_run check "$tmp/ev"
check "evidence check: no page says so and passes" sh -c '[ "$1" -eq 0 ] && printf "%s" "$2" | grep -q "no evidence page"' sh "$ev_code" "$ev_out"
check "evidence check: the playbook's evidence-rules.md passes" sh -c 'sh "$1" check "$2" | grep -q "no evidence page"' sh "$ev_script" "$tmp/ev"

# count: distinct reviews per kind and level.
ev_e() { printf '| %s | %s | %s | %s | A finding. |\n' "$1" "$2" "$3" "$4"; }
rm -rf "$tmp/ev"
ev_page "$tmp/ev" "$ev_krow" "$(ev_e missing-test 1 u1 2026-11-19)\n$(ev_e missing-test 1 u1 2026-11-20)\n$(ev_e missing-test 1 u1 2026-11-21)\n"
ev_run count "$tmp/ev"
check "evidence count: one review with the same kind three times counts once" sh -c 'printf "%s" "$1" | grep -Fq "not ready: missing-test (level 1): 1 distinct reviews, last 2026-11-21"' sh "$ev_out"
ev_page "$tmp/ev" "$ev_krow" "$(ev_e missing-test 1 u1 2026-11-19)\n$(ev_e missing-test 1 u2 2026-11-20)\n"
ev_run count "$tmp/ev"
check "evidence count: 2 distinct reviews are not ready" sh -c 'printf "%s" "$1" | grep -Fq "not ready: missing-test (level 1): 2 distinct reviews" && ! printf "%s" "$1" | grep -q "^ready"' sh "$ev_out"
ev_page "$tmp/ev" "$ev_krow" "$(ev_e missing-test 1 u1 2026-11-19)\n$(ev_e missing-test 1 u2 2026-11-25)\n$(ev_e missing-test 1 u3 2026-11-20)\n$(ev_e missing-test 1 u3 2026-11-22)\n"
ev_run count "$tmp/ev"
check "evidence count: 3 distinct reviews are ready, with the last date" sh -c 'printf "%s" "$1" | grep -Fq "ready to consolidate: missing-test (level 1): 3 distinct reviews, last 2026-11-25"' sh "$ev_out"
check "evidence count: exits 0" [ "$ev_code" -eq 0 ]
ev_page "$tmp/ev" "$ev_krow" "$(ev_e missing-test 1 u1 2026-11-19)\n$(ev_e missing-test 1 u2 2026-11-20)\n$(ev_e missing-test 2 u3 2026-11-21)\n$(ev_e missing-test 2 u4 2026-11-22)\n$(ev_e missing-test 2 u5 2026-11-23)\n"
ev_run count "$tmp/ev"
check "evidence count: groups at different levels are counted apart" sh -c 'printf "%s\n" "$1" | grep -Fq "not ready: missing-test (level 1): 2 distinct" && printf "%s\n" "$1" | grep -Fq "ready to consolidate: missing-test (level 2): 3 distinct" && [ "$(printf "%s\n" "$1" | wc -l)" -eq 2 ]' sh "$ev_out"
ev_page "$tmp/ev" "$ev_krow" "$(ev_e missing-test 1 u1 2026-11-19)\n$(ev_e test-passes-when-broken 1 u1 2026-11-19)\n$(ev_e test-passes-when-broken 1 u2 2026-11-19)\n"
ev_run count "$tmp/ev"
check "evidence count: kinds are counted apart" sh -c 'printf "%s\n" "$1" | grep -Fq "missing-test (level 1): 1 distinct" && printf "%s\n" "$1" | grep -Fq "test-passes-when-broken (level 1): 2 distinct"' sh "$ev_out"
rm -rf "$tmp/ev"; mkdir -p "$tmp/ev"
ev_run count "$tmp/ev"
check "evidence count: no page prints nothing and exits 0" [ "$ev_code" -eq 0 -a -z "$ev_out" ]

# rules: level 2 and up, from the page and from evidence-rules.md next to the script.
rm -rf "$tmp/evs"; mkdir -p "$tmp/evs"
cp "$ev_script" "$tmp/evs/evidence.sh"
printf '%b%b%b' '# Evidence\n\nGeneral rules.\n\n## Kinds\n\n' "$ev_kh" '| vague-name | 3 | Name the mistake, not the place. | a new kind | 4 reviews | general |\n| general-new | 1 | Not yet a rule. | x | | general |\n' > "$tmp/evs/evidence-rules.md"
rm -rf "$tmp/ev"; ev_page "$tmp/ev" "$ev_krow" ""
ev_rules() { ev_out=$(sh "$tmp/evs/evidence.sh" rules "$@" 2>&1); ev_code=$?; }
ev_rules "$tmp/ev"
check "evidence rules: prints level 2 and up from the page and evidence-rules.md" sh -c '[ "$(printf "%s\n" "$1" | wc -l)" -eq 3 ] && printf "%s\n" "$1" | grep -Fxq -- "- test-passes-when-broken (level 2; applies when: a change with tests): Break the code on purpose to see each new test fail." && printf "%s\n" "$1" | grep -Fxq -- "- vague-name (level 3; applies when: a new kind): Name the mistake, not the place."' sh "$ev_out"
check "evidence rules: leaves out level 1" sh -c '! printf "%s" "$1" | grep -Eq "missing-test|general-new"' sh "$ev_out"
check "evidence rules: one heading line first, exit 0" sh -c '[ "$2" -eq 0 ] && printf "%s\n" "$1" | head -n 1 | grep -q "^Rules learned"' sh "$ev_out" "$ev_code"
rm -rf "$tmp/ev"; ev_page "$tmp/ev" '| a-b | 1 | | x | | project |\n' ""
sed '/vague-name/d' "$tmp/evs/evidence-rules.md" > "$tmp/evs/x" && mv "$tmp/evs/x" "$tmp/evs/evidence-rules.md"
ev_rules "$tmp/ev"
check "evidence rules: prints nothing, no heading, when no kind is above level 1" [ "$ev_code" -eq 0 -a -z "$ev_out" ]
rm -rf "$tmp/ev"; mkdir -p "$tmp/ev"
ev_rules "$tmp/ev"
check "evidence rules: prints nothing with no page and no rules" [ "$ev_code" -eq 0 -a -z "$ev_out" ]
rm -f "$tmp/evs/evidence-rules.md"
ev_rules "$tmp/ev"
check "evidence rules: prints nothing with no files at all" [ "$ev_code" -eq 0 -a -z "$ev_out" ]
ev_page "$tmp/ev" '| a-b | 2 | Use x \| y. | a change | none | general |\n' ""
ev_rules "$tmp/ev"
check "evidence rules: an escaped pipe stays one cell" sh -c 'printf "%s\n" "$1" | grep -Fxq -- "- a-b (level 2; applies when: a change): Use x | y."' sh "$ev_out"
ev_script_real=$(sh "$ev_script" rules "$tmp/ev" 2>&1)
ev_general_n=$(grep -cE '^\| [a-z0-9-]+ \| [2-9][0-9]* \|' "$root/plugins/playbook-agents/evidence-rules.md")
check "evidence rules: the playbook's own evidence-rules.md adds each of its rules" sh -c '[ "$(printf "%s\n" "$1" | wc -l)" -eq $((2 + $2)) ] && [ "$2" -gt 0 ]' sh "$ev_script_real" "$ev_general_n"
check "evidence rules: the playbook's own evidence-rules.md passes check" sh "$root/plugins/playbook-agents/evidence.sh" check "$tmp/ev"

# index and rule (seed-evidence-31): the index of level 2 and up, and one rule.
printf '%b%b%b' '# Evidence\n\nGeneral rules.\n\n## Kinds\n\n' "$ev_kh" '| vague-name | 3 | Name the mistake, not the place. | a new kind | 4 reviews | general |\n| general-new | 1 | Not yet a rule. | x | | general |\n' > "$tmp/evs/evidence-rules.md"
rm -rf "$tmp/ev"; ev_page "$tmp/ev" "$ev_krow" ""
ev_idx() { ev_out=$(sh "$tmp/evs/evidence.sh" index "$@" 2>&1); ev_code=$?; }
ev_idx "$tmp/ev"
check "evidence index: one line per kind of level 2 and up, page first then evidence-rules.md" sh -c '[ "$1" = "- test-passes-when-broken (level 2): a change with tests
- vague-name (level 3): a new kind" ]' sh "$ev_out"
check "evidence index: leaves out level 1 and the rule text, exit 0" sh -c '[ "$2" -eq 0 ] && ! printf "%s" "$1" | grep -Eq "missing-test|general-new|Break the code"' sh "$ev_out" "$ev_code"
ev_rule() { ev_out=$(sh "$tmp/evs/evidence.sh" rule "$@" 2>"$tmp/ev.err"); ev_code=$?; }
ev_rule test-passes-when-broken "$tmp/ev"
check "evidence rule: a kind of the page prints level, rule, applies when, and source" sh -c '[ "$2" -eq 0 ] && [ "$1" = "kind: test-passes-when-broken
level: 2
rule: Break the code on purpose to see each new test fail.
applies when: a change with tests
source: 3 reviews, 2026-11-19 to 2026-12-02" ]' sh "$ev_out" "$ev_code"
ev_rule vague-name "$tmp/ev"
check "evidence rule: a kind of evidence-rules.md prints its rule" sh -c '[ "$2" -eq 0 ] && printf "%s\n" "$1" | grep -Fxq "level: 3" && printf "%s\n" "$1" | grep -Fxq "rule: Name the mistake, not the place."' sh "$ev_out" "$ev_code"
ev_rule missing-test "$tmp/ev"
check "evidence rule: a kind of level 1 prints its level" sh -c '[ "$2" -eq 0 ] && printf "%s\n" "$1" | grep -Fxq "level: 1"' sh "$ev_out" "$ev_code"
ev_rule no-such-kind "$tmp/ev"
check "evidence rule: a kind that is not found exits 1 with a message on stderr and nothing on stdout" sh -c '[ "$2" -eq 1 ] && [ -z "$1" ] && grep -Fq "no kind \"no-such-kind\"" "$3"' sh "$ev_out" "$ev_code" "$tmp/ev.err"
rm -rf "$tmp/ev"; ev_page "$tmp/ev" '| a-b | 1 | | x | | project |\n' ""
rm -f "$tmp/evs/evidence-rules.md"
ev_idx "$tmp/ev"
check "evidence index: prints nothing when no kind is above level 1" [ "$ev_code" -eq 0 -a -z "$ev_out" ]
rm -rf "$tmp/ev"; mkdir -p "$tmp/ev"
ev_idx "$tmp/ev"
check "evidence index: prints nothing with no files" [ "$ev_code" -eq 0 -a -z "$ev_out" ]
ev_rule a-b "$tmp/ev"
check "evidence rule: with no page and no file exits 1" [ "$ev_code" -eq 1 ]

# Failures found in review: a table that ends early, a missing separator row,
# an impossible day, the playbook's own file, code blocks, CRLF, the title.
rm -rf "$tmp/ev"; ev_page "$tmp/ev" "$ev_krow" "$(ev_e missing-test 1 r1 2026-11-19)\n$(ev_e missing-test 1 r2 2026-11-20)\n$(ev_e missing-test 1 r3 2026-11-21)\n\n$(ev_e missing-test 1 r4 2026-11-22)\n"
ev_run check "$tmp/ev"
check "evidence check: a row after a blank line ends the table and fails" sh -c '[ "$1" -eq 1 ] && printf "%s\n" "$2" | grep "^FAIL evidence.md: " | grep -Fq "a table row after the table of Evidence ended"' sh "$ev_code" "$ev_out"
ev_run count "$tmp/ev"
check "evidence count: a row after a blank line is still counted" sh -c 'printf "%s\n" "$1" | grep -Fxq "ready to consolidate: missing-test (level 1): 4 distinct reviews, last 2026-11-22"' sh "$ev_out"
rm -rf "$tmp/ev"; ev_page "$tmp/ev" "$ev_krow"'\n| extra-kind | 1 | | x | | project |\n' ""
ev_run check "$tmp/ev"
check "evidence check: a row of Kinds after a blank line fails" sh -c '[ "$1" -eq 1 ] && printf "%s\n" "$2" | grep -Fq "a table row after the table of Kinds ended"' sh "$ev_code" "$ev_out"

rm -rf "$tmp/ev"; ev_page "$tmp/ev" "$ev_krow" "$(ev_e missing-test 1 r1 2026-11-19)\n$(ev_e missing-test 1 r2 2026-11-20)\n$(ev_e missing-test 1 r3 2026-11-21)\n"
sed '/^|------|-------|--------|------|---------|$/d' "$tmp/ev/evidence.md" > "$tmp/ev/x" && mv "$tmp/ev/x" "$tmp/ev/evidence.md"
ev_run check "$tmp/ev"
check "evidence check: a missing separator row of Evidence fails" sh -c '[ "$1" -eq 1 ] && printf "%s\n" "$2" | grep -Fq "the second row of Evidence is not the separator row"' sh "$ev_code" "$ev_out"
ev_run count "$tmp/ev"
check "evidence count: with no separator row no data row is lost" sh -c 'printf "%s\n" "$1" | grep -Fq "3 distinct reviews"' sh "$ev_out"
rm -rf "$tmp/ev"; ev_page "$tmp/ev" "$ev_krow" ""
sed '/^|------|-------|------|--------------|--------|-------|$/d' "$tmp/ev/evidence.md" > "$tmp/ev/x" && mv "$tmp/ev/x" "$tmp/ev/evidence.md"
ev_run check "$tmp/ev"
check "evidence check: a missing separator row of Kinds fails" sh -c '[ "$1" -eq 1 ] && printf "%s\n" "$2" | grep -Fq "the second row of Kinds is not the separator row"' sh "$ev_code" "$ev_out"

ev_check_case "a day that the month does not have fails (02-31)" "$ev_krow" '| missing-test | 1 | u1 | 2026-02-31 | x |\n' 'has date "2026-02-31"'
ev_check_case "a day that the month does not have fails (04-31)" "$ev_krow" '| missing-test | 1 | u1 | 2026-04-31 | x |\n' 'has date "2026-04-31"'
ev_check_case "29 February of a leap year passes" "$ev_krow" '| missing-test | 1 | u1 | 2028-02-29 | x |\n' pass
ev_check_case "29 February of a year that is not a leap year fails" "$ev_krow" '| missing-test | 1 | u1 | 2026-02-29 | x |\n' 'has date "2026-02-29"'
ev_check_case "29 February of 2100 fails and of 2000 passes" "$ev_krow" '| missing-test | 1 | u1 | 2000-02-29 | x |\n| missing-test | 1 | u2 | 2100-02-29 | x |\n' 'has date "2100-02-29"'
ev_check_case "day 00 fails" "$ev_krow" '| missing-test | 1 | u1 | 2026-05-00 | x |\n' 'has date "2026-05-00"'

# check reads evidence-rules.md next to the script.
rm -rf "$tmp/evs" "$tmp/ev"; mkdir -p "$tmp/evs" "$tmp/ev"
cp "$ev_script" "$tmp/evs/evidence.sh"
printf '%b%b' '# Evidence\n\n## Kinds\n\n' "$ev_kh" > "$tmp/evs/evidence-rules.md"
out=$(sh "$tmp/evs/evidence.sh" check "$tmp/ev" 2>&1); code=$?
check "evidence check: a valid evidence-rules.md passes" [ "$code" -eq 0 ]
printf '%b%b' '# Evidence\n\n## Kinds\n\n' "$ev_kh"'| Bad_Kind | 1 | | x | | general |\n' > "$tmp/evs/evidence-rules.md"
out=$(sh "$tmp/evs/evidence.sh" check "$tmp/ev" 2>&1); code=$?
check "evidence check: a broken evidence-rules.md fails with its own name" sh -c '[ "$1" -eq 1 ] && printf "%s\n" "$2" | grep -Fq "FAIL evidence-rules.md: kind \"Bad_Kind\" is not kebab-case"' sh "$code" "$out"
printf '%b' '## Kinds\n\n' > "$tmp/evs/evidence-rules.md"
out=$(sh "$tmp/evs/evidence.sh" check "$tmp/ev" 2>&1); code=$?
check "evidence check: an evidence-rules.md with no title and no table fails" sh -c '[ "$1" -eq 1 ] && printf "%s\n" "$2" | grep -Fq "FAIL evidence-rules.md: missing the heading \"# Evidence\"" && printf "%s\n" "$2" | grep -Fq "FAIL evidence-rules.md: Kinds has no table"' sh "$code" "$out"

# A table inside a code block is not read.
rm -rf "$tmp/ev"; ev_page "$tmp/ev" "$ev_krow" "$ev_erow"
printf '\n```text\n| not-a-kind | zero | | nope | |\n| other | 1 | r9 | never | x |\n```\n' >> "$tmp/ev/evidence.md"
ev_run check "$tmp/ev"
check "evidence check: a table inside a code block is not read" [ "$ev_code" -eq 0 ]
ev_run count "$tmp/ev"
check "evidence count: a table inside a code block is not counted" sh -c '[ "$(printf "%s\n" "$1" | wc -l)" -eq 1 ]' sh "$ev_out"

# A page with CRLF line ends reads as one with LF.
rm -rf "$tmp/ev"; ev_page "$tmp/ev" "$ev_krow" "$(ev_e missing-test 1 u1 2026-11-19)\n"
sed 's/$/\r/' "$tmp/ev/evidence.md" > "$tmp/ev/x" && mv "$tmp/ev/x" "$tmp/ev/evidence.md"
ev_run check "$tmp/ev"
check "evidence check: a page with CRLF line ends passes" [ "$ev_code" -eq 0 ]
ev_run count "$tmp/ev"
check "evidence count: a page with CRLF line ends gives a clean last date" sh -c 'printf "%s\n" "$1" | grep -Fxq "not ready: missing-test (level 1): 1 distinct reviews, last 2026-11-19"' sh "$ev_out"

# Headings and title.
rm -rf "$tmp/ev"; ev_page "$tmp/ev" "$ev_krow" "$ev_erow"
sed '/^# Evidence$/d' "$tmp/ev/evidence.md" > "$tmp/ev/x" && mv "$tmp/ev/x" "$tmp/ev/evidence.md"
ev_run check "$tmp/ev"
check "evidence check: a missing title fails" sh -c '[ "$1" -eq 1 ] && printf "%s\n" "$2" | grep -Fq "missing the heading \"# Evidence\""' sh "$ev_code" "$ev_out"
printf '# Evidence\n\n## Kinds\n\n## Evidence\n\n' > "$tmp/ev/evidence.md"
ev_run check "$tmp/ev"
check "evidence check: a Kinds heading with no table fails" sh -c '[ "$1" -eq 1 ] && printf "%s\n" "$2" | grep -Fq "Kinds has no table"' sh "$ev_code" "$ev_out"
check "evidence check: an Evidence heading with no table fails" sh -c 'printf "%s\n" "$1" | grep -Fq "Evidence has no table"' sh "$ev_out"

# The default directory is $CLAUDE_PROJECT_DIR/docs/wiki.
rm -rf "$tmp/evp"; ev_page "$tmp/evp/docs/wiki" "$ev_krow" "$(ev_e missing-test 1 u1 2026-11-19)\n"
ev_out=$(CLAUDE_PROJECT_DIR="$tmp/evp" sh "$ev_script" rules 2>&1)
check "evidence: CLAUDE_PROJECT_DIR sets the default wiki directory" sh -c 'printf "%s" "$1" | grep -q "test-passes-when-broken"' sh "$ev_out"
ev_out=$(CLAUDE_PROJECT_DIR="$tmp/evp" sh "$ev_script" count 2>&1)
check "evidence: the default directory is read by count too" sh -c 'printf "%s" "$1" | grep -q "missing-test (level 1): 1 distinct"' sh "$ev_out"
ev_out=$(cd "$tmp/evp" && sh "$ev_script" count 2>&1)
check "evidence: with no variable the default is docs/wiki" sh -c 'printf "%s" "$1" | grep -q "missing-test (level 1): 1 distinct"' sh "$ev_out"
check "evidence: an unknown mode exits 2" sh -c 'sh "$1" frob >/dev/null 2>&1; [ $? -eq 2 ]' sh "$ev_script"
check "evidence: rule with no kind exits 2" sh -c 'sh "$1" rule >/dev/null 2>&1; [ $? -eq 2 ]' sh "$ev_script"
check "evidence: no file is written" sh -c '[ -z "$(find "$1" -newer "$2" -type f)" ]' sh "$tmp/evp" "$tmp/evp/docs/wiki/evidence.md"

# The rules at the start of write and review (repeated-corrections-18):
# plugins/playbook-agents/hooks/rules-for-subagent.sh.
# A copy of the plugin whose general rules file has no rule, so each case sees
# only the rules of its test project.
rm -rf "$tmp/rsplug"
cp -R "$root/plugins/playbook-agents" "$tmp/rsplug"
sed -n '1,/^|------/p' "$root/plugins/playbook-agents/evidence-rules.md" > "$tmp/rsplug/evidence-rules.md"
rs_hook="$tmp/rsplug/hooks/rules-for-subagent.sh"
rs_krow='| quoted-path | 2 | Write "stop" and C:\\dir with care. | a change that writes "paths" or C:\\dir | 3 reviews | project |\n| low-kind | 1 | | a change | | project |\n'
rs_proj="$tmp/rs project"
rm -rf "$rs_proj"
ev_page "$rs_proj/docs/wiki" "$rs_krow" ""
# rs_run <agent type> <set|unset> <project>: runs the hook, with
# CLAUDE_PROJECT_DIR set to the project, or unset and the project as the cwd
# of the input.
rs_run() {
  if [ "$2" = set ]; then
    rs_out=$(printf '{"session_id":"s","cwd":"/nonexistent","hook_event_name":"SubagentStart","agent_id":"x","agent_type":"%s"}' "$1" |
      CLAUDE_PROJECT_DIR="$3" sh "$rs_hook" 2>&1); rs_code=$?
  else
    rs_out=$(printf '{"session_id":"s","cwd":"%s","hook_event_name":"SubagentStart","agent_id":"x","agent_type":"%s"}' "$3" "$1" |
      sh "$rs_hook" 2>&1); rs_code=$?
  fi
}
rs_shape() {
  [ "$(printf '%s\n' "$rs_out" | wc -l | tr -d ' ')" -eq 1 ] &&
    [ "${rs_out#"$frame_start"}" != "$rs_out" ] && [ "${rs_out%"$frame_end"}" != "$rs_out" ]
}
rs_silent() { [ -z "$rs_out" ] && [ "$rs_code" -eq 0 ]; }
rs_decoded_has() { printf '%s\n' "$rs_out" | decode | grep -Fq -- "$1"; }
rs_no_rule_text() { ! printf '%s\n' "$rs_out" | decode | grep -Fq -- 'Write "stop"'; }
rs_no_low() { ! printf '%s' "$rs_out" | grep -q low-kind; }
rs_no_bare_quote() { printf '%s\n' "$rs_out" > "$tmp/rs.out"; no_bare_quote "$tmp/rs.out"; }
rs_has_index() {
  printf '%s\n' "$rs_out" | decode | grep -Fxq -- "$(sh "$ev_script" index "$rs_proj/docs/wiki")"
}
rs_command="sh \"$(cd "$tmp/rsplug" && pwd)/evidence.sh\" rule <kind> \"$rs_proj/docs/wiki\""

for rs_agent in playbook-agents:write playbook-agents:review; do
  rs_run "$rs_agent" set "$rs_proj"
  check "rules hook: $rs_agent gets one line in the frame" rs_shape
  check "rules hook: $rs_agent gets the kind and when it applies, with quotes and backslash decoded" rs_decoded_has '- quoted-path (level 2): a change that writes "paths" or C:\dir'
  check "rules hook: $rs_agent does not get the rule text" rs_no_rule_text
  check "rules hook: $rs_agent gets the command with the absolute plugin path and wiki dir, quoted" rs_decoded_has "$rs_command"
  check "rules hook: $rs_agent does not get a kind of level 1" rs_no_low
  check "rules hook: no quote is left unescaped for $rs_agent" rs_no_bare_quote
  check "rules hook: the text for $rs_agent holds what evidence.sh index prints" rs_has_index
done

rs_run playbook-agents:write unset "$rs_proj"
check "rules hook: without CLAUDE_PROJECT_DIR the cwd of the input gives the wiki" rs_decoded_has "$rs_command"
rs_run playbook-agents:write unset "$tmp/rs none"
check "rules hook: the cwd of the input with no page gets nothing" rs_silent

rs_run playbook-agents:explore set "$rs_proj"
check "rules hook: playbook-agents:explore gets nothing" rs_silent
rs_run general-purpose set "$rs_proj"
check "rules hook: another agent gets nothing" rs_silent
rs_run "" set "$rs_proj"
check "rules hook: an input with no agent type gets nothing" rs_silent
rs_run playbook-agents:write-more set "$rs_proj"
check "rules hook: an agent type that only starts like write gets nothing" rs_silent

rm -rf "$tmp/rs none"
mkdir -p "$tmp/rs none"
rs_run playbook-agents:write set "$tmp/rs none"
check "rules hook: a project with no evidence page gets nothing" rs_silent
rm -rf "$tmp/rs low"
ev_page "$tmp/rs low/docs/wiki" '| low-kind | 1 | | a change | | project |\n' ""
rs_run playbook-agents:review set "$tmp/rs low"
check "rules hook: a page with no rule of level 2 or up gets nothing" rs_silent
rs_out=$(printf '' | CLAUDE_PROJECT_DIR="$rs_proj" sh "$rs_hook" 2>&1); rs_code=$?
check "rules hook: empty input prints nothing and exits 0" rs_silent

# The reader of past reviews: plugins/playbook-agents/seed-reviews.sh, on
# synthetic transcripts shaped as the real ones (seed-evidence-U1).
sr_script="$root/plugins/playbook-agents/seed-reviews.sh"
sr_cfg="$tmp/sr/cfg"
sr_repo="$tmp/sr/repo"
mkdir -p "$sr_repo" "$sr_cfg/projects"
git -C "$sr_repo" init -q
git -C "$sr_repo" -c user.name=t -c user.email=t@example.com commit -q --allow-empty -m first
git -C "$sr_repo" worktree add -q "$tmp/sr/repo-wt" -b sr-wt
mkdir -p "$tmp/sr/repo2"
# sr_dir <path>: the transcript folder of a path, made by the rule of Claude Code.
sr_dir() { printf '%s/projects/%s' "$sr_cfg" "$(printf '%s' "$1" | sed 's/[^A-Za-z0-9]/-/g')"; }
# sr_call <file> <id> <subagent type> <timestamp>: an assistant line with a call.
sr_call() {
  mkdir -p "$(dirname "$1")"
  printf '{"parentUuid":"p","type":"assistant","message":{"role":"assistant","content":[{"type":"text","text":"go"},{"type":"tool_use","id":"toolu_%s","name":"%s","input":{"description":"d","subagent_type":"%s","prompt":"p"}}]},"timestamp":"%s"}\n' "$2" "${5:-Agent}" "$3" "$4" >> "$1"
}
# sr_fg <file> <id> <escaped text>: the result of a call in the foreground.
# sr_ts <timestamp>: the timestamp field of a line, or nothing with no timestamp.
sr_ts() { [ -z "$1" ] || printf ',"timestamp":"%s"' "$1"; }
sr_fg() {
  printf '{"type":"user","message":{"role":"user","content":[{"tool_use_id":"toolu_%s","type":"tool_result","content":[{"type":"text","text":"%s"}]}]}%s}\n' "$2" "$3" "$(sr_ts "${4:-}")" >> "$1"
}
# sr_fgstr <file> <id> <escaped text>: the same, with the content as a string.
sr_fgstr() {
  printf '{"type":"user","message":{"role":"user","content":[{"tool_use_id":"toolu_%s","type":"tool_result","content":"%s"}]}}\n' "$2" "$3" >> "$1"
}
# sr_start <file> <id>: the notice of a call in the background.
sr_start() {
  printf '{"type":"user","message":{"role":"user","content":[{"tool_use_id":"toolu_%s","type":"tool_result","content":[{"type":"text","text":"Async agent launched successfully.\\nagentId: a1"}]}]}}\n' "$2" >> "$1"
}
# sr_notice <file> <id> <escaped text>: the task notification, as a queued line.
sr_notice() {
  printf '{"type":"queue-operation","operation":"enqueue"%s,"content":"<task-notification>\\n<task-id>a1</task-id>\\n<tool-use-id>toolu_%s</tool-use-id>\\n<status>completed</status>\\n<result>%s</result>\\n</task-notification>"}\n' "$(sr_ts "${4:-}")" "$2" "$3" >> "$1"
}
sr_list() { sr_out=$(TZ="${sr_tz:-UTC}" CLAUDE_CONFIG_DIR="$sr_cfg" sh "$sr_script" list "$@" 2>&1); sr_code=$?; }
sr_show() { sr_out=$(TZ="${sr_tz:-UTC}" CLAUDE_CONFIG_DIR="$sr_cfg" sh "$sr_script" show "$@" 2>&1); sr_code=$?; }
sr_has() { printf '%s\n' "$sr_out" | grep -Fq -- "$1"; }
sr_lacks() { ! printf '%s\n' "$sr_out" | grep -Fq -- "$1"; }

sr_list "$sr_repo"
check "seed-reviews: no transcript folder says so and exits 0" sh -c '[ "$1" -eq 0 ] && printf "%s" "$2" | grep -q "No Claude Code transcript folder"' sh "$sr_code" "$sr_out"

# The folder of the repository: the newest review is written first.
sr_f="$(sr_dir "$sr_repo")/s1.jsonl"
sr_call "$sr_f" NEW1 playbook-agents:review 2026-11-12T10:30:00.500Z
sr_fg "$sr_f" NEW1 'Found two.\n\n1. late finding'
sr_call "$sr_f" GP1 general-purpose 2026-11-09T07:00:00Z
sr_fg "$sr_f" GP1 'Found one: not a review.'
sr_call "$sr_f" FG1 playbook:review 2026-11-10T08:00:00Z
sr_fgstr "$sr_f" FG1 'Found one.\n\n1. a finding'
sr_call "$sr_f" BG1 playbook-agents:review 2026-11-11T09:15:30Z
sr_start "$sr_f" BG1
sr_notice "$sr_f" BG1 'Found three.\n\n1. background finding'
sr_notice "$sr_f" BG1 'Found three.\n\n1. background finding'
sr_call "$sr_f" CLEAN1 playbook-agents:review 2026-11-13T11:00:00Z
sr_fg "$sr_f" CLEAN1 'I reviewed it.\n\nNo findings.\n\nNot checked: x'
sr_call "$sr_f" DUP1 playbook-agents:review 2026-11-14T12:00:00Z
sr_fg "$sr_f" DUP1 'Found one.\n\n1. a finding'
sr_call "$sr_f" TASK1 x:code-review 2026-11-15T12:00:00Z Task
sr_fg "$sr_f" TASK1 'Found five.\n\n1. with Task'
sr_fg "$sr_f" NOCALL 'A result of no call.'
mkdir -p "$(sr_dir "$sr_repo")/subagents"
sr_call "$(sr_dir "$sr_repo")/subagents/s2.jsonl" SUB1 playbook-agents:review 2026-11-16T12:00:00Z
sr_fg "$(sr_dir "$sr_repo")/subagents/s2.jsonl" SUB1 'Found six: in subagents/.'

sr_list "$sr_repo"
check "seed-reviews list: reviews are numbered, oldest first, with date and time (UTC)" sh -c 'printf "%s\n" "$1" | sed -n "1p" | grep -q "^1  2026-11-10 08:00:00  1 finding\$" && printf "%s\n" "$1" | sed -n "2p" | grep -q "^2  2026-11-11 09:15:30  1 finding\$" && printf "%s\n" "$1" | sed -n "3p" | grep -q "^3  2026-11-12 10:30:00.500  1 finding\$"' sh "$sr_out"
check "seed-reviews list: a foreground review with string content is found" sr_has "2026-11-10 08:00:00  1 finding"
check "seed-reviews list: a background review is found by its notification" sr_has "2026-11-11 09:15:30  1 finding"
check "seed-reviews list: a line that is exactly \"No findings.\" is detected" sr_has "4  2026-11-13 11:00:00  No findings."
check "seed-reviews list: an identical report counts once" sr_lacks "2026-11-14"
check "seed-reviews list: a call that is not a review is left out" sr_lacks "2026-11-09"
check "seed-reviews list: a call of \"Task\" with review in its type is found" sr_has "2026-11-15 12:00:00  1 finding"
check "seed-reviews list: transcripts in subagents/ are not read" sr_lacks "2026-11-16"
check "seed-reviews list: the runs line counts reviews with findings not seeded" sr_has "Runs of classify: 4"
check "seed-reviews list: the totals line" sr_has "5 reviews, 4 with findings, 4 with findings and not seeded yet."
sr_show "$sr_repo" 2
check "seed-reviews show: the identifier is the first line, then the report" sh -c '[ "$1" -eq 0 ] && [ "$(printf "%s\n" "$2" | sed -n 1p)" = "2026-11-11 09:15:30" ] && [ "$(printf "%s\n" "$2" | sed -n 2p)" = "Found three." ]' sh "$sr_code" "$sr_out"
check "seed-reviews show: the start notice is not taken as the report" sr_lacks "Async agent launched"
sr_show "$sr_repo" 1
check "seed-reviews show: numbering is stable, 1 is the oldest" sr_has "1. a finding"

# Escapes.
sr_e="$(sr_dir "$sr_repo")/esc.jsonl"
sr_call "$sr_e" ESC1 playbook-agents:review 2026-11-20T10:00:00Z
sr_fg "$sr_e" ESC1 'He said \"hi\"\nline2\ttab \\ back \u00e9 \u0041 \ud83d\ude00 a\/b'
sr_show "$sr_repo" 6
sr_want=$(printf 'He said "hi"\nline2\ttab \\ back \303\251 A \360\237\230\200 a/b')
check "seed-reviews show: escaped quotes, newlines, tabs, backslashes, and \\u codes are unescaped" sh -c '[ "$(printf "%s\n" "$1" | sed 1d)" = "$2" ]' sh "$sr_out" "$sr_want"
sr_show "$sr_repo" 99
check "seed-reviews show: a number with no review fails" sh -c '[ "$1" -eq 1 ]' sh "$sr_code"
sr_show "$sr_repo" x
check "seed-reviews show: a number that is not a number is a usage error" sh -c '[ "$1" -eq 2 ]' sh "$sr_code"

# The page marks the reviews already seeded.
ev_page "$tmp/sr/page" '| missing-test | 1 | | a change | | project |\n' '| missing-test | 1 | 2026-11-10 08:00:00 | 2026-11-10 | A finding. |\n| missing-test | 1 | 2026-11-12 10:30:00.500 | 2026-11-12 | Another. |\n'
sr_list "$sr_repo" "$tmp/sr/page/evidence.md"
check "seed-reviews list: a review in the Review column is marked already seeded" sr_has "1  2026-11-10 08:00:00  1 finding  already seeded"
check "seed-reviews list: a review not on the page is not marked" sh -c 'printf "%s\n" "$1" | grep "^2  " | grep -qv "already seeded"' sh "$sr_out"
check "seed-reviews list: the runs line leaves out the seeded reviews" sr_has "Runs of classify: 3"
mkdir -p "$sr_repo/docs/wiki"
cp "$tmp/sr/page/evidence.md" "$sr_repo/docs/wiki/evidence.md"
sr_list "$sr_repo"
check "seed-reviews list: with no page given, docs/wiki/evidence.md of the repository is read" sr_has "Runs of classify: 3"
rm -rf "$sr_repo/docs"

# Worktrees, sessions under .claude/worktrees, and other repositories.
sr_call "$(sr_dir "$tmp/sr/repo-wt")/w1.jsonl" WT1 playbook-agents:review 2026-11-05T01:00:00Z
sr_fg "$(sr_dir "$tmp/sr/repo-wt")/w1.jsonl" WT1 'Found one: in a worktree.\n\n1. w'
sr_call "$(sr_dir "$sr_repo/.claude/worktrees/s1")/c1.jsonl" CW1 playbook-agents:review 2026-11-04T01:00:00Z
sr_fg "$(sr_dir "$sr_repo/.claude/worktrees/s1")/c1.jsonl" CW1 'Found one: in a session.\n\n1. s'
sr_call "$(sr_dir "$tmp/sr/repo2")/o1.jsonl" OTH1 playbook-agents:review 2026-11-03T01:00:00Z
sr_fg "$(sr_dir "$tmp/sr/repo2")/o1.jsonl" OTH1 'Found one: in a sibling.\n\n1. o'
sr_call "$(sr_dir "$tmp/sr/repo2/.claude/worktrees/s1")/o2.jsonl" OTH2 playbook-agents:review 2026-11-02T01:00:00Z
sr_fg "$(sr_dir "$tmp/sr/repo2/.claude/worktrees/s1")/o2.jsonl" OTH2 'Found one: in a sibling session.\n\n1. o'
sr_call "$(sr_dir "$tmp/sr")/p1.jsonl" PAR1 playbook-agents:review 2026-11-01T01:00:00Z
sr_fg "$(sr_dir "$tmp/sr")/p1.jsonl" PAR1 'Found one: in the parent folder.\n\n1. p'
sr_list "$sr_repo"
check "seed-reviews list: the folder of a git worktree is read" sr_has "2026-11-05 01:00:00"
check "seed-reviews list: the folder of a .claude/worktrees session is read" sr_has "2026-11-04 01:00:00"
check "seed-reviews list: a sibling repository whose name starts the same is not read" sr_lacks "2026-11-03"
check "seed-reviews list: a session of a sibling repository is not read" sr_lacks "2026-11-02"
check "seed-reviews list: the folder of a parent directory is not read" sr_lacks "2026-11-01"
check "seed-reviews list: the oldest review of a worktree is number 1" sr_has "1  2026-11-04 01:00:00"
sr_list "$tmp/sr/repo-wt"
check "seed-reviews list: run from the worktree, the main folder is read too" sr_has "2026-11-10 08:00:00"

# A folder with no review.
mkdir -p "$(sr_dir "$tmp/sr/repo2")" "$tmp/sr/empty"
rm -rf "$(sr_dir "$tmp/sr/repo2")"/*.jsonl "$(sr_dir "$tmp/sr/repo2/.claude/worktrees/s1")"
sr_list "$tmp/sr/repo2"
check "seed-reviews list: a folder with no review says so and exits 0" sh -c '[ "$1" -eq 0 ] && printf "%s" "$2" | grep -q "No reviews found"' sh "$sr_code" "$sr_out"
sr_list
check "seed-reviews list: with no repository it is a usage error" sh -c '[ "$1" -eq 2 ]' sh "$sr_code"

# Marking by the minute of the identifier that classify gets from review
# ("<unit or description> YYYY-MM-DD HH:MM"), in the local zone only.
ev_page "$tmp/sr/page2" '| missing-test | 1 | | a change | | project |\n' '| missing-test | 1 | unit-7 2026-11-11 09:15 | 2026-11-11 | A finding. |\n| missing-test | 1 | 2026-11-12 10:30:00.500 | 2026-11-12 | Another. |\n'
sr_list "$sr_repo" "$tmp/sr/page2/evidence.md"
check "seed-reviews list: an identifier on the page that ends with the review's minute marks it seeded" sr_has "2026-11-11 09:15:30  1 finding  already seeded"
check "seed-reviews list: a review of another minute is not marked by it" sh -c 'printf "%s\n" "$1" | grep "2026-11-10 08:00:00" | grep -qv "already seeded"' sh "$sr_out"
sr_tz=UTC-3 sr_list "$sr_repo" "$tmp/sr/page2/evidence.md"
check "seed-reviews list: a minute of the page that matches only in UTC does not mark the review when the zone is not UTC" sh -c 'printf "%s\n" "$1" | grep "2026-11-11 09:15:30" | grep -qv "already seeded"' sh "$sr_out"
check "seed-reviews list: an identifier on the page with the fraction of a second marks the review" sr_has "2026-11-12 10:30:00.500  1 finding  already seeded"
sr_late="$(sr_dir "$sr_repo")/late.jsonl"
sr_call "$sr_late" LATE1 playbook-agents:review 2026-11-08T23:30:00Z
sr_fg "$sr_late" LATE1 'Found one.\n\n1. late in the day'
sr_call "$sr_late" EARLY1 playbook-agents:review 2026-11-09T02:00:00Z
sr_fg "$sr_late" EARLY1 'Found one.\n\n1. early in the day'
ev_page "$tmp/sr/page3" '| missing-test | 1 | | a change | | project |\n' '| missing-test | 1 | u 2026-11-09 02:30 | 2026-11-09 | A. |\n| missing-test | 1 | u 2026-11-08 21:00 | 2026-11-08 | B. |\n'
sr_tz=UTC-3 sr_list "$sr_repo" "$tmp/sr/page3/evidence.md"
check "seed-reviews list: the minute is also compared in the local zone, across midnight (UTC+3)" sr_has "2026-11-08 23:30:00  1 finding  already seeded"
check "seed-reviews list: in UTC+3 the other minute does not mark the early review" sh -c 'printf "%s\n" "$1" | grep "2026-11-09 02:00:00" | grep -qv "already seeded"' sh "$sr_out"
sr_tz=UTC+5 sr_list "$sr_repo" "$tmp/sr/page3/evidence.md"
check "seed-reviews list: the minute is also compared in the local zone, back across midnight (UTC-5)" sr_has "2026-11-09 02:00:00  1 finding  already seeded"

# A report that holds </result>, in the background.
sr_x="$(sr_dir "$sr_repo")/x.jsonl"
sr_call "$sr_x" BGX1 playbook-agents:review 2026-11-21T01:00:00Z
sr_start "$sr_x" BGX1
sr_notice "$sr_x" BGX1 'Found two.\n\n1. quotes the </result> tag\n\n2. last item'
sr_list "$sr_repo"
sr_n=$(printf '%s\n' "$sr_out" | awk '/2026-11-21 01:00:00/ { print $1 }')
check "seed-reviews list: a report with </result> in it is whole (two findings)" sr_has "2026-11-21 01:00:00  2 findings"
sr_show "$sr_repo" "$sr_n"
check "seed-reviews show: a report with </result> in it ends with its last line" sh -c 'printf "%s\n" "$1" | tail -n 1 | grep -Fqx "2. last item"' sh "$sr_out"

# A folder inside a repository is not the repository.
mkdir -p "$sr_repo/sub"
sr_list "$sr_repo/sub"
check "seed-reviews list: a folder inside a git repository does not read the repository's transcripts" sh -c '[ "$1" -eq 0 ] && printf "%s" "$2" | grep -q "No Claude Code transcript folder"' sh "$sr_code" "$sr_out"

# A root through a symbolic link.
ln -s "$sr_repo" "$tmp/sr/link"
sr_list "$tmp/sr/link"
check "seed-reviews list: a root through a symbolic link reads the folder of the physical path" sr_has "2026-11-10 08:00:00  1 finding"
mkdir -p "$tmp/sr/plain"
sr_call "$(sr_dir "$tmp/sr/plain")/l1.jsonl" LN1 playbook-agents:review 2026-11-27T10:00:00Z
sr_fg "$(sr_dir "$tmp/sr/plain")/l1.jsonl" LN1 'Found one.\n\n1. plain'
ln -s "$tmp/sr/plain" "$tmp/sr/plainlink"
sr_list "$tmp/sr/plainlink"
check "seed-reviews list: a link to a folder that is not a git repository reads the folder of the physical path" sr_has "2026-11-27 10:00:00  1 finding"

# Identifiers that repeat, and the fraction of a second. The file lists the
# review with the later tool use id first: the identifiers must not depend on
# the order of the file.
sr_i="$(sr_dir "$sr_repo")/ids.jsonl"
sr_call "$sr_i" IDbbb222 playbook-agents:review 2026-11-22T10:00:00.100Z
sr_fg "$sr_i" IDbbb222 'Found one.\n\n1. second'
sr_call "$sr_i" IDaaa111 playbook-agents:review 2026-11-22T10:00:00.100Z
sr_fg "$sr_i" IDaaa111 'Found one.\n\n1. first'
sr_call "$sr_i" IDccc333 playbook-agents:review 2026-11-22T10:00:00.200Z
sr_fg "$sr_i" IDccc333 'Found one.\n\n1. third'
sr_call "$sr_i" UNbbb222 playbook-agents:review ""
sr_fg "$sr_i" UNbbb222 'Found one.\n\n1. undated two'
sr_call "$sr_i" UNaaa111 playbook-agents:review ""
sr_fg "$sr_i" UNaaa111 'Found one.\n\n1. undated one'
sr_list "$sr_repo"
check "seed-reviews list: the fraction of a second stays in the identifier" sr_has "2026-11-22 10:00:00.200  1 finding"
check "seed-reviews list: reviews of the same identifier get the end of their tool use id" sh -c 'printf "%s\n" "$1" | grep -q "2026-11-22 10:00:00.100 aaa111  1 finding" && printf "%s\n" "$1" | grep -q "2026-11-22 10:00:00.100 bbb222  1 finding"' sh "$sr_out"
check "seed-reviews list: a review that does not collide has no suffix" sr_lacks "10:00:00.200 ccc333"
check "seed-reviews list: reviews with no timestamp are undated with the end of their tool use id" sh -c 'printf "%s\n" "$1" | grep -q "  undated aaa111  1 finding" && printf "%s\n" "$1" | grep -q "  undated bbb222  1 finding"' sh "$sr_out"
check "seed-reviews list: reviews of the same date are ordered by tool use id, not by the order of the file" sh -c 'printf "%s\n" "$1" | awk '"'"'/10:00:00.100 aaa111/ { a = $1 } /10:00:00.100 bbb222/ { b = $1 } END { exit !(a + 0 > 0 && a < b) }'"'"'' sh "$sr_out"
sr_n=$(printf '%s\n' "$sr_out" | awk '/10:00:00.100 aaa111/ { print $1 }')
sr_show "$sr_repo" "$sr_n"
check "seed-reviews show: the identifier of a colliding review is the same whatever the order of the file" sh -c 'printf "%s\n" "$1" | grep -Fq "1. first" && [ "$(printf "%s\n" "$1" | sed -n 1p)" = "2026-11-22 10:00:00.100 aaa111" ]' sh "$sr_out"

# The date comes from a later copy of the call when the first has none.
sr_c="$(sr_dir "$sr_repo")/copy.jsonl"
printf '{"type":"assistant","message":{"content":[{"type":"tool_use","id":"toolu_CP1","name":"Agent","input":{"description":"d","subagent_type":"playbook-agents:review","prompt":"p"}}]}}\n' >> "$sr_c"
sr_call "$sr_c" CP1 playbook-agents:review 2026-11-23T04:05:06Z
sr_fg "$sr_c" CP1 'Found one.\n\n1. copy'
sr_list "$sr_repo"
check "seed-reviews list: the date is taken from a later copy of the call" sr_has "2026-11-23 04:05:06  1 finding"

# A report that ends with an escaped backslash before n.
sr_b="$(sr_dir "$sr_repo")/bs.jsonl"
sr_call "$sr_b" BS1 playbook-agents:review 2026-11-24T10:00:00Z
sr_fg "$sr_b" BS1 'Found one.\n\n1. path C:\\n'
sr_call "$sr_b" BS2 playbook-agents:review 2026-11-24T11:00:00Z
sr_fg "$sr_b" BS2 '\n  Found one.\n\n1. spaces and newlines around\n\n  '
sr_list "$sr_repo"
sr_n=$(printf '%s\n' "$sr_out" | awk '/2026-11-24 10:00:00/ { print $1 }')
sr_show "$sr_repo" "$sr_n"
check "seed-reviews show: a trailing backslash and n is kept, not trimmed as a newline" sh -c 'printf "%s\n" "$1" | tail -n 1 | grep -Fqx "$2"' sh "$sr_out" '1. path C:\n'
sr_list "$sr_repo"
sr_n=$(printf '%s\n' "$sr_out" | awk '/2026-11-24 11:00:00/ { print $1 }')
sr_show "$sr_repo" "$sr_n"
check "seed-reviews show: newlines and spaces at both ends are trimmed" sh -c '[ "$(printf "%s\n" "$1" | sed -n 2p)" = "Found one." ] && [ "$(printf "%s\n" "$1" | tail -n 1)" = "1. spaces and newlines around" ]' sh "$sr_out"

# The number of findings.
sr_n2="$(sr_dir "$sr_repo")/num.jsonl"
sr_call "$sr_n2" NUM1 playbook-agents:review 2026-11-25T10:00:00Z
sr_fg "$sr_n2" NUM1 'Found three.\n\n**1. first**\n\nx\n\n**2. second**\n\n**3. third**\n\nNot checked:\n- a'
sr_call "$sr_n2" NUM2 playbook-agents:review 2026-11-26T10:00:00Z
sr_fg "$sr_n2" NUM2 'Only prose, no list.'
sr_list "$sr_repo"
check "seed-reviews list: the findings are counted from lines that start with a number and a dot, or ** and one" sr_has "2026-11-25 10:00:00  3 findings"
check "seed-reviews list: a report with no numbered line says only findings" sr_has "2026-11-26 10:00:00  findings"

# A repository with no transcript folder: show fails.
sr_show "$tmp/sr/empty" 1
check "seed-reviews show: with no transcript folder it fails with exit 1" sh -c '[ "$1" -eq 1 ] && printf "%s" "$2" | grep -q "no transcript folder"' sh "$sr_code" "$sr_out"

# A live review writes the minute when it takes the date, often minutes after
# its call: a minute of the page from the call's minute to the result's,
# inclusive, marks the review seeded, in the local zone only.
sr_g="$(sr_dir "$sr_repo")/range.jsonl"
sr_call "$sr_g" RGbg0001 playbook-agents:review 2026-11-28T20:11:17.312Z
sr_start "$sr_g" RGbg0001
sr_notice "$sr_g" RGbg0001 'Found one.\n\n1. in the background' 2026-11-28T20:25:40.000Z
sr_call "$sr_g" RGfg0002 playbook-agents:review 2026-11-29T09:00:10Z
sr_fg "$sr_g" RGfg0002 'Found one.\n\n1. in the foreground' 2026-11-29T09:07:00Z
# sr_page <name> <identifier>...: a page whose Review column has those identifiers.
sr_page() {
  sr_rows=
  sr_pn=$1; shift
  for sr_pi in "$@"; do sr_rows="$sr_rows| missing-test | 1 | $sr_pi | 2026-11-28 | A. |\\n"; done
  ev_page "$tmp/sr/$sr_pn" '| missing-test | 1 | | a change | | project |\n' "$sr_rows"
}
sr_page pg1 "unit 2026-11-28 20:21" "unit 2026-11-29 09:05"
sr_list "$sr_repo" "$tmp/sr/pg1/evidence.md"
check "seed-reviews list: a minute between the call and the result marks a review of the background" sr_has "2026-11-28 20:11:17.312  1 finding  already seeded"
check "seed-reviews list: a minute between the call and the result marks a review of the foreground" sr_has "2026-11-29 09:00:10  1 finding  already seeded"
sr_page pg2 "unit 2026-11-28 20:10" "unit 2026-11-28 20:26" "unit 2026-11-29 08:59" "unit 2026-11-29 09:08"
sr_list "$sr_repo" "$tmp/sr/pg2/evidence.md"
check "seed-reviews list: minutes just outside the call and the result do not mark them" sh -c 'printf "%s\n" "$1" | grep -E "2026-11-28 20:11|2026-11-29 09:00" | grep -qv "already seeded" && ! printf "%s\n" "$1" | grep -E "2026-11-28 20:11|2026-11-29 09:00" | grep -q "already seeded"' sh "$sr_out"
sr_page pg3 "unit 2026-11-28 20:25" "unit 2026-11-29 09:00"
sr_list "$sr_repo" "$tmp/sr/pg3/evidence.md"
check "seed-reviews list: the minute of the result and the minute of the call are included" sh -c 'printf "%s\n" "$1" | grep -c "2026-11-2[89] .*already seeded" | grep -qx 2' sh "$sr_out"
sr_page pg4 "unit 2026-11-28 23:21" "unit 2026-11-29 12:05"
sr_tz=UTC-3 sr_list "$sr_repo" "$tmp/sr/pg4/evidence.md"
check "seed-reviews list: the range is also compared in the local zone" sh -c 'printf "%s\n" "$1" | grep -c "2026-11-2[89] .*already seeded" | grep -qx 2' sh "$sr_out"
sr_tz=UTC-3 sr_list "$sr_repo" "$tmp/sr/pg1/evidence.md"
check "seed-reviews list: a range that matches only in UTC does not mark the reviews when the zone is not UTC" sh -c '! printf "%s\n" "$1" | grep -E "2026-11-2[89] " | grep -q "already seeded"' sh "$sr_out"

# A report of the background that quotes </task-notification> is whole.
sr_k="$(sr_dir "$sr_repo")/quote.jsonl"
sr_call "$sr_k" TNq00001 playbook-agents:review 2026-11-30T05:00:00Z
sr_start "$sr_k" TNq00001
sr_notice "$sr_k" TNq00001 'Found two.\n\n1. quotes \"</task-notification>\" and </task-notification> in it\n\n2. last item'
sr_list "$sr_repo"
sr_n=$(printf '%s\n' "$sr_out" | awk '/2026-11-30 05:00:00/ { print $1 }')
check "seed-reviews list: a report that quotes </task-notification> is whole (two findings)" sr_has "2026-11-30 05:00:00  2 findings"
sr_show "$sr_repo" "$sr_n"
check "seed-reviews show: a report that quotes </task-notification> ends with its last line" sh -c 'printf "%s\n" "$1" | tail -n 1 | grep -Fqx "2. last item"' sh "$sr_out"

# --from <old path>: the transcript folders of a repository's old path
# (seed-evidence-14). The old paths do not exist on disk.
mkdir -p "$tmp/sr/newrepo"
sr_call "$(sr_dir "$tmp/sr/newrepo")/n1.jsonl" FRn00001 playbook-agents:review 2026-12-01T10:00:00Z
sr_fg "$(sr_dir "$tmp/sr/newrepo")/n1.jsonl" FRn00001 'Found one.\n\n1. new'
sr_call "$(sr_dir "$tmp/sr/old1")/o1.jsonl" FRo00002 playbook-agents:review 2026-12-02T10:00:00Z
sr_fg "$(sr_dir "$tmp/sr/old1")/o1.jsonl" FRo00002 'Found one.\n\n1. old'
sr_call "$(sr_dir "$tmp/sr/old1/.claude/worktrees/s1")/o3.jsonl" FRo00003 playbook-agents:review 2026-12-03T10:00:00Z
sr_fg "$(sr_dir "$tmp/sr/old1/.claude/worktrees/s1")/o3.jsonl" FRo00003 'Found one.\n\n1. old session'
sr_call "$(sr_dir "$tmp/sr/old2")/o2.jsonl" FRo00004 playbook-agents:review 2026-12-04T10:00:00Z
sr_fg "$(sr_dir "$tmp/sr/old2")/o2.jsonl" FRo00004 'Found one.\n\n1. other old'
sr_call "$(sr_dir "$tmp/sr/old1b")/b1.jsonl" FRb00005 playbook-agents:review 2026-12-05T10:00:00Z
sr_fg "$(sr_dir "$tmp/sr/old1b")/b1.jsonl" FRb00005 'Found one.\n\n1. sibling of the old path'
sr_list "$tmp/sr/newrepo"
check "seed-reviews --from: without it the folder of an old path is not read" sh -c 'printf "%s\n" "$1" | grep -q "2026-12-01" && ! printf "%s\n" "$1" | grep -Eq "2026-12-0[2345]"' sh "$sr_out"
sr_list --from "$tmp/sr/old1" "$tmp/sr/newrepo"
check "seed-reviews --from: the folder of the old path is read, though the path does not exist" sh -c '[ ! -e "$1" ] && printf "%s\n" "$2" | grep -q "2026-12-02 10:00:00  1 finding"' sh "$tmp/sr/old1" "$sr_out"
check "seed-reviews --from: the .claude/worktrees sessions of the old path are read" sr_has "2026-12-03 10:00:00  1 finding"
check "seed-reviews --from: the reviews of the new path are still listed, oldest first" sh -c 'printf "%s\n" "$1" | sed -n 1p | grep -q "^1  2026-12-01"' sh "$sr_out"
check "seed-reviews --from: a sibling whose name starts like the old path is not read" sr_lacks "2026-12-05"
check "seed-reviews --from: a folder of another old path is not read" sr_lacks "2026-12-04"
sr_list --from "$tmp/sr/old1" --from "$tmp/sr/old2/" "$tmp/sr/newrepo"
check "seed-reviews --from: two of them read both old paths (a trailing slash is dropped)" sh -c 'printf "%s\n" "$1" | grep -q "2026-12-02" && printf "%s\n" "$1" | grep -q "2026-12-04" && ! printf "%s\n" "$1" | grep -q "2026-12-05"' sh "$sr_out"
sr_n=$(printf '%s\n' "$sr_out" | awk '/2026-12-04 10:00:00/ { print $1 }')
sr_show --from "$tmp/sr/old1" --from "$tmp/sr/old2" "$tmp/sr/newrepo" "$sr_n"
check "seed-reviews --from: show with the same options gives the review that list numbered" sh -c '[ "$(printf "%s\n" "$1" | sed -n 1p)" = "2026-12-04 10:00:00" ] && printf "%s\n" "$1" | grep -Fq "1. other old"' sh "$sr_out"
sr_list --from relative/path "$tmp/sr/newrepo"
check "seed-reviews --from: a path that is not absolute is a usage error" sh -c '[ "$1" -eq 2 ]' sh "$sr_code"
sr_list --from
check "seed-reviews --from: with no path after it is a usage error" sh -c '[ "$1" -eq 2 ]' sh "$sr_code"

if [ "$failed" -eq 0 ]; then
  printf 'all cases passed\n'
else
  printf '%s case(s) failed\n' "$failed"
  exit 1
fi
