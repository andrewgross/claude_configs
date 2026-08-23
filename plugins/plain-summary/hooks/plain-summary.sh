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

cat <<'EOF'
{"decision": "block", "reason": "Final step before ending the turn: append a plain-language recap of the response above. First print a horizontal rule (---), then a line starting with **In plain terms:** followed by the recap. Keep it to 1-4 short sentences that someone with no technical background would understand: everyday words only, no jargon, no acronyms, no code or file names unless they are the whole point. Say what was done or found, and what happens next if anything. Do not use any tools, do not redo or change any work, and do not add anything after the recap."}
EOF
exit 0
