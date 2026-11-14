#!/bin/sh
# Installs the product in opencode 2.x from this clone, with no copy:
# - two entries in opencode's global configuration file, opencode.json, that
#   name plugin/rules.md and plugin/skills in this clone;
# - a link from opencode's global agents folder to opencode/agents in this
#   clone.
# Usage: sh scripts/install-opencode.sh [opencode configuration directory]
# The directory defaults to $XDG_CONFIG_HOME/opencode, or ~/.config/opencode
# when that variable is not set, which is where opencode looks.
# It never changes a configuration file that already exists: it prints the two
# entries to add. It never replaces an agents folder that already exists.
# It cannot tell whether opencode reads a file it did not write, so it says
# "Installed" only for a file it wrote; scripts/verify.sh --opencode confirms.
# Exits 0 when nothing is left to do, 1 otherwise.
set -u

root=$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)
config=${1:-${XDG_CONFIG_HOME:-$HOME/.config}/opencode}
rules="$root/plugin/rules.md"
skills="$root/plugin/skills"
agents="$root/opencode/agents"
link="$config/agents"

changed=0
stop() {
  printf 'STOP %s\n' "$1"
  [ "$changed" -eq 1 ] || printf 'Nothing was changed.\n'
  exit 1
}

# Prints the configuration file this script writes.
wanted() {
  # $schema is a key of the file, not a variable of this script.
  # shellcheck disable=SC2016
  printf '{\n  "$schema": "https://opencode.ai/config.json",\n  "instructions": ["%s"],\n  "skills": ["%s"]\n}\n' \
    "$rules" "$skills"
}

# Succeeds when a file names both paths outside a comment line.
names_both() {
  grep -v '^[[:space:]]*//' "$1" | grep -q -F "\"$rules\"" &&
    grep -v '^[[:space:]]*//' "$1" | grep -q -F "\"$skills\""
}

# Everything is checked before anything is written.
[ -f "$rules" ] || stop "$rules is missing"
[ -d "$skills" ] || stop "$skills is missing"
[ -d "$agents" ] || stop "$agents is missing"
case $root in
  *'"'*|*\\*|*[[:cntrl:]]*)
    stop "the path of this clone holds a quote, a backslash, or a control character, which cannot be written into opencode.json" ;;
esac

if [ -L "$link" ]; then
  [ "$(CDPATH='' cd -- "$link" 2>/dev/null && pwd -P)" = "$(CDPATH='' cd -- "$agents" && pwd -P)" ] ||
    stop "$link is a link to $(readlink "$link"), which is not $agents"
  link_state=present
elif [ -e "$link" ]; then
  stop "$link exists and is not a link to $agents"
else
  link_state=missing
fi

# opencode reads opencode.json and opencode.jsonc; either one counts.
file=
for name in opencode.jsonc opencode.json; do
  [ -e "$config/$name" ] && file="$config/$name"
done

# What the last lines say: installed, unconfirmed, or todo.
state=installed

# The configuration file.
if [ -z "$file" ]; then
  made_config=0
  [ -d "$config" ] || made_config=1
  mkdir -p "$config" || stop "could not create $config"
  [ "$made_config" -eq 0 ] || changed=1
  if ! wanted > "$config/opencode.json"; then
    rm -f "$config/opencode.json"
    stop "could not write $config/opencode.json; the incomplete file was removed"
  fi
  changed=1
  printf 'wrote %s\n' "$config/opencode.json"
elif [ "$file" = "$config/opencode.json" ] && [ ! -e "$config/opencode.jsonc" ] &&
     [ "$(wanted)" = "$(cat "$file")" ]; then
  printf 'unchanged %s, which is the file this script writes\n' "$file"
elif names_both "$file"; then
  printf 'unchanged %s, which names the rules and the skills\n' "$file"
  state=unconfirmed
else
  printf 'TO DO %s exists and was not changed. Add these two entries to it by hand:\n' "$file"
  printf '  "instructions": ["%s"],\n  "skills": ["%s"]\n' "$rules" "$skills"
  printf 'When the file already has an "instructions" or a "skills" entry, add the path to its list.\n'
  state=todo
fi

# The link to the agents.
if [ "$link_state" = present ]; then
  printf 'unchanged %s, which already leads to %s\n' "$link" "$agents"
else
  ln -s "$agents" "$link" || stop "could not create the link $link"
  changed=1
  printf 'linked %s to %s\n' "$link" "$agents"
fi

check="sh '$root/scripts/verify.sh' --opencode"
case $state in
  installed)
    printf 'Installed. Run "opencode reload", then check with: %s\n' "$check" ;;
  unconfirmed)
    printf 'Not confirmed: this script did not write that file and cannot tell whether opencode reads the two entries.\n'
    printf 'Run "opencode reload", then check with: %s\n' "$check" ;;
  todo)
    printf 'Not complete: one step is left to do by hand, above.\n'
    exit 1 ;;
esac
