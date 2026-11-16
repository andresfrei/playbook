#!/bin/sh
# Tests for scripts/verify.sh, scripts/set-models.sh,
# scripts/install-opencode.sh, and the check of a project's wiki,
# plugin/skills/prepare-project/scripts/check-wiki.sh. Each case builds a copy
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
  cp -R "$root/.claude-plugin" "$root/plugin" "$root/opencode" "$tmp/repo/"
  mkdir "$tmp/repo/scripts"
  cp "$root/scripts/set-models.sh" "$root/scripts/install-opencode.sh" "$tmp/repo/scripts/"
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

# The agent files of opencode, generated into opencode/agents/.
fresh
printf 'edited by hand\n' >> "$tmp/repo/opencode/agents/explore.md"
expect_models "opencode: hand-edited generated file fails --check" fail "opencode/agents/explore.md differs"
sh "$root/scripts/set-models.sh" "$tmp/repo" >/dev/null 2>&1
expect_models "opencode: --check passes after the rewrite" pass ""

fresh
rm "$tmp/repo/opencode/agents/review.md"
expect_models "opencode: missing generated file fails --check" fail "opencode/agents/review.md is missing"

fresh
cp "$tmp/repo/opencode/agents/write.md" "$tmp/repo/opencode/agents/extra.md"
expect_models "opencode: generated file absent from the configuration fails" fail "opencode/agents/extra.md"

fresh
sed 's/Use it on a risky change/Use it on any change/' "$tmp/repo/plugin/agents/review.md" > "$tmp/x" &&
  mv "$tmp/x" "$tmp/repo/plugin/agents/review.md"
expect_models "opencode: changed source description fails --check" fail "opencode/agents/review.md differs"

fresh
sed 's/^explore .*/explore  haiku  medium  gpt-6-luna  medium/' "$tmp/repo/plugin/models.conf" > "$tmp/x" &&
  mv "$tmp/x" "$tmp/repo/plugin/models.conf"
expect_models "opencode: model without a provider is rejected" fail "gpt-6-luna"

fresh
sed 's/^explore .*/explore  haiku  medium  openai\/gpt-6-luna/' "$tmp/repo/plugin/models.conf" > "$tmp/x" &&
  mv "$tmp/x" "$tmp/repo/plugin/models.conf"
expect_models "opencode: missing variant is rejected" fail "variant"

fresh
sed 's/^explore .*/explore  haiku  medium  openai\/gpt-6-luna  medium  extra/' "$tmp/repo/plugin/models.conf" > "$tmp/x" &&
  mv "$tmp/x" "$tmp/repo/plugin/models.conf"
expect_models "opencode: a sixth field is rejected" fail "more than five fields"

fresh
sed 's/^review .*/review  opus  high  openai\/gpt-6-astra  xhigh/' "$tmp/repo/plugin/models.conf" > "$tmp/x" &&
  mv "$tmp/x" "$tmp/repo/plugin/models.conf"
sh "$root/scripts/set-models.sh" "$tmp/repo" >/dev/null 2>&1
if grep -q '^model: openai/gpt-6-astra#xhigh$' "$tmp/repo/opencode/agents/review.md" &&
   grep -q '^model: opus$' "$tmp/repo/plugin/agents/review.md"; then
  printf 'ok    opencode: a changed line is written to the generated file only\n'
else
  printf 'FAIL  opencode: a changed line is written to the generated file only\n'
  failed=$((failed + 1))
fi

fresh
if grep -q '^  - action: edit$' "$tmp/repo/opencode/agents/explore.md" &&
   grep -q '^  - action: edit$' "$tmp/repo/opencode/agents/review.md" &&
   ! grep -q '^permissions:' "$tmp/repo/opencode/agents/write.md"; then
  printf 'ok    opencode: edit is denied for the read-only agents only\n'
else
  printf 'FAIL  opencode: edit is denied for the read-only agents only\n'
  failed=$((failed + 1))
