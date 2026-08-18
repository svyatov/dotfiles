---
name: track-contrib
description: Track and review open-source contributions. Use with no argument to see every tracked thread and what it is waiting for, or with a GitHub issue or pull request reference to start tracking one. Also use when asked what needs a reply, what nobody has answered, or what has moved since the last look.
---

# track-contrib

This skill routes. All the logic is in the script beside it.

To see every tracked thread, run this:

```
~/.claude/skills/track-contrib/track-contrib check --md
```

To track a new thread, pass everything through verbatim:

```
~/.claude/skills/track-contrib/track-contrib add --md "$@"
```

The reference is a GitHub URL, `owner/repo#number`, a bare number, or `.`. A bare number
resolves against the repository the shell is standing in. `.` resolves to the current
branch's pull request. Everything after the reference becomes a note. Adding prints the
table too.

## Show the output in your reply

Copy the script's output into your reply, character for character. Do not reformat it. Do
not summarise it. Do not re-sort it.

The `--md` flag exists for this. Tool output does not reliably reach the user in Claude
Code, so your reply is the only channel that works. The script emits markdown, so the
links and the emphasis survive the copy. Without `--md` the script emits ANSI colour and
OSC 8 links, and both die on the way to the screen.

The store is `items.jsonl` in the tracker directory. To remove an item or fix a note, edit
that file by hand. There is no command for it.
