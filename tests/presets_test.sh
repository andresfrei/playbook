#!/bin/sh
# Tests of plugins/playbook/scripts/presets.sh. Run from the repository root.
script=$PWD/plugins/playbook/scripts/presets.sh
tmp=$(mktemp -d) || exit 1
trap 'rm -rf "$tmp"' EXIT
failed=0
PLAYBOOK_HOME=$tmp/home
export PLAYBOOK_HOME

ok() { printf 'ok   %s\n' "$1"; }
bad() { printf 'FAIL %s\n' "$1"; failed=1; }
check() { if jq -e "$3" "$2" >/dev/null 2>&1; then ok "$1"; else bad "$1"; fi; }
# snap DIR: names and checksums of everything under DIR.
snap() { (cd "$1" 2>/dev/null && find . | sort && find . -type f -exec cksum {} + | sort); }
# refused NAME ARGS...: exits non-zero, prints on stderr, PLAYBOOK_HOME and the
# folder in $watch (when set) unchanged.
watch=
refused() {
  name=$1; shift
  before=$(snap "$PLAYBOOK_HOME"; [ -z "$watch" ] || snap "$watch")
  if sh "$script" "$@" 2>"$tmp/err"; then bad "$name (exit 0)"; return; fi
  after=$(snap "$PLAYBOOK_HOME"; [ -z "$watch" ] || snap "$watch")
  if [ -s "$tmp/err" ] && [ "$before" = "$after" ]; then ok "$name"; else bad "$name"; fi
}

# Source project with a skill, an agent, and two signal files.
src=$tmp/src
mkdir -p "$src/.claude/skills/deploy/sub" "$src/.claude/agents"
printf 'name: deploy\n' > "$src/.claude/skills/deploy/SKILL.md"
printf 'x\n' > "$src/.claude/skills/deploy/sub/a.txt"
printf 'agent\n' > "$src/.claude/agents/cf.md"
: > "$src/wrangler.toml"
mkdir "$src/functions"

sh "$script" save cloudflare "$src" signal wrangler.toml signal wrangler.toml \
  allow 'Bash(wrangler deploy)' allow 'Bash(echo "a b")' allow 'Bash(wrangler deploy)' \
  ask 'Bash(wrangler delete *)' deny 'Read(.dev.vars)' skill deploy agent cf || bad "save runs"
p=$PLAYBOOK_HOME/presets/cloudflare
if [ "$(cat "$p/signals")" = "wrangler.toml" ]; then ok "save writes signals deduped"; else bad "save writes signals deduped"; fi
check "save writes rules" "$p/rules.json" '. == {"allow":["Bash(wrangler deploy)","Bash(echo \"a b\")"],"ask":["Bash(wrangler delete *)"],"deny":["Read(.dev.vars)"]}'
if diff -r "$src/.claude/skills/deploy" "$p/skills/deploy" >/dev/null && cmp -s "$src/.claude/agents/cf.md" "$p/agents/cf.md"; then ok "save copies skill and agent"; else bad "save copies skill and agent"; fi

# Save refusals leave nothing.
refused "existing name refused" save cloudflare "$src" signal wrangler.toml
refused "missing signal file refused" save other "$src" signal nope.toml
refused "missing skill refused" save other "$src" signal wrangler.toml skill ghost
refused "missing agent refused" save other "$src" signal wrangler.toml agent ghost
refused "no signal refused" save other "$src" allow X
refused "bad name refused" save .hidden "$src" signal wrangler.toml
refused "bad name with slash refused" save a/b "$src" signal wrangler.toml
refused "unknown keyword refused" save other "$src" signal wrangler.toml bogus X
refused "unknown command refused" remove cloudflare
refused "missing args refused" apply

# Detect: a second preset needs two signals.
sh "$script" save both "$src" signal wrangler.toml signal functions || bad "save second preset"
mkdir -p "$tmp/pboth/functions" "$tmp/pone" "$tmp/pnone"
: > "$tmp/pboth/wrangler.toml"
: > "$tmp/pone/wrangler.toml"
if [ "$(sh "$script" detect "$tmp/pboth")" = "$(printf 'both\ncloudflare')" ]; then ok "detect lists both"; else bad "detect lists both"; fi
if [ "$(sh "$script" detect "$tmp/pone")" = "cloudflare" ]; then ok "detect lists only the matching one"; else bad "detect lists only the matching one"; fi
if [ -z "$(sh "$script" detect "$tmp/pnone")" ]; then ok "detect lists none"; else bad "detect lists none"; fi
mkdir -p "$PLAYBOOK_HOME/presets/empty"
: > "$PLAYBOOK_HOME/presets/empty/signals"
if [ "$(sh "$script" detect "$tmp/pnone")" = "" ]; then ok "empty signals never listed"; else bad "empty signals never listed"; fi
rm -rf "$PLAYBOOK_HOME/presets/empty"
out=$(PLAYBOOK_HOME=$tmp/nohome sh "$script" detect "$tmp/pone"; echo "rc=$?")
if [ "$out" = "rc=0" ]; then ok "detect without presets dir prints nothing"; else bad "detect without presets dir prints nothing"; fi

