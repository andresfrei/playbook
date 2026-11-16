#!/bin/sh
# Writes the values of plugins/playbook-agents/models.conf into the model and effort lines of
# each plugins/playbook-agents/agents/<agent>.md.
# Usage: sh scripts/set-models.sh [--check] [repository root]
# With --check it changes nothing and exits 1 when an agent file differs from
# the configuration. Exits 0 otherwise.
set -u

check=0
if [ "${1:-}" = "--check" ]; then
  check=1
  shift
fi
root=${1:-$(cd "$(dirname "$0")/.." && pwd)}
conf="$root/plugins/playbook-agents/models.conf"
agents="$root/plugins/playbook-agents/agents"

failures=0
fail() {
  printf 'FAIL %s\n' "$1"
  failures=$((failures + 1))
}

# Prints the value of a front matter key of an agent file.
field() {
  awk -v key="$2" 'NR == 1 { if ($0 != "---") exit; next }
                   $0 == "---" { exit }
                   index($0, key ": ") == 1 { print substr($0, length(key) + 3) }' "$1"
}

# Rewrites the model and effort lines of an agent file.
write_file() {
  tmp=$(mktemp) || return 1
  awk -v model="$2" -v effort="$3" '
    NR == 1 && $0 == "---" { inside = 1; print; next }
    inside && $0 == "---" { print "model: " model; print "effort: " effort; inside = 0; print; next }
    inside && (index($0, "model: ") == 1 || index($0, "effort: ") == 1) { next }
    { print }' "$1" > "$tmp" && cat "$tmp" > "$1"
  status=$?
  rm -f "$tmp"
  return $status
}

if [ ! -f "$conf" ]; then
  fail "$conf is missing"
  exit 1
fi

configured=" "
while read -r agent model effort extra; do
  case $agent in ''|'#'*) continue ;; esac
  file="$agents/$agent.md"
  configured="$configured$agent "

  case $model in
    haiku|sonnet|opus|fable|inherit|claude-*) ;;
    *) fail "models.conf: model '$model' of $agent is not haiku, sonnet, opus, fable, inherit, or a claude- id"; continue ;;
  esac
  case $effort in
    low|medium|high|xhigh|max) ;;
    *) fail "models.conf: effort '$effort' of $agent is not low, medium, high, xhigh, or max"; continue ;;
  esac
  if [ -n "$extra" ]; then
    fail "models.conf: the line of $agent has more than three fields"
    continue
  fi
  if [ ! -f "$file" ]; then
    fail "plugins/playbook-agents/agents/$agent.md is missing, but models.conf configures $agent"
    continue
  fi

  if [ "$check" -eq 1 ]; then
    [ "$(field "$file" model)" = "$model" ] ||
      fail "plugins/playbook-agents/agents/$agent.md has model '$(field "$file" model)', models.conf says '$model'"
    [ "$(field "$file" effort)" = "$effort" ] ||
      fail "plugins/playbook-agents/agents/$agent.md has effort '$(field "$file" effort)', models.conf says '$effort'"
  else
    write_file "$file" "$model" "$effort" || fail "could not write plugins/playbook-agents/agents/$agent.md"
  fi
done < "$conf"

for file in "$agents"/*.md; do
  [ -f "$file" ] || continue
  name=$(basename "$file" .md)
  case $configured in
    *" $name "*) ;;
    *) fail "plugins/playbook-agents/agents/$name.md has no line in models.conf" ;;
  esac
done

[ "$failures" -eq 0 ] || exit 1
