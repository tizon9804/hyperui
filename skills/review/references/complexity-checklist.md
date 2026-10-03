# Complexity checklist

Language-agnostic. Framing rule: complexity is a finding only if it **grows with the data or
with real usage**. A nested loop over two fixed three-element lists is not a problem.

## 1. Algorithmic complexity

For each function in scope, estimate cost as a function of input size and ask who controls
that size — the system or the user?

- **Nested loops over unbounded collections** → O(n²) where a map/index gives O(n).
- **N+1**: a query, HTTP call or file read **inside a loop**. The most frequent finding;
  in a request handler it is almost always `blocking`. Fix: one batched query (`IN`, join,
  dataloader) and a map keyed by id.
- **Unbounded reads**: `SELECT` without `LIMIT`/pagination, loading a whole table to filter in
  code what the DB filters better, reading a whole file or response that could be streamed.
- **Repeated work in loops**: recomputing the same value each iteration, sorting inside the
  loop, parsing config per request, compiling the same regex each call.
- **String concatenation in a loop** where the language makes it O(n²) → builder / join.
- **Recursion without memoization or a depth cutoff** (and on user-shaped input, a stack-overflow DoS).
- **Wrong data structure**: repeated linear search in a list where a set or map belongs.
- **Missing index** on the columns a new query filters, joins or sorts by.
- **Unbounded growth**: caches, maps, arrays, queues or listeners that only grow (no TTL, max
  size or cleanup); retries without a cap or backoff; polling with no stop condition.
- **Frontend**: work inside render that should be memoized, effects that refetch on every
  render, lists of thousands of rows without virtualization.

Phrase it with the current cost, the proposed cost and the trigger:

```
handler.ts:57 — blocking: query per user inside the loop (N+1)
  Why: 500 users = 500 DB round trips in a synchronous endpoint; the timeout hits first.
  Fix: fetch all profiles in one query with IN and build a Map keyed by userId. O(n) queries → 1.
```

## 2. Cyclomatic complexity

Count decision points: `1 + (if | else if | for | while | case | catch | && | || | ?: | ??)`.
`else` and `default` do not count. McCabe's limit is 10 (NIST Structured Testing allows up to
15 with a written reason).

| Value | Class |
|---|---|
| ≤ 10 | no finding |
| 11 – 15 | `should` — extract conditions, guard clauses |
| > 15 | `should`, raised to `blocking` in code hyperui just wrote — refactor before "done" |

Beyond the number:

- **Nesting deeper than 3 levels** → invert conditions, return early.
- **Functions longer than ~60 lines**, or doing more than their name says.
- **Boolean parameters that switch behavior** (`process(data, true)`) → two functions.
- **Unreadable compound conditions** → a named variable or predicate function.
- **The same `if` chain duplicated** in several places → a table, map or polymorphism.
- **A `switch` that grows with every feature** → a missing abstraction.

## 3. How to measure

Cite the number from a tool when the repo has one; otherwise count by hand and say so.
- JS/TS: ESLint `complexity` (default threshold 20 — set 10), `max-depth`,
  `max-lines-per-function`. Python: `radon cc -s`, Ruff `C901`. Go: `gocyclo -over 10 .`.
  Many languages: `lizard`. Platforms: SonarQube cyclomatic / cognitive complexity.
- Algorithmic cost: reason from the code first; measure only when it is disputed (query log
  with a counter, `EXPLAIN` on the new query, a quick benchmark with realistic n).

## What NOT to flag

- Complexity in tests, fixtures, mocks or generated code.
- Micro-optimizations with no measurable impact (swapping `for` for `map` "just because").
- Optimizing bounded, small data that will not grow.
- A large refactor during a hotfix — leave it as a note in `state.md` `open:`.

Sources: https://en.wikipedia.org/wiki/Cyclomatic_complexity ·
https://eslint.org/docs/latest/rules/complexity · https://eslint.org/docs/latest/rules/max-depth ·
https://eslint.org/docs/latest/rules/max-lines-per-function · https://radon.readthedocs.io/en/latest/ ·
https://docs.astral.sh/ruff/rules/complex-structure/ · https://github.com/fzipp/gocyclo ·
https://github.com/terryyin/lizard ·
https://docs.sonarsource.com/sonarqube-server/latest/user-guide/code-metrics/metrics-definition/
