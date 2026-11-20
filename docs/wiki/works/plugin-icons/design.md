# Design of the work plugin-icons

Each icon is the logo "Manual con franjas" on its ink square, on the logo's 16×16 grid of 32 px cells, with the plugin's sign on the right page in place of the play triangle (plugin-icons-2). [design-preview.png](design-preview.png) shows both at 512 px and at 64 px.

| Part | Choice |
|------|--------|
| Ground | Ink `#0e1116`, a 512 px square with corners of radius 96, as the logo |
| Book and stripes | The logo's cells, unchanged: paper `#f2ebdd`, orange `#ff5a1f`, amber `#ffb020` |
| `playbook-wiki` | A pixel check of four cells on the right page, in orange |
| `playbook-agents` | Three pixel dots in a triangle on the right page, in orange |

## `playbook-wiki`

```svg
<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" viewBox="0 0 512 512">
<rect width="512" height="512" rx="96" fill="#0e1116"/>
<g shape-rendering="crispEdges">
<path d="M32 32h96v32h-96zM384 32h96v32h-96zM32 64h160v32h-160zM320 64h160v32h-160zM32 96h192v32h-192zM288 96h192v32h-192zM32 128h32v32h-32zM160 128h64v32h-64zM288 128h192v32h-192zM32 160h192v32h-192zM288 160h128v32h-128zM448 160h32v32h-32zM32 192h32v32h-32zM192 192h32v32h-32zM288 192h32v32h-32zM352 192h32v32h-32zM416 192h64v32h-64zM32 224h192v32h-192zM288 224h64v32h-64zM384 224h96v32h-96zM32 256h32v32h-32zM128 256h96v32h-96zM288 256h192v32h-192zM32 288h192v32h-192zM288 288h192v32h-192zM32 320h192v32h-192zM288 320h192v32h-192zM64 416h160v32h-160zM288 416h160v32h-160z" fill="#f2ebdd"/>
<path d="M416 160h32v32h-32zM320 192h32v32h-32zM384 192h32v32h-32zM352 224h32v32h-32zM32 352h192v32h-192zM288 352h192v32h-192z" fill="#ff5a1f"/>
<path d="M32 384h192v32h-192zM288 384h192v32h-192z" fill="#ffb020"/>
<path d="M64 128h96v32h-96zM64 192h128v32h-128zM64 256h64v32h-64z" fill="#0e1116"/>
</g>
</svg>
```

## `playbook-agents`

```svg
<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" viewBox="0 0 512 512">
<rect width="512" height="512" rx="96" fill="#0e1116"/>
<g shape-rendering="crispEdges">
<path d="M32 32h96v32h-96zM384 32h96v32h-96zM32 64h160v32h-160zM320 64h160v32h-160zM32 96h192v32h-192zM288 96h192v32h-192zM32 128h32v32h-32zM160 128h64v32h-64zM288 128h192v32h-192zM32 160h192v32h-192zM288 160h64v32h-64zM384 160h96v32h-96zM32 192h32v32h-32zM192 192h32v32h-32zM288 192h192v32h-192zM32 224h192v32h-192zM288 224h32v32h-32zM352 224h32v32h-32zM416 224h64v32h-64zM32 256h32v32h-32zM128 256h96v32h-96zM288 256h192v32h-192zM32 288h192v32h-192zM288 288h192v32h-192zM32 320h192v32h-192zM288 320h192v32h-192zM64 416h160v32h-160zM288 416h160v32h-160z" fill="#f2ebdd"/>
<path d="M352 160h32v32h-32zM320 224h32v32h-32zM384 224h32v32h-32zM32 352h192v32h-192zM288 352h192v32h-192z" fill="#ff5a1f"/>
<path d="M32 384h192v32h-192zM288 384h192v32h-192z" fill="#ffb020"/>
<path d="M64 128h96v32h-96zM64 192h128v32h-128zM64 256h64v32h-64z" fill="#0e1116"/>
</g>
</svg>
```
