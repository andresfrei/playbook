# Stage 2 — Technology

Every technology the project uses is a decision of the owner, a row of the work's `decisions.md`.

## Steps

1. List what the product needs from its technology, one need per line, taken from the product pages. Add no need the wiki does not contain.
2. A technology that the owner's brief names is the first candidate for its need. It is Proposed, not Decided.
3. Choose the simplest solution that solves the current problem and can evolve. Propose a dependency, a service, or a pattern only when a requirement written in the wiki needs it.
4. Check each candidate in its current documentation: version, limits, price, and whether it meets the requirement. Write the link and the date checked. Say when something is recalled and not checked.
5. When a candidate cannot meet a requirement, say so and propose alternatives, each with what it gains and what it gives up. Never replace it silently.
6. Ask for each decision. Each answer is a decision.
7. Write, in the work's folder, the technology chosen for each need, with its version and source, and the architecture page. They become pages of `03-technology/` when the work closes.

## The architecture page

- The problem, in two or three sentences.
- The requirements that shape the architecture, and the assumptions made.
- The shape chosen, and why it fits those requirements.
- The modules. For each one: what it is responsible for, its limits (what it does not do), and how the other modules use it.
- The main data and how its parts relate.
- The outside systems: what each is for and how critical it is.
- The risks, each with what reduces it.
- The trade-offs: for each significant decision, what is gained and what is given up.
- The discarded alternatives, each with the reason.
- How the architecture can evolve.

Leave out a section that does not apply, and say why.

## Project already started

- Write the technology the project already uses, with the versions read from the repository. Do not ask the owner to decide it again.
- Ask for a decision only for what changes: a need the current technology does not meet, or a part the owner wants replaced.
- The architecture page describes the project as it is, then what changes.

## Closing condition

- Every need has a decision, or a technology the project already uses.
- The architecture page is written.
- The owner accepts the technology.