# Apply.
dst=$tmp/dst
mkdir -p "$dst/.claude"
printf '{"outputStyle":"x","permissions":{"allow":["Old"]}}' > "$dst/.claude/settings.json"
sh "$script" apply cloudflare "$dst" || bad "apply runs"
phys=$(cd "$dst" && pwd -P)
check "apply adds rules, keeps others" "$dst/.claude/settings.json" \
  '.outputStyle == "x" and .permissions.allow == ["Old","Bash(wrangler deploy)","Bash(echo \"a b\")"] and .permissions.ask == ["Bash(wrangler delete *)"] and .permissions.deny == ["Read(.dev.vars)"]'
if diff -r "$p/skills/deploy" "$dst/.claude/skills/deploy" >/dev/null && cmp -s "$p/agents/cf.md" "$dst/.claude/agents/cf.md"; then ok "apply copies skill and agent"; else bad "apply copies skill and agent"; fi
check "apply records the project" "$PLAYBOOK_HOME/registry.json" ". == {\"$phys\":[\"cloudflare\"]}"

# A second apply changes nothing.
before=$(snap "$dst"; snap "$PLAYBOOK_HOME")
sh "$script" apply cloudflare "$dst" || bad "second apply runs"
after=$(snap "$dst"; snap "$PLAYBOOK_HOME")
if [ "$before" = "$after" ]; then ok "second apply changes nothing"; else bad "second apply changes nothing"; fi
check "registry keeps one entry" "$PLAYBOOK_HOME/registry.json" ".[\"$phys\"] == [\"cloudflare\"]"

# A differing skill or agent is a conflict; nothing is written.
dst2=$tmp/dst2
mkdir -p "$dst2/.claude/skills/deploy" "$dst2/.claude/agents"
printf 'mine\n' > "$dst2/.claude/skills/deploy/SKILL.md"
printf 'mine\n' > "$dst2/.claude/agents/cf.md"
before=$(snap "$dst2"; snap "$PLAYBOOK_HOME")
if sh "$script" apply cloudflare "$dst2" 2>"$tmp/err"; then bad "conflict refused (exit 0)"; else
  after=$(snap "$dst2"; snap "$PLAYBOOK_HOME")
  if [ "$before" = "$after" ] && grep -q 'skill:deploy' "$tmp/err" && grep -q 'agent:cf' "$tmp/err" && [ ! -e "$dst2/.claude/settings.json" ]; then ok "conflict refused, nothing written, both named"; else bad "conflict refused, nothing written, both named"; fi
fi
# Overwrite of only the skill still leaves the agent as a conflict.
before=$(snap "$dst2")
if sh "$script" apply cloudflare "$dst2" overwrite skill:deploy 2>/dev/null; then bad "partial overwrite refused (exit 0)"; elif [ "$before" = "$(snap "$dst2")" ]; then ok "partial overwrite refused, nothing written"; else bad "partial overwrite refused, nothing written"; fi
sh "$script" apply cloudflare "$dst2" overwrite skill:deploy overwrite agent:cf || bad "overwrite apply runs"
if diff -r "$p/skills/deploy" "$dst2/.claude/skills/deploy" >/dev/null && cmp -s "$p/agents/cf.md" "$dst2/.claude/agents/cf.md"; then ok "overwrite replaces skill and agent"; else bad "overwrite replaces skill and agent"; fi
check "overwrite apply wrote rules" "$dst2/.claude/settings.json" '.permissions.deny == ["Read(.dev.vars)"]'

# Overwrite replaces the skill entirely (extra files go).
dst3=$tmp/dst3
mkdir -p "$dst3/.claude/skills/deploy"
printf 'old\n' > "$dst3/.claude/skills/deploy/extra.txt"
sh "$script" apply cloudflare "$dst3" overwrite skill:deploy || bad "overwrite entirely runs"
if [ ! -e "$dst3/.claude/skills/deploy/extra.txt" ] && diff -r "$p/skills/deploy" "$dst3/.claude/skills/deploy" >/dev/null; then ok "overwrite replaces the skill entirely"; else bad "overwrite replaces the skill entirely"; fi

