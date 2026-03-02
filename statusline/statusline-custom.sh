#!/bin/bash

# Start timer
START_MS=$(python3 -c 'import time; print(int(time.time()*1e3))')

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

# Context window usage (provided directly by Claude Code)
USED_PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0')
CONTEXT_SIZE=$(echo "$input" | jq -r '.context_window.context_window_size // 200000')
COST_USD=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
SESSION_ID=$(echo "$input" | jq -r '.session_id // empty')
TOTAL_DURATION_MS=$(echo "$input" | jq -r '.cost.total_duration_ms // 0')
API_DURATION_MS=$(echo "$input" | jq -r '.cost.total_api_duration_ms // 0')
LINES_ADDED=$(echo "$input" | jq -r '.cost.total_lines_added // 0')
LINES_REMOVED=$(echo "$input" | jq -r '.cost.total_lines_removed // 0')
TRANSCRIPT_PATH=$(echo "$input" | jq -r '.transcript_path // empty')

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

# Context window color based on usage percentage
PERCENTAGE=${USED_PCT%.*}  # truncate to integer
if [ "$PERCENTAGE" -lt 50 ]; then
    CTX_COLOR="$GREEN"
elif [ "$PERCENTAGE" -lt 75 ]; then
    CTX_COLOR="$ORANGE"
else
    CTX_COLOR="$RED"
fi

# Format cost
COST_DISPLAY=$(printf '$%.2f' "$COST_USD")

# Build path segment
if [[ -n "$ABBREVIATED_PATH" ]]; then
    PATH_SEGMENT="${BLUE}${PROJECT_NAME}${RESET}/${LIGHT_BLUE}${ABBREVIATED_PATH}${RESET}"
else
    PATH_SEGMENT="${BLUE}${PROJECT_NAME}${RESET}"
fi

# Build statusline: model [ctx%] cost (git) path
MODEL_SEGMENT="${ORANGE}${MODEL_DISPLAY}${RESET} [${CTX_COLOR}${PERCENTAGE}%${RESET}]"

if [[ -n "$GIT_STATUS" ]]; then
    OUTPUT="${MODEL_SEGMENT} ${WHITE}${COST_DISPLAY}${RESET} ${GIT_STATUS} ${PATH_SEGMENT}"
else
    OUTPUT="${MODEL_SEGMENT} ${WHITE}${COST_DISPLAY}${RESET} ${PATH_SEGMENT}"
fi

# Parse timing breakdown from transcript (incremental, cached)
TIMING_DATA="0,0,0"
if [[ -n "$TRANSCRIPT_PATH" && -f "$TRANSCRIPT_PATH" ]]; then
    TIMING_DATA=$(python3 ~/.claude/statusline-timing.py "$TRANSCRIPT_PATH" "$TOTAL_DURATION_MS" "$API_DURATION_MS" 2>/dev/null) || TIMING_DATA="0,0,0"
fi
IFS=',' read -r TOTAL_FMT API_FMT IDLE_FMT TURNS <<< "$TIMING_DATA"

# Calculate elapsed time
END_MS=$(python3 -c 'import time; print(int(time.time()*1e3))')
ELAPSED_MS=$(( END_MS - START_MS ))

DARK_GREY='\033[90m'

# Line 1: model [ctx%] cost (git) path
printf "%s\n" "$(echo -e "$OUTPUT")"

# Line 2: all grey metadata
LINE2="${DARK_GREY}Session: ${SESSION_ID} | Duration: ${TOTAL_FMT}/${API_FMT}/${IDLE_FMT} (total/api/idle) | Turns: ${TURNS} | Changes: +${LINES_ADDED} -${LINES_REMOVED} | Hook: ${ELAPSED_MS}ms${RESET}"
printf "%s\n" "$(echo -e "$LINE2")"
