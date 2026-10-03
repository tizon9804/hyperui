---
name: setup
description: "Install the hyperui stack (HyperFrames, Motion, Motion AI Kit, UI UX Pro Max, 21st.dev MCP, frontend-design, Impeccable) into the current project, and help install missing prerequisites (node, python3). Manual: /hyperui:setup [--global] [--21st-key KEY] [--skip-*] [--motion-plus] [--install-prereqs] [--dry-run]"
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

2. **Preflight failed** (`[hyperui] ✗ node …` or `✗ python3 …`): show the install line the
   script printed for this OS, then ask ONCE, in the user's language: "Shall I install it for
   you?" — on **yes**, run exactly `${CLAUDE_PLUGIN_ROOT}/scripts/setup.sh --install-prereqs
   $ARGUMENTS` (macOS with Homebrew: runs `brew install node` / `brew install python` and
   re-runs preflight; Homebrew missing or Linux/WSL2: the script prints the official lines for
   the user to run, since they need a password), then re-run step 1. On **no**, continue and
   relay which steps were skipped. Never run an install the user did not say yes to.
   Windows: say to use WSL2 and follow the Linux lines. Terraform is never installed here.
3. Show the `[hyperui] summary` table verbatim to the user.
4. If the 21st.dev MCP row says `skipped (no key)`, add one line: get a free key at
   https://21st.dev/mcp, then rerun `/hyperui:setup --21st-key <key>` (or export
   `TWENTY_FIRST_API_KEY`). The key is stored at user scope, never in the project.
5. Confirm with:

   ```
   ${CLAUDE_PLUGIN_ROOT}/scripts/doctor.sh
   ```

6. Close with one line on what to try next: `/hyperui:design` for a design brief, `/motion` for
   Motion docs, springs and audits, `/hyperframes` for a video, `/ui-ux-pro-max`, `/frontend-design`, `/impeccable audit`.

## Rules

- Never improvise extra installs or fixes beyond what the script does. If a step fails,
  relay the `[hyperui] ✗` line and the script's own hint; the user decides.
- Flags pass straight through: `--global`, `--21st-key <key>`, `--skip-hyperframes`,
  `--skip-uipro`, `--skip-motion`, `--skip-motion-kit`, `--skip-21st`, `--skip-frontend-design`, `--skip-impeccable`,
  `--motion-plus` (also registers the `motion-plus` MCP for Motion+ subscribers),
  `--install-prereqs`, `--dry-run`. `--dry-run` prints every command, including the prerequisite ones.
