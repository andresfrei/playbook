# Definition of the plugin icons

## The problem

Playbook has a new logo, "Manual con franjas": an open pixel book on a 16×16 grid, notes on the left page, a play triangle on the right, and the book's edge drawn as three stripes, orange, amber, and paper (neuralmind playbook-product-34). The landing and the README use it (readme-redesign-18). The two plugin icons still show the earlier drawing: a smooth open book on ink, a check mark for `playbook-wiki` and three joined dots for `playbook-agents` (plugin-directory-7). The brand decided one logo for Playbook everywhere (neuralmind playbook-product-14).

## What the icons are for

- Each is `.claude-plugin/icon.png`, 512 px, drawn from `.claude-plugin/icon.svg`, in `plugins/playbook-wiki/` and `plugins/playbook-agents/` (plugin-directory-3).
- Anthropic's plugin directory reads them, and takes an icon only at the first submission (plugin-directory-3). Neither plugin is submitted yet: the directory needs a Verified organization (plugin-directory-9). So the icons can change now at no cost; after a submission they cannot.
- `playbook`, the setup plugin, has no icon: it is not submitted (plugin-directory-1).

## Who sees them

A person browsing the directory, where the two icons sit among others, at small sizes, and next to each other when both are listed.

## What is known

- Brand colours, fixed in light and dark: ink `#0e1116`, orange `#ff5a1f`, amber `#ffb020`, paper `#f2ebdd` (neuralmind playbook-product-34).
- The logo's source, `docs/assets/playbook-logo.svg`, is a 512 px square with rounded corners (`rx` 96) on ink.

## Coverage of the topics

| Topic | Coverage |
|-------|----------|
| The problem, and who has it | Covered |
| Users and what each does | Covered: a person browsing the directory |
| Main flows | Covered: the directory shows the icon |
| What it must do | Covered: the logo with a sign of each plugin (plugin-icons-2) |
| What it must not do | Covered: break the installation from the marketplace (plugin-directory-2) |
| Qualities | Covered: readable at small sizes |
| Limits | Covered: 512 px PNG, taken only at the first submission |
| Outside systems | Covered: Anthropic's plugin directory |
| Volume, operation | Not applicable |
| Vocabulary | Covered |

## What each icon shows

The logo "Manual con franjas" on its ink square, with the plugin's sign on the right page in place of the play triangle: a pixel check for `playbook-wiki`, three pixel dots for `playbook-agents`, in orange (plugin-icons-2).
