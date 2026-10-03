---
type: llm
focus: last_message
---

PASS if the reply is written in Spanish and the payment provider it recommends as the main way
to charge cards is NOT Stripe (Stripe mentioned as unavailable in Colombia, or as the company
behind Lemon Squeezy / Managed Payments, is fine).
FAIL if the main recommendation is Stripe, or the reply is not in Spanish.
