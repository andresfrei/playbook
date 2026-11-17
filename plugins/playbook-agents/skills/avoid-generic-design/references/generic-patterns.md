# Generic patterns

The catalogue of patterns that make a web or interface design look generic: what each looks like, how to find it, and its alternatives.

A pattern is generic when it is in the design because it is the default, not because someone chose it.

## 1. The default sans-serif typeface

**Looks like:** one widely used sans-serif for headings and body alike, for example Inter, Roboto, or the system interface font, with nothing in the project that calls for it.

**Find it in:** the `font-family` declarations, the font imports, and the font setting of the theme when the project has one.

**Alternatives:**

- A typeface family that fits the content and is already on the reader's device, such as a system serif or monospace stack. It adds no dependency.
- Two typefaces with different roles: one with character for headings, a plain one for body text.
- A web font chosen for the project, when the design needs it and the dependency is justified.
- Whatever the typeface, a deliberate scale: few sizes, few weights, and a clear difference between heading and body.

## 2. The violet-to-blue gradient

**Looks like:** a gradient from violet, purple, or indigo to blue behind the top section of the page, on buttons, or filling the text of a heading.

**Find it in:** `linear-gradient` and similar values whose stops are violet, purple, or indigo and blue; gradient utility classes; text clipped to a gradient background.

**Alternatives:**

- A solid background: white, a tinted off-white, a dark tone, or a colour of the project's brand.
- One accent colour taken from the brand or the subject, used only where the reader must act, such as the main button and the links.
- A gradient, when one is wanted, built from the project's own colours and used in one place.

## 3. Generic shadow cards

**Looks like:** every block of content in a white box with rounded corners and the same soft shadow, where the shadow is the only thing that separates one block from the next.

**Find it in:** the same `box-shadow` and `border-radius` values repeated on every container; shadow utility classes on every card.

**Alternatives:**

- Separate blocks with space, a thin border, or a change of background tone.
- Drop the box: group content with alignment and type alone.
- Keep the shadow for what sits above the page, such as a menu, a dialog, or a tooltip.

## 4. The flat three-column grid

**Looks like:** a section made of three equal columns, each with an icon, a short heading, and two lines of text, all the same size and weight. Often the same grid again in the next section.

**Find it in:** `grid-template-columns: repeat(3, 1fr)`, three equal flex children, or the utility classes for three equal columns, used for one section after another.

**Alternatives:**

- A layout that follows the importance of the content: the main item large, the others smaller.
- Columns of unequal width, or blocks offset from each other.
- A numbered sequence when the items have an order.
- Rows that pair text with an image or an example when each item needs explaining.
- A plain list when the items are short.
