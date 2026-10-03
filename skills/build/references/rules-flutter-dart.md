# Flutter and Dart — rules for writing code

Dart rules apply to any Dart code (CLI, server, packages); the Flutter section applies when
`pubspec.yaml` depends on `flutter`.

**Sources** (open before stating): Effective Dart https://dart.dev/effective-dart · Flutter
architecture guide https://docs.flutter.dev/app-architecture/guide · Flutter testing
https://docs.flutter.dev/testing/overview · Dart & Flutter MCP server
https://github.com/dart-lang/ai/tree/main/pkgs/dart_mcp_server · Material 3 https://m3.material.io/

## Rules for the Agent

1. Run `dart format .` and `dart analyze` (or `flutter analyze`) on every change; fix every warning, do not `// ignore:` to pass.
2. Keep `flutter test` / `dart test` green; a red test you did not write is a signal.
3. Use the state-management and DI approach the repo already has; never add a second one.
4. For UI tasks hand off to the Impeccable pass via `design`; respect text scaling, dark theme and reduced motion.
5. Prefer the Dart/Flutter docs MCP (`dart mcp-server`) when connected for API questions; otherwise open the docs. Never add the MCP yourself.
6. Clear task → execute. Destructive step (delete user data, change app id/signing, bump SDK constraints) → stop and ask.

## Project layout

- Layered as the architecture guide describes: `ui/` (views + view models), `domain/` (models, use cases when logic is shared), `data/` (repositories, services). Why: testable layers with one direction of dependency (UI → domain → data).
- Group by feature inside each layer (`lib/ui/checkout/`, `lib/data/repositories/order_repository.dart`).
- Repositories own data sources and caching; services wrap one external API each; view models expose immutable UI state.
- `lib/` for app code, `test/` mirroring `lib/`, `integration_test/` for device tests.
- Dependency injection via constructor parameters, provided at the top (`provider`, `riverpod`, `get_it` — whatever the repo has).
- Secrets never in Dart source or `pubspec`; pass with `--dart-define` and read via `String.fromEnvironment`.
- Package `name` in `pubspec.yaml` and directory names `snake_case`.

## Naming

- `UpperCamelCase` types, extensions, enums; `lowerCamelCase` members, variables, constants, enum values; `snake_case` files and directories.
- Acronyms capitalised like words: `HttpRequest`, `userId`, `Db`.
- No prefix letters on types or members; no `_` on local variables unless unused.
- Booleans as predicates (`isEnabled`, `hasItems`); getters are nouns, methods are verbs.
- Private members start with `_`; keep them in the library that uses them.
- Doc comments `///` on public APIs, one-sentence summary first.

## Errors

- Throw `Exception` subtypes for recoverable conditions and `Error` subtypes only for programmer mistakes; never throw strings.
- Define domain exceptions (`class PaymentDeclinedException implements Exception`) in the data/domain layer; the UI never catches `DioException`/`HttpException` directly.
- Catch specific types (`on FormatException catch (e)`), rethrow with `rethrow`; never an empty `catch (_) {}`.
- Prefer a sealed `Result` type (`sealed class Result<T>` with `Ok`/`Err`) across the repository boundary when failures are expected; exceptions for the unexpected.
- Null safety: avoid `!`; use `?.`, `??`, `late` only when initialisation is guaranteed before use, and `required` named parameters.
- Validate inputs at the edge (forms, JSON) and fail with a message the UI can show.
- Log with `dart:developer log` or the repo's logger, never `print` in app code; never log tokens or personal data.

## Concurrency / async

- `async/await` over raw `Future.then`; always return or await a `Future` (`unawaited(...)` only with a comment).
- Isolates (`Isolate.run`, `compute`) for CPU-heavy work (parsing big JSON, image processing). Why: the UI isolate must not jank.
- Every network call has a timeout (`.timeout(const Duration(seconds: 10))` or the client's option) and handles cancellation (`CancelToken` in dio).
- Streams: cancel subscriptions in `dispose`; prefer `StreamBuilder`/the state library's stream support over manual listening.
- Never call `setState` or mutate state after `dispose`; check `mounted` after an `await` in widget code.
- Avoid starting work in `build()`; start it in `initState`, the view model, or a provider.

## Data access & SQL safety

- SQL (`sqflite`, `drift`, `sqlite3`) parameterised only (`?` placeholders or drift's typed queries); never interpolate values. Why: injection and quoting bugs.
- Repositories expose domain models, not rows or DTOs; JSON mapping in one `fromJson`/`toJson` per model (consider `freezed`/`json_serializable` if the repo uses them).
- Transactions short and explicit; writes off the UI isolate when large.
- Schema migrations versioned (`onUpgrade` or drift migrations), tested against a fixture database.
- Secure storage (`flutter_secure_storage`) for tokens; `shared_preferences` only for non-sensitive values.
- Treat every server response as untrusted: validate shape and ranges before using it in UI or storage.

## Flutter widgets

- Small, composable widgets; extract a widget (not a helper method) when `build` grows. Why: rebuild boundaries and `const` constructors.
- `const` constructors everywhere possible; `Key`s when lists reorder; avoid rebuilding whole trees — rebuild the leaf that changed.
- Theme everything through `ThemeData`/`ColorScheme` and text styles; no hardcoded colours or sizes; use the tokens from `.hyperui/design.md`.
- Layout adapts: `LayoutBuilder`/`MediaQuery` breakpoints, `SafeArea`, text scaling tested at 1.3×.
- Navigation with the repo's router (`go_router`, Navigator 2.0) and typed routes; deep links handled.
- Accessibility: `Semantics` labels on custom widgets, tap targets ≥ 48 dp, contrast per Material 3.

## Testing

- Unit tests for view models, repositories, use cases (`test/`), fakes injected through constructors; no network or real database.
- Widget tests (`testWidgets`, `WidgetTester`) for UI behaviour: pump, find by text/key/semantics, assert; `pumpAndSettle` with care for infinite animations.
- Integration tests (`integration_test/`) only for critical flows; run on CI devices or emulators.
- Golden tests, if used, pinned to one platform and font set.
- Name tests as behaviour: `test('total includes shipping when cart is not empty', ...)`; `group` by unit.
- Mocks with `mocktail`/`mockito` at the boundary only; never mock the class under test.

## Tooling

| Step | Command | Note |
|---|---|---|
| Format | `dart format .` | non-negotiable |
| Analyze | `dart analyze` / `flutter analyze` | use `package:flutter_lints` or `package:lints` via `analysis_options.yaml` |
| Test | `flutter test` / `dart test` | `--coverage` when configured |
| Deps | `flutter pub get` / `dart pub get`; `dart pub outdated` to report | never bump without asking |
| Fix | `dart fix --apply` | for analyzer-suggested migrations, review the diff |
| Docs MCP | `dart mcp-server` | see `docs-mcps.md`; offer, never add |

Before saying "done": formatted, analyzer clean, tests green, no new `ignore:` comments, Impeccable pass requested for UI.
