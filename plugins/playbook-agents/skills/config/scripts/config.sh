#!/bin/sh
# The script of /playbook-agents:config (setup-commands-4, setup-commands-10).
# It shows and sets the model and the effort of the agents explore, write, and
# review, kept under "playbook" > "models" in Claude Code's settings files,
# where the hook agent-models.sh reads them.
#
# Usage:
#   sh config.sh show
#   sh config.sh set <local|user> <explore|write|review> <haiku|sonnet|opus|fable> [low|medium|high|xhigh|max]
#
# show  Prints one line per agent: the agent, its model, its effort, and where
#       they come from: "this repository" (.claude/settings.local.json of the
#       project), "every project" (the person's settings.json), or "plugin
#       default" (the agent's file). As in the hook, the first scope that holds
#       a value decides; a value that is not an alias and an effort is printed
#       as ignored, and the plugin default applies.
# set   Writes "<model> [effort]" for the agent in the settings file of the
#       scope: local is .claude/settings.local.json of the project, which is
#       $CLAUDE_PROJECT_DIR, or else the top of the git repository, or else the
#       current folder, kept out of git; user is the person's settings.json. Creates the file
#       when missing and changes no other key.
#
# Exit codes: 0 done; 2 bad arguments; 3 the settings file is not a JSON
# object, or "playbook" or "models" in it is not an object; 4 the file could
# not be written. Messages go to standard error.
set -u

here=$(cd "$(dirname "$0")" && pwd)
plugin=$(cd "$here/../../.." && pwd)
lib="$plugin/hooks/hook-lib.sh"
[ -f "$lib" ] || { printf 'hook-lib.sh is missing from %s/hooks. Reinstall playbook-agents.\n' "$plugin" >&2; exit 4; }
# json_readstr and json_path come from the sourced file.
# shellcheck source=/dev/null disable=SC2154
. "$lib"

# The repository's file is read where the hook reads it.
project=${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}
local_file=$project/.claude/settings.local.json
user_file=${CLAUDE_CONFIG_DIR:-$HOME/.claude}/settings.json
agents="explore write review"

usage() {
  sed -n '7,9p' "$0" | sed 's/^# //' >&2
  exit 2
}

# valid <value>: succeeds when the value is an alias and, optionally, an effort.
valid() {
  set -f
  # shellcheck disable=SC2086
  set -- $1
  set +f
  [ $# -ge 1 ] && [ $# -le 2 ] || return 1
  case $1 in haiku|sonnet|opus|fable) ;; *) return 1 ;; esac
  case ${2:-} in ''|low|medium|high|xhigh|max) ;; *) return 1 ;; esac
}

# front <agent> <key>: the value of a key of the agent file's front matter.
front() {
  awk -v key="$2" 'NR == 1 { if ($0 != "---") exit; next }
                   $0 == "---" { exit }
                   index($0, key ": ") == 1 { print substr($0, length(key) + 3) }' "$plugin/agents/$1.md"
}

show() {
  for agent in $agents; do
    model=$(front "$agent" model)
    effort=$(front "$agent" effort)
    source="plugin default"
    note=
    for scope in local user; do
      if [ "$scope" = local ]; then file=$local_file; name="this repository"; else file=$user_file; name="every project"; fi
      value=$(json_path "$file" "playbook/models/$agent")
      [ -n "$value" ] || continue
      if valid "$value"; then
        set -f
        # shellcheck disable=SC2086
        set -- $value
        set +f
        model=$1
        [ -n "${2:-}" ] && effort=$2
        source=$name
      else
        note="; ignored in $name: \"$value\""
      fi
      break
    done
    printf '%s\t%s\t%s\t%s%s\n' "$agent" "$model" "$effort" "$source" "$note"
  done
  [ -z "${CLAUDE_CODE_EFFORT_LEVEL:-}" ] ||
    printf 'CLAUDE_CODE_EFFORT_LEVEL is set to %s and overrides every effort above.\n' "$CLAUDE_CODE_EFFORT_LEVEL"
}

