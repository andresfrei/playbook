#!/bin/sh
# The script of /playbook:init. It turns the plugins of this marketplace on
# with the `claude plugin` command. It writes no file of its own and no
# CLAUDE.md.
#
# Usage:
#   sh init.sh scan
#   sh init.sh skills <wiki|all>
#   sh init.sh apply <wiki|all> <local|user> [language]
#   sh init.sh keep <local|user> <skill>
#
# scan   Prints the product's plugins and whether they are on here, the other
#        plugins that are on here, whether a global CLAUDE.md exists, and
#        whether this repository has a wiki (setup-commands-6); when it has
#        none, where the steps that write a wiki's skeleton are.
# skills Prints the name and description of the skills the choice turns on,
#        read from this marketplace's folder, and of the skills that are not
#        the product's: this repository's, the person's, and those of the
#        other plugins that are on here. It marks " (off)" a skill a settings
#        file turns off, and " (kept)" a skill whose pair the person settled
#        with "Keep both" (setup-commands-8). It also prints where the format
#        and the skeleton of a wiki are.
# apply  wiki: installs playbook-wiki at the scope by name, and turns
#              playbook-agents off at the scope when it is on there.
#        all:  installs playbook-wiki and playbook-agents at the scope by name,
#              then saves the language as agents' userConfig "language"; an
#              empty or missing language clears it.
#        `claude plugin install` of a plugin already installed turns it on
#        and marks it as installed by name, not as a dependency.
#        Each claude command is printed with "+ " before it runs.
# keep   Adds the skill's name, as `skills` prints it, to "playbook" >
#        "keepBoth" in the settings file of the scope: local is
#        .claude/settings.local.json of the project, user is the person's
#        settings.json. Creates the file when missing, changes no other key,
#        and adds a name only once.
#
# Exit codes: 0 done; 1 a claude command failed, after printing its output;
# 2 bad arguments; 3 the marketplace playbook is not added, or for keep, the
# settings file is not a JSON object or its "playbook" or "keepBoth" has
# another type; 4 the plugins or marketplaces could not be read from claude,
# or a file could not be written. Messages go to standard error.
#
# `claude plugin list --json` reports, in each record, whether the plugin is
# on in the folder it runs in, not at the record's scope. The folder decides:
# the repository for scope local, and / for scope user, where no project's
# settings apply.

marketplace=playbook
wiki_id=playbook-wiki@$marketplace
agents_id=playbook-agents@$marketplace
# The project's folder, where the hooks of the product read it.
project=${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}
local_settings=$project/.claude/settings.local.json
user_settings=${CLAUDE_CONFIG_DIR:-$HOME/.claude}/settings.json

# The awk function that reads a JSON string: readstr(p) reads the string whose
# first character is at p in text, of length n, sets str to it decoded and pos
# to the position after the closing quote, and returns 0 when the text ends
# first. A copy of the one in playbook-agents' hook-lib.sh, since this plugin
# installs without it.
json_readstr='
function readstr(p,   out, c, d, hex) {
  out = ""
  while (p <= n) {
    c = substr(text, p, 1)
    if (c == "\"") { str = out; pos = p + 1; return 1 }
    if (c == "\\") {
      p++; d = substr(text, p, 1)
      if (d == "n") c = "\n"; else if (d == "t") c = "\t"; else if (d == "r") c = "\r"
      else if (d == "b" || d == "f") c = " "
      else if (d == "u") { p += 4; c = "?" }
      else c = d
    }
    out = out c
    p++
  }
  return 0
}'

