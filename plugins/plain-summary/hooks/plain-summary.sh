#!/bin/bash

# Stop hook for the plain-summary plugin.
#
# Fires when Claude finishes responding. The first time it fires in a turn,
# it blocks the stop and asks Claude to append a plain-language recap of the
# response. When Claude stops again after writing the recap, Claude Code sets
# stop_hook_active to true and the hook lets the turn end, so the recap is
# requested exactly once per turn and the hook cannot trigger itself forever.

INPUT=$(cat)

# Only block when we can positively read stop_hook_active=false (the first
# stop of the turn). On stop_hook_active=true, or anything unexpected in the
# input, stay out of the way and let Claude stop.
STATE=unknown
if command -v jq >/dev/null 2>&1; then
    PARSED=$(printf '%s' "$INPUT" | jq -r '.stop_hook_active // false' 2>/dev/null)
    case "$PARSED" in
        true) STATE=active ;;
        false) STATE=first ;;
    esac
elif [[ "$INPUT" =~ \"stop_hook_active\"[[:space:]]*:[[:space:]]*true ]]; then
    STATE=active
elif [[ "$INPUT" =~ \"stop_hook_active\"[[:space:]]*:[[:space:]]*false ]]; then
    STATE=first
fi

if [ "$STATE" != "first" ]; then
    exit 0
fi

# Skip the recap when the response is short: a minor answer does not need
# rephrasing. The line count comes from the last_assistant_message field of
# the hook input. The gate needs jq; without it (or when the field is empty
# or missing, which counts as 0 lines) the gate is bypassed and the recap
# runs as before. Threshold is configurable via PLAIN_SUMMARY_MIN_LINES.
MIN_LINES="${PLAIN_SUMMARY_MIN_LINES:-10}"
[[ "$MIN_LINES" =~ ^[0-9]+$ ]] || MIN_LINES=10
if command -v jq >/dev/null 2>&1; then
    LINES=$(printf '%s' "$INPUT" | jq -r '.last_assistant_message // "" | split("\n") | length' 2>/dev/null)
    if [[ "$LINES" =~ ^[0-9]+$ ]] && [ "$LINES" -gt 0 ] && [ "$LINES" -lt "$MIN_LINES" ]; then
        exit 0
    fi
fi

# If the response already ends with a recap-shaped footer (a bare --- line
# within its last 15 lines), a recap is already there: requesting another
# would duplicate it, so stand down. Needs jq; without it the check is
# skipped.
if command -v jq >/dev/null 2>&1; then
    if printf '%s' "$INPUT" | jq -e '.last_assistant_message // "" | split("\n") | .[-15:] | any(. == "---")' >/dev/null 2>&1; then
        exit 0
    fi
fi

# Everything the hook prints is shown to the user: the reason renders as an
# error-styled banner and additionalContext renders as a feedback line, so
# there is no hidden channel for instructions. The reason is therefore one
# compact line carrying the distilled recap style, and nothing else is sent.
cat <<'EOF'
{"decision": "block", "reason": "Append a recap of the response above: print a --- line, then short plain-language bullets, one per substantive point, brief but concrete, noting next steps if any. No jargon or project-invented terms; mention code or files only if central. Use no tools, change nothing, and add nothing after the recap."}
EOF
exit 0
