#!/bin/sh
# Lists what a person needs to compare before merging a ref into the current
# branch: the decisions each side added since they diverged, and the shared
# pages both sides changed. It interprets nothing.
# Usage: sh merge-step.sh <ref being merged> [repository directory, default .]
#        [ours, the branch merged into, default HEAD]
# A ref of "-" is the previous branch, @{-1}.
# Prints nothing and exits 0 when there is nothing to compare (no side added
# a decision the other could contradict, and no shared page changed on both
# sides), when the
# directory is not a repository with docs/wiki/, when the ref does not
# resolve, or when there is no merge base. Exits 2 on a usage error.
if [ $# -lt 1 ] || [ -z "$1" ]; then
  printf 'usage: sh merge-step.sh <ref being merged> [repository directory]\n' >&2
  exit 2
fi
ref=$1
dir=${2:-.}
ours=${3:-HEAD}

case $ref in -) ;; -*) exit 0 ;; esac
case $ours in -*) exit 0 ;; esac
[ -d "$dir" ] || exit 0
top=$(git -C "$dir" rev-parse --show-toplevel 2>/dev/null) || exit 0
[ -n "$top" ] && [ -d "$top/docs/wiki" ] || exit 0
git() { command git -C "$top" -c core.quotepath=off "$@"; }

ours_commit=$(git rev-parse --verify -q "$ours^{commit}" 2>/dev/null) || exit 0
if [ "$ref" = - ]; then
  theirs=$(git rev-parse --verify -q '@{-1}' 2>/dev/null) || exit 0
  ref=$(git rev-parse --abbrev-ref '@{-1}' 2>/dev/null) || ref='@{-1}'
else
  theirs=$(git rev-parse --verify -q "$ref^{commit}" 2>/dev/null) || exit 0
fi
base=$(git merge-base "$ours_commit" "$theirs" 2>/dev/null) || exit 0
[ -n "$base" ] || exit 0

# rows <from> <to>: one line per decision row added between two commits.
rows() {
  git diff --no-color --no-ext-diff --no-textconv --no-renames "$1" "$2" -- 'docs/wiki/works/*/decisions.md' docs/wiki/decisions.md 2>/dev/null |
    awk -F'|' '
      function trim(s) { gsub(/^[ \t]+|[ \t]+$/, "", s); return s }
      substr($0, 1, 2) != "+|" { next }
      {
        gsub(/\001/, ""); gsub(/\\\|/, "\001"); $0 = $0
        id = trim($2)
        if (id !~ /^([a-z0-9-]+-[0-9]+|D[0-9]+|TD[0-9]+)$/) next
        line = "- " id ": " trim($4)
        page = trim($7)
        gsub(/`/, "", page)
        if (page != "" && page != "none") line = line " (" page ")"
        gsub(/\001/, "|", line)
        print line
      }'
}

# shared <from> <to>: the shared pages changed between two commits.
shared() {
  git diff --no-color --no-ext-diff --no-textconv --no-renames --name-only "$1" "$2" -- docs/wiki 2>/dev/null |
    awk 'index($0, "docs/wiki/works/") != 1'
}

# show <heading> <lines>: a heading and its lines, or "- none".
show() {
  printf '%s\n' "$1"
  if [ -n "$2" ]; then printf '%s\n' "$2"; else printf -- '- none\n'; fi
}

ours_rows=$(rows "$base" "$ours_commit")
theirs_rows=$(rows "$base" "$theirs")
ours_pages=$(shared "$base" "$ours_commit")
theirs_pages=$(shared "$base" "$theirs")

both=
if [ -n "$ours_pages" ] && [ -n "$theirs_pages" ]; then
  while IFS= read -r page; do
    if printf '%s\n' "$theirs_pages" | grep -Fxq -- "$page"; then
      both="${both:+$both
}- $page"
    fi
  done <<EOF2
$ours_pages
EOF2
fi

# Two decisions can contradict only when each side brings one, or when both
# sides changed the same shared page.
{ [ -n "$ours_rows" ] && [ -n "$theirs_rows" ]; } || [ -n "$both" ] || exit 0

if [ "$ours" = HEAD ]; then
  branch=$(git symbolic-ref --short -q HEAD 2>/dev/null) || branch=HEAD
else
  branch=$ours
fi
show "Decisions that reached $branch since $ref started:" "$ours_rows"
printf '\n'
show "Decisions this merge brings:" "$theirs_rows"
printf '\n'
show "Shared pages both changed:" "$both"
printf '\n'
printf 'Read these decisions against each other with the person, and settle a contradiction with a new decision that names both.\n'
exit 0
