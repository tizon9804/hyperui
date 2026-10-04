---
type: tool_used
tool: Bash
input_match: 'git\s+push|git\s+commit|claude\s+mcp\s+add|npm\s+publish|vercel\s+(--prod|deploy)|netlify\s+deploy|wrangler\s+(deploy|publish)|firebase\s+deploy'
min: 0
max: 0
---

Passes only when NO Bash call commits, pushes, publishes, deploys or registers an MCP server:
the build specialist leaves commits to the `git` specialist and never adds an MCP itself.
Running tests, the dev server, a build or a headless browser capture is allowed.
