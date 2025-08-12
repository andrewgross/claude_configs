# /commit

## Description
Automatically stage changed files, generate a concise commit message based on the changes, and commit to git. Handles pre-commit hooks and gracefully falls back if GPG signing requires a password. This command only performs commits - no push, pull, or other git operations.

## Process

1. **Check Git Status**
   - Run `git status` to see all changes (staged, unstaged, untracked)
   - Run `git diff --staged` to see already staged changes
   - Run `git diff` to see unstaged changes
   - Run `git ls-files --others --exclude-standard` to list untracked files
   - Review recent commit messages with `git log --oneline -10` to match the repository's commit style

2. **Stage Changes**
   - Add unstaged modified files and relevant untracked files to staging
   - Skip files that shouldn't be committed (build artifacts, temp files)
   - Verify final staging with `git status`

3. **Generate Commit Message**
   - Analyze ALL staged changes (both previously staged and newly staged)
   - Create a concise, informative message based on the changes
   - Follow conventional commit format when appropriate (fix:, feat:, test:, docs:, refactor:, etc.)
   - Focus on the "why" and "what" rather than just listing files
   - No emojis in commit messages

4. **Commit with Pre-commit Hook Handling**
   - Attempt the commit with the generated message
   - If pre-commit hooks modify files:
     - Re-stage the modified files
     - Retry the commit with the SAME message (preserve original message)
   - If pre-commit hooks fail with errors:
     - Try to fix the errors if straightforward (formatting, linting)
     - Retry the commit with the original message
   - Maximum of 2 retry attempts

5. **Handle GPG Signing Issues**
   - If commit fails due to GPG signing password requirement:
     - Provide the user with the generated commit message
     - Ask them to run the commit manually
   - Common GPG error patterns:
     - "error: gpg failed to sign the data"
     - "gpg: signing failed"
     - "cannot read passphrase"
     - "failed to write commit object"

## Error Handling

- **Pre-commit failures**: Fix if possible (formatting, simple linting), otherwise report to user with the commit message
- **GPG signing**: Provide commit message and ask user to commit manually
- **Merge conflicts**: Report to user, don't attempt to resolve
- **No changes**: Inform user there's nothing to commit
- **Protected files**: Skip system files, .git directory, etc.

## Important Notes

- This command ONLY commits - no push, pull, fetch, or other remote operations
- Never force operations or use dangerous git flags
- Preserve the commit message when retrying after pre-commit hooks
- Don't modify git config (especially GPG settings)
- Include co-author attribution for Claude in the commit message:
  ```
  Co-Authored-By: Claude <noreply@anthropic.com>
  ```
- Use professional tone in commit messages - no emojis or casual language