# json_walk: the awk program that walks a JSON text, keeping the path of each
# value in key[1..depth], joined by path_at(); an element of an array has the
# key "#". For each value it calls value(at, first, last, type), with type
# "o", "a", "s" (str holds it), or "l". It sets bad when the text is not one
# JSON value, and kind[path] and open[path], the position of "{" or "[", for
# the first value at each path.
json_walk="$json_readstr"'
function path_at(d,   i, s) { s = ""; for (i = 1; i <= d; i++) s = s (i > 1 ? "/" : "") key[i]; return s }
function walk(   c, q, at, done, prev) {
  n = length(text); p = 1; depth = 0; done = 0; bad = 0; prev = ""
  while (p <= n) {
    c = substr(text, p, 1)
    if (c ~ /[ \t\n\r]/) { p++; continue }
    if (done) { bad = 1; return }
    if (c == ",") { if (prev != "value" || depth == 0) { bad = 1; return }; prev = "comma"; if (type[depth] == "o") expect[depth] = 1; p++; continue }
    if (c == ":") { prev = "colon"; p++; continue }
    if ((c == "}" || c == "]") && (prev == "comma" || prev == "colon")) { bad = 1; return }
    if (c != "}" && c != "]" && type[depth] == "a") empty[path_at(depth - 1)] = 0
    if (c == "{" || c == "[") {
      at = path_at(depth)
      if (!(at in kind)) { kind[at] = (c == "{" ? "o" : "a"); open[at] = p; empty[at] = 1 }
      else if (open[at] == "") open[at] = p
      depth++; type[depth] = (c == "{" ? "o" : "a"); expect[depth] = (c == "{"); key[depth] = (c == "{" ? "" : "#")
      prev = "open"; p++; continue
    }
    if (c == "}" || c == "]") {
      if (depth == 0 || type[depth] != (c == "}" ? "o" : "a")) { bad = 1; return }
      depth--; if (depth == 0) done = 1; prev = "value"; p++; continue
    }
    if (c == "\"") {
      q = p
      if (!readstr(p + 1)) { bad = 1; return }
      p = pos
      if (type[depth] == "o" && expect[depth]) { key[depth] = str; expect[depth] = 0; empty[path_at(depth - 1)] = 0; prev = "key"; continue }
      prev = "value"
      at = path_at(depth)
      if (!(at in kind)) kind[at] = "s"
      if (at == want) strings[++count] = str
      continue
    }
    while (p <= n && substr(text, p, 1) !~ /[,}\] \t\n\r]/) p++
    prev = "value"
    at = path_at(depth)
    if (!(at in kind)) kind[at] = "l"
  }
  if (depth != 0 || !done) bad = 1
}'

# json_strings <file> <path>: each string at that path of the JSON file, one
# per line, such as the elements of "playbook/keepBoth/#"; nothing when the
# file is missing or is not JSON.
json_strings() {
  [ -f "$1" ] || return 0
  awk -v want="$2" "$json_walk"'
    { text = text (NR > 1 ? "\n" : "") $0 }
    END { walk(); if (bad) exit; for (i = 1; i <= count; i++) print strings[i] }' "$1"
}

# json_add <file> <path of an array> <name>: prints the file with the name
# added at the start of that array, creating the objects and the array that
# are missing, and unchanged when the array holds it. Exits 3 when the text is
# not a JSON object or a part of the path has another type.
json_add() {
  awk -v want="$2/#" -v array="$2" -v val="$3" "$json_walk"'
    { text = text (NR > 1 ? "\n" : "") $0 }
    END {
      walk()
      if (bad || kind[""] != "o") exit 3
      for (i = 1; i <= count; i++) if (strings[i] == val) { print text; exit }
      if (array in kind) {
        if (kind[array] != "a") exit 3
        o = open[array]
        printf "%s\"%s\"%s%s\n", substr(text, 1, o), val, (empty[array] ? "" : ","), substr(text, o + 1)
        exit
      }
      k = split(array, part, "/")
      prefix = ""
      for (i = 1; i < k; i++) {
        next_prefix = prefix (i > 1 ? "/" : "") part[i]
        if (!(next_prefix in kind)) break
        if (kind[next_prefix] != "o") exit 3
        prefix = next_prefix
      }
      added = "\"" part[k] "\": [\"" val "\"]"
      for (j = k - 1; j >= i; j--) added = "\"" part[j] "\": {" added "}"
      o = open[prefix]
      printf "%s%s%s%s\n", substr(text, 1, o), added, (empty[prefix] ? "" : ","), substr(text, o + 1)
    }' "$1"
}

usage_text() {
  cat <<'USAGE'
Usage: init.sh scan
       init.sh skills <wiki|all>
       init.sh apply <wiki|all> <local|user> [language]
       init.sh keep <local|user> <skill>
       init.sh --help
Exit codes: 0 done; 1 a claude command failed; 2 bad arguments;
3 the marketplace playbook is not added, or a settings file is not as
expected; 4 claude could not be read, or a file could not be written.
USAGE
}

usage() {
  usage_text >&2
  exit 2
}

bad_language() {
  printf 'the language must not hold a quote, a backslash, or a control character\n' >&2
  usage
}

