#!/bin/sh
# Checks the plugin against the limits and the format in
# docs/wiki/01-product/style-guide.md, and validates its manifests.
# Usage: sh scripts/verify.sh [--opencode] [repository root]
# With --opencode it also checks that opencode, started in the repository
# root, loads the rules, the skills, and the agents from this repository.
# Exits 0 when every check passes, 1 otherwise.
set -u

opencode_check=0
if [ "${1:-}" = "--opencode" ]; then
  opencode_check=1
  shift
fi
root=${1:-$(cd "$(dirname "$0")/.." && pwd)}
opencode=${OPENCODE:-opencode}
plugin="$root/plugin"

max_rules_words=500        # L1
max_skill_body_words=700   # L2
max_description_chars=250  # L3
max_startup_words=800      # L4

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
  for target in "$root" "$plugin"; do
    if ! output=$(claude plugin validate "$target" 2>&1); then
      fail "claude plugin validate $target"
      printf '%s\n' "$output"
    fi
  done
else
  fail "the claude command is not installed, so the manifests were not validated"
fi

# L1: the rules file.
startup_words=0
if [ -f "$plugin/rules.md" ]; then
  rules_words=$(count_words < "$plugin/rules.md")
  startup_words=$rules_words
  if [ "$rules_words" -gt "$max_rules_words" ]; then
    fail "L1 rules.md has $rules_words words, limit $max_rules_words"
  fi
else
  fail "L1 rules.md is missing"
fi

# L2 and L3: each skill.
for skill in "$plugin"/skills/*/SKILL.md; do
  [ -f "$skill" ] || continue
  name=${skill#"$plugin"/}

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
    *) startup_words=$((startup_words + $(printf '%s' "$description" | count_words))) ;;
  esac

  body_words=$(body "$skill" | count_words)
  if [ "$body_words" -gt "$max_skill_body_words" ]; then
    fail "L2 body of $name has $body_words words, limit $max_skill_body_words"
  fi
done

# Models: each agent file matches plugin/models.conf.
if ! output=$(sh "$root/scripts/set-models.sh" --check "$root" 2>&1); then
  fail "agent files differ from plugin/models.conf"
  printf '%s\n' "$output"
fi

# An agent of Claude Code may preload skills with a "skills" line: names on
# that line, separated by commas, each with or without the plugin's prefix. Claude Code
# gives no error for a name it does not find, and the agent then runs without
# that skill, so each name must be a skill of this plugin.
for agent in "$plugin"/agents/*.md; do
  [ -f "$agent" ] || continue
  if front_matter "$agent" | grep -q '^skills:[[:space:]]*$'; then
    fail "${agent#"$plugin"/} has a skills line with no name on it; write the names on that line, separated by commas"
  fi
  for skill in $(front_matter "$agent" | sed -n 's/^skills: *//p' | tr ',' ' '); do
    [ -f "$plugin/skills/${skill##*:}/SKILL.md" ] ||
      fail "${agent#"$plugin"/} preloads the skill '$skill', which is not in plugin/skills"
  done
done

# The agent files of opencode hold only the fields its schema allows. Their
# text is checked above: set-models.sh --check compares each with its source.
for agent in "$root"/opencode/agents/*.md; do
  [ -f "$agent" ] || continue
  for key in $(front_matter "$agent" | sed -n 's/^\([A-Za-z_][A-Za-z_-]*\):.*/\1/p'); do
    case $key in
      model|request|system|description|mode|hidden|color|steps|disabled|permissions) ;;
      *) fail "opencode/agents/$(basename "$agent") has the field '$key', which opencode does not allow" ;;
    esac
  done
done

# L3 and L4: each agent description. Both tools list agents at session start,
# and opencode reads the same rules and descriptions, so one count serves both.
for agent in "$plugin"/agents/*.md; do
  [ -f "$agent" ] || continue
  name=${agent#"$plugin"/}
  description=$(front_matter "$agent" | sed -n 's/^description: *//p' |
    sed 's/^"\(.*\)"$/\1/')
  description_chars=$(printf '%s' "$description" | count_chars)
  if [ "$description_chars" -gt "$max_description_chars" ]; then
    fail "L3 description of $name has $description_chars characters, limit $max_description_chars"
  fi
  startup_words=$((startup_words + $(printf '%s' "$description" | count_words)))
