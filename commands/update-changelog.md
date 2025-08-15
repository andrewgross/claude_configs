# /update-changelog

## Description
Automatically analyze git history and update or create CHANGELOG.md files based on recent commits and changes. Handles both single repositories and monorepos with multiple changelogs. Uses the changelog-updater subagent to perform comprehensive git analysis and generate well-structured, user-focused changelog entries.

## Process

1. **Invoke Changelog Updater Agent**
   - Use the Task tool to launch the changelog-updater subagent
   - Pass any specific changelog path if provided by the user
   - The agent will handle all git analysis and changelog updates

2. **Agent Actions**
   The changelog-updater agent will:
   - Locate existing CHANGELOG.md files or determine where to create one
   - Analyze git history since the last changelog update
   - Categorize changes (Breaking Changes, Features, Bug Fixes, etc.)
   - Generate clear, user-focused descriptions with commit hashes
   - Update or create the changelog file with proper formatting

3. **Monorepo Support**
   - If multiple changelogs exist, the agent determines which to update based on:
     - User-specified path or project name
     - Git changes relevant to each project directory
   - Only includes changes that affect the specific project

## Usage Examples

### Basic Usage
```
/update-changelog
```
Updates the main changelog with all recent changes since the last update.

### Specific Project in Monorepo
```
/update-changelog router
```
Updates only the router project's changelog with relevant changes.

### Create New Changelog
```
/update-changelog
```
If no changelog exists, creates a new CHANGELOG.md with all relevant commit history.

## Implementation

When the user invokes `/update-changelog`:

1. **Parse User Input**
   - Check if a specific path or project name was provided
   - Pass this information to the changelog-updater agent

2. **Launch Agent**
   ```
   Use Task tool with:
   - description: "Update changelog"
   - subagent_type: "changelog-updater"
   - prompt: Include any specific path/project from user input
   ```

3. **Agent Execution**
   The changelog-updater agent will:
   - Run git commands to analyze history
   - Determine which changes to include
   - Generate properly formatted changelog entries
   - Update or create the changelog file

4. **Report Results**
   - Confirm which changelog was updated
   - Summarize the types of changes added
   - Note if no changes were found since last update

## Error Handling

- **No Git Repository**: Inform user that command requires a git repository
- **No Changes Found**: Report that changelog is already up to date
- **Multiple Changelogs**: If ambiguous, ask user to specify which project
- **Git Command Failures**: Report specific git errors to user

## Important Notes

- The agent includes commit short hashes (first 7 characters) with each entry
- Changes are categorized automatically based on commit messages and code analysis
- Follows existing changelog format and style when updating
- Creates standard markdown format for new changelogs
- Focuses on user-facing descriptions rather than technical implementation details
- Excludes trivial changes like typo fixes unless significant
- Preserves any existing changelog entries and adds new ones at the top