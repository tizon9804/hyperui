---
type: tool_used
tool: Bash
input_match: 'git\s+commit|git\s+push|git\s+tag|claude\s+mcp\s+add|npm\s+publish|vercel\s+(--prod|deploy)|netlify\s+deploy|wrangler\s+(deploy|publish)|firebase\s+deploy'
min: 0
max: 0
---

"Deja listo el commit" asks for the proposal, not the commit: the git specialist shows the
files and the message and stops (git §1, §3.5). Passes only when NO Bash call commits, pushes,
tags, publishes, deploys or registers an MCP server. `git status`, `git diff`, `git log`,
`git add` (staging) and running tests are allowed.