done

# L4: everything loaded at session start.
if [ "$startup_words" -gt "$max_startup_words" ]; then
  fail "L4 rules.md plus all descriptions have $startup_words words, limit $max_startup_words"
fi

# The installation in opencode: what opencode resolves when started in the
# repository root. It reads opencode's own answers and calls no model.

# Prints one line per problem, starting with FAIL, and one line per check that
# could not be done, starting with SKIP.
opencode_problems() {
  # The rules: an instructions entry of opencode's configuration names the file.
  config=$(cd "$root" && "$opencode" api GET "/api/config?location[directory]=$root" 2>/dev/null)
  case $config in
    '['*)
      entries=$(printf '%s' "$config" | grep -o '"instructions":\[[^]]*\]' |
        sed 's/^"instructions":\[//; s/\]$//' | tr '\n' ' ' | sed 's/^ *//; s/ *$//')
      case $entries in
        *"\"$plugin/rules.md\""*) ;;
        *) printf 'FAIL opencode: no instructions entry names %s; the entries are: %s\n' \
             "$plugin/rules.md" "${entries:-none}" ;;
      esac ;;
    *) printf 'SKIP opencode did not answer the configuration request, so the rules were not checked\n' ;;
  esac

  # The skills: opencode lists each one from this repository.
  skills=$(cd "$root" && "$opencode" api GET "/api/skill?location[directory]=$root" 2>/dev/null)
  case $skills in
    '{'*)
      for skill in "$plugin"/skills/*/SKILL.md; do
        [ -f "$skill" ] || continue
        printf '%s' "$skills" | grep -q -F "\"path\":\"$skill\"" ||
          printf 'FAIL opencode: the skill %s is not loaded from this repository\n' "${skill#"$plugin"/}"
      done ;;
    *) printf 'SKIP opencode did not answer the skills request, so the skills were not checked\n' ;;
  esac

  # The agents: opencode lists each one with the model of models.conf.
  agents=$(cd "$root" && "$opencode" debug agents 2>/dev/null | tr -d ' \n')
  case $agents in
    '['*)
      while read -r agent _ _ omodel ovariant _; do
        case $agent in ''|'#'*) continue ;; esac
        printf '%s' "$agents" | grep -q "\"id\":\"$agent\",\"name\":\"[^\"]*\",\"model\":{\"id\":\"${omodel#*/}\",\"providerID\":\"${omodel%%/*}\",\"variant\":\"$ovariant\"}" ||
          printf 'FAIL opencode: the agent %s is not loaded with the model %s#%s\n' "$agent" "$omodel" "$ovariant"
      done < "$plugin/models.conf" ;;
    *) printf 'SKIP opencode did not list its agents, so the agents were not checked\n' ;;
  esac
}

# opencode loads a directory it has not opened yet in the background, and its
# first answers can be incomplete, so a problem is asked again before it counts.
check_opencode() {
  if ! command -v "$opencode" >/dev/null 2>&1; then
    printf 'SKIP opencode is not installed, so its installation was not checked\n'
    return
  fi
  tries=${OPENCODE_TRIES:-5}
  while :; do
    problems=$(opencode_problems)
    tries=$((tries - 1))
    case $problems in *FAIL*) ;; *) break ;; esac
    [ "$tries" -gt 0 ] || break
    sleep 2
  done
  [ -n "$problems" ] ||
    printf 'opencode loads the rules, the skills, and the agents from this repository\n'
  while IFS= read -r line; do
    case $line in
      'FAIL '*) fail "${line#FAIL }" ;;
      ?*) printf '%s\n' "$line" ;;
    esac
  done <<EOF
$problems
EOF
}
[ "$opencode_check" -eq 0 ] || check_opencode

if [ "$failures" -gt 0 ]; then
  printf '%s check(s) failed\n' "$failures"
  exit 1
fi
printf 'verify passed: %s words loaded at session start, limit %s\n' \
  "$startup_words" "$max_startup_words"
