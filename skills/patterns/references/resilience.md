# Resilience: timeouts, retry, circuit breaker, bulkhead, rate limiting, idempotency

**Definition.** Every call that leaves the process (HTTP API, database, SDK, queue) can be slow,
fail briefly or fail for minutes. Resilience patterns bound the wait, retry what is transient,
stop calling what is broken and keep one failure from spreading.

## Building blocks

- **Timeout** — every external call has one, shorter than the caller's own deadline. Without
  it a circuit breaker cannot protect you (Azure: long timeouts tie up threads first).
- **Retry** — only transient faults (timeouts, 5xx, 429), only idempotent operations or with an
  idempotency key; exponential backoff **with jitter**; few attempts; never nested retries.
- **Circuit breaker** — closed → open after N failures in a window → half-open trial calls →
  closed. Open = fail fast or fallback (queue the email, cached value). Retry runs *through*
  the breaker and stops when it is open.
- **Bulkhead** — separate pools/concurrency limits/queues per dependency or tenant, so a slow
  email API cannot exhaust the connections the payments path needs.
- **Rate limiting** (client side) — stay under a provider's quota; **throttling** (server side)
  — reject excess with 429 + `Retry-After`. Honor the provider's `Retry-After`.
- **Idempotent consumer** — webhooks and messages arrive at least once; store the event id
  with a unique constraint in the same transaction as the side effect; duplicates are no-ops.
- **Fallback** — degraded answer when open (send later, show "pending").
- **Serverless/edge** — isolates share no memory: keep the breaker, store its state in a shared
  store (Durable Object, KV, Redis) or run the call from one queue worker that owns it.

## When

- Any external call on a user path (payment API, email API, maps, LLM, third-party SDK).
- Inbound payment webhooks (redelivery is normal) → idempotent consumer + signature check.
- Shared pools across dependencies or tenants → bulkhead.

## When not

- In-process calls or local data structures — a breaker only adds overhead.
- Business errors (card declined, 4xx validation) — never retried, never trip the breaker.
- Message-driven flows where the broker already retries and dead-letters.
- A non-critical fire-and-forget call: a timeout alone is enough.

## Sketch

```
emailBreaker = CircuitBreaker(failures=5, window=30s, openFor=60s)
sendWelcome(user):
  for attempt in 1..3:
    if emailBreaker.isOpen(): return Outbox.enqueue("welcome", user.id)   # fallback
    try: return emailBreaker.call(() => Email.send(user, timeout=2s, idemKey=user.id))
    catch Transient: sleep(random(0, 200ms * 2^attempt))                  # full jitter
    catch Permanent: raise                                                # no retry
  Outbox.enqueue("welcome", user.id)
onPaymentWebhook(raw, sig):
  evt = verifySignature(raw, sig)
  tx: if ProcessedEvents.insertIfAbsent(evt.id): Subscriptions.apply(evt)
```

## Pitfalls

- Retry storms: many clients retrying in sync without jitter, or retries at every layer.
- Retrying a charge without an idempotency key → double charge.
- One breaker for several independent providers/shards (one failure blocks all).
- Logging every retry as an error; log the final failure only (Azure Retry guidance).
- Hiding a downstream 429/503 behind a generic 500 — propagate back-pressure.

## Canonical URLs (opened 2026-10-03)

- Fowler, Circuit Breaker: https://martinfowler.com/bliki/CircuitBreaker.html
- Azure, Circuit Breaker: https://learn.microsoft.com/en-us/azure/architecture/patterns/circuit-breaker
- Azure, Retry: https://learn.microsoft.com/en-us/azure/architecture/patterns/retry
- Azure, Bulkhead: https://learn.microsoft.com/en-us/azure/architecture/patterns/bulkhead
- Azure, Rate Limiting: https://learn.microsoft.com/en-us/azure/architecture/patterns/rate-limiting-pattern
- Azure, Throttling: https://learn.microsoft.com/en-us/azure/architecture/patterns/throttling
- Azure, Idempotent Consumer: https://learn.microsoft.com/en-us/azure/architecture/patterns/idempotent-consumer
- Resilience4j (JVM: circuitbreaker, retry, bulkhead, ratelimiter, timelimiter): https://resilience4j.readme.io/docs/getting-started
- Polly (.NET: retry with jitter, circuit breaker, timeout, rate limiter): https://www.pollydocs.org/ · https://www.pollydocs.org/strategies/retry.html
- Azure, Transactional Outbox (state + event in one transaction, worker relays): https://learn.microsoft.com/en-us/azure/architecture/databases/guide/transactional-out-box-cosmos
