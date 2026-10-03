---
type: regex
target: last_message
pattern: '\b\d+\s+(grises|colores|acentos|radios|sombras|tipograf[ií]as|fuentes)|sin tokens|no hay (ning[uú]n )?tokens?|tokens? de dise[nñ]o|\bArial\b|gradiente|degradado'
flags: i
---

The audit of the existing CSS is reported with at least one concrete observation: a count of
grays / accents / radii / shadows, the absence of design tokens, the Arial fallback, or the
purple-to-blue gradient.
