# Decisions of the audit of 2026-11-22

| ID | Date | Decision | Who decided | Their words |
|----|------|----------|-------------|-------------|
| audit-2026-11-22-1 | 2026-11-22 | `product.md` says what the session-start hook does: the rules and the wiki's README share 9,000 of the 10,000 characters of a hook's output, the rest left for the two lines of the language (`hooks/session-start.sh`). It said "the 10,000 characters", which overstates the room left by 1,000 when 78 remain. | Andres Frei | Asked whether to correct `product.md` to 9,000, as the hook computes: "Corregir a 9.000 (Recommended)" |
| audit-2026-11-22-2 | 2026-11-22 | The wiki's README describes `technology.md` as each technology, why it was chosen, and the Claude Code version last evaluated, without "its version": the table has no version column, the plugin's version lives in `plugin.json` only (TD22), and plain shell has none. | Andres Frei | Asked how to resolve that the README promises each technology's version and `technology.md` holds none: "Sacar \"its version\" (Recommended)" |
