#!/bin/sh
# At the start of a session, tells the person and the agent when the local copy
# of the marketplace holds a newer version of this plugin than the one installed.
# It reads local files only: no network, and nothing is written. On any missing
# file or value it cannot read, it prints nothing and exits 0.
#
# Installed: "version" of ${CLAUDE_PLUGIN_ROOT}/.claude-plugin/plugin.json, where
# CLAUDE_PLUGIN_ROOT is <plugins>/cache/<marketplace>/<plugin>/<version>.
# Available: "version" of plugins/<plugin>/.claude-plugin/plugin.json in the
# marketplace's copy: <plugins>/marketplaces/<marketplace>, or, for a marketplace
# from a folder, the installLocation that <plugins>/known_marketplaces.json
# records for it.

root=${CLAUDE_PLUGIN_ROOT:-}
[ -n "$root" ] || exit 0

# The value of the first line of a manifest that holds a "version" key.
version_of() {
  sed -n 's/^.*"version"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$1" 2>/dev/null | head -n 1
}

plugin_dir=$(dirname "$root")
marketplace_dir=$(dirname "$plugin_dir")
cache=$(dirname "$marketplace_dir")
[ "$(basename "$cache")" = cache ] || exit 0
plugins=$(dirname "$cache")
marketplace=$(basename "$marketplace_dir")
plugin=$(basename "$plugin_dir")
case "$marketplace$plugin" in
  *[!A-Za-z0-9._-]*) exit 0 ;;
esac

copy="$plugins/marketplaces/$marketplace"
if [ ! -d "$copy" ]; then
  # The installLocation inside the object that follows the marketplace's key.
  copy=$(awk -v key="\"$marketplace\"" '
    { text = text $0 "\n" }
    END {
      # The key is the occurrence followed by a colon and an object, not a value.
      rest = text
      while ((start = index(rest, key)) > 0) {
        rest = substr(rest, start + length(key))
        if (match(rest, /^[ \t\n]*:[ \t\n]*\{/)) break
      }
      if (!start) exit
      rest = substr(rest, RLENGTH)
      depth = 0; quoted = 0; object = ""
      for (i = 1; i <= length(rest); i++) {
        c = substr(rest, i, 1)
        object = object c
        if (quoted) {
          if (c == "\\") { i++; object = object substr(rest, i, 1) }
          else if (c == "\"") quoted = 0
        } else if (c == "\"") quoted = 1
        else if (c == "{") depth++
        else if (c == "}") { depth--; if (depth == 0) break }
      }
      if (match(object, /"installLocation"[ \t\n]*:[ \t\n]*"[^"]*"/)) {
        value = substr(object, RSTART, RLENGTH)
        sub(/^"installLocation"[ \t\n]*:[ \t\n]*"/, "", value)
        sub(/"$/, "", value)
        print value
      }
    }' "$plugins/known_marketplaces.json" 2>/dev/null)
  [ -n "$copy" ] || exit 0
fi

installed=$(version_of "$root/.claude-plugin/plugin.json")
available=$(version_of "$copy/plugins/$plugin/.claude-plugin/plugin.json")

# Exits 0 when the second version is newer than the first; 1 otherwise, or when
# either is not three numbers.
awk -v a="$installed" -v b="$available" 'BEGIN {
  form = "^[0-9]+\\.[0-9]+\\.[0-9]+$"
  if (a !~ form || b !~ form) exit 1
  split(a, x, "."); split(b, y, ".")
  for (i = 1; i <= 3; i++) {
    if (y[i] + 0 > x[i] + 0) exit 0
    if (y[i] + 0 < x[i] + 0) exit 1
  }
  exit 1
}' || exit 0

printf '{"systemMessage":"The playbook is at %s, and %s is available. Update its plugins with /plugin or claude plugin update <plugin>@%s, then start a new session.","hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"The playbook installed is at %s, and the local copy of the marketplace %s holds %s; the person was told at the start of the session. Do not update a plugin unasked."}}\n' \
  "$installed" "$available" "$marketplace" "$installed" "$marketplace" "$available"
exit 0