# The physical path is recorded for '..' and symlinks.
mkdir -p "$tmp/real/proj" "$tmp/real/other"
ln -s "$tmp/real/proj" "$tmp/link"
rphys=$(cd "$tmp/real/proj" && pwd -P)
sh "$script" apply cloudflare "$tmp/real/other/../proj" || bad "apply with .. runs"
sh "$script" apply both "$tmp/link" || bad "apply via symlink runs"
check "'..' and symlink record the physical path" "$PLAYBOOK_HOME/registry.json" ".[\"$rphys\"] == [\"cloudflare\",\"both\"]"

# Apply refusals.
watch=$dst
refused "unknown preset refused" apply ghost "$dst"
refused "bad overwrite item refused" apply cloudflare "$dst" overwrite nonsense
watch=
refused "missing project refused" apply cloudflare "$tmp/none"

# No temporary leftovers in the project after successful applies.
for d in "$dst" "$dst2" "$dst3"; do
  if [ "$(ls -A "$d/.claude/skills")" = "deploy" ] && [ "$(ls -A "$d/.claude/agents" 2>/dev/null)" != "" ] && [ -z "$(find "$d/.claude" -name '.presets-tmp*')" ]; then ok "no temporary leftovers in $(basename "$d")"; else bad "no temporary leftovers in $(basename "$d")"; fi
done

# Preconditions: each refuses and leaves the project and PLAYBOOK_HOME untouched.
sh "$script" save rw "$src" signal wrangler.toml allow 'Bash(a)' deny 'Bash(b)' || bad "save rw"
pf=$tmp/pf1
mkdir -p "$pf/.claude"
printf '{"permissions":{"allow":[],"deny":"x"}}' > "$pf/.claude/settings.json"
watch=$pf
refused "deny not an array refused" apply rw "$pf"
printf '{"permissions":"x"}' > "$pf/.claude/settings.json"
refused "permissions not an object refused" apply rw "$pf"
printf '{broken' > "$pf/.claude/settings.json"
refused "broken settings refused" apply rw "$pf"
pf=$tmp/pf2
mkdir -p "$pf/.claude"
printf 'x' > "$pf/.claude/skills"
watch=$pf
refused "skills as a file refused" apply cloudflare "$pf"
pf=$tmp/pf3
mkdir -p "$pf/.claude"
printf '{}' > "$tmp/target.json"
ln -s "$tmp/target.json" "$pf/.claude/settings.json"
watch=$pf
refused "symlinked settings refused" apply rw "$pf"
pf=$tmp/pf4
mkdir -p "$pf"
cp "$PLAYBOOK_HOME/registry.json" "$tmp/registry.bak"
pfphys=$(cd "$pf" && pwd -P)
jq --arg p "$pfphys" '.[$p] = "cloudflare"' "$tmp/registry.bak" > "$PLAYBOOK_HOME/registry.json"
watch=$pf
refused "registry entry not an array refused" apply cloudflare "$pf"
cp "$tmp/registry.bak" "$PLAYBOOK_HOME/registry.json"
watch=

# Symlinked skills and agents are saved and applied as real files.
mkdir -p "$tmp/outside/folder" "$tmp/src2/.claude/skills/withlink" "$tmp/src2/.claude/agents"
printf 'out\n' > "$tmp/outside/folder/f.txt"
printf 'ofile\n' > "$tmp/outside/file.txt"
printf 'ag\n' > "$tmp/outside/ag.md"
ln -s "$tmp/outside/folder" "$tmp/src2/.claude/skills/linked"
printf 's\n' > "$tmp/src2/.claude/skills/withlink/SKILL.md"
ln -s "$tmp/outside/file.txt" "$tmp/src2/.claude/skills/withlink/ref.txt"
ln -s "$tmp/outside/ag.md" "$tmp/src2/.claude/agents/ag.md"
: > "$tmp/src2/wrangler.toml"
sh "$script" save links "$tmp/src2" signal wrangler.toml skill linked skill withlink agent ag || bad "save links"
mkdir -p "$tmp/dstl"
sh "$script" apply links "$tmp/dstl" || bad "apply links"
if [ -z "$(find "$PLAYBOOK_HOME/presets/links" -type l)" ]; then ok "saved preset has no symlinks"; else bad "saved preset has no symlinks"; fi
if [ -z "$(find "$tmp/dstl/.claude" -type l)" ] && [ "$(cat "$tmp/dstl/.claude/skills/linked/f.txt")" = out ] && [ "$(cat "$tmp/dstl/.claude/skills/withlink/ref.txt")" = ofile ] && [ "$(cat "$tmp/dstl/.claude/agents/ag.md")" = ag ]; then ok "applied copy has real files only"; else bad "applied copy has real files only"; fi