# records <json> prints one line per installed plugin and scope: id, scope,
# enabled (true or false, in the folder the list ran in), projectPath;
# separated by tabs. `claude plugin list --json` prints one field per line,
# and the fields of a record start with "id".
records() {
  printf '%s\n' "$1" | awk '
    function value(line) {
      sub(/^[^:]*: */, "", line)
      sub(/[ ,]*$/, "", line)
      sub(/^"/, "", line)
      sub(/"$/, "", line)
      return line
    }
    function flush() {
      if (id != "") printf "%s\t%s\t%s\t%s\n", id, scope, enabled, path
      id = ""; scope = ""; enabled = ""; path = ""
    }
    /^    "id":/ { flush(); id = value($0) }
    /^    "scope":/ { scope = value($0) }
    /^    "enabled":/ { enabled = value($0) }
    /^    "projectPath":/ { path = value($0) }
    END { flush() }
  '
}

# list <folder> prints the records, as `records` does, read in that folder.
list() {
  json=$(cd "$1" && claude plugin list --json) ||
    { printf 'could not read claude plugin list --json. Check that the claude command runs in this shell.\n' >&2; exit 4; }
  records "$json"
}

# is_on <records> <id> prints yes when a record of the plugin is enabled.
is_on() {
  printf '%s\n' "$1" | awk -F '\t' -v id="$2" '
    $1 == id && $3 == "true" { on = 1 }
    END { print on ? "yes" : "no" }'
}

# Runs a command, prints it with "+ " first and its output after, and exits 1
# when it fails.
run() {
  printf '+ %s\n' "$*"
  out=$("$@" 2>&1)
  code=$?
  [ -z "$out" ] || printf '%s\n' "$out"
  [ "$code" -eq 0 ] || { printf 'FAIL the command above exited %s. Repair what it printed, then run init.sh again.\n' "$code" >&2; exit 1; }
}

# Saves the language of playbook-agents, empty to clear it.
configure_language() {
  printf '+ printf %s | claude plugin configure %s --values-stdin\n' \
    "'{\"language\":\"$1\"}'" "$agents_id"
  out=$(printf '{"language":"%s"}\n' "$1" |
    claude plugin configure "$agents_id" --values-stdin 2>&1)
  code=$?
  [ -z "$out" ] || printf '%s\n' "$out"
  [ "$code" -eq 0 ] || { printf 'FAIL the command above exited %s. Repair what it printed, then run init.sh again.\n' "$code" >&2; exit 1; }
}

scan() {
  recs=$(list .) || exit $?
  printf 'Plugins of the playbook on this machine:\n'
  for id in "$wiki_id" "$agents_id"; do
    lines=$(printf '%s\n' "$recs" | awk -F '\t' -v id="$id" '$1 == id')
    if [ -z "$lines" ]; then
      printf '  %s: not installed\n' "$id"
      continue
    fi
    if [ "$(is_on "$recs" "$id")" = yes ]; then
      printf '  %s: on here\n' "$id"
    else
      printf '  %s: off here\n' "$id"
    fi
    printf '%s\n' "$lines" | awk -F '\t' '{
      printf "    installed at scope %s", $2
      if ($4 != "") printf " for %s", $4
      printf "\n"
    }'
  done
  printf 'Other plugins that are on here:\n'
  others=$(printf '%s\n' "$recs" | awk -F '\t' -v m="@$marketplace" '
    $3 == "true" && substr($1, length($1) - length(m) + 1) != m &&
      !seen[$1]++ { printf "  %s\n", $1 }')
  if [ -z "$others" ]; then printf '  none\n'; else printf '%s\n' "$others"; fi
  printf 'Global CLAUDE.md:\n'
  found=0
  configured=${CLAUDE_CONFIG_DIR:-$HOME/.claude}
  paths=$configured/CLAUDE.md
  # Claude Code reads the file in ~/.claude for a project under the home
  # folder even when CLAUDE_CONFIG_DIR points elsewhere.
  if [ "$configured" != "$HOME/.claude" ]; then
    paths="$paths
$HOME/.claude/CLAUDE.md"
  fi
  while IFS= read -r path; do
    if [ -f "$path" ]; then
      printf '  exists: %s\n' "$path"
      found=1
    fi
  done <<PATHS
$paths
PATHS
  [ "$found" -eq 1 ] || printf '  none\n'
  if [ -f "$project/docs/wiki/README.md" ]; then
    printf 'Wiki of this repository: %s/docs/wiki/README.md\n' "$project"
  else
    printf 'Wiki of this repository: missing\n'
    location=$(market_location 2>/dev/null) || location=
    [ -z "$location" ] ||
      printf 'The skeleton of a wiki: %s/plugins/playbook-wiki/skeleton.md\n' "$location"
  fi
}

# skill_line <folder of a skill> <prefix> prints "  <prefix><name> — <description>"
# from the front matter of its SKILL.md, and " (off)" after the name when a
# settings file sets it off (see `offs`). A value written over several lines is
# joined; the folder's name stands for a missing name. Front matter with no
# closing "---" gives no name and no description.
skill_line() {
  [ -f "$1/SKILL.md" ] || return 0
  awk -v fallback="${1##*/}" -v prefix="$2" -v offs=" $off_names " -v kept=" $kept_names " '
    function unquote(s) {
      if (s ~ /^".*"$/) return substr(s, 2, length(s) - 2)
      if (s ~ /^\047.*\047$/) { s = substr(s, 2, length(s) - 2); gsub(/\047\047/, "\047", s) }
      return s
    }
    function trim(s) { sub(/^[ \t]+/, "", s); sub(/[ \t]+$/, "", s); return s }
    { sub(/\r$/, "") }
    NR == 1 { if ($0 !~ /^---[ \t]*$/) exit; next }
    /^---[ \t]*$/ { closed = 1; exit }
    /^name:/ { name = $0; sub(/^name:/, "", name); key = "name"; next }
    /^description:/ {
      desc = trim(substr($0, 13)); key = "description"
      if (desc ~ /^[>|][-+]?$/) desc = ""
      next
    }
    /^[ \t]*$/ { next }
    /^[ \t]/ { if (key == "description") desc = desc (desc == "" ? "" : " ") trim($0); next }
    { key = "" }
    END {
      if (!closed) { name = ""; desc = "" }
      name = unquote(trim(name))
      if (name == "") name = fallback
      off = index(offs, " " name " ") ? " (off)" : ""
      if (index(kept, " " prefix name " ")) off = off " (kept)"
      printf "  %s%s%s — %s\n", prefix, name, off, unquote(trim(desc))
    }' "$1/SKILL.md"
}

# Prints the names set to "off" in the settings files that hold skillOverrides
# for this repository and for the person.
off_names() {
  for file in .claude/settings.local.json .claude/settings.json \
      "${CLAUDE_CONFIG_DIR:-$HOME/.claude}/settings.json"; do
    [ -f "$file" ] || continue
    sed -n 's/.*"\([^"]*\)"[ \t]*:[ \t]*"off".*/\1/p' "$file"
  done | tr '\n' ' '
}

# skills_in <folder of skills> <prefix> prints a line for each skill there, or
# "  none".
skills_in() {
  found=
  for dir in "$1"/*/; do
    [ -f "$dir/SKILL.md" ] || continue
    skill_line "${dir%/}" "$2"
    found=1
  done
  [ -n "$found" ] || printf '  none\n'
}

# market_location prints the folder of the marketplace playbook, or nothing
# when it is not added; exits 1 when the list cannot be read.
market_location() {
  json=$(claude plugin marketplace list --json) ||
    { printf 'could not read claude plugin marketplace list --json. Check that the claude command runs in this shell.\n' >&2; return 1; }
  printf '%s\n' "$json" | awk -v m="$marketplace" '
    /^    "name":/ { name = $0; sub(/^[^:]*: *"/, "", name); sub(/".*$/, "", name) }
    /^    "installLocation":/ && name == m {
      sub(/^[^:]*: *"/, ""); sub(/"[ ,]*$/, ""); print; exit
    }'
}

skills() {
  case ${1:-} in wiki | all) ;; *) usage ;; esac
  location=$(market_location) || exit 4
  if [ -z "$location" ]; then
    printf 'the marketplace %s is not added. Add it with claude plugin marketplace add, from GitHub or from a clone.\n' "$marketplace" >&2
    exit 3
  fi
  off_names=$(off_names)
  kept_names=$( { json_strings "$local_settings" playbook/keepBoth/#
                  json_strings "$user_settings" playbook/keepBoth/#; } | tr '\n' ' ')
  plugins=playbook-wiki
  [ "$1" = all ] && plugins="playbook-wiki playbook-agents"
  printf 'Skills the choice turns on:\n'
  for plugin in $plugins; do
    skills_in "$location/plugins/$plugin/skills" "$plugin:"
  done
  printf 'Skills of this repository (.claude/skills):\n'
  skills_in .claude/skills ""
  personal=${CLAUDE_CONFIG_DIR:-$HOME/.claude}/skills
  printf 'Skills of the person (%s):\n' "$personal"
  skills_in "$personal" ""
  printf 'Skills of the other plugins that are on here:\n'
  json=$(claude plugin list --json) ||
    { printf 'could not read claude plugin list --json. Check that the claude command runs in this shell.\n' >&2; exit 4; }
  folders=$(printf '%s\n' "$json" | awk -v m="@$marketplace" '
    function value(line) {
      sub(/^[^:]*: */, "", line); sub(/[ ,]*$/, "", line)
      sub(/^"/, "", line); sub(/"$/, "", line)
      return line
    }
    # A plugin of a directory marketplace is read from its folder; any other
    # from its copy, installPath.
    function flush() {
      if (folder == "") folder = copy
      if (id != "" && enabled == "true" && substr(id, length(id) - length(m) + 1) != m &&
          folder != "" && !seen[id]++) {
        name = id; sub(/@.*$/, "", name)
        printf "%s\t%s\n", name, folder
      }
      id = ""; enabled = ""; folder = ""; copy = ""
    }
    /^    "id":/ { flush(); id = value($0) }
    /^    "enabled":/ { enabled = value($0) }
    /^    "readFromFolder":/ { folder = value($0) }
    /^    "installPath":/ { copy = value($0) }
    END { flush() }')
  if [ -z "$folders" ]; then
    printf '  none\n'
  else
    printf '%s\n' "$folders" | while IFS='	' read -r name folder; do
      skills_in "$folder/skills" "$name:"
    done
  fi
  printf 'The format of a wiki: %s/plugins/playbook-wiki/format.md\n' "$location"
  printf 'The skeleton of a wiki: %s/plugins/playbook-wiki/skeleton.md\n' "$location"
}

