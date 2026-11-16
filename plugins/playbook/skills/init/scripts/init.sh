#!/bin/sh
# The script of /playbook:init. It turns the plugins of this marketplace on
# with the `claude plugin` command. It writes no file of its own and no
# CLAUDE.md.
#
# Usage:
#   sh init.sh scan
#   sh init.sh skills <wiki|all>
#   sh init.sh apply <wiki|all> <local|user> [language]
#
# scan   Prints the product's plugins and whether they are on here, the other
#        plugins that are on here, and whether a global CLAUDE.md exists.
# skills Prints the name and description of the skills the choice turns on,
#        read from this marketplace's folder, and of the skills that are not
#        the product's: this repository's, the person's, and those of the
#        other plugins that are on here. It also prints where the format of a
#        wiki is.
# apply  wiki: installs playbook-wiki at the scope by name, and turns
#              playbook-agents off at the scope when it is on there.
#        all:  installs playbook-wiki and playbook-agents at the scope by name,
#              then saves the language as agents' userConfig "language"; an
#              empty or missing language clears it.
#        `claude plugin install` of a plugin already installed turns it on
#        and marks it as installed by name, not as a dependency.
#        Each claude command is printed with "+ " before it runs. Exits 1 at
#        the first command that fails, after printing its output.
# Exits 2 on bad arguments.
#
# `claude plugin list --json` reports, in each record, whether the plugin is
# on in the folder it runs in, not at the record's scope. The folder decides:
# the repository for scope local, and / for scope user, where no project's
# settings apply.

marketplace=playbook
wiki_id=playbook-wiki@$marketplace
agents_id=playbook-agents@$marketplace

usage() {
  cat >&2 <<'USAGE'
Usage: init.sh scan
       init.sh skills <wiki|all>
       init.sh apply <wiki|all> <local|user> [language]
USAGE
  exit 2
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
    { printf 'could not read claude plugin list --json\n' >&2; exit 1; }
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
  [ "$code" -eq 0 ] || exit 1
}

# Saves the language of playbook-agents, empty to clear it.
configure_language() {
  printf '+ printf %s | claude plugin configure %s --values-stdin\n' \
    "'{\"language\":\"$1\"}'" "$agents_id"
  out=$(printf '{"language":"%s"}\n' "$1" |
    claude plugin configure "$agents_id" --values-stdin 2>&1)
  code=$?
  [ -z "$out" ] || printf '%s\n' "$out"
  [ "$code" -eq 0 ] || exit 1
}

scan() {
  recs=$(list .) || exit 1
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
}

# skill_line <folder of a skill> <prefix> prints "  <prefix><name> — <description>"
# from the front matter of its SKILL.md, and " (off)" after the name when a
# settings file sets it off (see `offs`). A value written over several lines is
# joined; the folder's name stands for a missing name. Front matter with no
# closing "---" gives no name and no description.
skill_line() {
  [ -f "$1/SKILL.md" ] || return 0
  awk -v fallback="${1##*/}" -v prefix="$2" -v offs=" $off_names " '
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

skills() {
  case ${1:-} in wiki | all) ;; *) usage ;; esac
  json=$(claude plugin marketplace list --json) ||
    { printf 'could not read claude plugin marketplace list --json\n' >&2; exit 1; }
  location=$(printf '%s\n' "$json" | awk -v m="$marketplace" '
    /^    "name":/ { name = $0; sub(/^[^:]*: *"/, "", name); sub(/".*$/, "", name) }
    /^    "installLocation":/ && name == m {
      sub(/^[^:]*: *"/, ""); sub(/"[ ,]*$/, ""); print; exit
    }')
  if [ -z "$location" ]; then
    printf 'the marketplace %s is not added\n' "$marketplace" >&2
    exit 1
  fi
  off_names=$(off_names)
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
    { printf 'could not read claude plugin list --json\n' >&2; exit 1; }
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
}

apply() {
  what=$1
  scope=$2
  language=${3:-}
  case $what in wiki | all) ;; *) usage ;; esac
  case $scope in local | user) ;; *) usage ;; esac
  # The language goes into a JSON string and a command line.
  case $language in
    *\"* | *\\*) usage ;;
  esac
  [ "$(printf '%s' "$language" | tr -d '[:cntrl:]')" = "$language" ] || usage

  if [ "$what" = wiki ]; then
    folder=.
    [ "$scope" = user ] && folder=/
    recs=$(list "$folder") || exit 1
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
  scan) [ $# -eq 1 ] || usage; scan ;;
  skills) [ $# -eq 2 ] || usage; skills "$2" ;;
  apply) [ $# -ge 3 ] && [ $# -le 4 ] || usage; shift; apply "$@" ;;
  *) usage ;;
esac
