---
name: ask
description: |
  Math Research OS entry: auto-diagnose user intent, route to thinking lenses, math knowledge base, or design translation layer.
---

## Language Routing (inline)

Determine primary language: judge by sentence frame, verbs, mood particles. AI/math/engineering terms (attention, loss, routing, etc.) do not count as language signals. Code, paths, formulas do not count. When CN/EN ratio is close, follow the previous turn's language; default to Chinese if no context. Explicit "in English/in Chinese" takes priority.

- Chinese primary → load `../SKILL.md` (canonical entry, can answer in either language)
- English primary → load `../SKILL.en.md` (English compatibility entry)
- Do not load both simultaneously

Current question:
$ARGUMENTS
