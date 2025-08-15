# Changelog

All notable changes to this project will be documented in this file.

## [2025-08-15 - Current]

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