# CQRS (and when event sourcing is NOT included)

**Definition.** Command Query Responsibility Segregation uses one model to change data
(commands) and a different model to read it (queries). The read side can be a projection or a
separate store shaped for screens and reports. Fowler: "be very cautious about using CQRS".

## Building blocks

- **Command** — a business intent (`BookRoom`, not `SetStatus=Reserved`); validated by the
  write model (often an aggregate); returns success/failure, not data.
- **Query** — returns DTOs/projections; no business logic, never mutates.
- **Write model** — transactional, normalized, holds the invariants.
- **Read model** — denormalized view / materialized view / read replica, optimized per screen.
- **Synchronization** — same store (simplest) or separate stores fed by events; with separate
  stores use a transactional outbox and idempotent projection consumers.

## Levels (pick the lowest that solves the problem)

1. Separate query classes/SQL views over the same database — no messaging.
2. Read replica or materialized view for reports.
3. Separate read store fed by events — eventual consistency, real complexity.

## When

- Reads and writes scale very differently (many more reads; heavy dashboards/reporting).
- The read shape diverges strongly from the write model (search, analytics, timelines).
- Task-based UI on a rich domain with collaborative edits.

## When not

- Simple domain or business rules; a CRUD UI is enough (Azure: "might not be suitable").
- Small team / MVP without a measured read bottleneck.
- **Event sourcing is not part of the default.** Add it only with an explicit need for a full
  audit trail, replay or temporal queries; Azure calls it complex and costly to migrate from,
  and unsuitable for MVPs or teams new to event-driven systems.

## Sketch

```
command CancelOrder(orderId, reason)
handle(cmd):
  order = Orders.byId(cmd.orderId)      # write model / aggregate
  order.cancel(cmd.reason)              # invariants enforced here
  tx: Orders.save(order); Outbox.add(OrderCanceled(order.id))
projector on OrderCanceled(e):          # idempotent: keyed by event id
  OrderSummaryView.upsert(e.orderId, status="canceled")
query OrderSummaries(customerId):       # read model, no rules
  return OrderSummaryView.where(customerId)
```

## Pitfalls

- Stale reads surprise users — show "processing" or read-your-writes from the write side.
- Dual writes (DB + broker) without an outbox → lost or phantom events.
- Non-idempotent projectors under at-least-once delivery.
- Adopting level 3 (separate stores) when level 1 would do.

## Canonical URLs (opened 2026-10-03)

- Fowler, CQRS: https://martinfowler.com/bliki/CQRS.html
- Azure Architecture Center, CQRS: https://learn.microsoft.com/en-us/azure/architecture/patterns/cqrs
- Azure Architecture Center, Event Sourcing: https://learn.microsoft.com/en-us/azure/architecture/patterns/event-sourcing
- Azure Architecture Center, Idempotent Consumer: https://learn.microsoft.com/en-us/azure/architecture/patterns/idempotent-consumer
- Azure, Transactional Outbox (state + event in one transaction, worker relays): https://learn.microsoft.com/en-us/azure/architecture/databases/guide/transactional-out-box-cosmos
