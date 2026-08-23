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

# If the response already ends with a recap (a line that is exactly the
# recap marker within its last 15 lines), stand down rather than duplicate.
# The marker -.-.- is used instead of a markdown horizontal rule because
# --- appears legitimately in ordinary markdown output. Needs jq; without
# it the check is skipped.
if command -v jq >/dev/null 2>&1; then
    if printf '%s' "$INPUT" | jq -e '.last_assistant_message // "" | split("\n") | .[-15:] | any(. == "-.-.-")' >/dev/null 2>&1; then
        exit 0
    fi
fi

# Copyable content (a prompt, a snippet, a template the user asked for) is
# handled in the recap instructions rather than detected here: the model is
# told to print only the -.-.- line when the response is chiefly content to
# copy, so nothing lands after the copyable block. The stop_hook_active
# check above prevents any re-block of that marker-only continuation.

# Everything the hook prints is shown to the user: the reason renders as an
# error-styled banner and additionalContext renders as a feedback line, so
# there is no hidden channel for instructions. The reason is therefore one
# compact line carrying the distilled recap style, and nothing else is sent.
#
# The recap instructions live in recap-style.md next to this script so the
# prompt can be edited without touching JSON; its content becomes the reason
# and therefore the visible banner, so it must stay compact. @-style file
# references are not resolved inside hook output (tested empirically), so
# the file is inlined here rather than linked. If the file or jq is
# unavailable, a built-in copy of the same instruction is used.
if command -v jq >/dev/null 2>&1; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    STYLE_FILE="$SCRIPT_DIR/recap-style.md"
    if [ -r "$STYLE_FILE" ]; then
        REASON=$(tr '\n' ' ' < "$STYLE_FILE" | sed -e 's/  */ /g' -e 's/^ //' -e 's/ $//')
        if [ -n "$REASON" ]; then
            jq -cn --arg r "$REASON" '{decision: "block", reason: $r}'
            exit 0
        fi
    fi
fi

cat <<'EOF'
{"decision": "block", "reason": "Append a recap of the response above: print a line containing exactly -.-.- then short plain-language bullets, one per substantive point, brief but concrete, noting next steps if any. No jargon or project-invented terms; mention code or files only if central. If the response is chiefly content the user asked to copy, print only the -.-.- line and no recap. Use no tools, change nothing, and add nothing after the recap."}
EOF
exit 0
