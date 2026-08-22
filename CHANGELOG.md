# Changelog

All notable changes to this project will be documented in this file.

## [2026-08-21 - Current]

### Breaking Changes
- Restructure the repository as a Claude Code plugin marketplace; commands and agents move into plugins/dev-workflow and install via /plugin instead of symlinks (5954a22)

### Features
- Add .claude-plugin/marketplace.json and the dev-workflow plugin manifest (5954a22)
- Sync statusline with the newer live copy, adding rate limit display with reset countdowns (5954a22)

### Enhancements
- setup.sh now manages only the non-plugin pieces (global CLAUDE.md and statusline) and cleans up symlinks from the old layout (5954a22)

### Removed
- Drop unused Python packaging files pyproject.toml and .python-version (5954a22)

## [2025-08-15]

### Features
- Add /update-changelog command for automated changelog generation (08d8cc2)
- Install Changelog agent for comprehensive git history analysis (c23410b)
- Add changelog updater agent configuration (4103a9f)

### Bug Fixes
- Correct CLAUDE.md symlink path and add communication style guidelines (1360660)

### Documentation
- Add installation instructions for linking configs to ~/.claude (60b6de5)
- Add comprehensive README and refine documentation tone (442459a)

## [2025-08-12 - Initial Release]

### Features
- Add repo-interface-analyzer agent configuration for library analysis (54ccd3e)
- Track commands directory with development workflow commands (3cd9136)
- Initialize CLAUDE.md with core configuration and guidelines (06bfafb)

### Commands Added
- /commit - Intelligent staging and commit message generation
- /fix-docs - Repository documentation review and updates
- /fix-tests - Test execution and failure resolution

### Configuration
- Python project configuration with pyproject.toml
- Core CLAUDE.md with principles and testing guidelines
- Language server integration documentation
- Communication style guidelines emphasizing direct feedback

### Project Structure
- agents/ - Specialized agent configurations
- commands/ - Command definitions for common tasks
- configs/ - Global configuration and guidelines
- Initial Python 3.13 project setup