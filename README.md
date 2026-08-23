# Claude Configurations

A personal Claude Code plugin marketplace, plus the few configuration pieces that plugins cannot provide (global CLAUDE.md guidelines and a custom statusline).

## Installation

### Plugins (commands, agents, hooks)

Add the marketplace and install plugins from inside Claude Code:

```
/plugin marketplace add andrewgross/claude_configs
/plugin install dev-workflow@claude-configs
/plugin install plain-summary@claude-configs
```

To have the marketplace and plugins configured automatically on a machine, add this to `~/.claude/settings.json` instead:

```json
{
  "extraKnownMarketplaces": {
    "claude-configs": {
      "source": {
        "source": "github",
        "repo": "andrewgross/claude_configs"
      }
    }
  },
  "enabledPlugins": {
    "dev-workflow@claude-configs": true,
    "plain-summary@claude-configs": true
  }
}
```

To pick up new plugin versions later:

```
/plugin marketplace update claude-configs
```

### Statusline and global CLAUDE.md

Claude Code plugins cannot ship statusline scripts or global memory files, so those two pieces are still installed with symlinks. From the root of this repository:

```bash
./setup.sh
```

The script links `configs/CLAUDE.md` to `~/.claude/CLAUDE.md`, links the statusline script to `~/.claude/statusline-custom.sh`, registers the statusline in `~/.claude/settings.json`, and removes any symlinks left over from the old pre-plugin layout. It is safe to run multiple times.

## Plugins

### dev-workflow

Development workflow commands and agents.

Commands (available as `/dev-workflow:commit` etc., or unprefixed when unambiguous):

- **`/commit`** - Stage changed files, generate a commit message, and commit
- **`/fix-docs`** - Review and update repository documentation
- **`/fix-tests`** - Run tests, identify failures, and fix them
- **`/update-changelog`** - Update CHANGELOG.md from git history

Agents:

- **`changelog-updater`** - Analyze git history and generate changelog entries
- **`repo-interface-analyzer`** - Analyze library interfaces and generate usage documentation

### plain-summary

A `Stop` hook that ends every turn with a short plain-language recap of what Claude just did, appended after the normal response and set apart by a `-.-.-` marker line. Responses shorter than 10 lines are skipped (configurable via `PLAIN_SUMMARY_MIN_LINES`), as are responses that already end with a recap, so recaps are never duplicated; for responses that are chiefly copyable content, the instructions tell the model to print only the marker line. The recap prompt lives in `plugins/plain-summary/hooks/recap-style.md`. The hook blocks the first stop of each turn to request the recap, then uses the `stop_hook_active` flag to let the second stop through, so it runs exactly once per turn. See `plugins/plain-summary/README.md` for details.

## Non-plugin components

### Statusline

`statusline/statusline-custom.sh` displays:

- Model name and context window usage percentage (color coded)
- Rate limit usage (5 hour and 7 day windows) with reset countdowns when above 90%
- Session cost
- Git branch and status indicators (staged/modified/untracked, ahead/behind)
- Project and current directory names
- A second line of session metadata (session id, durations, turns, line changes)

The timing breakdown on the second line depends on an optional helper, `~/.claude/statusline-timing.py`, which is not part of this repository. Without it the duration fields display zeros.

### Global guidelines

`configs/CLAUDE.md` contains core principles, communication style, and Python testing guidelines applied globally to Claude sessions on this machine.

## Repository structure

```
claude_configs/
    .claude-plugin/
        marketplace.json          # Marketplace manifest listing all plugins
    plugins/
        dev-workflow/
            .claude-plugin/
                plugin.json       # Plugin manifest
            commands/             # Slash commands
            agents/               # Subagent definitions
        plain-summary/
            .claude-plugin/
                plugin.json       # Plugin manifest
            hooks/
                hooks.json        # Stop hook wiring
                plain-summary.sh  # Hook script
                recap-style.md    # The recap prompt (inlined as the reason)
    configs/
        CLAUDE.md                 # Global guidelines (symlinked by setup.sh)
    statusline/
        statusline-custom.sh      # Statusline script (symlinked by setup.sh)
    setup.sh                      # Installs the non-plugin pieces
```

## Requirements

- Claude Code with plugin support
- Git for version control operations
- `jq` for the statusline script, the plain-summary hook, and settings.json updates

## Contributing

When adding a new plugin:

1. Create `plugins/<name>/` with a `.claude-plugin/plugin.json` manifest
2. Add the plugin to `.claude-plugin/marketplace.json`
3. Validate with `claude plugin validate .`
4. Document the plugin in this README
5. Maintain professional tone without emojis
