# Java — rules for writing code

Applies to modern Java (17+/21 LTS) services and libraries; the Spring Boot notes apply when
`spring-boot` is on the build path.

**Sources** (open before stating): Google Java Style Guide
https://google.github.io/styleguide/javaguide.html · Effective Java, 3rd ed. (Bloch)
https://www.informit.com/store/effective-java-9780134685991 · Spring Boot reference
https://docs.spring.io/spring-boot/index.html · google-java-format
https://github.com/google/google-java-format · JUnit 5 user guide https://junit.org/junit5/docs/current/user-guide/

## Rules for the Agent

1. Run `google-java-format` (or the repo's Spotless/Checkstyle setup) on every file you touch; never hand-format.
2. Keep `./mvnw verify` / `./gradlew check` green: compile, tests, Checkstyle/SpotBugs if configured.
3. Never catch `Exception`/`Throwable` to swallow it; never return `null` from a collection-returning method.
4. Use the build tool, Java version and frameworks the repo already has; never add a second DI, JSON or HTTP library.
5. Short responses: the diff and at most 3–5 lines of text.
6. Clear task → execute. Destructive step (drop tables, change Java/Spring majors, delete data) → stop and ask.

## Project layout

- Standard layout: `src/main/java`, `src/test/java`, `src/main/resources`; one Gradle/Maven module per deployable, `-api`/`-core` modules when a library is shared.
- Packages by domain (`com.acme.billing`, `com.acme.users`) with `api` (controllers/DTOs), `domain` (model, services), `infra` (repositories, clients) inside each; dependencies point inward. Why: a feature stays cohesive and replaceable.
- One top-level class per file, file named after the class; package-private by default, `public` only for the real API.
- Constructor injection only (final fields); no field injection, no static singletons for services. Why: testable without the container.
- Configuration typed (`@ConfigurationProperties` records / a config class), validated at startup; secrets from the environment or a vault, never in `application.yml` committed to git.
- Immutable data: `record` for DTOs/values, `final` fields, unmodifiable collections (`List.copyOf`).

## Naming

- `UpperCamelCase` classes/interfaces/records/enums, `lowerCamelCase` methods/fields/locals, `UPPER_SNAKE_CASE` constants, packages lowercase without underscores.
- No `I` prefix on interfaces, no `Impl` suffix when there is one implementation — name by role (`JdbcOrderRepository`).
- Acronyms as words: `HttpClient`, `userId`, `parseUrl` (Google style).
- Methods are verbs (`calculateTotal`), booleans read as predicates (`isPaid`, `hasItems`), getters without `get` only in records.
- Test classes `<Class>Test`, methods describe behaviour: `totalIncludesTax_whenRegionRequiresIt`.
- Avoid `Util`/`Helper`/`Manager` classes; put behaviour on the type that owns the data.

## Errors

- Unchecked exceptions for programming errors and most domain failures (`class PaymentDeclinedException extends RuntimeException`); checked only when the caller can realistically recover. Why: checked exceptions leak through every signature.
- Catch specific types; wrap and rethrow with the cause (`throw new BillingException("…", e)`); never lose the cause.
- Handle at the boundary (controller advice, job runner), map to status codes/messages there; never expose stack traces or SQL in responses.
- Return `Optional<T>` for "may be absent" single values; never `Optional` fields, parameters or collections; never `Optional.get()` without `isPresent` — use `orElseThrow`.
- Validate arguments early (`Objects.requireNonNull`, Bean Validation `@Valid` on DTOs); fail fast with a clear message.
- `try-with-resources` for every `AutoCloseable`; `finally` only for non-resource cleanup.
- Logging via SLF4J, parameterised (`log.info("order {} paid", id)`), never string concatenation; never log secrets or personal data; log or rethrow, not both.

## Concurrency

- Prefer immutability and message passing; share mutable state only through `java.util.concurrent` types (`ConcurrentHashMap`, `AtomicLong`) or guarded by one lock.
- Never create raw `Thread`s in application code; use an `ExecutorService` (virtual threads on 21+: `Executors.newVirtualThreadPerTaskExecutor()`) owned and shut down by the application.
- Timeouts on every outbound call (`HttpClient` `connectTimeout` + request `timeout`, JDBC `queryTimeout`); bound queues and pools.
- `CompletableFuture` chains end with a handler; never block (`join()`/`get()`) on a request thread in a reactive stack.
- `synchronized`/`ReentrantLock` sections tiny; no I/O while holding a lock; document lock order if more than one.
- `@Transactional` methods must be called through the proxy (not `this.`) and kept short; no remote calls inside a transaction.
- Scheduled jobs idempotent and single-instance (lock or leader election) when the service scales out.

## Data access & SQL safety

- Parameterised queries only: `PreparedStatement` placeholders, `JdbcTemplate` with args, JPQL/Criteria with parameters, jOOQ typed DSL; never concatenate user input into SQL. Why: injection.
- Repository/DAO per aggregate returning domain types or records, not `ResultSet`s or JPA entities to the web layer.
- JPA: `fetch = LAZY` by default, `@EntityGraph`/`join fetch` to avoid N+1, `open-in-view: false`, `equals/hashCode` on business keys.
- Transactions at the service layer, read-only where applicable; pool (HikariCP) sized explicitly.
- Migrations with the repo's tool (versioned SQL or changelog files), one logical change each, never edited after being applied in a shared environment.
- Validate and size-limit inputs (`@Size`, `@Max`) before they reach the database.

## Testing

- JUnit 5 (`@Test`, `@ParameterizedTest`, `@Nested`), AssertJ assertions (`assertThat(total).isEqualTo(…)`), Mockito only at the boundary.
- Unit tests instantiate the class directly with fakes; no Spring context. Why: milliseconds, not seconds.
- Slice tests (`@WebMvcTest`, `@DataJpaTest`) for the boundary; full `@SpringBootTest` for a few end-to-end paths.
- Database tests against the real engine via Testcontainers, not H2, when SQL matters.
- Given–when–then structure; one behaviour per test; no shared mutable state between tests.
- Test error paths with `assertThatThrownBy(...).isInstanceOf(...)`; test time with an injected `Clock`.
- Mutation/coverage tools (JaCoCo, PIT) report, never gate without the user's decision.

## Tooling

| Step | Command | Note |
|---|---|---|
| Format | `google-java-format -i $(git ls-files '*.java')` or `./gradlew spotlessApply` / `./mvnw spotless:apply` | follow the repo's setup |
| Static | `./gradlew checkstyleMain spotbugsMain` / `./mvnw checkstyle:check spotbugs:check` | if configured |
| Build + test | `./gradlew check` / `./mvnw verify` | must pass |
| Deps | `./gradlew dependencyUpdates` / `./mvnw versions:display-dependency-updates` | report; never bump without asking |
| Security | OWASP `dependency-check` plugin if present | report |

Before saying "done": formatted, static analysis clean, `verify`/`check` green, no new `@SuppressWarnings` without a reason.
