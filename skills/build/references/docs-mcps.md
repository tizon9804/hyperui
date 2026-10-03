# Docs-on-demand MCP servers

Use the official docs instead of memory. Policy (REQ-018): when one of these fits the task,
**show the exact line below and ask**; the user runs it. Never run `claude mcp add` yourself,
never paste a secret into a command (point to an env var). Without an MCP, `WebFetch` the docs
URL. Syntax verified 2026-10-03 at https://code.claude.com/docs/en/mcp: options (`--scope|-s`,
`--transport|-t`, `--header|-H`, `--env|-e`) go **before** the server name; stdio commands go
after `--`; `--scope user` makes it available in every project, the default `local` only here.

| Server | What it is for | Install line (user runs it) | Docs |
|---|---|---|---|
| **Context7** | Version-specific docs and code examples for any library (`resolve-library-id` → `get-library-docs`). Default pick for "how does X work in version Y". | Remote: `claude mcp add --scope user --transport http context7 https://mcp.context7.com/mcp` · Local: `claude mcp add --scope user context7 -- npx -y @upstash/context7-mcp` · Optional key for higher limits: add `--header "Authorization: Bearer $CONTEXT7_API_KEY"` (remote) or `--api-key $CONTEXT7_API_KEY` (local). Interactive alternative: `npx ctx7 setup` (Node ≥ 18). | https://context7.com/docs/resources/all-clients · https://github.com/upstash/context7 |
| **Next.js devtools MCP** | Next.js **16+**: version-accurate Next docs plus live dev-server data (`get_errors`, `get_logs`, `get_routes`, `get_page_metadata`, `get_project_metadata`, `get_server_action_by_id`; Turbopack: `get_compilation_issues`, `compile_route`). Auto-discovers the dev server's built-in `/_next/mcp` endpoint. | `claude mcp add next-devtools -- npx -y next-devtools-mcp@latest` (the docs show the equivalent `.mcp.json`) | https://nextjs.org/docs/app/guides/mcp |
| **Angular CLI MCP** | Angular team's server: `get_best_practices`, `search_documentation` (angular.dev), `list_projects`, `run_target`, dev-server control, `onpush_zoneless_migration`, `ai_tutor`. Add `--read-only` / `--local-only` to restrict. | `claude mcp add angular-cli -- npx -y @angular/cli mcp` | https://angular.dev/ai/mcp |
| **Dart & Flutter MCP** | Official Dart/Flutter server (Dart SDK ≥ 3.9): analyzer errors, `dart fix`, pub, tests, running app inspection, docs search. | `claude mcp add dart -- dart mcp-server` (plain MCP) · or the Flutter team's plugin route: `claude plugin marketplace add flutter/agent-plugins` then `claude plugin install dart-flutter@dart-flutter` | https://github.com/dart-lang/ai/tree/main/pkgs/dart_mcp_server · https://docs.flutter.dev/ai/get-started |
| **Microsoft Learn** | Search and fetch Microsoft docs (Azure, .NET, Windows, M365) and code samples; free, no auth, streamable HTTP. | `claude mcp add --transport http microsoft-learn https://learn.microsoft.com/api/mcp` | https://learn.microsoft.com/en-us/training/support/mcp |
| **DeepWiki** | Ask questions about any public GitHub repo (`read_wiki_structure`, `read_wiki_contents`, `ask_question`); free, no auth. Use when the library has no Context7 entry or you need the repo's internals. | `claude mcp add -s user -t http deepwiki https://mcp.deepwiki.com/mcp` (the `/sse` endpoint is deprecated) | https://docs.devin.ai/work-with-devin/deepwiki-mcp |
| **GitHub MCP** | Issues, PRs, code search, Actions logs on the user's GitHub; remote server with OAuth by default. Useful for `build` when a task references an issue, and for `git`. | OAuth: `claude mcp add --transport http github https://api.githubcopilot.com/mcp/` · PAT: `claude mcp add --transport http github https://api.githubcopilot.com/mcp/ --header "Authorization: Bearer $GITHUB_PAT"` · Local Docker: `claude mcp add github -e GITHUB_PERSONAL_ACCESS_TOKEN=$GITHUB_PAT -- docker run -i --rm -e GITHUB_PERSONAL_ACCESS_TOKEN ghcr.io/github/github-mcp-server` | https://github.com/github/github-mcp-server |

## How to offer one (template, rendered in the user's language)

```
Context7 gives me the exact docs for <library> <version> instead of my memory. If you want it, run:
claude mcp add --scope user --transport http context7 https://mcp.context7.com/mcp
Then restart Claude Code. Or I continue by opening the docs pages directly — your call.
```

One offer per server per project: record the answer in `.hyperui/state.md` `open:` (declined →
do not offer again; accepted → use it). Check what is already connected with `claude mcp list`
(read-only) before offering.

## Which one, when

| Situation | First choice | Fallback |
|---|---|---|
| Any library API, version pinned in the lockfile | Context7 (`get-library-docs` with the version) | `WebFetch` the official docs page |
| Next.js 16+ project, runtime errors or routing questions | Next.js devtools MCP (needs `next dev` running) | Context7 `/vercel/next.js` |
| Angular project | Angular CLI MCP `get_best_practices` + `search_documentation` | `WebFetch` angular.dev |
| Flutter/Dart project | Dart & Flutter MCP | `WebFetch` api.flutter.dev / dart.dev |
| Azure, .NET, Windows APIs, Microsoft Store | Microsoft Learn | `WebFetch` learn.microsoft.com |
| A GitHub library without docs, or internals of a dependency | DeepWiki `ask_question` | read the dependency's source in `node_modules`/vendor |
| Task references an issue or PR | GitHub MCP | `gh issue view` / `gh pr view` via Bash |

Provider MCPs (Vercel, Supabase, Stripe, Cloudflare, AWS, Terraform…) live in the `ship` and
`infra` specialists' references; do not duplicate them here.
