#!/bin/bash

# Stop hook for the plain-summary plugin.
#
# Fires when Claude finishes responding. The first time it fires in a turn,
# it blocks the stop and asks Claude to append a plain-language recap of the
# response. When Claude stops again after writing the recap, Claude Code sets
# stop_hook_active to true and the hook lets the turn end, so the recap is
# requested exactly once per turn and the hook cannot trigger itself forever.
#
# jq and the adjacent recap-style.md are hard requirements: without them the
# hook reports an error on stderr and requests nothing.

INPUT=$(cat)

if ! command -v jq >/dev/null 2>&1; then
    echo "plain-summary: jq is required but was not found; no recap was requested" >&2
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STYLE_FILE="$SCRIPT_DIR/recap-style.md"
if [ ! -r "$STYLE_FILE" ]; then
    echo "plain-summary: $STYLE_FILE is missing or unreadable; no recap was requested" >&2
    exit 1
fi

# Only block when we can positively read stop_hook_active=false (the first
# stop of the turn). On stop_hook_active=true, or anything unexpected in the
# input, stay out of the way and let Claude stop.
PARSED=$(printf '%s' "$INPUT" | jq -r '.stop_hook_active // false' 2>/dev/null)
[ "$PARSED" = "false" ] || exit 0

# Skip the recap when the response is short: a minor answer does not need
# rephrasing. Length is measured in estimated rendered lines, not raw
# newlines: each source line counts as ceil(length / 80) and blank lines
# count as 1, so a long prose paragraph that wraps in the terminal is
# measured roughly the way the user sees it instead of as a single line.
# An empty or missing message measures 0 and bypasses the gate, preserving
# the recap on Claude Code versions that do not provide the field.
# Threshold is configurable via PLAIN_SUMMARY_MIN_LINES.
MIN_LINES="${PLAIN_SUMMARY_MIN_LINES:-10}"
[[ "$MIN_LINES" =~ ^[0-9]+$ ]] || MIN_LINES=10
LINES=$(printf '%s' "$INPUT" | jq -r '.last_assistant_message // "" | split("\n") | map(if length == 0 then 1 else ((length + 79) / 80 | floor) end) | add // 0' 2>/dev/null)
if [[ "$LINES" =~ ^[0-9]+$ ]] && [ "$LINES" -gt 0 ] && [ "$LINES" -lt "$MIN_LINES" ]; then
    exit 0
fi

# If the response already ends with a recap (a line that is exactly the
# recap marker within its last 15 lines), stand down rather than duplicate.
# The marker -.-.- is used instead of a markdown horizontal rule because
# --- appears legitimately in ordinary markdown output.
if printf '%s' "$INPUT" | jq -e '.last_assistant_message // "" | split("\n") | .[-15:] | any(. == "-.-.-")' >/dev/null 2>&1; then
    exit 0
fi

# Copyable content (a prompt, a snippet, a template the user asked for) is
# handled in the recap instructions rather than detected here: the model is
# told to print only the -.-.- line when the response is chiefly content to
# copy, so nothing lands after the copyable block. The stop_hook_active
# check above prevents any re-block of that marker-only continuation.

# Everything the hook prints is shown to the user: the reason renders as an
# error-styled banner and additionalContext renders as a feedback line, so
# there is no hidden channel for instructions. The reason is therefore one
# compact line carrying the recap instructions, inlined from recap-style.md,
# the single place the wording lives; its content is the visible notice, so
# it must stay compact. @-style file references are not resolved inside hook
# output (tested empirically), so the file is inlined rather than linked.
REASON=$(tr '\n' ' ' < "$STYLE_FILE" | sed -e 's/  */ /g' -e 's/^ //' -e 's/ $//')
if [ -z "$REASON" ]; then
    echo "plain-summary: $STYLE_FILE is empty; no recap was requested" >&2
    exit 1
fi
jq -cn --arg r "$REASON" '{decision: "block", reason: $r}'
exit 0
