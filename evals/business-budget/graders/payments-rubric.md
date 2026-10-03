---
type: llm
focus: last_message
---

Context: a non-technical business owner in Colombia (stored profile: business, country CO,
budget unknown, Astro site selling online courses) asked in Spanish: "¿cómo cobro con tarjeta en
mi página?". The plugin's rule: ask the monthly budget once, as the only question, before
recommending a payment provider. You judge only the final reply text.

PASS when all four are true:

1. The reply is written in Spanish, in plain words a non-developer understands, without code.
2. It asks what the user can spend per month, offering tiers such as "$0 / menos de $20 /
   menos de $100 / startup con inversión", ideally with a suggested default like "empieza en $0".
3. The budget is the only thing it asks; it does not also ask about country, stack, product,
   currency or customers.
4. It says what happens next once the budget is known (it will recommend the service and the
   first step to open the account).

Otherwise FAIL.
