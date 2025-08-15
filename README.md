# Claude Configurations

A collection of configuration files for Claude AI agents, providing standardized commands, agents, and guidelines for software development workflows.

## Overview

This repository contains configuration files that enhance Claude's capabilities when working on software projects. These configurations provide Claude with:

- Standardized commands for common development tasks
- Specialized agent configurations for complex workflows
- Consistent coding and testing guidelines
- Language server integration for intelligent code analysis

## Structure

```
claude_configs/
    agents/           # Specialized agent configurations
    commands/         # Command definitions for common tasks
    configs/          # Global configuration and guidelines
    pyproject.toml    # Python project configuration
```

## Components

### Commands

Pre-defined workflows for common development tasks:

- **`/commit`** - Intelligently stage changes and generate commit messages
- **`/fix-docs`** - Review and update repository documentation
- **`/fix-tests`** - Run tests, identify failures, and fix them
- **`/update-changelog`** - Automatically update CHANGELOG.md from git history

### Agents

Specialized configurations for complex analysis tasks:

- **`changelog-updater`** - Analyze git history and generate changelog entries
- **`repo-interface-analyzer`** - Analyze library interfaces and generate usage documentation

### Configuration

- **`CLAUDE.md`** - Core principles, testing guidelines, and language server tool documentation

## Requirements

- Python >=3.13
- Git for version control operations
- PyTest for Python testing workflows
- Language server (MCP cclsp) for intelligent code operations

## Installation

To use these configurations with Claude, you need to link them into your home directory where Claude can discover them. Claude looks for configuration files in the `~/.claude/` directory structure.

### Setting Up Configuration Links

First, ensure the Claude configuration directory exists:

```bash
mkdir -p ~/.claude/{agents,commands,configs}
```

Then create symbolic links from this repository to your Claude configuration directory. From the root of this repository, run:

```bash
# Link individual configuration files
ln -sf "$(pwd)/configs/CLAUDE.md" ~/.claude/CLAUDE.md
ln -sf "$(pwd)/commands/commit.md" ~/.claude/commands/commit.md
ln -sf "$(pwd)/commands/fix-docs.md" ~/.claude/commands/fix-docs.md
ln -sf "$(pwd)/commands/fix-tests.md" ~/.claude/commands/fix-tests.md
ln -sf "$(pwd)/commands/update-changelog.md" ~/.claude/commands/update-changelog.md
ln -sf "$(pwd)/agents/changelog-updater.md" ~/.claude/agents/changelog-updater.md
ln -sf "$(pwd)/agents/repo-interface-analyzer.md" ~/.claude/agents/repo-interface-analyzer.md
```

Alternatively, you can link entire directories if you want all configurations from this repository:

```bash
# Link entire directories (removes ability to have other configs)
ln -sf "$(pwd)/configs" ~/.claude/
ln -sf "$(pwd)/commands" ~/.claude/
ln -sf "$(pwd)/agents" ~/.claude/
```

### Verifying Installation

After linking, verify the configuration files are accessible:

```bash
ls -la ~/.claude/
```

You should see symbolic links pointing to the files in this repository. Claude will automatically discover and load these configurations when you interact with it in your development environment.

### How Claude Uses These Files

When Claude starts a session, it automatically scans the `~/.claude/` directory for configuration files. Commands become available as slash commands (like `/commit`), agents can be invoked for specialized tasks, and the guidelines in CLAUDE.md are applied globally to Claude's behavior. The configurations are loaded dynamically, so any updates to the linked files will be reflected in Claude's next session.

## Usage

These configurations are designed to be used with Claude AI in development environments. They provide Claude with structured approaches to common software engineering tasks.

### Example Workflow

1. Make code changes to your project
2. Use `/commit` to automatically stage and commit changes with appropriate messages
3. Use `/fix-tests` to ensure all tests pass after changes
4. Use `/fix-docs` to update documentation to reflect code changes
5. Use `/update-changelog` to generate changelog entries from recent commits

## Testing Guidelines

This repository follows strict testing principles:

- Single responsibility per test
- Fast and deterministic execution
- Independent test execution
- No external dependencies in unit tests

See `configs/CLAUDE.md` for detailed testing guidelines.

## Language Server Integration

The configurations include support for MCP cclsp tools, providing intelligent code operations:

- Find definitions and references
- Rename symbols across codebases
- Get language diagnostics
- Perform safe refactoring

## Contributing

When adding new configurations:

1. Follow the existing structure and naming conventions
2. Document all commands and agents thoroughly
3. Include examples and error handling
4. Maintain professional tone without emojis
5. Test configurations before committing
