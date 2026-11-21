# Technology of the work plugin-icons

The work uses what the icons already use (plugin-directory-5): each icon is an SVG written by hand, `.claude-plugin/icon.svg`, turned into a 512 px PNG, `.claude-plugin/icon.png`, with ImageMagick: `convert -background none icon.svg icon.png`. ImageMagick 6.9.12 is installed. Nothing new is chosen.

Architecture: not applicable, two image files per plugin.
