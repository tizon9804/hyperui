---
name: doctor
description: "Report which parts of the hyperui stack are installed in this project/machine"
disable-model-invocation: true
allowed-tools:
  - Bash(${CLAUDE_PLUGIN_ROOT}/scripts/doctor.sh *)
---

# hyperui:doctor

Read-only check of the hyperui stack.

1. Run exactly:

   ```
   ${CLAUDE_PLUGIN_ROOT}/scripts/doctor.sh
   ```

2. Relay the table verbatim. For every `missing` row, keep the script's own hint; do not
   install anything from this skill — that is `/hyperui:setup`'s job.
