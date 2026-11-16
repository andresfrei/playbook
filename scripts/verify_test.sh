#!/bin/sh
# Tests for scripts/verify.sh, scripts/set-models.sh, and the check of a
# project's wiki, plugin/skills/prepare-project/scripts/check-wiki.sh. Each case builds a copy
# of the plugin, or a small wiki, in a temporary directory, changes one thing,
# and checks the exit code and message.
# Usage: sh scripts/verify_test.sh
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

# Creates a fresh copy of the plugin and its marketplace manifest.
fresh() {
  rm -rf "$tmp/repo"
  mkdir -p "$tmp/repo"
  cp -R "$root/.claude-plugin" "$root/plugin" "$tmp/repo/"
  mkdir "$tmp/repo/scripts"
  cp "$root/scripts/set-models.sh" "$tmp/repo/scripts/"
}

# add_skill <name> <description> <body words> [extra front matter line]
add_skill() {
  dir="$tmp/repo/plugin/skills/$1"
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
words 501 > "$tmp/repo/plugin/rules.md"
expect "L1: rules file over 500 words fails" fail "L1"

fresh
rm "$tmp/repo/plugin/rules.md"
expect "L1: missing rules file fails" fail "L1"

fresh
add_skill long-body "Short description." 701
expect "L2: skill body over 700 words fails" fail "L2"

fresh
add_skill long-description "$(chars 251)" 10
expect "L3: description over 250 characters fails" fail "L3"

fresh
words 500 > "$tmp/repo/plugin/rules.md"
for i in 1 2 3 4 5 6 7 8; do
  add_skill "skill-$i" "$(words 40 | cut -c1-200)" 10
done
expect "L4: session start load over 800 words fails" fail "L4"

fresh
add_skill extra-key "Short description." 10 "license: MIT"
expect "front matter with a third key fails" fail "front matter"

fresh
add_skill forked "Short description." 10 "context: fork
agent: playbook:review"
expect "front matter with context and agent passes" pass

fresh
add_skill forked-model "Short description." 10 "context: fork
agent: playbook:review
model: opus"
expect "front matter with context, agent, and model fails" fail "front matter"

fresh
add_skill owner-only "Short description." 10 "disable-model-invocation: true"
expect "front matter with disable-model-invocation: true passes" pass

fresh
add_skill owner-only "Short description." 10 "disable-model-invocation: false"
expect "front matter with disable-model-invocation other than true fails" fail "disable-model-invocation of"

fresh
words 500 > "$tmp/repo/plugin/rules.md"
for i in 1 2 3 4 5 6 7 8; do
  add_skill "skill-$i" "$(words 40 | cut -c1-200)" 10 "disable-model-invocation: true"
done
expect "L4: the description of a skill only the owner starts is not counted" pass

fresh
add_skill agent-only "Short description." 10 "agent: playbook:review"
expect "front matter with agent and no context fails" fail "front matter"

fresh
add_skill inline "Short description." 10 "context: inline
agent: playbook:review"
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
sed 's/^model: .*/model: opus/' "$tmp/repo/plugin/agents/explore.md" > "$tmp/x" &&
  mv "$tmp/x" "$tmp/repo/plugin/agents/explore.md"
expect_models "models: hand-edited model fails --check" fail "explore.md"
expect_models "models: --check changes nothing" fail "explore.md" --check
grep -q '^model: opus' "$tmp/repo/plugin/agents/explore.md" ||
  { printf 'FAIL  models: --check changed a file\n'; failed=$((failed + 1)); }
sh "$root/scripts/set-models.sh" "$tmp/repo" >/dev/null 2>&1
expect_models "models: --check passes after the rewrite" pass ""

fresh
rm "$tmp/repo/plugin/agents/review.md"
expect_models "models: configured agent without a file fails" fail "review.md"

fresh
cp "$tmp/repo/plugin/agents/write.md" "$tmp/repo/plugin/agents/extra.md"
expect_models "models: agent file absent from the configuration fails" fail "extra.md"

fresh
sed 's/^explore .*/explore  gpt  medium/' "$tmp/repo/plugin/models.conf" > "$tmp/x" &&
  mv "$tmp/x" "$tmp/repo/plugin/models.conf"
expect_models "models: invalid model is rejected" fail "gpt"

fresh
sed 's/^explore .*/explore  haiku  extreme/' "$tmp/repo/plugin/models.conf" > "$tmp/x" &&
  mv "$tmp/x" "$tmp/repo/plugin/models.conf"
expect_models "models: invalid effort is rejected" fail "extreme"

fresh
sed 's/^explore .*/explore  haiku  medium  extra/' "$tmp/repo/plugin/models.conf" > "$tmp/x" &&
  mv "$tmp/x" "$tmp/repo/plugin/models.conf"
expect_models "models: a fourth field is rejected" fail "more than three fields"

fresh
sed 's/^description: .*/description: '"$(chars 251)"'/' "$tmp/repo/plugin/agents/write.md" > "$tmp/x" &&
  mv "$tmp/x" "$tmp/repo/plugin/agents/write.md"
expect "L3: agent description over 250 characters fails" fail "L3 description of agents/write.md"

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
check_wiki="$root/plugin/skills/prepare-project/scripts/check-wiki.sh"

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
decision D1 200 >> "$tmp/wiki/decisions.md"
expect_wiki "decisions: a wiki without the count of unchecked rows has no row checked" pass

fresh_wiki 10
decisions
{ decision D1 200; decision D2 60 300; decision TD1 60; } >> "$tmp/wiki/decisions.md"
printf '1\n' > "$tmp/wiki/.unchecked-decisions"
expect_wiki "decisions: rows at the limit pass, and the owner's words are not counted" pass

fresh_wiki 10
decisions
{ decision D1 200; decision D2 61; } >> "$tmp/wiki/decisions.md"
printf '1\n' > "$tmp/wiki/.unchecked-decisions"
expect_wiki "decisions: a row over 60 words fails and names it" fail "the decision of D2 has 61 words, limit 60"

fresh_wiki 10
decisions
{ decision D1 10; decision TD1 90; decision D2 90; } >> "$tmp/wiki/decisions.md"
printf '1\n' > "$tmp/wiki/.unchecked-decisions"
expect_wiki "decisions: a technical decision is a row, and each long row is one failure" fail "2 check(s) failed"

fresh_wiki 10
decisions
decision D1 90 >> "$tmp/wiki/decisions.md"
printf '0\n' > "$tmp/wiki/.unchecked-decisions"
expect_wiki "decisions: with a count of zero the first row is checked" fail "the decision of D1 has 90 words"

fresh_wiki 10
decisions
decision D1 90 >> "$tmp/wiki/decisions.md"
printf 'all\n' > "$tmp/wiki/.unchecked-decisions"
expect_wiki "decisions: a count that is not a number fails" fail ".unchecked-decisions does not hold a number"

fresh_wiki 10
decisions
{ decision D1 10; decision TD1 10; decision D2 10; } >> "$tmp/wiki/decisions.md"
check "decisions: --rows counts the rows and not the heading of the table" test "$(sh "$check_wiki" --rows "$tmp/wiki")" = 3

fresh_wiki 10
check "decisions: --rows prints 0 for a wiki without decisions.md" test "$(sh "$check_wiki" --rows "$tmp/wiki")" = 0

fresh_wiki 10
decisions
{ decision D1 10; decision D2 90; } >> "$tmp/wiki/decisions.md"
printf '1 1\n' > "$tmp/wiki/.unchecked-decisions"
expect_wiki "decisions: a count with a space inside is not read as a number" fail ".unchecked-decisions does not hold a number"

fresh_wiki 10
decisions
decision D1 90 >> "$tmp/wiki/decisions.md"
awk '{ printf "%s\r\n", $0 }' "$tmp/wiki/decisions.md" > "$tmp/x" && mv "$tmp/x" "$tmp/wiki/decisions.md"
printf '0\r\n' > "$tmp/wiki/.unchecked-decisions"
expect_wiki "decisions: rows and a count that end in a carriage return are read" fail "the decision of D1 has 90 words"

fresh_wiki 10
decisions
{ decision D1 10; printf '\n```text\n'; decision D2 90; printf '```\n'; } >> "$tmp/wiki/decisions.md"
printf '0\n' > "$tmp/wiki/.unchecked-decisions"
expect_wiki "decisions: a row inside a code block is not a row" pass
check "decisions: --rows does not count a row inside a code block" test "$(sh "$check_wiki" --rows "$tmp/wiki")" = 1

fresh_wiki 10
decisions
decision D1 90 >> "$tmp/wiki/decisions.md"
printf '3\n' > "$tmp/wiki/.format"
expect_wiki "decisions: a wiki at format 3 without the count of unchecked rows fails" fail ".unchecked-decisions is missing in a wiki at format 3"

fresh_wiki 10
decisions
decision D1 90 >> "$tmp/wiki/decisions.md"
printf '2\n' > "$tmp/wiki/.format"
expect_wiki "decisions: a wiki at format 2 has no row checked" pass

# The marker of a wiki's format.
wiki_format="$root/plugin/skills/doctor/scripts/wiki-format.sh"
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
expect_format "format: the first mark says how many rows are not checked" mark 0 "the 2 rows already in"
check "format: the first mark writes the count of rows" test "$(cat "$tmp/wiki/.unchecked-decisions")" = 2
decision D3 61 >> "$tmp/wiki/decisions.md"
expect_format "format: after mark, a new long row fails the check" mark 1 "the decision of D3 has 61 words"

fresh_wiki 10
decisions
{ decision D1 10; decision D2 10; } >> "$tmp/wiki/decisions.md"
printf '1\n' > "$tmp/wiki/.unchecked-decisions"
expect_format "format: a later mark succeeds" mark 0 "as wiki format $product_format"
check "format: a later mark leaves the count of rows as it was" test "$(cat "$tmp/wiki/.unchecked-decisions")" = 1

fresh_wiki 10
expect_format "format: mark on a wiki without decisions.md succeeds" mark 0 "the 0 rows already in"

fresh_wiki 10
mkdir "$tmp/wiki/.unchecked-decisions"
expect_format "format: mark fails when the count of rows cannot be written" mark 1 "could not write"
check "format: no marker exists when the count of rows could not be written" absent "$tmp/wiki/.format"

fresh_wiki 10
decisions
{ decision D1 10; decision D2 90; } >> "$tmp/wiki/decisions.md"
printf '%s\n' "$product_format" > "$tmp/wiki/.format"
expect_format "format: mark does not count the rows again for a wiki already at the format" mark 1 ".unchecked-decisions is missing"
check "format: the count of rows is not written for a wiki already at the format" absent "$tmp/wiki/.unchecked-decisions"

fresh_wiki 10
printf '# Wiki\n\n## Where work stands\n\nNothing open.\n\n```text\n| Page | Content | Code it governs |\n```\n' > "$tmp/wiki/README.md"
expect_format "format: mark refuses a wiki whose only code column is inside a code block" mark 1 "has no column"

# The hook: the command the plugin runs at session start, for the project of
# the session.
hook=$(awk '/"SessionStart"/ { inside = 1 }
            /"(SessionEnd|Stop|PreToolUse|PostToolUse|UserPromptSubmit)"/ { inside = 0 }
            inside' "$root/plugin/hooks/hooks.json" |
  sed -n 's/.*"command": "\(sh .*wiki-format.sh.*\)".*/\1/p' | sed 's/\\"/"/g')
check "format: the plugin runs the notice at session start" test -n "$hook"

fresh_wiki 10
rm -rf "$tmp/my project"
mkdir -p "$tmp/my project/docs"
mv "$tmp/wiki" "$tmp/my project/docs/wiki"
out=$(CLAUDE_PLUGIN_ROOT="$root/plugin" CLAUDE_PROJECT_DIR="$tmp/my project" sh -c "$hook" 2>&1)
check "format: the hook gives the notice for the project of the session" sh -c 'printf "%s" "$1" | grep -q -F "has no format marker"' sh "$out"

printf '%s\n' "$product_format" > "$tmp/my project/docs/wiki/.format"
out=$(CLAUDE_PLUGIN_ROOT="$root/plugin" CLAUDE_PROJECT_DIR="$tmp/my project" sh -c "$hook" 2>&1); code=$?
check "format: the hook prints nothing and exits 0 for a wiki at the playbook's format" test -z "$out" -a "$code" -eq 0

out=$(CLAUDE_PLUGIN_ROOT="$root/plugin" sh -c 'unset CLAUDE_PROJECT_DIR; '"$hook" 2>&1); code=$?
check "format: the hook prints nothing and exits 0 when the session names no project" test -z "$out" -a "$code" -eq 0

# The skills an agent preloads.
fresh
check "skills: the review agent preloads the review skill" grep -q '^skills: review-change$' "$tmp/repo/plugin/agents/review.md"
expect "skills: an agent that preloads a skill of the plugin passes" pass

fresh
sed 's/^skills: .*/skills: playbook:review-change, keep-minimal/' "$tmp/repo/plugin/agents/review.md" > "$tmp/x" &&
  mv "$tmp/x" "$tmp/repo/plugin/agents/review.md"
expect "skills: several names, with or without the plugin's prefix, pass" pass

fresh
sed 's/^skills: .*/skills: review-changes/' "$tmp/repo/plugin/agents/review.md" > "$tmp/x" &&
  mv "$tmp/x" "$tmp/repo/plugin/agents/review.md"
expect "skills: a name that is not a skill of the plugin fails" fail "agents/review.md preloads the skill 'review-changes'"

fresh
mv "$tmp/repo/plugin/skills/review-change" "$tmp/repo/plugin/skills/review-diff"
expect "skills: renaming a skill that an agent preloads fails" fail "preloads the skill 'review-change'"

fresh
awk '/^skills: / { print "skills:"; print "  - no-such-skill"; next } { print }' "$tmp/repo/plugin/agents/review.md" > "$tmp/x" &&
  mv "$tmp/x" "$tmp/repo/plugin/agents/review.md"
expect "skills: names written as a list under the line fail" fail "has a skills line with no name on it"

fresh
expect "agents and skills together still pass" pass

if [ "$failed" -eq 0 ]; then
  printf 'all cases passed\n'
else
  printf '%s case(s) failed\n' "$failed"
  exit 1
fi