fi

fresh
sed 's/^description: .*/description: '"$(chars 251)"'/' "$tmp/repo/plugin/agents/write.md" > "$tmp/x" &&
  mv "$tmp/x" "$tmp/repo/plugin/agents/write.md"
expect "L3: agent description over 250 characters fails" fail "L3 description of agents/write.md"

fresh
printf -- '---\ndescription: Extra.\nmode: subagent\nmodel: openai/gpt-6-luna#medium\neffort: high\n---\nBody.\n' \
  > "$tmp/repo/opencode/agents/review.md"
expect "opencode: a field opencode does not allow fails" fail "has the field 'effort'"

# The installation in opencode, checked against a stand-in for the opencode
# command that prints what opencode 2.3.0 prints for each request.
# fake_opencode writes the stand-in and the three answers of a complete
# installation of the copy.
fake_opencode() {
  mkdir -p "$tmp/bin" "$tmp/fake"
  {
    printf '#!/bin/sh\n'
    # The stand-in expands these itself, so they stay unexpanded here.
    # shellcheck disable=SC2016
    printf 'case "$1 $2 ${3:-}" in\n'
    printf '  "debug agents "*) cat "%s/fake/agents.json" ;;\n' "$tmp"
    printf '  "api GET /api/config"*) cat "%s/fake/config.json" ;;\n' "$tmp"
    printf '  "api GET /api/skill"*) cat "%s/fake/skill.json" ;;\n' "$tmp"
    printf 'esac\n'
  } > "$tmp/bin/opencode"
  chmod +x "$tmp/bin/opencode"
  printf '[{"type":"directory","path":"%s"},{"type":"document","path":"%s","info":{"skills":["%s"],"instructions":["%s"]}}]\n' \
    "$tmp/config" "$tmp/config/opencode.json" "$tmp/repo/plugin/skills" "$tmp/repo/plugin/rules.md" \
    > "$tmp/fake/config.json"
  {
    printf '{"location":{"directory":"%s"},"data":[{"id":"opencode","path":"skill://opencode"}' "$tmp/repo"
    for skill in "$tmp/repo"/plugin/skills/*/SKILL.md; do
      printf ',{"id":"x","path":"%s"}' "$skill"
    done
    printf ']}\n'
  } > "$tmp/fake/skill.json"
  {
    printf '[\n  {\n    "id": "build",\n    "name": "Build",\n    "mode": "primary"\n  }'
    while read -r agent _ _ omodel ovariant _; do
      case $agent in ''|'#'*) continue ;; esac
      printf ',\n  {\n    "id": "%s",\n    "name": "%s",\n    "model": {\n      "id": "%s",\n      "providerID": "%s",\n      "variant": "%s"\n    },\n    "mode": "subagent"\n  }' \
        "$agent" "$agent" "${omodel#*/}" "${omodel%%/*}" "$ovariant"
    done < "$tmp/repo/plugin/models.conf"
    printf '\n]\n'
  } > "$tmp/fake/agents.json"
}

# expect_opencode <case name> <expected exit: pass|fail> <text the output must contain> [opencode command] [tries]
expect_opencode() {
  out=$(OPENCODE=${4:-$tmp/bin/opencode} OPENCODE_TRIES=${5:-1} sh "$root/scripts/verify.sh" --opencode "$tmp/repo" 2>&1)
  code=$?
  ok=1
  if [ "$2" = pass ] && [ "$code" -ne 0 ]; then ok=0; fi
  if [ "$2" = fail ] && [ "$code" -eq 0 ]; then ok=0; fi
  if [ -n "$3" ] && ! printf '%s' "$out" | grep -q "$3"; then ok=0; fi
  if [ "$ok" -eq 1 ]; then
    printf 'ok    %s\n' "$1"
  else
    printf 'FAIL  %s (exit %s)\n%s\n' "$1" "$code" "$out"
    failed=$((failed + 1))
  fi
}

fresh
fake_opencode
expect_opencode "opencode: a complete installation passes" pass "opencode loads the rules, the skills, and the agents"

fresh
fake_opencode
sed 's|"instructions":\[[^]]*\]|"instructions":["/moved/plugin/rules.md"]|' "$tmp/fake/config.json" > "$tmp/x" &&
  mv "$tmp/x" "$tmp/fake/config.json"
expect_opencode "opencode: a rules path outside this repository fails and is named" fail 'the entries are: "/moved/plugin/rules.md"'

fresh
fake_opencode
sed 's|"instructions":\[[^]]*\]|"instructions":[]|' "$tmp/fake/config.json" > "$tmp/x" &&
  mv "$tmp/x" "$tmp/fake/config.json"
expect_opencode "opencode: no instructions entry fails" fail "the entries are: none"

fresh
fake_opencode
sed 's|/plugin/skills/write-docs/SKILL.md|/elsewhere/write-docs/SKILL.md|' "$tmp/fake/skill.json" > "$tmp/x" &&
  mv "$tmp/x" "$tmp/fake/skill.json"
expect_opencode "opencode: a skill loaded from elsewhere fails" fail "skills/write-docs/SKILL.md is not loaded"

fresh
fake_opencode
sed 's/"variant": "high"/"variant": "low"/' "$tmp/fake/agents.json" > "$tmp/x" &&
  mv "$tmp/x" "$tmp/fake/agents.json"
expect_opencode "opencode: an agent with another variant fails" fail "the agent review is not loaded"

fresh
fake_opencode
: > "$tmp/fake/agents.json"
: > "$tmp/fake/config.json"
: > "$tmp/fake/skill.json"
expect_opencode "opencode: no answer skips the three checks and passes" pass "SKIP opencode did not list its agents"

# opencode answers with an empty list of skills the first time it is asked
# about a directory, and with the whole list afterwards.
fresh
fake_opencode
mv "$tmp/fake/skill.json" "$tmp/fake/skill-full.json"
printf '{"location":{"directory":"%s"},"data":[]}\n' "$tmp/repo" > "$tmp/fake/skill.json"
# The stand-in expands these itself, so they stay unexpanded here.
# shellcheck disable=SC2016
{
  printf '#!/bin/sh\n'
  printf '"%s/bin/opencode" "$@"\n' "$tmp"
  printf 'case "$2 ${3:-}" in "GET /api/skill"*) cp "%s/fake/skill-full.json" "%s/fake/skill.json" ;; esac\n' "$tmp" "$tmp"
} > "$tmp/bin/opencode-slow"
chmod +x "$tmp/bin/opencode-slow"
expect_opencode "opencode: an incomplete first answer is asked again" pass "verify passed" "$tmp/bin/opencode-slow" 2
printf '{"location":{"directory":"%s"},"data":[]}\n' "$tmp/repo" > "$tmp/fake/skill.json"
expect_opencode "opencode: an incomplete answer fails when it is asked once" fail "is not loaded" "$tmp/bin/opencode-slow" 1

fresh
expect_opencode "opencode: a missing command skips the check and the rest runs" pass "SKIP opencode is not installed" "$tmp/no-such-command"

fresh
out=$(OPENCODE="$tmp/no-such-command" sh "$root/scripts/verify.sh" "$tmp/repo" 2>&1)
case $out in
  *opencode*) printf 'FAIL  opencode: without --opencode nothing is asked of opencode\n%s\n' "$out"; failed=$((failed + 1)) ;;
  *) printf 'ok    opencode: without --opencode nothing is asked of opencode\n' ;;
esac

# The installer for opencode, run from the copy against a temporary directory
# in place of ~/.config/opencode. Every run also gets HOME and XDG_CONFIG_HOME
# inside the temporary directory, so that an installer that ignores its
# argument, or is given none, still cannot write in the real configuration.
install() {
  HOME="$tmp/userhome" XDG_CONFIG_HOME="$tmp/xdg" sh "$@"
}
# expect_install <case name> <expected exit: pass|fail> <text the output must contain>
expect_install() {
  out=$(install "$tmp/repo/scripts/install-opencode.sh" "$tmp/config" 2>&1)
  code=$?
  ok=1
  if [ "$2" = pass ] && [ "$code" -ne 0 ]; then ok=0; fi
  if [ "$2" = fail ] && [ "$code" -eq 0 ]; then ok=0; fi
  if [ -n "$3" ] && ! printf '%s' "$out" | grep -q "$3"; then ok=0; fi
  if [ "$ok" -eq 1 ]; then
    printf 'ok    %s\n' "$1"
  else
    printf 'FAIL  %s (exit %s)\n%s\n' "$1" "$code" "$out"
    failed=$((failed + 1))
  fi
}

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

installed() {
  grep -q -F "\"instructions\": [\"$tmp/repo/plugin/rules.md\"]" "$tmp/config/opencode.json" &&
    grep -q -F "\"skills\": [\"$tmp/repo/plugin/skills\"]" "$tmp/config/opencode.json" &&
    [ "$(readlink "$tmp/config/agents")" = "$tmp/repo/opencode/agents" ]
}
same_sum() { [ "$(cksum < "$1")" = "$2" ]; }
absent() { [ ! -e "$1" ] && [ ! -L "$1" ]; }

fresh
rm -rf "$tmp/config"
expect_install "install: an empty configuration directory is installed" pass "Installed"
check "install: the file names the rules and the skills, and the link points to the agents" installed
sum=$(cksum < "$tmp/config/opencode.json")
expect_install "install: a second run passes and says Installed" pass "Installed"
check "install: a second run changes nothing" same_sum "$tmp/config/opencode.json" "$sum"

fresh
rm -rf "$tmp/config"
mkdir -p "$tmp/config"
printf '{\n  "theme": "dark"\n}\n' > "$tmp/config/opencode.json"
sum=$(cksum < "$tmp/config/opencode.json")
expect_install "install: an existing configuration file is not changed and the entries are printed" fail "\"instructions\": \[\"$tmp/repo/plugin/rules.md\"\]"
check "install: the existing configuration file has the same checksum" same_sum "$tmp/config/opencode.json" "$sum"
printf '{\n  "theme": "dark",\n  "instructions": ["%s"],\n  "skills": ["/other", "%s"]\n}\n' \
  "$tmp/repo/plugin/rules.md" "$tmp/repo/plugin/skills" > "$tmp/config/opencode.json"
expect_install "install: a file with the entries added by hand passes as not confirmed" pass "Not confirmed"
printf '{\n  // "instructions": ["%s"],\n  // "skills": ["%s"]\n}\n' \
  "$tmp/repo/plugin/rules.md" "$tmp/repo/plugin/skills" > "$tmp/config/opencode.json"
expect_install "install: paths that are only in comment lines do not count" fail "TO DO"

fresh
rm -rf "$tmp/config"
mkdir -p "$tmp/config"
printf '{}\n' > "$tmp/config/opencode.jsonc"
expect_install "install: an existing opencode.jsonc counts as the configuration file" fail "opencode.jsonc exists"
check "install: no opencode.json is written next to an opencode.jsonc" absent "$tmp/config/opencode.json"

fresh
rm -rf "$tmp/config"
mkdir -p "$tmp/config/agents"
printf 'mine\n' > "$tmp/config/agents/own.md"
expect_install "install: an agents folder that is not the link stops it" fail "Nothing was changed"
check "install: nothing is written when it stops" absent "$tmp/config/opencode.json"
check "install: the agents folder is left as it was" test -f "$tmp/config/agents/own.md"

fresh
rm -rf "$tmp/config"
mkdir -p "$tmp/config" "$tmp/elsewhere"
ln -s "$tmp/elsewhere" "$tmp/config/agents"
expect_install "install: a link to another folder stops it" fail "Nothing was changed"
check "install: the link to another folder is left as it was" test "$(readlink "$tmp/config/agents")" = "$tmp/elsewhere"

fresh
rm -rf "$tmp/config"
mkdir -p "$tmp/config"
(cd "$tmp/config" && ln -s ../repo/opencode/agents agents)
expect_install "install: a link written another way that leads to the agents is accepted" pass "already leads to"

fresh
rm -rf "$tmp/config"
mkdir -p "$tmp/config"
ln -s "$tmp/no-such-folder" "$tmp/config/agents"
expect_install "install: a link that leads nowhere stops it" fail "Nothing was changed"

# A write that fails: the file size limit of the run is zero.
fresh
rm -rf "$tmp/config"
out=$( (trap '' XFSZ; ulimit -f 0; install "$tmp/repo/scripts/install-opencode.sh" "$tmp/config") 2>&1)
code=$?
if [ "$code" -ne 0 ] && absent "$tmp/config/opencode.json" && absent "$tmp/config/agents" &&
   ! printf '%s' "$out" | grep -q "Nothing was changed"; then
  printf 'ok    install: a failed write leaves no file and does not say nothing was changed\n'
else
  printf 'FAIL  install: a failed write leaves no file and does not say nothing was changed (exit %s)\n%s\n' "$code" "$out"
  failed=$((failed + 1))
fi

fresh
rm -rf "${tmp:?}/xdg" "${tmp:?}/userhome"
out=$(install "$tmp/repo/scripts/install-opencode.sh" 2>&1)
check "install: without an argument it follows XDG_CONFIG_HOME" test -f "$tmp/xdg/opencode/opencode.json"
check "install: with XDG_CONFIG_HOME set it writes nothing under the home directory" absent "$tmp/userhome"

rm -rf "${tmp:?}/xdg" "${tmp:?}/userhome"
out=$(HOME="$tmp/userhome" sh -c 'unset XDG_CONFIG_HOME; sh "$1"' sh "$tmp/repo/scripts/install-opencode.sh" 2>&1)
check "install: without the variable it uses .config/opencode under the home directory" test -f "$tmp/userhome/.config/opencode/opencode.json"

fresh
rm -rf "$tmp/config"
out=$(cd "$tmp/repo" && CDPATH=. install scripts/install-opencode.sh "$tmp/config" 2>&1)
check "install: CDPATH does not change the path of the clone" installed

rm -rf "$tmp/my clone" "$tmp/config"
mkdir -p "$tmp/my clone"
cp -R "$tmp/repo/plugin" "$tmp/repo/opencode" "$tmp/repo/scripts" "$tmp/my clone/"
out=$(install "$tmp/my clone/scripts/install-opencode.sh" "$tmp/config" 2>&1)
if printf '%s' "$out" | grep -q -F "sh '$tmp/my clone/scripts/verify.sh' --opencode" &&
   grep -q -F "\"$tmp/my clone/plugin/rules.md\"" "$tmp/config/opencode.json"; then
  printf 'ok    install: a clone path with a space is written whole and quoted in the command\n'
else
  printf 'FAIL  install: a clone path with a space is written whole and quoted in the command\n%s\n' "$out"
  failed=$((failed + 1))
fi

fresh
rm -rf "$tmp/config" "$tmp/repo/opencode"
expect_install "install: a clone without the generated agents stops it" fail "opencode/agents is missing"
check "install: no configuration directory is made when it stops" absent "$tmp/config"

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

fresh
expect "agents and skills together still pass" pass

if [ "$failed" -eq 0 ]; then
  printf 'all cases passed\n'
else
  printf '%s case(s) failed\n' "$failed"
  exit 1
fi
