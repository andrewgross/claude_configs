# Plain Summary

Ends every Claude Code turn with a short plain-language recap of what Claude just did, appended after the normal response and set apart by a horizontal rule:

```
---
I looked at why the tests were failing and fixed the two broken ones.
Everything passes now, and nothing else was changed.
```

The original response is unchanged; the recap is added at the end. It can be a couple of sentences, a few short bullet points, or both. General technical terms are allowed; jargon and project-specific invented terms are not, and code or file names appear only when one is central to the answer.

The horizontal rule is purely visual. Nothing parses the recap text: turn state comes entirely from the `stop_hook_active` flag described below, so the recap needs no fixed marker phrase.

## How it works

A `Stop` hook fires when Claude finishes responding:

1. On the first stop of a turn, the hook returns `{"decision": "block"}` with instructions to append the recap, so Claude continues for one more step and writes it.
2. When Claude stops again, Claude Code sets `stop_hook_active` to `true` in the hook input. The hook sees that and exits cleanly, ending the turn.

The `stop_hook_active` check is what guarantees the recap is requested exactly once per turn instead of looping forever. Claude Code additionally caps consecutive Stop-hook blocks as a backstop.

## Install

```
/plugin install plain-summary@claude-configs
```

Disable or uninstall any time via `/plugin`. The hook uses `jq` when available and falls back to pure-bash parsing when it is not. It only blocks a stop when it can positively read `stop_hook_active: false`; on anything unexpected it stays out of the way, so a parsing problem can never trap Claude in forced continuations.
