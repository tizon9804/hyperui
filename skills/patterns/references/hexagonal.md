# Hexagonal architecture (ports and adapters) and the dependency rule

**Definition.** The application core (domain + use cases) talks to the outside only through
**ports** (interfaces it owns); **adapters** implement them for a concrete technology. Cockburn's
intent: drive the app equally from users, programs, tests or batch, and develop and test it in
isolation from its run-time devices and databases.

## Building blocks

- **Core** — entities, value objects, domain services, use cases. Imports nothing from
  frameworks, ORMs, HTTP or provider SDKs.
- **Driving (primary) port** — what the app offers: `CheckoutUseCase.start(cart)`.
- **Driven (secondary) port** — what the app needs: `PaymentGateway`, `Mailer`, `OrderRepository`.
- **Driving adapter** — HTTP controller, CLI, webhook handler, test harness → calls a driving port.
- **Driven adapter** — Postgres repository, Stripe/Polar/Paddle gateway, email API client.
- **Composition root** — the one place (main / DI container) that wires adapters to ports.
- **Dependency rule** (Clean Architecture): "source code dependencies can only point inwards."

## When

- The domain has real rules worth testing without I/O.
- A provider may change (payments by country, email vendor) or several adapters coexist.
- Several drivers hit the same use case (HTTP + webhook + scheduled job).

## When not

- A static site or a thin CRUD where the framework *is* the app — ports would only forward.
- One-off scripts and prototypes.
- Do not create a port per class: ports sit at I/O boundaries only.

## Sketch

```
# core (no framework imports)
port PaymentGateway: createCheckout(order) -> url ; verifyWebhook(raw, sig) -> PaymentEvent
port Mailer: send(to, template, data)
usecase StartCheckout(orders: OrderRepository, pay: PaymentGateway):
  run(cartId): order = orders.fromCart(cartId); return pay.createCheckout(order)
# adapters (outside)
adapter PolarGateway implements PaymentGateway      # SDK + timeout + retry + breaker here
adapter HttpCheckoutController -> StartCheckout.run
adapter InMemoryPaymentGateway implements PaymentGateway   # tests
main: wire(StartCheckout, PostgresOrders(pool), PolarGateway(client))
```

## Pitfalls

- Leaking ORM entities or SDK types through ports (the core then depends outward).
- Ports shaped like the vendor API instead of the domain need.
- Resilience logic (timeouts, retries, circuit breaker) in the core — it belongs in the
  driven adapter.
- Layers for their own sake: three mappings for a field that never differs.

## Canonical URLs (opened 2026-10-03)

- Cockburn, Hexagonal Architecture: https://alistair.cockburn.us/hexagonal-architecture
- Martin, The Clean Architecture (2012): https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html
- Fowler, Inversion of Control containers and dependency injection: https://martinfowler.com/articles/injection.html
- Azure, Anti-Corruption Layer (adapter toward a foreign model): https://learn.microsoft.com/en-us/azure/architecture/patterns/anti-corruption-layer
