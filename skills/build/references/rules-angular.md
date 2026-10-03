# Angular — rules for writing code

Applies when `angular.json` exists (Angular 17+; written against the v20+ docs: standalone,
signals, new control flow). Language rules come from `rules-typescript.md`.

**Sources** (open before stating): Angular Style Guide https://angular.dev/style-guide ·
Best practices https://angular.dev/best-practices · Testing https://angular.dev/guide/testing ·
Angular CLI MCP https://angular.dev/ai/mcp (`get_best_practices`, `search_documentation`)

## Rules for the Agent

1. Use the Angular CLI for everything it can do (`ng generate`, `ng test`, `ng lint`, `ng update`); never hand-wire what a schematic creates.
2. Standalone components, signals and the built-in control flow (`@if`, `@for`, `@switch`) by default; `NgModule` and `*ngIf` only when the repo still uses them.
3. Keep `ng lint`, `ng test` and `ng build` green; `strict` templates on.
4. When the Angular CLI MCP is connected, call `get_best_practices` before writing and `search_documentation` for any API you are unsure of; otherwise open angular.dev. Never add the MCP yourself.
5. For UI tasks hand off to the Impeccable pass via `design`; respect the tokens in `.hyperui/design.md`.
6. Clear task → execute. Destructive step (delete routes/data, `ng update` majors) → stop and ask.

## Project layout

- Feature folders (`src/app/checkout/`), each with its routes, components, services and tests; `src/app/core/` for app-wide singletons, `src/app/shared/` for dumb reusable UI. Why: lazy-loadable, deletable features.
- One component/directive/pipe/service per file; file names `feature-name.component.ts` or the v20 style (`feature-name.ts`) — follow the repo's convention, not both.
- Lazy-load every feature route (`loadComponent`/`loadChildren`); eager only the shell.
- Smart (route-level) components fetch and coordinate; presentational components take `input()` and emit `output()`. Why: testability and reuse.
- `providedIn: 'root'` services; no provider arrays in components unless scope demands it.
- Environment config via `environment.ts` files or injected tokens; secrets never in the bundle (everything in Angular ships to the browser).

## Naming

- Selectors prefixed per app/library (`app-order-list`), `kebab-case` elements, `camelCase` attribute directives.
- Classes `UpperCamelCase` with the type suffix the repo uses (`OrderListComponent` or `OrderList`), services end in what they do (`OrderApi`, `CartStore`).
- Signals are nouns (`items`, `total`), setters/actions are verbs (`addItem`); `input()`/`output()` names without `on` prefix (`(saved)` not `(onSaved)`).
- Pipes `camelCase` names, `UpperCamelCase` classes ending in `Pipe`.
- Booleans read as predicates (`isOpen`, `hasErrors`).

## Errors

- A single `ErrorHandler` implementation logs unexpected errors; `HttpInterceptorFn` maps HTTP failures to domain errors and retries only idempotent calls.
- Services return typed results (`Observable<Order>`/`Promise<Order>`); never swallow with `catchError(() => of(null))` unless the null is handled and commented.
- Components show error states explicitly (`@if (error()) {…}`); no silent empty screens.
- Forms: typed reactive forms (`FormGroup<{...}>`), validators declared once, server-side validation always repeated.
- Never use `any` for HTTP responses; declare the interface and validate when the contract is unreliable.
- Never bypass sanitisation (`bypassSecurityTrust*`) unless the value is provably safe and the reason is documented; never build templates from strings.

## Async / reactivity

- Signals for component and store state (`signal`, `computed`, `effect` sparingly); RxJS for streams of events and HTTP, converted at the edge with `toSignal`/`toObservable`.
- `OnPush` change detection on every component (zoneless-ready); mutate state only through signals or immutable updates.
- Subscriptions are owned: prefer the `async` pipe or `toSignal`; manual `subscribe` only with `takeUntilDestroyed()`.
- No nested subscribes; compose with `switchMap`/`concatMap`/`exhaustMap` chosen deliberately (cancel vs queue vs ignore).
- `effect()` for synchronising with the outside world only, never for deriving state (use `computed`).
- Cancel on navigation: `switchMap` on route params; `resolve` only for data the page cannot render without.
- Use `inject()` in functions and constructors consistently; avoid constructor-parameter injection in new code when the repo uses `inject()`.

## Data access & SQL safety

- All data goes through `HttpClient` in a service; components never call `fetch` or talk to storage directly.
- Interceptors add auth headers and correlation ids; tokens live in memory or `HttpOnly` cookies set by the server, not `localStorage`.
- Any SQL belongs to the backend; the Angular app sends typed DTOs and treats every response as untrusted (validate shape before trusting).
- Sanitise user content; Angular's template binding escapes by default — keep it that way (no `innerHTML` with untrusted input).
- Pagination, debouncing (`debounceTime`) and caching (`shareReplay(1)` with care) at the service layer to avoid request storms.

## Templates and UI

- Built-in control flow (`@if`, `@for` with `track`, `@switch`, `@defer` for below-the-fold); `track` by id, never by index for mutable lists.
- Templates hold no logic beyond bindings; move expressions to `computed()` or pipes.
- Images with `NgOptimizedImage`; fonts and critical CSS inlined by the CLI budget; keep bundle budgets in `angular.json` green.
- Accessibility: semantic elements, `aria-*` where semantics are missing, focus management in dialogs, Angular CDK a11y utilities; `prefers-reduced-motion` respected in animations.
- i18n via `$localize`/`i18n` attributes when `product_languages` has more than one entry.

## Testing

- Unit tests with the CLI runner (Karma/Jasmine, Jest or Vitest — whatever `angular.json` says) using `TestBed` only when DI/template is involved; plain `new Service(fake)` otherwise.
- Component tests use the harness pattern (`ComponentFixture`, CDK test harnesses) and query by role/text; set `input()`s via `fixture.componentRef.setInput`.
- HTTP with `provideHttpClientTesting` + `HttpTestingController`; never hit the network.
- Signals: assert `component.total()` after `fixture.detectChanges()`; `fakeAsync`/`tick` or `await fixture.whenStable()` for async.
- Names describe behaviour: `it('disables pay button when cart is empty', …)`.
- E2E with Playwright for critical flows only; user-visible locators, independent tests.

## Tooling

| Step | Command | Note |
|---|---|---|
| Generate | `ng generate component checkout/order-list` | schematics keep conventions |
| Lint | `ng lint` (angular-eslint) | add via `ng add angular-eslint` if absent — ask first |
| Format | `npx prettier --write .` | if configured |
| Test | `ng test --watch=false` | CI mode |
| Build | `ng build` | budgets must pass |
| Update | `ng update` | report available updates; never run majors without asking |
| Docs MCP | `npx @angular/cli mcp` | see `docs-mcps.md`; offer, never add |

Before saying "done": lint clean, `tsc`/templates strict, tests green, build within budgets, Impeccable pass requested for UI.