keep() {
  case $1 in local) file=$local_settings ;; user) file=$user_settings ;; *) usage ;; esac
  case $2 in '' | *[!A-Za-z0-9_.:-]*) printf 'the skill must be a name as skills prints it: letters, digits, and _ . : -\n' >&2; usage ;; esac
  if [ ! -s "$file" ]; then
    { mkdir -p "$(dirname "$file")" && printf '{}\n' > "$file"; } ||
      { printf 'could not write %s\n' "$file" >&2; exit 4; }
  fi
  tmp=$(mktemp) || exit 4
  if ! json_add "$file" playbook/keepBoth "$2" > "$tmp"; then
    rm -f "$tmp"
    printf '%s is not a JSON object, or its "playbook" or "keepBoth" has another type. Repair it, then run init.sh again.\n' "$file" >&2
    exit 3
  fi
  cat "$tmp" > "$file" || { rm -f "$tmp"; printf 'could not write %s\n' "$file" >&2; exit 4; }
  rm -f "$tmp"
  printf '%s: %s kept beside the product\n' "$file" "$2"
}

apply() {
  what=$1
  scope=$2
  language=${3:-}
  case $what in wiki | all) ;; *) usage ;; esac
  case $scope in local | user) ;; *) usage ;; esac
  # The language goes into a JSON string and a command line.
  case $language in
    *\"* | *\\*) bad_language ;;
  esac
  [ "$(printf '%s' "$language" | tr -d '[:cntrl:]')" = "$language" ] || bad_language

  if [ "$what" = wiki ]; then
    folder=.
    [ "$scope" = user ] && folder=/
    recs=$(list "$folder") || exit $?
    agents_on=$(is_on "$recs" "$agents_id")
  fi

  # By name, even for the whole product: a dependency is pruned when the
  # plugin that needed it goes.
  run claude plugin install "$wiki_id" --scope "$scope"

  if [ "$what" = wiki ]; then
    [ "$agents_on" = no ] || run claude plugin disable "$agents_id" --scope "$scope"
    return
  fi

  run claude plugin install "$agents_id" --scope "$scope"
  configure_language "$language"
}

case ${1:-} in
  -h | --help) usage_text ;;
  scan) [ $# -eq 1 ] || usage; scan ;;
  skills) [ $# -eq 2 ] || usage; skills "$2" ;;
  apply) [ $# -ge 3 ] && [ $# -le 4 ] || usage; shift; apply "$@" ;;
  keep) [ $# -eq 3 ] || usage; keep "$2" "$3" ;;
  *) usage ;;
esac
