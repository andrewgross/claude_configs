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

# The terminal renders the reason field of a blocking Stop hook as a loud
# banner, so the reason is kept to one short line. The full recap style
# instructions travel in hookSpecificOutput.additionalContext, which reaches
# Claude for the same continuation without being printed in the banner
# (verified empirically with a headless claude -p run). On versions that do
# not deliver additionalContext for Stop hooks, the one-line reason alone
# still produces a plain recap, just with less style guidance.
cat <<'EOF'
{"decision": "block", "reason": "Append a plain-language recap of the response above, after a --- rule (recap style instructions are provided in context).", "hookSpecificOutput": {"hookEventName": "Stop", "additionalContext": "Recap style: print a horizontal rule (---) on its own line, then recap mostly as short bullet points, with a plain sentence only where a bullet fits poorly. Give one bullet per meaningful point and cover every substantive detail briefly and concretely; do not collapse the response to a single headline, and do not expound either. Write for a reader who knows general technology but not this project: common technical terms are fine, but no jargon and no names or terms invented for this project; describe those in plain words. Mention specific code, files, or commands only when one is central. Say what happens next if anything. Do not use any tools, do not redo or change any work, and do not add anything after the recap."}}
EOF
exit 0
