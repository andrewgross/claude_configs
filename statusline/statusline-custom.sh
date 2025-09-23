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
printf "[%s] | %s | %d%% | [proj] %s | [cwd] %s" "$MODEL_DISPLAY" "$TOKEN_DISPLAY" "$PERCENTAGE" "$PROJECT_NAME" "$CURRENT_NAME"
