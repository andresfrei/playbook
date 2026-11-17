# Definition of the work plugin-directory

## The problem

The owner wants the product listed in Anthropic's plugin directory, in the release after version 2 (D198). Version 2.1.0 is out, so this is that release. Today the product is installed only from this repository's marketplace, `playbook`, with `claude plugin marketplace add andresfrei/playbook`.

## What the directory asks

Read on 2026-11-17 from these pages, which are the source of every point below:

- https://claude.com/docs/plugins/submit.md
- https://claude.com/docs/plugins/pre-submission-checklist.md
- https://claude.com/docs/directory/publish.md
- https://claude.com/docs/plugins/platform-support.md
- https://support.claude.com/en/articles/13145358-anthropic-software-directory-policy

Not read: the Software Directory Terms, and the Claude Code pages on reserved names and on plugins synced from the directory.

The submission:

- It is made in the developer portal, https://claude.ai/directory/manage, from a github.com repository, by a Pro, Max, Ultra, Team, or Enterprise account with the GitHub account connected.
- "Each plugin folder is its own submission": the three plugins are three submissions. The marketplace itself is not submitted.
- The directory follows the default branch, or a tag. "If your `plugin.json` sets `version`, raise it with every release", which TD22 already does. An Anthropic reviewer publishes each version by default.
- The portal asks for listing details, data handling, a contact email, and four acknowledgements.

The automated checks that block, as they apply to this product:

- A `README` of at least 40 words and a `LICENSE`, or `license` in `plugin.json`. The local validator takes both from the repository's root when the plugin folder has none.
- Every file a hook runs is inside the plugin folder, and each hook command is a path from `${CLAUDE_PLUGIN_ROOT}`.
- No real credentials in any file.

Checks that hold a version for a reviewer instead of blocking: a script a hook runs that uses command substitution, a shell variable other than `${CLAUDE_PLUGIN_ROOT}`, or a call to another file of the plugin. The hook scripts of `playbook-wiki` do all three.

The policy asks for: only the data a plugin needs; no change to "Claude's behavior across sessions"; no hidden instructions; a contact and support channel; documentation of how it works; at least three example prompts. After submission, a security scan looks for behaviour a plugin does not disclose.

Where each part loads (platform-support): skills load in chat, Cowork, and Claude Code; hooks and agents load in Cowork and Claude Code, and are ignored in chat.

## What the product has today

Checked on 2026-11-17 by running `claude plugin validate` (Claude Code 2.1.326) on each plugin folder: all three pass. Each has one directory warning, `ICON_MISSING`: a square PNG of 512 to 2048 px. The icon is taken only the first time the plugin is submitted; a later change does not change it.

Checked by reading the files:

- `playbook` holds only `/playbook:init`, which turns the other two plugins on by the marketplace name `playbook` (TD27).
- `playbook-wiki` has five hooks, each run as `sh "${CLAUDE_PLUGIN_ROOT}/..."` or `cat "${CLAUDE_PLUGIN_ROOT}/..."`. Two of its scripts read a shared file, `hooks/git-hook-lib.sh`.
- `playbook-agents` declares `"dependencies": ["playbook-wiki"]`.
- No plugin folder holds its own `README.md` or `LICENSE`; the repository's root holds both.

Open, for stage 2, and not stated in the pages read: whether a plugin listed in the directory may depend on another, under what marketplace name a plugin installed from the directory appears, and whether `sh "${CLAUDE_PLUGIN_ROOT}/..."` counts as a path from `${CLAUDE_PLUGIN_ROOT}`. The portal's Validate answers the last one.

## What the work must do

- Submit `playbook-wiki` and `playbook-agents` to the directory, as two submissions. `playbook` is not submitted (plugin-directory-1).
- Give each of the two an icon: a square PNG of 512 px, in one visual line, designed by the agent and approved by the owner before the first submission (plugin-directory-3).
- Pass the portal's Validate for each, with no blocking finding.

The submission itself is made by the owner in the portal, with the owner's account (R14, R24).

## What the work must not do

- Change the installation from this repository's marketplace, `/playbook:init` included. A change for the directory that breaks it is dropped or made another way (plugin-directory-2).

## Coverage of the topics

| Topic | Coverage |
|-------|----------|
| The problem, and who has it | Covered: above |
| Who uses it | Covered: people who find plugins in the directory, in Claude Code |
| Main flows | Covered: the submission is above; a person installs `playbook-wiki`, or both plugins, from the directory |
| What it must do | Covered: plugin-directory-1, -3 |
| What it must not do | Covered: plugin-directory-2 |
| Qualities | Covered by the policy above |
| Limits | Covered: a paid plan, and the owner submits in the portal |
| Outside systems | Covered: the developer portal and GitHub |
| Volume | Does not apply |
| Who runs and maintains it | Covered: the owner |
| Business rules and vocabulary | Covered: the checks above |
