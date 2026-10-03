# Swift — rules for writing code

Applies to iOS/macOS/watchOS apps (SwiftUI or UIKit/AppKit) and Swift packages.

**Sources** (open before stating): Swift API Design Guidelines
https://www.swift.org/documentation/api-design-guidelines/ · SwiftLint https://github.com/realm/SwiftLint ·
swift-format https://github.com/swiftlang/swift-format · Swift Testing
https://developer.apple.com/documentation/testing · XCTest https://developer.apple.com/documentation/xctest ·
Human Interface Guidelines https://developer.apple.com/design/human-interface-guidelines

## Rules for the Agent

1. Run `swift-format` (or the repo's SwiftFormat) and `swiftlint` on every file you touch; fix, do not disable rules.
2. Build with warnings treated as work items; keep `swift test` / `xcodebuild test` green.
3. Use `async/await` and structured concurrency; never add callbacks or Combine where the repo uses async.
4. Never `try!`, `as!` or force-unwrap outside tests and provably-safe literals; handle the `nil`/`throws` path.
5. For UI tasks hand off to the Impeccable pass via `design`; respect Dynamic Type, Dark Mode and reduced motion.
6. Clear task → execute. Destructive step (delete user data, change bundle id/signing, bump SDK) → stop and ask.

## Project layout

- Swift Package Manager by default: `Sources/<Target>/`, `Tests/<Target>Tests/`; app targets thin, logic in packages. Why: fast tests without the simulator.
- Group by feature (`Features/Checkout/`), with `View`, `ViewModel`/`Model`, `Service` per feature; shared `Core/` for networking, persistence, design system.
- One type per file, file named after the type (`OrderView.swift`, `OrderStore.swift`).
- Dependencies injected through initialisers or an `Environment` value; no singletons beyond system ones.
- `@MainActor` on UI-facing types; isolate everything else from the main thread.
- Secrets never in source or `Info.plist`; use the Keychain for tokens and an `.xcconfig` that is gitignored for build-time values.

## Naming

- Clarity at the call site over brevity: `remove(at: index)`, `insert(_:at:)`; omit needless words (`allViews.remove(cancelButton)`).
- Methods and functions as verb phrases for mutating (`sort()`), noun phrases/`-ed`/`-ing` for non-mutating (`sorted()`, `formingUnion`).
- Booleans read as assertions (`isEmpty`, `hasPendingChanges`); protocols that describe what something is are nouns (`Collection`), capabilities end in `-able`/`-ible` (`Equatable`).
- `UpperCamelCase` types and protocols, `lowerCamelCase` everything else; acronyms uniform (`urlSession`, `userID`).
- Label the first argument when it is not the direct object; drop it when the call reads as a sentence.
- Document every public declaration with a `///` summary sentence.

## Errors

- Model failures as `enum`s conforming to `Error` (`enum PaymentError: Error { case declined(reason: String) }`); add `LocalizedError` only for user-facing text.
- Throw and propagate with `throws`/`try`; `Result` only when storing or passing a failure as a value.
- Never swallow with `try?` unless the absence is truly the same as failure; comment it.
- Convert system errors to domain errors at the boundary (network, persistence); the UI never switches on `URLError`.
- Optionals: `guard let` early returns, `if let` for branches, `??` for defaults; no pyramid of `if let`.
- `fatalError`/`precondition` only for programmer errors that must crash in development; never for bad input or network state.
- Use `defer` for cleanup that must happen on every exit path.

## Concurrency

- Swift concurrency only: `async/await`, `Task`, `TaskGroup`, `actor`. Why: compile-time data-race safety under strict concurrency.
- UI state is `@MainActor`; long work runs off the main actor and returns a value.
- Every `Task` you spawn is stored or structured (child of a `TaskGroup`); cancel on view disappear; check `Task.isCancelled` in loops.
- `Sendable` for anything crossing isolation; protect mutable shared state in an `actor`, not with locks.
- Timeouts on network calls (`URLSessionConfiguration.timeoutIntervalForRequest`) and cancellation via the owning `Task`.
- Enable `-strict-concurrency=complete` (Swift 6 language mode when the repo allows) and fix warnings instead of silencing them.

## Data access & persistence safety

- Persistence through one layer (SwiftData, Core Data, GRDB, or files); the UI talks to a repository type, never to the store directly.
- Raw SQL (GRDB/SQLite) is parameterised (`?` arguments or record queries); never interpolate values.
- Writes happen in a background context/actor; the main actor reads published snapshots.
- Migrations are explicit and versioned (lightweight only when the model change qualifies); test them with a fixture store.
- `Codable` models mirror the wire format; map to domain models in one place; unknown enum cases decode to a fallback.
- Keychain for secrets, `UserDefaults` only for non-sensitive preferences; files in the right container (`Application Support`, `Caches`).
- Validate and sanitise anything shown in a `WKWebView` or passed to a URL.

## Testing

- Swift Testing (`@Test`, `#expect`, `#require`) for new tests on Swift 6 toolchains; XCTest where the repo already uses it. Do not mix in one target without reason.
- Name tests as behaviour: `@Test func totalIncludesTaxWhenRegionRequiresIt()`.
- Inject fakes through initialisers/protocols; no network, filesystem or real Keychain in unit tests.
- `async` tests `await` the real API; no `sleep`, no `XCTestExpectation` when `await` works.
- Parameterised tests (`@Test(arguments:)`) for scenario tables.
- UI logic lives in testable models; UI tests (XCUITest) only for critical flows, using accessibility identifiers.
- Snapshot tests, if used, pinned to one device/OS in CI.

## Tooling

| Step | Command | Note |
|---|---|---|
| Format | `swift format --in-place --recursive Sources Tests` (`swift-format`) | or `swiftformat .` if the repo uses nicklockwood's |
| Lint | `swiftlint --fix && swiftlint` | respect `.swiftlint.yml`; never add `disable` comments to pass |
| Build | `swift build` / `xcodebuild -scheme <S> build` | warnings are work items |
| Test | `swift test` / `xcodebuild test -scheme <S> -destination '…'` | keep green |
| Deps | SwiftPM `Package.swift` | never bump versions without asking |

Before saying "done": formatted, lint clean, no force unwraps added, tests green, Impeccable pass requested for UI.
