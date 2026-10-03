# Go — rules for writing code

**Sources** (open before stating; this file is the condensed, actionable subset):
Effective Go https://go.dev/doc/effective_go · Go Code Review Comments
https://go.dev/wiki/CodeReviewComments · Google Go Style Guide https://google.github.io/styleguide/go/
(decisions and best practices live there; link, do not paraphrase at length) · `testing` package
https://pkg.go.dev/testing · Table-driven tests https://go.dev/wiki/TableDrivenTests

## Rules for the Agent

1. Run `gofmt` (or `goimports`) on every file you touch; never hand-format.
2. Never ignore an error with `_` unless the line says why in a comment. Never `panic` in library code.
3. Keep `go build ./... && go vet ./... && go test ./...` green after every change; fix, do not skip.
4. Follow this file and the project's existing idioms; do not introduce a second pattern for the same job.
5. Short responses: the diff and at most 3–5 lines of text. No restating code you did not change.
6. Clear task → execute. Destructive step (drop data, rewrite history, change dependency versions) → stop and ask.

## Project layout

- One package = one domain, describable in one sentence ("package order manages orders"). Why: cohesion beats layering by type.
- Package names lowercase, singular, no underscores (`order`, not `orders`/`order_service`). Why: they read as prefixes everywhere.
- No `util`, `common`, `helpers` packages — put functions in the domain that uses them. Why: grab-bags grow unbounded and create import cycles.
- `internal/` for code that must not be imported from outside the module. Why: the compiler enforces the boundary.
- `cmd/<binary>/main.go` only wires dependencies; logic lives in packages. Why: keeps `main` testable by omission.
- Avoid `init()`; prefer explicit constructors (`NewService(repo)`) and a `LoadConfig()` called from `main`. Why: hidden side effects break tests.
- Inject interfaces through constructors; never instantiate dependencies inside the consumer. Why: swap for fakes in tests.
- Imports in three blocks: stdlib · third party · this module (goimports does it). Why: diff noise and readability.

## Naming

- Do not repeat the package name: `order.Create`, not `order.CreateOrder`; `health.Status`, not `health.HealthStatus`.
- No `Get` prefix on getters (`o.Name()`); verbs for actions (`Create`, `Update`, `Delete`).
- Acronyms keep one case: `userID`, `httpClient`, `parseURL` — never `userId`, `parseUrl`.
- Receivers 1–2 letters, the same on every method of the type. Why: convention readers expect.
- Interfaces named by behaviour, small (1–3 methods): `Reader`, `Storage`, `Notifier`. Define them where they are **consumed**, not where implemented. Why: the consumer decides what it needs.
- Sentinel errors `ErrNotFound`; error types `NotFoundError`. Document when each occurs.
- Constructors `NewX`; test doubles named by behaviour (`alwaysFailsRepo`), prefixed `fake`/`stub`/`spy`.
- Every package has a doc comment in one file: `// Package order manages orders.`

## Errors

- Return errors; do not log **and** return the same error (double logging). Pick one layer to log, usually the outermost.
- Wrap with context using `%w` when callers need `errors.Is`/`errors.As`; `%v` at boundaries to hide internals. Place `%w` at the end: `fmt.Errorf("load order %s: %w", id, err)`.
- Compare with `errors.Is` / `errors.As`, never by string. Why: messages change; identity does not.
- Do not add redundant words: `fmt.Errorf("failed: %v", err)` adds nothing — return `err`.
- Map storage errors (e.g. `sql.ErrNoRows`) to domain sentinels at the repository boundary. Why: callers never import the driver.
- No `panic` in production paths; acceptable only in `main` for unrecoverable startup invariants. A panic inside a package must be recovered before the public API.
- No shadowing with `:=` in inner scopes when the outer variable exists; use `=`. Why: the classic "err never checked" bug.
- Zero values should be useful or documented as invalid with a constructor that makes a valid one.

## Concurrency

- `context.Context` is the first parameter, named `ctx`, never stored in a struct, always propagated (queries, HTTP calls, goroutines).
- Every goroutine has an owner and a stop condition (cancelled ctx or closed channel). No fire-and-forget. Why: leaks and lost errors.
- `defer wg.Done()` at the top of the goroutine; use `errgroup.Group` when goroutines return errors.
- Share by communicating (channels) when it fits; otherwise protect shared state with `sync.Mutex`/`RWMutex` and keep the critical section tiny.
- Capture loop variables explicitly when launching goroutines on Go < 1.22. Why: data race on the shared variable.
- Run `go test -race ./...` on anything that spawns goroutines.
- Timeouts on every outbound call: `http.Client{Timeout: …}` or `context.WithTimeout`. Why: the default client never times out.

## Data access & SQL safety

- Parameterised queries only (`db.QueryContext(ctx, "… WHERE id = $1", id)`); never build SQL with `fmt.Sprintf` or `+`. Why: injection.
- Always the `…Context` variants (`QueryContext`, `ExecContext`, `WithContext`). Why: cancellation reaches the database.
- `defer rows.Close()` right after a successful `Query`; check `rows.Err()` after the loop.
- Transactions: `BeginTx`, then `defer tx.Rollback()` and an explicit `Commit`; rollback after commit is a no-op.
- Repository returns domain types, never driver/ORM structs. Why: keeps the schema out of the service layer.
- Avoid N+1: batch with `IN (…)` / joins / the ORM's preload instead of querying inside a loop.
- Keep `sql.DB` pool settings explicit (`SetMaxOpenConns`, `SetConnMaxLifetime`). Why: defaults are unbounded.
- Migrations are versioned files in the repo, one logical change each, never edited once applied anywhere shared.

## Testing

- Tests live next to the code (`order/service_test.go`), package `order` for white-box or `order_test` for black-box.
- Table-driven tests with `t.Run(tc.name, …)` for several scenarios; one behaviour per case.
- Names say the scenario: `TestCreate_WhenEmailExists_ReturnsErrConflict`.
- Test behaviour through exported APIs; do not test private functions directly.
- Fakes over mocks; keep reusable doubles in an `<pkg>test` package (`ordertest`).
- `t.Helper()` in helpers, `t.Cleanup` for teardown, `t.Parallel()` where independent.
- Use `testify/require` for fatal checks or plain `if got != want { t.Fatalf(…) }`; no assertion libraries beyond one.
- Integration tests behind a build tag or `testing.Short()` skip; unit tests must run with no network or database.

## Tooling

| Step | Command | Note |
|---|---|---|
| Format | `gofmt -l -w .` or `goimports -w .` | non-negotiable; CI should fail on diff |
| Vet | `go vet ./...` | always |
| Lint | `golangci-lint run` | if `.golangci.yml` exists; otherwise suggest, do not add |
| Test | `go test -race -cover ./...` | `-race` whenever goroutines are involved |
| Deps | `go mod tidy` | after adding or removing imports; never bump versions without asking |
| Static | `staticcheck ./...` | if installed |

Before saying "done": format, vet, tests green, no new `//nolint` without a reason in the same comment.