# json_set <file> <path> <value>: prints the file with the string at that path,
# whose keys are joined with "/", set to the value: replaced when it exists,
# otherwise added at the start of the deepest object of the path that exists,
# with the objects missing below it. Exits 3 when the text is not a JSON
# object or a part of the path holds something other than an object.
# shellcheck disable=SC2154
json_set() {
  awk -v want="$2" -v val="$3" "$json_readstr"'
    function path_at(d,   i, s) { s = ""; for (i = 1; i <= d; i++) s = s (i > 1 ? "/" : "") key[i]; return s }
    { text = text (NR > 1 ? "\n" : "") $0 }
    END {
      n = length(text); p = 1; depth = 0; done = 0
      while (p <= n) {
        c = substr(text, p, 1)
        if (c ~ /[ \t\n\r]/) { p++; continue }
        if (done) exit 3
        if (c == ",") { if (type[depth] == "o") expect[depth] = 1; p++; continue }
        if (c == ":") { p++; continue }
        if (c == "{" || c == "[") {
          at = path_at(depth)
          if (!(at in kind)) kind[at] = (c == "{" ? "o" : "a")
          if (c == "{") { open[at] = p; empty[at] = 1 }
          depth++; type[depth] = (c == "{" ? "o" : "a"); expect[depth] = (c == "{"); key[depth] = (c == "{" ? "" : "#")
          p++; continue
        }
        if (c == "}" || c == "]") { depth--; if (depth < 0) exit 3; if (depth == 0) done = 1; p++; continue }
        if (c == "\"") {
          q = p
          if (!readstr(p + 1)) exit 3
          p = pos
          if (type[depth] == "o" && expect[depth]) { key[depth] = str; expect[depth] = 0; empty[path_at(depth - 1)] = 0; continue }
          at = path_at(depth)
          if (!(at in kind)) kind[at] = "s"
          if (at == want && !found) { found = 1; from = q; to = p }
          continue
        }
        q = p
        while (p <= n && substr(text, p, 1) !~ /[,}\] \t\n\r]/) p++
        at = path_at(depth)
        if (!(at in kind)) kind[at] = "l"
      }
      if (kind[""] != "o" || depth != 0) exit 3
      if (found) { printf "%s\"%s\"%s\n", substr(text, 1, from - 1), val, substr(text, to); exit }
      if (want in kind) exit 3
      k = split(want, part, "/")
      prefix = ""
      for (i = 1; i < k; i++) {
        next_prefix = prefix (i > 1 ? "/" : "") part[i]
        if (!(next_prefix in kind)) break
        if (kind[next_prefix] != "o") exit 3
        prefix = next_prefix
      }
      added = "\"" part[k] "\": \"" val "\""
      for (j = k - 1; j >= i; j--) added = "\"" part[j] "\": {" added "}"
      o = open[prefix]
      printf "%s%s%s%s\n", substr(text, 1, o), added, (empty[prefix] ? "" : ","), substr(text, o + 1)
    }' "$1"
}

set_value() {
  [ $# -ge 3 ] && [ $# -le 4 ] || usage
  case $1 in local) file=$local_file ;; user) file=$user_file ;; *) usage ;; esac
  case " $agents " in *" $2 "*) ;; *) usage ;; esac
  value=$3${4:+ $4}
  valid "$value" || { printf 'The model must be haiku, sonnet, opus, or fable, and the effort low, medium, high, xhigh, or max.\n' >&2; exit 2; }

  if [ ! -s "$file" ]; then
    mkdir -p "$(dirname "$file")" || exit 4
    printf '{}\n' > "$file" || { printf 'Could not write %s.\n' "$file" >&2; exit 4; }
  fi
  tmp=$(mktemp) || exit 4
  json_set "$file" "playbook/models/$2" "$value" > "$tmp"
  status=$?
  if [ "$status" -ne 0 ]; then
    rm -f "$tmp"
    printf '%s is not a JSON object, or its "playbook" or "models" is not an object. Repair it, then run again.\n' "$file" >&2
    exit 3
  fi
  cat "$tmp" > "$file" || { rm -f "$tmp"; printf 'Could not write %s.\n' "$file" >&2; exit 4; }
  rm -f "$tmp"
  printf '%s: %s set to "%s"\n' "$file" "$2" "$value"
}

case ${1:-} in
  show) [ $# -eq 1 ] || usage; show ;;
  set) shift; set_value "$@" ;;
  --help) usage ;;
  *) usage ;;
esac
