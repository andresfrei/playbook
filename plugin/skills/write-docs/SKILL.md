---
name: write-docs
description: Write or update a README, a guide, a wiki page, an architecture page, or other documentation, or record a definition the owner changed. Produces a document that a person or an agent can understand without the conversation that produced it.
---

## When to use

- The owner asks to write or update a document that a person or an agent will read later: a README, a guide, a wiki page, an architecture page.
- The owner changes a definition that a document states, such as a pattern or a rule of the project.

Do not use it for writing a skill or for preparing a project in stages. Use it for code comments only when the owner asks.

## Rules

- The document stands alone. A reader who never saw the conversation understands it: every term, file, and decision it mentions is defined in it or linked from it, and it never says "as discussed" or "the change above".
- Write in English, whatever language the owner speaks.
- State only what was verified. Where a reader may need to check a claim, such as a tool's behaviour, a limit, a version, or a measurement, put the evidence next to it: the file, the command and its result, or the link.
- Mark a recalled fact as recalled. List what could not be verified in a last section named "Not verified".
- One fact, one place. When a fact is already written in another document, link to it. Do not copy it.
- One word for one thing. Use the terms the existing documents use, and do not vary a term for style.
- One topic per page. Open the page with one or two sentences that say what it covers.
- Where a document records what was chosen, mark each statement as Decided, Proposed, or Open. Never write a proposal as a decision.
- A set of documents has one entry point: a page that says what is decided, what is open, and what comes next, and that links to every other page.
- Write what the reader must do as instructions: "Run X", "Open Y". Keep reasons and history in a section or page of their own.
- Use a table to compare options and to list items that share the same fields. Use a numbered list for actions in order.
- Write dates in full, such as 2026-11-13. Never "today" or "last week".
- When the owner changes a definition, rewrite the page that states it so that it says only the new one. Record the decision and name the one it replaces. Ask what happens to the code that follows the old definition: changed now, changed when it is next touched, or listed as debt. When the change is for every project, it belongs to the playbook, not to this project.

## Steps

1. Find out what the document is for, who will read it, and where it will live. Take this from the request and the repository. Ask the owner for what neither says.
2. Read the documents that already exist there: the entry point, the pages on the same topic, and the glossary when there is one. Keep their terms and format. When a page already covers the topic, update it instead of adding one.
3. Collect the facts the document needs. Verify each one against its source: the code, a command's output, a tool's current documentation, or the owner's words. Keep the evidence. Ask the owner for a fact that has no source. Do not invent it.
4. Write the document following the Rules.
5. Link a new page from the entry point, and update what the entry point says is decided, open, and next when that changed. When several documents have no entry point, report it to the owner.
6. Read the document as a reader who has nothing else. Fix every reference that needs the conversation, every link or path that does not resolve, every fact stated twice, and every unverified claim that is not marked.

## Output

- The files written or changed.
- What was verified and how, and what the document lists as not verified.
- Questions for the owner: facts that are missing, and statements left as Proposed or Open.
