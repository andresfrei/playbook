#!/bin/sh
# Tests of plugins/playbook/scripts/startup-context.sh. Run from the repository root.
script=$PWD/plugins/playbook/scripts/startup-context.sh
tmp=$(mktemp -d) || exit 1
trap 'rm -rf "$tmp"' EXIT
failed=0

home=$tmp/home
proj=$home/work/app
plug=$tmp/plugin
mkdir -p "$proj/.claude/rules/sub" "$proj/.claude/skills/a" "$proj/.claude/skills/b" "$proj/.claude/agents" \
  "$home/.claude/rules" "$home/.claude/skills/u" "$home/.claude/agents" "$proj/docs/playbook" \
  "$plug/skills/p" "$plug/agents" "$home/.claude/plugins" "$tmp/other/skills/o" \
  "$home/.claude/projects/-home-work-app/memory"
# The folder name of the project's memory: every character that is not a letter
# or a digit becomes a dash, as the folders in ~/.claude/projects/ show.
mkdir -p "$home/.claude/projects/$(printf '%s' "$proj" | sed 's/[^A-Za-z0-9]/-/g')/memory"
mem=$home/.claude/projects/$(printf '%s' "$proj" | sed 's/[^A-Za-z0-9]/-/g')/memory/MEMORY.md

lines() { awk -v n="$1" 'BEGIN { for (i = 1; i <= n; i++) print "line " i }'; }

printf 'one\n@notes.md\n' > "$proj/CLAUDE.md"
lines 3 > "$proj/notes.md"
lines 201 > "$proj/CLAUDE.local.md"
lines 2 > "$proj/.claude/CLAUDE.md"
lines 4 > "$home/work/CLAUDE.md"
lines 5 > "$home/.claude/CLAUDE.md"
lines 6 > "$proj/.claude/rules/always.md"
printf -- '---\npaths:\n  - "src/**"\n---\nbody\n' > "$proj/.claude/rules/sub/scoped.md"
lines 7 > "$home/.claude/rules/mine.md"
lines 201 > "$mem"
printf '# rules\n' > "$plug/rules.md"
lines 3 > "$proj/docs/playbook/README.md"
printf '{"outputStyle": "Terse", "enabledPlugins": {"other@m": true, "off@m": false, "playbook@playbook": true}}\n' > "$home/.claude/settings.json"
printf -- '---\nname: a\ndescription: abcde\n---\n' > "$proj/.claude/skills/a/SKILL.md"
printf -- '---\nname: b\ndescription: hidden hidden\ndisable-model-invocation: true\n---\n' > "$proj/.claude/skills/b/SKILL.md"
printf -- '---\nname: x\ndescription: >\n  one\n  two\n---\n' > "$home/.claude/skills/u/SKILL.md"
printf -- '---\nname: g\ndescription: "12345678"\n---\n' > "$home/.claude/agents/g.md"
printf -- '---\nname: p\ndescription: ppp\n---\n' > "$plug/skills/p/SKILL.md"
printf -- '---\nname: q\ndescription: qq\n---\n' > "$plug/agents/q.md"
printf -- '---\nname: o\ndescription: oooo\n---\n' > "$tmp/other/skills/o/SKILL.md"
printf '{"plugins": {"other@m": [{"installPath": "%s"}]}}\n' "$tmp/other" > "$home/.claude/plugins/installed_plugins.json"

run() { HOME=$home CLAUDE_PLUGIN_ROOT=$plug CLAUDE_MANAGED_MD=$tmp/managed.md sh "$script" "$proj" 2>&1; }
out=$(run)
has() { # has <case> <fixed text in one row>
  if printf '%s\n' "$out" | grep -qF -- "$2"; then printf 'ok %s\n' "$1"
  else printf 'not ok %s: no row with %s\n%s\n' "$1" "$2" "$out"; failed=1; fi
}
hasnt() {
  if printf '%s\n' "$out" | grep -qF -- "$2"; then printf 'not ok %s: found %s\n' "$1" "$2"; failed=1
  else printf 'ok %s\n' "$1"; fi
}

