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
words 251 > "$tmp/repo/plugins/playbook-wiki/contract.md"
expect "L1: contract over 250 words fails" fail "L1 contract.md has 251 words"

fresh
words 250 > "$tmp/repo/plugins/playbook-wiki/contract.md"
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
words 400 > "$tmp/repo/plugins/playbook-agents/rules.md"
for i in 1 2 3 4 5 6 7 8; do
  add_skill "skill-$i" "$(words 40 | cut -c1-200)" 10
done
expect "L4: playbook-agents over 620 words at session start fails" fail "L4 playbook-agents loads"

fresh
skill_plugin=playbook-wiki add_skill wiki-skill "$(words 40 | cut -c1-200)" 10
expect "L4: playbook-wiki over 350 words at session start fails" fail "L4 playbook-wiki loads"

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

# fresh_wiki <words under "Where work stands">: an entry point and one page,
# each linking to the other. The table of pages names no code.
fresh_wiki() {
  rm -rf "$tmp/wiki"
  mkdir -p "$tmp/wiki/01-product"
  {
    printf '# Wiki\n\n## Where work stands\n\n'
    words "$1"
    printf '\n## Pages\n\n| Page | Content | Code it governs |\n|---|---|---|\n'
    printf '| [Overview](01-product/overview.md) | The product | |\n'
  } > "$tmp/wiki/README.md"
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

fresh_wiki 250
expect_wiki "wiki: a state section at the limit passes" pass "has 250 words"

fresh_wiki 251
expect_wiki "wiki: a state section over 250 words fails" fail "has 251 words, limit 250"

fresh_wiki 250
{ printf '\n## History\n\n'; words 400; } >> "$tmp/wiki/README.md"
expect_wiki "wiki: words under another heading are not counted" pass "has 250 words"

fresh_wiki 100
{ printf '\n### A smaller heading\n\n'; words 200; } > "$tmp/part"
awk -v part="$tmp/part" '/^## Pages/ { while ((getline line < part) > 0) print line } { print }' \
  "$tmp/wiki/README.md" > "$tmp/readme" && mv "$tmp/readme" "$tmp/wiki/README.md"
expect_wiki "wiki: a smaller heading inside the state section is counted with it" fail "limit 250"

fresh_wiki 10
printf 'See the [plan](../06-plan/plan.md).\n' >> "$tmp/wiki/01-product/overview.md"
expect_wiki "wiki: a link to a missing page fails and names both" fail "01-product/overview.md links to ../06-plan/plan.md"

fresh_wiki 10
printf 'See [the top](../README.md#where-work-stands), [here](#overview), [a site](https://example.com/a.md), and [mail](mailto:a@example.com).\n' >> "$tmp/wiki/01-product/overview.md"
expect_wiki "wiki: anchors and addresses with a scheme are not checked as files" pass

fresh_wiki 10
printf 'Write a link as `[text](missing.md)`.\n\n```text\n[text](also-missing.md)\n```\n' >> "$tmp/wiki/01-product/overview.md"
expect_wiki "wiki: a link inside code is not checked" pass

fresh_wiki 10
printf 'Two on one line: [a](../README.md) and [b](gone.md).\n' >> "$tmp/wiki/01-product/overview.md"
expect_wiki "wiki: the second link of a line is checked too" fail "links to gone.md"

fresh_wiki 10
printf '# Wiki\n\n## Pages\n\n[Overview](01-product/overview.md)\n' > "$tmp/wiki/README.md"
expect_wiki "wiki: a wiki without the state section passes with a note" pass "has no \"Where work stands\" section"

fresh_wiki 10
rm "$tmp/wiki/README.md"
expect_wiki "wiki: a wiki without an entry point fails" fail "has no README.md"

fresh_wiki 10
rm -rf "$tmp/my wiki"
mv "$tmp/wiki" "$tmp/my wiki"
expect_wiki "wiki: a path with a space is read whole" pass "has 10 words" "$tmp/my wiki"
printf 'See [b](gone.md).\n' >> "$tmp/my wiki/01-product/overview.md"
expect_wiki "wiki: a broken link under a path with a space is found" fail "links to gone.md" "$tmp/my wiki"

# state_section <heading line> <words>: replaces the entry point with one
# whose state section has that heading.
state_section() {
  { printf '# Wiki\n\n%s\n\n' "$1"; words "$2"; printf '\n## Pages\n\n[Overview](01-product/overview.md)\n'; } > "$tmp/wiki/README.md"
}

fresh_wiki 10
state_section '## Where work stands (2026-11-14)' 300
expect_wiki "wiki: a heading with text after the title is still the state section" fail "has 300 words"

fresh_wiki 10
state_section '### Where work stands' 300
expect_wiki "wiki: a state section under a smaller heading is still counted" fail "has 300 words"

fresh_wiki 300
awk '{ printf "%s\r\n", $0 }' "$tmp/wiki/README.md" > "$tmp/readme" && mv "$tmp/readme" "$tmp/wiki/README.md"
expect_wiki "wiki: lines that end in a carriage return are counted" fail "has 300 words"

fresh_wiki 10
{ printf '# Wiki\n\n## Where work stands\n\n```sh\n## a comment\n```\n\n'; words 300; printf '\n## Pages\n\n[Overview](01-product/overview.md)\n'; } > "$tmp/wiki/README.md"
expect_wiki "wiki: a heading inside a code block does not end the state section" fail "limit 250"

fresh_wiki 10
{ printf '\n# Appendix\n\n'; words 400; } >> "$tmp/wiki/README.md"
expect_wiki "wiki: a larger heading ends the state section" pass "has 10 words"

fresh_wiki 10
printf '~~~text\n```\n~~~\n\nSee [b](gone.md).\n' >> "$tmp/wiki/01-product/overview.md"
expect_wiki "wiki: a code block ends only at the marker that opened it" fail "links to gone.md"

fresh_wiki 10
printf 'See [a](gone.md) and [b](lost.md).\n' >> "$tmp/wiki/01-product/overview.md"
expect_wiki "wiki: each broken link counts as one failure" fail "2 check(s) failed"

fresh_wiki 10
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
  fresh_wiki 10
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
printf '# Wiki\n\n## Where work stands\n\nNothing open.\n\n## Pages\n\n| Page | Content |\n|---|---|\n| [Overview](01-product/overview.md) | Built with `no-such-tool` |\n' > "$state_readme"
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

fresh_wiki 10
decisions
{ decision D1 200; decision TD1 90; } >> "$tmp/wiki/decisions.md"
printf '3\n' > "$tmp/wiki/.format"
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

fresh_project
printf '3\n' > "$project_wiki/.format"
expect_wiki "works: a wiki at format 3 without works/ passes" pass "" "$project_wiki"

fresh_works
printf '3\n' > "$project_wiki/.format"
expect_wiki "works: the works of a wiki at format 3 are checked too" pass "" "$project_wiki"

fresh_works
printf '3\n' > "$project_wiki/.format"
rm "$project_wiki/works/billing/README.md"
expect_wiki "works: the works of a wiki at format 3 fail when they break a rule" fail "FAIL works/billing has no README.md" "$project_wiki"

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

# The marker of a wiki's format.
wiki_format="$root/plugins/playbook-wiki/skills/doctor/scripts/wiki-format.sh"
product_format=$(sed -n 's/^format=//p' "$wiki_format")

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

rm -rf "$tmp/wiki"
expect_format "format: a project without a wiki gets no notice" status 0 ""

fresh_wiki 10
expect_format "format: a wiki without a marker gets a notice that names the doctor" status 0 "has no format marker"
expect_format "format: the notice says not to repair unasked" status 0 "Do not repair the wiki unasked"

fresh_wiki 10
printf '1\n' > "$tmp/wiki/.format"
expect_format "format: a marker behind the playbook gets a notice with both numbers" status 0 "is at wiki format 1, and the playbook is at $product_format"

fresh_wiki 10
printf '%s\n' "$product_format" > "$tmp/wiki/.format"
expect_format "format: a marker at the playbook's format gets no notice" status 0 ""

fresh_wiki 10
printf '%s\n' "$((product_format + 1))" > "$tmp/wiki/.format"
expect_format "format: a marker ahead of the playbook gets no notice" status 0 ""

fresh_wiki 10
printf 'valid\n' > "$tmp/wiki/.format"
expect_format "format: a marker that is not a number counts as missing" status 0 "has no format marker"

fresh_wiki 10
printf '%s\r\n' "$product_format" > "$tmp/wiki/.format"
expect_format "format: a marker that ends in a carriage return is read" status 0 ""

fresh_wiki 251
expect_format "format: mark writes nothing when the check fails" mark 1 "The marker was not written"
check "format: no marker exists after a failed mark" absent "$tmp/wiki/.format"

fresh_wiki 251
printf '1\n' > "$tmp/wiki/.format"
expect_format "format: a failed mark leaves an older marker as it was" mark 1 "limit 250"
check "format: the older marker still says 1" test "$(cat "$tmp/wiki/.format")" = 1

fresh_wiki 10
expect_format "format: mark writes the marker when the check passes" mark 0 "as wiki format $product_format"
check "format: the marker holds the playbook's format" test "$(cat "$tmp/wiki/.format")" = "$product_format"
expect_format "format: after mark there is no notice" status 0 ""

rm -rf "$tmp/wiki"
expect_format "format: mark fails when there is no wiki" mark 1 "has no README.md"

out=$(sh "$wiki_format" 2>&1); code=$?
check "format: without a command it prints the usage and exits 2" test "$code" -eq 2

fresh_wiki 10
printf '# Old notes\n\nSome design notes.\n' > "$tmp/wiki/README.md"
expect_format "format: mark refuses a wiki that has no state section" mark 1 "is not in the format of the playbook"
check "format: a wiki that is not in the format is left without a marker" absent "$tmp/wiki/.format"

fresh_wiki 10
mkdir "$tmp/wiki/.format"
expect_format "format: mark fails when the marker cannot be written" mark 1 "could not write"

fresh_wiki 10
printf '99999999999999999999\n' > "$tmp/wiki/.format"
expect_format "format: a number too long to compare counts as missing" status 0 "has no format marker"

fresh_wiki 10
awk '{ gsub(/ \| Code it governs/, ""); print }' "$tmp/wiki/README.md" > "$tmp/readme" && mv "$tmp/readme" "$tmp/wiki/README.md"
expect_format "format: mark refuses a wiki whose table of pages names no code column" mark 1 "has no column \"Code it governs\""
check "format: a wiki without the column is left without a marker" absent "$tmp/wiki/.format"

fresh_wiki 10
decisions
{ decision D1 200; decision D2 200; } >> "$tmp/wiki/decisions.md"
expect_format "format: mark succeeds on a wiki with long rows in decisions.md" mark 0 "as wiki format $product_format"
check "format: mark writes no count of rows" absent "$tmp/wiki/.unchecked-decisions"

fresh_wiki 10
printf '# Wiki\n\n## Where work stands\n\nNothing open.\n\n```text\n| Page | Content | Code it governs |\n```\n' > "$tmp/wiki/README.md"
expect_format "format: mark refuses a wiki whose only code column is inside a code block" mark 1 "has no column"

# The hook: the command the plugin runs at session start, for the project of
# the session.
hook=$(awk '/"SessionStart"/ { inside = 1 }
            /"(SessionEnd|Stop|PreToolUse|PostToolUse|UserPromptSubmit)"/ { inside = 0 }
            inside' "$root/plugins/playbook-wiki/hooks/hooks.json" |
  sed -n 's/.*"command": "\(sh .*wiki-format.sh.*\)".*/\1/p' | sed 's/\\"/"/g')
check "format: the plugin runs the notice at session start" test -n "$hook"

fresh_wiki 10
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

if [ "$failed" -eq 0 ]; then
  printf 'all cases passed\n'
else
  printf '%s case(s) failed\n' "$failed"
  exit 1
fi
