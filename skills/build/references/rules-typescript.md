# TypeScript (and JavaScript) — rules for writing code

Covers **JavaScript too**: every rule that is not about types applies unchanged to `.js`/`.mjs`
files; for JS projects prefer JSDoc types + `// @ts-check` over leaving things untyped.

**Sources** (open before stating): TS Handbook Do's and Don'ts
https://www.typescriptlang.org/docs/handbook/declaration-files/do-s-and-don-ts.html · Google
TypeScript Style Guide https://google.github.io/styleguide/tsguide.html · typescript-eslint
https://typescript-eslint.io/ · Airbnb JavaScript Style Guide https://github.com/airbnb/javascript ·
Vitest https://vitest.dev/guide/ · Playwright best practices https://playwright.dev/docs/best-practices

## Rules for the Agent

1. Run the project's formatter (`prettier`) and `eslint --fix` on every file you touch; never hand-format.
2. `tsc --noEmit` must pass; no `any`, no `@ts-ignore` (use `@ts-expect-error` with a reason if unavoidable).
3. Keep the test runner green (`vitest`/`jest`); a red test you did not write is a signal.
4. Use the module system, package manager and config the repo already has (`package.json`, lockfile); never switch them.
5. Short responses: the diff and at most 3–5 lines of text.
6. Clear task → execute. Destructive step (delete data, bump dependency majors, rewrite history) → stop and ask.

## Project layout

- `src/` by feature (`src/billing/`, `src/users/`), not by kind (`controllers/`, `utils/`). Why: a feature is deletable and readable in one place.
- ES modules only (`import`/`export`); no `require` in new code; set `"type": "module"` or respect what the repo has.
- Named exports; default exports only where a framework demands them (pages, config). Why: refactors and auto-imports work.
- One concept per file; files `kebab-case.ts`, except framework conventions (`Component.tsx`).
- Barrel files (`index.ts`) only at package boundaries; avoid them inside a feature. Why: circular imports and slow bundles.
- `tsconfig`: `strict: true`, `noUncheckedIndexedAccess: true`, `exactOptionalPropertyTypes` when feasible; do not loosen an existing config.
- Environment variables read in one module, validated at startup (`zod`/`valibot`), typed; never `process.env.X!` scattered around.

## Naming

- `camelCase` variables/functions, `PascalCase` types/classes/components/enums, `UPPER_SNAKE_CASE` only for true constants.
- No `I` prefix on interfaces, no `T` suffix on types; name by role (`User`, `UserRepository`).
- Booleans read as predicates (`isOpen`, `hasAccess`, `canEdit`); functions are verbs; collections are plural.
- Prefer `interface` for object shapes you extend, `type` for unions, tuples and mapped types; stay consistent with the repo.
- Avoid abbreviations beyond the universal ones (`id`, `url`, `db`).
- Use `unknown` not `any` for values of unknown shape, then narrow.

## Errors

- `throw` only `Error` (or subclasses); never throw strings or objects. Why: stack traces and `instanceof`.
- Custom error classes per domain (`class NotFoundError extends Error`), with `cause` (`new Error(msg, { cause })`).
- Catch at boundaries (request handler, CLI entry, event loop), not around every call; let the rest propagate.
- In `catch (err)` the value is `unknown`: narrow with `instanceof` before using it.
- Never swallow: an empty `catch {}` needs a comment saying why. Log or rethrow, not both.
- Prefer returning a typed result (`{ ok: true, value } | { ok: false, error }`) for expected failures in domain code; exceptions for unexpected ones.
- Exhaustive `switch` over unions with a `never` default. Why: the compiler catches new variants.
- Use `===`; avoid `==` except `== null`. Prefer `??` and `?.` over `||` for defaults.

## Concurrency / async

- `async/await` over raw `.then` chains; never mix the two in one function.
- Always `await` or return a promise; floating promises are bugs (`@typescript-eslint/no-floating-promises`).
- Independent awaits → `Promise.all` / `Promise.allSettled`; sequential awaits only when the order matters. Why: latency.
- Every outbound call gets a timeout and cancellation (`AbortSignal.timeout(ms)` / `AbortController`).
- Do not block the event loop with sync I/O (`fs.readFileSync`) or heavy loops in a server; offload with workers.
- Avoid `async` in `forEach`; use `for … of` or `Promise.all(array.map(...))`.
- Handle `unhandledRejection` once at the process entry; do not rely on it for flow.

## Data access & SQL safety

- Parameterised queries only (`db.query('… WHERE id = $1', [id])`, tagged templates, or the ORM's query builder); never template-literal SQL. Why: injection.
- Prefer a typed layer (Drizzle, Prisma, Kysely); raw SQL stays parameterised and lives in the repository module.
- Watch N+1 in loops and in resolvers; batch (`IN (...)`, `dataloader`) or join.
- Transactions explicit and short; never await a network call inside one.
- Validate everything that crosses the boundary (request body, env, external JSON) with a schema; TypeScript types are erased at runtime.
- Never trust `JSON.parse` output as a typed value without validation.
- Migrations generated by the tool, reviewed, one logical change each.

## Testing

- Runner: what the repo has; default `vitest` for new projects (`jest` when present). File `foo.test.ts` next to `foo.ts` or under `tests/` — follow the repo.
- `describe('unit')` + `it('does X when Y')`: one behaviour per test, arrange–act–assert, no shared mutable state between tests.
- Test behaviour through the public API; do not export internals just to test them.
- Mock at the boundary (`vi.mock` for modules doing I/O, `msw` for HTTP, fake timers for time); never mock the unit under test.
- Async tests `await` everything; use `expect(promise).rejects.toThrow(SpecificError)`.
- E2E with Playwright: user-visible locators (`getByRole`), independent tests, no fixed `sleep`s, web-first assertions.
- Type-level checks with `expectTypeOf` when a public type is the contract.

## Tooling

| Step | Command | Note |
|---|---|---|
| Types | `npx tsc --noEmit` | or `pnpm/yarn` equivalent; must pass |
| Lint | `npx eslint . --fix` | typescript-eslint `recommended-type-checked` when configuring |
| Format | `npx prettier --write .` | if a config exists; otherwise ask before adding |
| Test | `npx vitest run` / `npx jest` | `--coverage` only when configured |
| Deps | `npm/pnpm/yarn install` with the existing lockfile | never change the package manager; never bump majors without asking |
| Audit | `npm audit` / `pnpm audit` | report, do not auto-fix majors |

Before saying "done": `tsc` clean, eslint clean, formatted, tests green, no new `eslint-disable` without a reason.
