# DDD tactical building blocks

**Definition.** Domain-Driven Design models the business in code using the domain's own
language. The tactical part gives building blocks for one bounded context: entities, value
objects, aggregates, domain services, domain events, repositories, factories.

## Building blocks

- **Entity** — identity that persists over time (`Account`, `Subscription`). Holds behavior,
  not only data (an anemic model is the antipattern).
- **Value object** — no identity, equal by value, immutable (`Money`, `Email`, `DateRange`).
  Default modeling choice; promote to entity only when identity must be tracked.
- **Aggregate** — consistency boundary around entities with one **root**. Outside code holds
  references to the root only. "Transactions should not cross aggregate boundaries" (Fowler).
  Rules: small aggregates; reference other aggregates by id; eventual consistency between them.
- **Repository** — collection-like access to aggregates, one per aggregate root, hides storage.
- **Domain service** — stateless rule spanning several aggregates (pricing, scheduling).
- **Application service** — orchestrates a use case (load, call domain, save, publish); no rules.
- **Domain event** — a business fact in past tense (`PaymentSucceeded`), raised by the
  aggregate after a state change; the way to coordinate across aggregates.
- **Bounded context** — the boundary inside which one model and vocabulary are consistent.

## When

- A rule must hold across several objects in one change (invariant): order lines vs total,
  seats vs capacity, one active plan per account.
- Rich state transitions (subscription: trialing → active → past_due → canceled).
- Several sub-domains with clashing vocabulary (billing vs identity).

## When not

- CRUD with no cross-entity rule; a static site; a form that only stores rows.
- A repository layer over an ORM that already is one, with no aggregate to protect.

## Sketch

```
aggregate Subscription (root)
  id, accountId, plan, status, periodEnd
  activate(payment):                       # the only way to change status
    require status in [trialing, past_due]
    require payment.amount == plan.price   # invariant lives here
    status = active; periodEnd = payment.periodEnd
    raise SubscriptionActivated(id, accountId)
repository Subscriptions: byId(id), save(sub)   # one transaction per aggregate
on PaymentSucceeded(evt):                  # application service
  sub = Subscriptions.byId(evt.subscriptionId)
  sub.activate(evt.payment); Subscriptions.save(sub)
```

## Pitfalls

- Giant aggregates that lock unrelated data; size by the invariant, not by the screen.
- Holding object references across aggregates instead of ids.
- Updating two aggregates in one transaction — use a domain event instead.
- Domain events that are database changes ("row inserted") rather than business facts.
- Publishing events outside the transaction without an outbox (lost or phantom events).

## Canonical URLs (opened 2026-10-03)

- Evans, Domain Language DDD resources: https://www.domainlanguage.com/ddd/
- Vernon, Implementing Domain-Driven Design: https://www.informit.com/store/implementing-domain-driven-design-9780321834577
- DDD Crew (aggregate-design-canvas, bounded-context-canvas): https://github.com/ddd-crew
- Microsoft, tactical DDD: https://learn.microsoft.com/en-us/azure/architecture/microservices/model/tactical-domain-driven-design
- Fowler, DDD Aggregate: https://martinfowler.com/bliki/DDD_Aggregate.html
- Fowler, Repository: https://martinfowler.com/eaaCatalog/repository.html
- Fowler, Bounded Context: https://martinfowler.com/bliki/BoundedContext.html
- Azure, Transactional Outbox (state + event in one transaction, worker relays): https://learn.microsoft.com/en-us/azure/architecture/databases/guide/transactional-out-box-cosmos
