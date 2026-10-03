---
type: regex
target: last_message
match: not_contains
pattern: 'soy hyperui|me llamo hyperui|te har[ée] (como m[aá]ximo |m[aá]ximo |a lo sumo )?(tres|3) preguntas|¿(es|ser[aá]) para (un|tu) negocio|negocio o (uso )?personal|¿en qu[ée] idiomas?|¿qu[ée] (estamos|vamos a) constru|¿necesitas? (i18n|varios idiomas|traducci)'
flags: i
---

Fails when the senior user is re-onboarded (intro, "three questions", business/personal, what
are we building) or asked the product-language / i18n question that the profile already answers.
