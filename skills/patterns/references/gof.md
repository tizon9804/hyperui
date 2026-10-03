# GoF patterns — by name, only when a real force exists

**Definition.** The Gang of Four catalog: 23 reusable designs in three groups — creational
(how objects are made), structural (how they are composed), behavioral (how they collaborate).
Name one only when the code already has the problem it solves.

## The ones that come up in product backends

| Force present today | Pattern | Group |
|---|---|---|
| Exactly one instance of an expensive resource with a lifecycle (DB pool, HTTP client) | **Singleton scope** via DI container / composition root | creational |
| Concrete class chosen by config or type (payment provider per country) | **Factory method** | creational |
| Several interchangeable algorithms chosen at runtime (pricing, tax, export) | **Strategy** | behavioral |
| Many listeners react to one change (in-process) | **Observer** (domain events are its cousin) | behavioral |
| A foreign interface must fit your port | **Adapter** | structural |
| Add cross-cutting behavior around a call (logging, retry, cache) | **Decorator** | structural |

## When not

- One algorithm that rarely changes: refactoring.guru says Strategy then just
  "overcomplicates the program with new classes and interfaces".
- Singleton as a global for convenience: it violates single responsibility, can mask bad
  design, needs care under multithreading and is hard to unit test (refactoring.guru).
  Prefer one instance created in the composition root and passed in (dependency injection).
- Factory for a class with one implementation.

## Sketch

```
# Singleton scope without global state
main:
  pool = DbPool(env.DATABASE_URL, max=10)      # created once, closed on shutdown
  http = HttpClient(timeout=3s)
  app  = App(OrderRepo(pool), EmailClient(http))   # injected, replaceable in tests
# Strategy
interface PriceRule: price(cart) -> Money
class FlatRule, TieredRule, PromoRule implements PriceRule
checkout(cart, rule: PriceRule): return rule.price(cart)
rules = { "flat": FlatRule(), "tiered": TieredRule() }   # chosen at runtime
```

## Pitfalls

- Pattern names in class names without the pattern's force (`UserFactoryStrategyManager`).
- Static `getInstance()` hidden in domain code — tests cannot replace it.
- Lazy singletons initialized concurrently (double creation).
- Strategy maps that grow `if` checks inside each strategy.

## Canonical URLs (opened 2026-10-03)

- Refactoring.Guru catalog: https://refactoring.guru/design-patterns
- Singleton: https://refactoring.guru/design-patterns/singleton
- Strategy: https://refactoring.guru/design-patterns/strategy
- Factory Method: https://refactoring.guru/design-patterns/factory-method
- Adapter: https://refactoring.guru/design-patterns/adapter
- Observer: https://refactoring.guru/design-patterns/observer
- Fowler, IoC containers and dependency injection: https://martinfowler.com/articles/injection.html
