# bin/hyperui.js

Zero-dependency Node (>= 20) CLI shipped in the `hyperui` npm package. It wraps the
`claude plugin` commands so people can install the Claude Code plugin in one step:

```bash
npx @tizonai/hyperui install     # default: add the tizonai marketplace + install hyperui@tizonai (updates if present)
npx @tizonai/hyperui doctor      # claude / marketplace / plugin / node / python3 / OS status
npx @tizonai/hyperui uninstall   # uninstall the plugin, then ask before removing the marketplace
npx @tizonai/hyperui install --dry-run   # print the claude commands without running them
```

The package version must match `.claude-plugin/plugin.json` — `npm run version-check`
enforces it and runs automatically before `npm publish`.
