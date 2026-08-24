# Plain Summary

Ends every Claude Code turn with a short plain-language recap of what Claude just did, appended after the normal response and set apart by a `-.-.-` marker line. Short responses (under 10 lines by default) are left alone, so minor answers do not get rephrased. When the response is chiefly content the user asked to copy (a prompt, a snippet, a template), the instructions tell the model to print only the marker line, so nothing lands after the copyable content.

Example recap:

```
-.-.-
* Two tests checked an outdated value; fixed both and the suite passes.
* Nothing else changed.
```

The original response is unchanged; the recap is added at the end. It is a handful of short bullets (using `*` as the bullet marker), one per meaningful point with minor ones merged — usually two to four total, each as short as it can be while staying concrete. The voice is a person jotting a quick note: basic markdown such as bold and backticked names is allowed, general technical terms are allowed, but jargon, project-specific invented terms, stock assistant phrasing ("successfully", "went ahead and", "you're all set"), celebration, and hedging are not. Code or file names appear only when one is central to the answer.

The `-.-.-` marker is used instead of a markdown horizontal rule (`---`) because `---` legitimately appears in ordinary output, which would confuse the duplicate-recap check. The marker is the only thing the hook ever looks for in the recap text; turn state itself comes entirely from the `stop_hook_active` flag described below.

## How it works

A `Stop` hook fires when Claude finishes responding:

1. On the first stop of a turn, the hook measures the response using the `last_assistant_message` field of the hook input, in estimated rendered lines rather than raw newlines, so wrapped prose counts the way it looks on screen. If the response measures shorter than the threshold, the hook exits and the turn ends normally with no recap.
2. If the response already ends with a recap (a `-.-.-` marker line within its last 15 lines), the hook also stands down: a recap is already there, and requesting another would duplicate it. This makes it harmless when the model writes the recap into the response on its own.
3. Otherwise the hook returns `{"decision": "block"}` with a single compact line carrying the recap instructions, and Claude continues for one more step to write the recap. Everything a blocking Stop hook outputs is rendered in the terminal — the `reason` as an error-styled banner and any `additionalContext` as a feedback line — so there is no hidden channel for long instructions. Keeping the reason to one line, and sending nothing else, is what keeps the on-screen notice small.
4. Copyable content is handled inside the instructions rather than by detection: there is no structured signal for it in the hook input, so the model is told to print only the `-.-.-` line when the response is chiefly content the user asked to copy. The `stop_hook_active` check prevents that marker-only continuation from being blocked again.
5. When Claude stops again, Claude Code sets `stop_hook_active` to `true` in the hook input. The hook sees that and exits cleanly, ending the turn.

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

The length gate measures the final text message of the turn (that is what a recap would restate) in estimated rendered lines: each source line counts as its length divided by 80 columns, rounded up, and blank lines count as 1. A three-paragraph prose answer is only 5 source lines but wraps to a dozen or more on screen, and it is measured the way it looks. The 80-column assumption is deliberately narrower than most terminals, so borderline prose errs toward getting a recap. An empty or missing message field bypasses the gate.

To tune the recap prompt itself, edit `hooks/recap-style.md`: the script inlines its content as the block reason, so the file is the single place the wording lives. Its content is also exactly what the terminal notice shows, so keep it compact. `@`-style file references are not resolved inside hook output (tested empirically), which is why the file is inlined rather than linked.

## Install

```
/plugin install plain-summary@claude-configs
```

Disable or uninstall any time via `/plugin`. `jq` and the adjacent `recap-style.md` are hard requirements: if either is missing the hook prints an error to stderr and requests nothing, rather than degrading silently. It only blocks a stop when it can positively read `stop_hook_active: false`; on anything unexpected it stays out of the way, so a parsing problem can never trap Claude in forced continuations.
