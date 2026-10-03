# Rust — rules for writing code

**Sources** (open before stating): Rust API Guidelines https://rust-lang.github.io/api-guidelines/ ·
Clippy https://doc.rust-lang.org/clippy/ · The Rust Programming Language https://doc.rust-lang.org/book/
(testing: https://doc.rust-lang.org/book/ch11-00-testing.html) · rustfmt https://github.com/rust-lang/rustfmt

## Rules for the Agent

1. Run `cargo fmt` and `cargo clippy --all-targets -- -D warnings` on every change; fix lints, do not `#[allow]` them without a reason.
2. No `unwrap()`/`expect()` in library or server paths; propagate with `?`. Tests and `main` prototypes may `expect("why")`.
3. No `unsafe` unless the task requires it, each block with a `// SAFETY:` comment proving the invariant.
4. Keep `cargo test` green; `cargo build` with no warnings.
5. Use the crates and async runtime the repo already has (`tokio`/`async-std`, `sqlx`/`diesel`); never add a parallel one.
6. Clear task → execute. Destructive step (delete data, change MSRV/edition, bump major deps) → stop and ask.

## Project layout

- One crate per deployable or library; a workspace (`Cargo.toml` `[workspace]`) when there are several. Why: compile times and clear boundaries.
- `src/lib.rs` holds the logic, `src/main.rs` only parses args/config and calls `lib`. Why: integration tests and benches can use the library.
- Modules by domain (`src/billing/mod.rs` or `src/billing.rs` + `src/billing/`), `pub(crate)` by default, `pub` only for the real API.
- Re-export the public surface from `lib.rs`; keep internal paths private so refactors do not break users.
- Config from environment/files through one typed struct (`serde` + `config`/`envy`), validated at startup; secrets never in source.
- `Cargo.lock` committed for binaries; MSRV declared with `rust-version`.
- Edition: the repo's; new crates use the latest stable edition.

## Naming

- `snake_case` functions, methods, modules, variables; `UpperCamelCase` types, traits, enum variants; `SCREAMING_SNAKE_CASE` constants/statics.
- Conversions follow `as_` (cheap borrow), `to_` (expensive/owned), `into_` (consuming); getters have no `get_` prefix.
- Iterator-producing methods: `iter`, `iter_mut`, `into_iter`; builder methods take `self` or `&mut self` consistently.
- Acronyms as words: `HttpClient`, `Uuid`, `parse_url`.
- Error types named `Error` inside their module (`billing::Error`) or `XError` at the crate root; error enums' variants describe the cause.
- Crates and features `kebab-case`; types implement the common traits (`Debug`, `Clone`, `PartialEq`, `Default`) when it makes sense (C-COMMON-TRAITS).

## Errors

- Libraries define an error `enum` deriving `thiserror::Error` with `#[from]` conversions; binaries may use `anyhow::Result` and `.context("…")`. Why: callers match on library errors; binaries just report.
- Propagate with `?`; convert at module boundaries with `From` impls or `map_err`; never stringify an error you may need to match later.
- Implement `std::error::Error` + `Display` for every public error; keep `source()` chains intact.
- `Option` for "may be absent", `Result` for "may fail"; do not encode errors as `Option`.
- `panic!`/`unreachable!` only for invariants that cannot be violated by input; document them. Validate external input and return errors.
- Make invalid states unrepresentable: newtypes (`struct Email(String)`) with a validating constructor, enums over boolean flags.
- Logging/tracing via `tracing` (or the repo's logger) with structured fields; never log secrets.

## Concurrency / async

- One async runtime per binary (usually `tokio`); never block the runtime (`std::thread::sleep`, sync I/O) — use `tokio::task::spawn_blocking` for blocking work.
- Spawned tasks are owned: keep the `JoinHandle` or use a `JoinSet`; handle panics/errors from joins.
- Cancellation-safe code: prefer `tokio::select!` with care, `CancellationToken` for shutdown, timeouts with `tokio::time::timeout` on every outbound call.
- Share state with `Arc<Mutex<_>>`/`RwLock` (`tokio::sync` when held across `.await`, `std::sync` otherwise) and keep critical sections tiny; prefer channels (`mpsc`, `watch`) for ownership transfer.
- `Send + Sync` bounds on anything crossing tasks; let the compiler reject the rest.
- CPU-parallel work with `rayon` iterators, not hand-rolled threads.
- Avoid holding a lock or a database connection across `.await`.

## Data access & SQL safety

- Parameterised queries only: `sqlx::query!("… WHERE id = $1", id)` / `query_as`, `diesel` DSL, `rusqlite` with `params![]`; never `format!` SQL. Why: injection.
- Prefer compile-time checked queries (`sqlx` macros with an offline `.sqlx` dir) or the ORM's typed DSL.
- Connection pool (`sqlx::Pool`, `r2d2`, `deadpool`) created once, sized explicitly, passed by reference/`Arc`.
- Transactions explicit (`pool.begin().await?` … `tx.commit().await?`); dropping without commit rolls back — rely on that for the error path.
- Repository returns domain structs, not rows; map `NotFound` to a domain error at the boundary.
- Migrations as versioned files (`sqlx migrate`, `diesel migration`, `refinery`), one logical change each, never edited once applied anywhere shared.
- `serde` structs for the wire with `#[serde(deny_unknown_fields)]` where strictness matters; validate ranges after deserialising.

## Testing

- Unit tests in the same file under `#[cfg(test)] mod tests`; integration tests in `tests/` exercising the public API; doc tests for examples in `///` comments.
- Names describe behaviour: `fn total_includes_tax_when_region_requires_it()`.
- `#[should_panic(expected = "…")]` only for invariant checks; test error paths by matching the `Err` variant.
- Fakes via traits + generics or `Box<dyn Trait>`; keep I/O behind traits so units run without network or database.
- Async tests with `#[tokio::test]`; database tests behind a feature flag or env var, using a temp schema/`sqlx::test`.
- Property tests (`proptest`) for parsers and encoders; snapshot tests (`insta`) for serialised output.
- `cargo test -- --nocapture` for debugging only; tests must be deterministic and independent.

## Tooling

| Step | Command | Note |
|---|---|---|
| Format | `cargo fmt --all` | `rustfmt.toml` if present |
| Lint | `cargo clippy --all-targets --all-features -- -D warnings` | fix, do not allow |
| Build | `cargo build` | no warnings |
| Test | `cargo test --all-features` | plus `cargo doc --no-deps` so doc tests and links compile |
| Deps | `cargo add`/`cargo update -p <crate>` | never bump majors without asking; `cargo audit`/`cargo deny` if installed |
| Watch | `cargo watch -x check -x test` | optional, for TDD loops |

Before saying "done": fmt clean, clippy clean, no new `unwrap`/`allow`/`unsafe` without justification, tests green.