has claude-md "| $proj/CLAUDE.md | project | startup | 2 | 14 | - |"
has import "| $proj/notes.md | project | startup | 3 |"
has local-over-200 "| $proj/CLAUDE.local.md | project | startup | 201 |"
has local-limit "over 200 lines per CLAUDE.md |"
has dot-claude "| $proj/.claude/CLAUDE.md | project | startup | 2 |"
has ancestor "| $home/work/CLAUDE.md | user | startup | 4 |"
has user-claude "| $home/.claude/CLAUDE.md | user | startup | 5 |"
has rule-no-paths "| $proj/.claude/rules/always.md | project | startup | 6 |"
has rule-paths "| $proj/.claude/rules/sub/scoped.md | project | on demand | 5 |"
has rule-user "| $home/.claude/rules/mine.md | user | startup | 7 |"
has memory "| $mem | project | startup | 201 |"
has memory-lines "over 200 lines of MEMORY.md |"
has rules-plugin "| $plug/rules.md | plugin | startup | 1 | 8 |"
has readme-budget "| $proj/docs/playbook/README.md | project | startup | 3 |"
has readme-within "within the hook budget of 8992 "
has output-style "output style: Terse ($home/.claude/settings.json) | user | startup"
has skills-project "project skills: 1 descriptions (characters in the bytes column) | project | startup | - | 5 |"
has skills-user "user skills: 1 descriptions (characters in the bytes column) | user | startup | - | 7 |"
has agents-user "user agents: 1 descriptions (characters in the bytes column) | user | startup | - | 8 |"
has skills-plugin "plugin skills: 2 descriptions (characters in the bytes column) | plugin | startup | - | 7 |"
has agents-plugin "plugin agents: 1 descriptions (characters in the bytes column) | plugin | startup | - | 2 |"
hasnt mcp "mcp"

# MEMORY.md over 25KB with few lines.
awk 'BEGIN { for (i = 1; i <= 30; i++) { s = ""; for (j = 0; j < 1000; j++) s = s "x"; print s } }' > "$mem"
out=$(run)
has memory-bytes "| $mem | project | startup | 30 |"
has memory-25kb "over 25KB of MEMORY.md |"

# The wiki README over the hook's budget.
awk 'BEGIN { for (i = 1; i <= 9000; i++) printf "x" }' > "$proj/docs/playbook/README.md"
out=$(run)
has readme-over "over the hook budget of 8992 "

# autoMemoryDirectory and the project's settings before the user's.
mkdir -p "$tmp/mem2"; lines 4 > "$tmp/mem2/MEMORY.md"
printf '{"autoMemoryDirectory": "%s", "outputStyle": "Loud"}\n' "$tmp/mem2" > "$proj/.claude/settings.local.json"
out=$(run)
has auto-memory-dir "| $tmp/mem2/MEMORY.md | project | startup | 4 |"
has style-project "output style: Loud ($proj/.claude/settings.local.json) | project | startup"

# The root can also be the current folder.
out=$(cd "$proj" && HOME=$home CLAUDE_PLUGIN_ROOT=$plug sh "$script" 2>&1)
has cwd-root "| $proj/CLAUDE.md | project | startup | 2 |"

# A later import of the parent resolves against the parent's folder.
mkdir -p "$proj/docs"; lines 2 > "$proj/docs/a.md"; lines 9 > "$proj/b.md"
printf 'one\n@docs/a.md\n@b.md\n' > "$proj/CLAUDE.md"
out=$(run)
has import-nested "| $proj/docs/a.md | project | startup | 2 |"
has import-after-nested "| $proj/b.md | project | startup | 9 |"

# Managed policy CLAUDE.md and claudeMdExcludes.
out=$(run)
hasnt managed-absent "| managed |"
lines 3 > "$tmp/managed.md"
printf '{"claudeMdExcludes": ["**/x/CLAUDE.md"]}\n' > "$proj/.claude/settings.json"
out=$(run)
has managed "| $tmp/managed.md | managed | startup | 3 |"
has excludes "| $proj/.claude/settings.json | - | claudeMdExcludes set | - | - | - |"
rm "$proj/.claude/settings.json"

