#!/bin/bash

# Configurable threshold (default: 160K tokens = 80% of 200K context)
# NOTE: Setting this to 100K tokens = 50% of 200K context to encourage frequent compaction
THRESHOLD=${CLAUDE_AUTO_COMPACT_THRESHOLD:-100000}

# Color definitions
ORANGE='\033[38;5;208m'
BLUE='\033[34m'
LIGHT_BLUE='\033[94m'
GREEN='\033[32m'
RED='\033[31m'
WHITE='\033[37m'
RESET='\033[0m'

# Read JSON input from stdin
input=$(cat)

# Extract values using jq
MODEL_DISPLAY=$(echo "$input" | jq -r '.model.display_name')
PROJECT_DIR=$(echo "$input" | jq -r '.workspace.project_dir')
CURRENT_DIR=$(echo "$input" | jq -r '.workspace.current_dir')
SESSION_ID=$(echo "$input" | jq -r '.session_id')

# Get directory names and relative path
PROJECT_NAME=$(basename "$PROJECT_DIR")

# Calculate relative path from project root
if [[ "$CURRENT_DIR" == "$PROJECT_DIR" ]]; then
    # We're in the project root
    RELATIVE_PATH=""
else
    # Get relative path from project to current directory
    RELATIVE_PATH=$(realpath --relative-to="$PROJECT_DIR" "$CURRENT_DIR" 2>/dev/null || echo "")

    # If relative path calculation failed or we're outside project, show current dir name
    if [[ -z "$RELATIVE_PATH" || "$RELATIVE_PATH" == ..* ]]; then
        RELATIVE_PATH=$(basename "$CURRENT_DIR")
    fi
fi

# Abbreviate long paths (keep first and last components if path has more than 3 segments)
if [[ -n "$RELATIVE_PATH" ]]; then
    IFS='/' read -ra PATH_PARTS <<< "$RELATIVE_PATH"
    if [[ ${#PATH_PARTS[@]} -gt 3 ]]; then
        # Long path: show first/last with ... in between
        ABBREVIATED_PATH="${PATH_PARTS[0]}/.../${PATH_PARTS[-1]}"
    else
        ABBREVIATED_PATH="$RELATIVE_PATH"
    fi
fi

# Check git status
GIT_STATUS=""
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    # Get current branch
    BRANCH=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)

    # Check repository status
    STAGED=$(git diff --cached --name-only | wc -l | tr -d ' ')
    UNSTAGED=$(git diff --name-only | wc -l | tr -d ' ')
    UNTRACKED=$(git ls-files --others --exclude-standard | wc -l | tr -d ' ')

    # Build status indicators (like traditional git PS1)
    STATUS_INDICATORS=""
    [[ "$STAGED" -gt 0 ]] && STATUS_INDICATORS+="+"
    [[ "$UNSTAGED" -gt 0 ]] && STATUS_INDICATORS+="*"
    [[ "$UNTRACKED" -gt 0 ]] && STATUS_INDICATORS+="?"

    # Check if we're ahead/behind remote
    AHEAD_BEHIND=$(git rev-list --count --left-right @{upstream}...HEAD 2>/dev/null)
    if [ $? -eq 0 ]; then
        BEHIND=$(echo "$AHEAD_BEHIND" | cut -f1)
        AHEAD=$(echo "$AHEAD_BEHIND" | cut -f2)
        [[ "$AHEAD" -gt 0 ]] && STATUS_INDICATORS+="↑$AHEAD"
        [[ "$BEHIND" -gt 0 ]] && STATUS_INDICATORS+="↓$BEHIND"
    fi

    if [[ -n "$STATUS_INDICATORS" ]]; then
        GIT_STATUS="(${GREEN}${BRANCH}${RESET} ${RED}${STATUS_INDICATORS}${RESET})"
    else
        GIT_STATUS="(${GREEN}${BRANCH}${RESET})"
    fi
else
    GIT_STATUS=""
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

# Determine token percentage color
if [ $PERCENTAGE -lt 50 ]; then
    TOKEN_COLOR="$GREEN"
elif [ $PERCENTAGE -lt 70 ]; then
    TOKEN_COLOR="$ORANGE"
else
    TOKEN_COLOR="$RED"
fi

# Format threshold with K notation
THRESHOLD_K=$(echo "scale=0; $THRESHOLD / 1000" | bc)"K"

# Build left side of statusline
if [[ -n "$GIT_STATUS" ]]; then
    if [[ -n "$ABBREVIATED_PATH" ]]; then
        LEFT_SIDE="${GIT_STATUS} ${BLUE}${PROJECT_NAME}${RESET}/${LIGHT_BLUE}${ABBREVIATED_PATH}${RESET}"
    else
        LEFT_SIDE="${GIT_STATUS} ${BLUE}${PROJECT_NAME}${RESET}"
    fi
else
    if [[ -n "$ABBREVIATED_PATH" ]]; then
        LEFT_SIDE="${BLUE}${PROJECT_NAME}${RESET}/${LIGHT_BLUE}${ABBREVIATED_PATH}${RESET}"
    else
        LEFT_SIDE="${BLUE}${PROJECT_NAME}${RESET}"
    fi
fi

# Build right side of statusline
RIGHT_SIDE="${WHITE}${TOKEN_DISPLAY}${RESET}/${WHITE}${THRESHOLD_K}${RESET}[${TOKEN_COLOR}${PERCENTAGE}%${RESET}] ${ORANGE}${MODEL_DISPLAY}${RESET}"

# Calculate terminal width and positioning
TERM_WIDTH=$(tput cols 2>/dev/null || echo 80)

# Strip ANSI codes for length calculation
LEFT_PLAIN=$(echo -e "$LEFT_SIDE" | sed 's/\x1b\[[0-9;]*m//g')
RIGHT_PLAIN=$(echo -e "$RIGHT_SIDE" | sed 's/\x1b\[[0-9;]*m//g')

LEFT_LENGTH=${#LEFT_PLAIN}
RIGHT_LENGTH=${#RIGHT_PLAIN}

# Calculate spaces needed
SPACES_NEEDED=$((TERM_WIDTH - LEFT_LENGTH - RIGHT_LENGTH))
if [[ $SPACES_NEEDED -lt 1 ]]; then
    SPACES_NEEDED=1
fi

# Output with proper spacing
printf "%s%*s%s\n" "$(echo -e "$LEFT_SIDE")" "$SPACES_NEEDED" "" "$(echo -e "$RIGHT_SIDE")" 