# A dangling symlink at a destination is a conflict.
d4=$tmp/dang
mkdir -p "$d4/.claude/skills"
ln -s "$tmp/nowhere" "$d4/.claude/skills/deploy"
watch=$d4
refused "dangling skill link refused" apply cloudflare "$d4"
watch=
sh "$script" apply cloudflare "$d4" overwrite skill:deploy || bad "overwrite over dangling link runs"
if [ ! -L "$d4/.claude/skills/deploy" ] && [ -f "$d4/.claude/skills/deploy/SKILL.md" ]; then ok "overwrite replaces a dangling link"; else bad "overwrite replaces a dangling link"; fi
d5=$tmp/dang2
mkdir -p "$d5/.claude/agents"
ln -s "$tmp/nowhere" "$d5/.claude/agents/cf.md"
watch=$d5
refused "dangling agent link refused" apply cloudflare "$d5"
watch=

# CDPATH does not redirect a relative project name.
mkdir -p "$tmp/cwd/name" "$tmp/cdp/name"
cwdphys=$(cd "$tmp/cwd/name" && pwd -P)
(cd "$tmp/cwd" && CDPATH=$tmp/cdp sh "$script" apply cloudflare name) || bad "apply with CDPATH runs"
check "CDPATH ignored" "$PLAYBOOK_HOME/registry.json" ".[\"$cwdphys\"] == [\"cloudflare\"]"
if [ ! -e "$tmp/cdp/name/.claude" ]; then ok "CDPATH decoy untouched"; else bad "CDPATH decoy untouched"; fi

# Spaces in paths and names; rules starting with a dash or holding a backslash.
oldhome=$PLAYBOOK_HOME
PLAYBOOK_HOME="$tmp/home dir"
mkdir -p "$tmp/sp ace/src p/.claude/skills/my skill" "$tmp/sp ace/dst p"
printf 'k\n' > "$tmp/sp ace/src p/.claude/skills/my skill/my file.md"
: > "$tmp/sp ace/src p/wrangler.toml"
sh "$script" save sp "$tmp/sp ace/src p" signal wrangler.toml allow -dash allow 'Bash(grep \d)' skill 'my skill' 2>/dev/null && bad "skill name with a space refused"
sh "$script" save sp "$tmp/sp ace/src p" signal wrangler.toml allow -dash allow 'Bash(grep \d)' || bad "save with spaces"
mkdir -p "$tmp/sp ace/src p/.claude/skills/sk"
printf 'k\n' > "$tmp/sp ace/src p/.claude/skills/sk/my file.md"
sh "$script" save sp2 "$tmp/sp ace/src p" signal wrangler.toml allow -dash allow 'Bash(grep \d)' skill sk || bad "save sp2"
check "rules literal in the preset" "$PLAYBOOK_HOME/presets/sp/rules.json" '.allow == ["-dash","Bash(grep \\d)"]'
sh "$script" apply sp2 "$tmp/sp ace/dst p" || bad "apply with spaces"
check "rules literal in the project" "$tmp/sp ace/dst p/.claude/settings.json" '.permissions.allow == ["-dash","Bash(grep \\d)"]'
sp_phys=$(cd "$tmp/sp ace/dst p" && pwd -P)
check "registry key with a space" "$PLAYBOOK_HOME/registry.json" ".[\"$sp_phys\"] == [\"sp2\"]"
if [ -f "$tmp/sp ace/dst p/.claude/skills/sk/my file.md" ]; then ok "file name with a space copied"; else bad "file name with a space copied"; fi
PLAYBOOK_HOME=$oldhome

# Missing jq: a PATH with the basic tools and no jq.
bin=$tmp/bin
mkdir -p "$bin"
for t in sh cat dirname mkdir mktemp mv rm cp chmod printf; do
  q=$(command -v "$t") && case $q in /*) ln -s "$q" "$bin/$t" ;; esac
done
before=$(snap "$PLAYBOOK_HOME")
if PATH=$bin sh "$script" save nojq "$src" signal wrangler.toml 2>"$tmp/err"; then
  bad "missing jq exits non-zero"
elif grep -q jq "$tmp/err" && [ "$before" = "$(snap "$PLAYBOOK_HOME")" ]; then ok "missing jq refused, nothing written"; else bad "missing jq refused, nothing written"; fi

exit "$failed"