# A symlinked rule without paths: loads at startup, and a circular link does not hang.
lines 4 > "$tmp/real-rule.md"; ln -s "$tmp/real-rule.md" "$proj/.claude/rules/linked.md"
ln -s "$proj/.claude/rules" "$proj/.claude/rules/loop"
out=$(run)
has rule-symlink "| $proj/.claude/rules/linked.md | project | startup | 4 |"
rm "$proj/.claude/rules/loop"

# The memory folder is the main repository's, from a worktree or a subfolder.
repo=$tmp/repo; mkdir -p "$repo/sub"
git -C "$repo" init -q . && git -C "$repo" -c user.name=t -c user.email=t@t commit -q --allow-empty -m init
git -C "$repo" worktree add -q "$tmp/wt" 2>/dev/null
repo=$(cd "$repo" && pwd -P)
rmem=$home/.claude/projects/$(printf '%s' "$repo" | sed 's/[^A-Za-z0-9]/-/g')/memory
mkdir -p "$rmem"; lines 5 > "$rmem/MEMORY.md"
out=$(HOME=$home CLAUDE_PLUGIN_ROOT=$plug CLAUDE_MANAGED_MD=$tmp/managed.md sh "$script" "$tmp/wt" 2>&1)
has memory-worktree "| $rmem/MEMORY.md | project | startup | 5 |"
out=$(HOME=$home CLAUDE_PLUGIN_ROOT=$plug CLAUDE_MANAGED_MD=$tmp/managed.md sh "$script" "$repo/sub" 2>&1)
has memory-subfolder "| $rmem/MEMORY.md | project | startup | 5 |"

# skillOverrides, and the synced skills apart from the user's.
us=$home/.claude/skills
mkdir -p "$us/ov-off" "$us/ov-inv" "$us/ov-name" "$us/ov-prec" "$us/synced/uuid1/hid" "$us/synced/uuid1/shown" "$us/synced/uuid1/bare"
for k in ov-off ov-inv ov-prec; do printf -- '---\nname: %s\ndescription: dddddddddd\n---\n' "$k" > "$us/$k/SKILL.md"; done
printf -- '---\nname: ov-name\ndescription: dddddddddd\n---\n' > "$us/ov-name/SKILL.md"
printf -- '---\nname: hid\ndescription: 1111\n---\n' > "$us/synced/uuid1/hid/SKILL.md"
printf -- '---\nname: shown\ndescription: 22222\n---\n' > "$us/synced/uuid1/shown/SKILL.md"
printf -- '---\nname: bare\ndescription: 333\n---\n' > "$us/synced/uuid1/bare/SKILL.md"
printf '{\n  "other": {"ov-off": "off"},\n  "skillOverrides": {\n    "ov-off": "off",\n    "ov-inv": "user-invocable-only",\n    "ov-name": "name-only",\n    "ov-prec": "off",\n    "anthropic-skills:hid": "user-invocable-only",\n    "bare": "off"\n  }\n}\n' > "$proj/.claude/settings.json"
rm -f "$proj/.claude/settings.local.json"
out=$(run)
# u (7) + ov-name (7, its name) + ov-prec is hidden by the project settings: 2 skills, 15 characters.
has ov-user-row "user skills: 2 descriptions (characters in the bytes column) | user | startup | - | 14 |"
has ov-sync-row "claude.ai sync skills: 1 descriptions (characters in the bytes column) | user | startup | - | 5 |"
# A project local setting before the project's: ov-prec is on again.
printf '{"skillOverrides": {"ov-prec": "on"}}\n' > "$proj/.claude/settings.local.json"
out=$(run)
has ov-precedence "user skills: 3 descriptions (characters in the bytes column) | user | startup | - | 24 |"
rm "$proj/.claude/settings.local.json" "$proj/.claude/settings.json"

exit $failed
