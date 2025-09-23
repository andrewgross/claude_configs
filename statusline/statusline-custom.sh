#!/bin/bash

# Configurable threshold (default: 160K tokens = 80% of 200K context)
THRESHOLD=${CLAUDE_AUTO_COMPACT_THRESHOLD:-160000}

# Read JSON input from stdin
input=$(cat)

# Extract values using jq
MODEL_DISPLAY=$(echo "$input" | jq -r '.model.display_name')
PROJECT_DIR=$(echo "$input" | jq -r '.workspace.project_dir')
CURRENT_DIR=$(echo "$input" | jq -r '.workspace.current_dir')
SESSION_ID=$(echo "$input" | jq -r '.session_id')

# Get directory names
PROJECT_NAME=$(basename "$PROJECT_DIR")
CURRENT_NAME=$(basename "$CURRENT_DIR")

# Check git status
GIT_STATUS=""
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    # We're in a git repository
    STAGED=$(git diff --cached --name-only | wc -l | tr -d ' ')
    UNSTAGED=$(git diff --name-only | wc -l | tr -d ' ')
    UNTRACKED=$(git ls-files --others --exclude-standard | wc -l | tr -d ' ')

    if [[ "$STAGED" -eq 0 && "$UNSTAGED" -eq 0 && "$UNTRACKED" -eq 0 ]]; then
        GIT_STATUS="clean"
    else
        GIT_PARTS=()
        [[ "$STAGED" -gt 0 ]] && GIT_PARTS+=("${STAGED}s")
        [[ "$UNSTAGED" -gt 0 ]] && GIT_PARTS+=("${UNSTAGED}m")
        [[ "$UNTRACKED" -gt 0 ]] && GIT_PARTS+=("${UNTRACKED}u")

        # Join array elements with +
        GIT_STATUS=$(IFS='+'; echo "${GIT_PARTS[*]}")
    fi
else
    GIT_STATUS="no-git"
fi

# Calculate tokens from transcript
TOTAL_TOKENS=0
if [ -n "$SESSION_ID" ] && [ "$SESSION_ID" != "null" ]; then
    TRANSCRIPT_PATH=$(find ~/.claude/projects -name "${SESSION_ID}.jsonl" 2>/dev/null | head -1)
    if [ -f "$TRANSCRIPT_PATH" ]; then
        # Estimate tokens (rough approximation: 1 token per 4 characters)
        TOTAL_CHARS=$(wc -c < "$TRANSCRIPT_PATH")
        TOTAL_TOKENS=$((TOTAL_CHARS / 4))
    fi
fi

# Calculate percentage
PERCENTAGE=$((TOTAL_TOKENS * 100 / THRESHOLD))
if [ $PERCENTAGE -gt 100 ]; then
    PERCENTAGE=100
fi

# Format token count with K notation
if [ $TOTAL_TOKENS -ge 1000 ]; then
    TOKEN_DISPLAY=$(echo "scale=1; $TOTAL_TOKENS / 1000" | bc)"K"
else
    TOKEN_DISPLAY="$TOTAL_TOKENS"
fi

# Output statusline
printf "[%s] | %s | %d%% | [git] %s | [proj] %s | [cwd] %s" "$MODEL_DISPLAY" "$TOKEN_DISPLAY" "$PERCENTAGE" "$GIT_STATUS" "$PROJECT_NAME" "$CURRENT_NAME"
