---
name: avoid-generic-design
description: Design, review, or refine a landing page, a web page, an interface, or a component's styling. Keeps out the generic look AI tools produce by default, and in a review lists each generic pattern, where it is, and an alternative.
---

## When to use

- The owner asks to design or build the look of a landing page, a web page, an interface, or a component.
- The owner asks to review or refine the visual design of one.

Do not use it for work with no visual design in it, such as a data model, an API, or business logic.

## Rules

- A project's own design system or visual identity wins over this skill. Follow it, and do not report as a finding what it prescribes.
- Do not use a pattern from `references/generic-patterns.md` unless the owner or the project asks for it.
- Back each choice that replaces a generic pattern with evidence: something in the project, such as its content, its audience, or its brand, or a reference the owner named. Cite no source you have not checked.
- Choose the simplest alternative that removes the generic pattern. Add a dependency, such as a web font, an icon set, or a library, only when the context justifies it (R9).
- When the project's stack cannot produce an alternative, say so and propose ones it can. Never change the stack silently (R8).
- In a review, change nothing. Apply the alternatives only when the owner asked to refine or fix the design.

## Steps

### Produce a design

1. Look in the project for a design system or a visual identity: design tokens, a theme, a style guide, brand rules. When there is one, build the design from it and go to Output.
2. Read `references/generic-patterns.md`.
3. Choose the typeface, the colour, the way blocks are separated, and the layout. Write down each choice and its evidence.
4. Build the design.
5. Compare the result with each pattern in the reference file. Replace every one found that nobody asked for.

### Review a design

1. Look in the project for a design system or a visual identity, and note what it prescribes.
2. Read `references/generic-patterns.md`.
3. Compare the design with each pattern. For every one found, note where it is: the file and line, or the page section or component.
4. Propose one alternative for each finding, with its evidence.
5. Return the list. When the owner asked to refine or fix, apply the alternatives and do the comparison again.

## Output

- Design: the design, the four choices of step 3 with the evidence for each, and any generic pattern kept, with who asked for it.
- Review: one entry per finding with the generic pattern, where it is, and the alternative proposed. Or "no generic patterns found".
- Any requirement the stack cannot meet, with the alternatives proposed.
- The design system or visual identity followed, when the project has one.

## References

- `references/generic-patterns.md` — the catalogue of generic patterns: what each looks like, how to find it, and its alternatives. Read it before producing or reviewing a design.
