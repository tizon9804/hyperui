# React and Next.js — rules for writing code

React rules apply to **every** React codebase (Vite, Remix, Expo…); the Next.js section applies
on top when `next.config.*` exists (App Router, Next 13+; written against Next 16 docs).
Language rules come from `rules-typescript.md`; this file adds the framework layer.

**Sources** (open before stating): Thinking in React https://react.dev/learn/thinking-in-react ·
Rules of React https://react.dev/reference/rules · Rules of Hooks
https://react.dev/reference/rules/rules-of-hooks · Next.js App Router https://nextjs.org/docs/app ·
Fetching data https://nextjs.org/docs/app/getting-started/fetching-data · Caching
https://nextjs.org/docs/app/getting-started/caching · Production checklist
https://nextjs.org/docs/app/guides/production-checklist

## Rules for the Agent

1. Components are pure: same props and state → same JSX; side effects only in event handlers or `useEffect`.
2. Never fetch in `useEffect` when the framework offers a server/loader path; never introduce a data library the repo lacks.
3. `eslint-plugin-react-hooks` must be clean; `tsc --noEmit` and the test runner green.
4. Respect the existing styling approach (CSS modules, Tailwind, styled…) and the design tokens in `.hyperui/design.md`.
5. For UI tasks hand off to the Impeccable `audit` → `polish` pass via `design` before "done".
6. Clear task → execute. Destructive step (delete routes/data, bump React/Next majors) → stop and ask.

## Project layout

- Group by feature/route, not by kind: `features/checkout/{CheckoutForm.tsx, useCheckout.ts, checkout.test.tsx}`. Why: deletable features.
- One component per file, `PascalCase.tsx`; hooks `useX.ts`; colocated test and styles.
- Shared primitives (`Button`, `Dialog`) in `components/ui/`; feature components never imported across features except through an explicit public module.
- Props typed with an `interface XProps`; no `React.FC` (children typed explicitly when needed).
- Keep server-only code (`db`, secrets) in modules marked `import 'server-only'` so a client import fails at build time.

## Naming

- Components and files `PascalCase`; hooks `useThing`; event handlers `handleX` inside, `onX` as props.
- Booleans as predicates (`isLoading`, `hasError`); state setters paired (`[value, setValue]`).
- Context: `ThingContext` + `ThingProvider` + `useThing()` hook that throws outside the provider.
- Avoid `data`, `info`, `item` as names; say what it is (`order`, `invoiceLines`).

## Components, state and hooks (errors live here)

- Hooks at the top level only, in components or other hooks, same order every render. Why: React relies on call order.
- Derive, do not duplicate: compute values from props/state during render instead of mirroring them in state.
- Lift state to the lowest common parent; colocate everything else. Why: fewer re-renders and props.
- Never mutate props, state or anything returned from a hook; produce new objects/arrays.
- `key` is stable identity (an id), never the array index for reorderable lists.
- `useEffect` for synchronising with external systems only (subscriptions, DOM, timers); include every dependency; return a cleanup. Not for computing state and not for fetching when a loader exists.
- Memoise (`useMemo`, `useCallback`, `memo`) only after measuring; React Compiler (React 19) removes most of the need.
- Error boundaries around route segments and risky widgets; show a recoverable UI, log the error with its component stack.
- Forms: controlled inputs or `useActionState` with server actions; validate on both sides; never trust client validation.
- Accessibility is correctness: semantic elements, labels for inputs, focus management in dialogs, `prefers-reduced-motion` respected.

## Async and data

- Fetch on the server when possible (Server Components, loaders); on the client use the repo's data library (TanStack Query/SWR) — not ad-hoc `useEffect` + `fetch`.
- Every async UI path has loading, empty, error and success states; no spinner without a timeout or skeleton strategy.
- Cancel stale requests (`AbortController`) when inputs change; guard against setting state after unmount.
- Parallelise independent fetches (`Promise.all`); stream the slow parts with `Suspense`.

## Next.js (App Router)

- Default to Server Components; add `'use client'` only at the leaves that need state, effects or browser APIs. Why: smaller bundles, secrets stay on the server.
- Fetch in Server Components or Route Handlers with `fetch`/the ORM; pass data down as props. Keep `'use client'` boundaries small.
- Mutations through Server Actions (`'use server'`), validate input with a schema, call `revalidatePath`/`revalidateTag` after writing.
- Caching is explicit: read the current semantics in the Caching guide before using `fetch` options, `cache`, `unstable_cache`, `revalidate` or `dynamic`. Do not assume the defaults of an earlier version.
- `loading.tsx`, `error.tsx`, `not-found.tsx` per route segment; `generateMetadata` for SEO; `next/image` and `next/font` instead of raw tags.
- Route Handlers return typed `Response`; never leak internal error messages; set cache headers deliberately.
- Environment: only `NEXT_PUBLIC_*` reaches the browser; everything else stays server-side.
- Middleware (`proxy.ts` in Next 16; `middleware.ts` earlier) for redirects/headers only; auth decisions also enforced in the page or handler.
- Before shipping, run the Production checklist (bundle analysis, images, fonts, caching, `next build` warnings as errors).

## Data access & SQL safety

- Database access only on the server (Server Components, Route Handlers, Server Actions); never from client code.
- Parameterised queries or the ORM; never build SQL from request input.
- Authorise inside every Server Action and handler (session check + ownership); the client cannot be trusted to hide buttons.

## Testing

- Unit/component: Vitest or Jest with Testing Library; query by role/label (`getByRole('button', { name: /pay/i })`), assert what the user sees.
- Test behaviour, not implementation: no snapshot-everything, no asserting on internal state or hook calls.
- Hooks via `renderHook`; async with `findBy*`/`waitFor`, never fixed timeouts.
- Server Components and Server Actions: test the underlying functions directly; E2E with Playwright for the composed route.
- Mock the network with `msw`, not the data library; never mock React itself.

## Tooling

| Step | Command | Note |
|---|---|---|
| Lint | `npx eslint .` | `eslint-plugin-react-hooks`, `jsx-a11y`; Next: `next lint` / `eslint-config-next` |
| Types | `npx tsc --noEmit` | must pass |
| Test | `npx vitest run` / `npx jest` | Testing Library |
| Build | `next build` / `vite build` | treat warnings as todo items |
| Docs MCP | `next-devtools-mcp` (Next 16+) | see `docs-mcps.md`; offer, never add |

Before saying "done": hooks lint clean, `tsc` clean, tests green, build passes, Impeccable pass requested for UI.
