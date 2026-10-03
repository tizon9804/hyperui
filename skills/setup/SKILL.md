---
name: setup
description: "Install the hyperui stack (HyperFrames, Motion, UI UX Pro Max, 21st.dev MCP, frontend-design, Impeccable) into the current project. Manual: /hyperui:setup [--global] [--21st-key KEY] [--skip-*] [--dry-run]"
disable-model-invocation: true
allowed-tools:
  - Bash(${CLAUDE_PLUGIN_ROOT}/scripts/setup.sh *)
  - Bash(${CLAUDE_PLUGIN_ROOT}/scripts/doctor.sh *)
---

# hyperui:setup

Install the frontend craft stack into the current project. The script is idempotent and
checks each component before touching anything.

## Steps

1. Run exactly:

   ```
   ${CLAUDE_PLUGIN_ROOT}/scripts/setup.sh $ARGUMENTS
   ```

2. Show the `[hyperui] summary` table verbatim to the user.
3. If the 21st.dev MCP row says `skipped (no key)`, add one line: get a free key at
   https://21st.dev/mcp, then rerun `/hyperui:setup --21st-key <key>` (or export
   `TWENTY_FIRST_API_KEY`). The key is stored at user scope, never in the project.
4. Confirm with:

   ```
   ${CLAUDE_PLUGIN_ROOT}/scripts/doctor.sh
   ```

5. Close with one line on what to try next: `/hyperui:design` for a design brief, `/hyperframes`
   for a video, `/ui-ux-pro-max`, `/frontend-design`, `/impeccable audit`.

## Rules

- Never improvise extra installs or fixes beyond what the script does. If a step fails,
  relay the `[hyperui] ✗` line and the script's own hint; the user decides.
- Flags pass straight through: `--global`, `--21st-key <key>`, `--skip-hyperframes`,
  `--skip-uipro`, `--skip-motion`, `--skip-21st`, `--skip-frontend-design`, `--skip-impeccable`, `--dry-run`.
