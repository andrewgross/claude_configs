# Plain Summary

Ends every Claude Code turn with a short plain-language recap of what Claude just did, appended after the normal response and set apart by a horizontal rule. Short responses (under 10 lines by default) are left alone, so minor answers do not get rephrased.

Example recap:

```
---
- Found why the tests were failing: two of them checked an outdated value.
- Fixed both; the whole suite passes now.
- Nothing else was changed, and no follow-up is needed.
```

The original response is unchanged; the recap is added at the end. It leans on short bullet points, one per meaningful point, covering the substance briefly rather than collapsing it to a headline; plain sentences appear only where a bullet fits poorly. General technical terms are allowed; jargon and project-specific invented terms are not, and code or file names appear only when one is central to the answer.

The horizontal rule is purely visual. Nothing parses the recap text: turn state comes entirely from the `stop_hook_active` flag described below, so the recap needs no fixed marker phrase.

## How it works

A `Stop` hook fires when Claude finishes responding:

1. On the first stop of a turn, the hook measures the response using the `last_assistant_message` field of the hook input. If the response is shorter than the threshold, the hook exits and the turn ends normally with no recap.
2. If the response already ends with a recap-shaped footer (a bare `---` line within its last 15 lines), the hook also stands down: a recap is already there, and requesting another would duplicate it. This makes it harmless when the model writes the recap into the response on its own.
3. Otherwise the hook returns `{"decision": "block"}` with a single compact line carrying the distilled recap style, and Claude continues for one more step to write the recap. Everything a blocking Stop hook outputs is rendered in the terminal — the `reason` as an error-styled banner and any `additionalContext` as a feedback line — so there is no hidden channel for long instructions. Keeping the reason to one line, and sending nothing else, is what keeps the on-screen notice small.
4. When Claude stops again, Claude Code sets `stop_hook_active` to `true` in the hook input. The hook sees that and exits cleanly, ending the turn.

The `stop_hook_active` check is what guarantees the recap is requested exactly once per turn instead of looping forever. Claude Code additionally caps consecutive Stop-hook blocks as a backstop.

## Configuration

`PLAIN_SUMMARY_MIN_LINES` sets the minimum response length, in lines, that triggers a recap. The default is 10. Responses with fewer lines are skipped; set it to 1 to recap everything. The cleanest place to set it is the `env` block of `~/.claude/settings.json`:

```json
{
  "env": {
    "PLAIN_SUMMARY_MIN_LINES": "5"
  }
}
```

The length gate measures the final text message of the turn (that is what a recap would restate) and requires `jq`. When `jq` is unavailable, or the message field is empty or missing, the gate is bypassed and every turn gets a recap, matching the previous behavior.

## Install

```
/plugin install plain-summary@claude-configs
```

Disable or uninstall any time via `/plugin`. The hook uses `jq` when available and falls back to pure-bash parsing when it is not. It only blocks a stop when it can positively read `stop_hook_active: false`; on anything unexpected it stays out of the way, so a parsing problem can never trap Claude in forced continuations.
