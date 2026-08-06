---
name: track-contrib
description: Track and review open-source contributions. Use with no argument to see every tracked thread and what it is waiting for, or with a GitHub issue or pull request reference to start tracking one. Also use when asked what needs a reply, what nobody has answered, or what has moved since the last look.
---

# track-contrib

This skill routes. All the logic is in the script beside it.

**No argument** — run and show the output unchanged:

```
~/.claude/skills/track-contrib/track-contrib check
```

**With an argument** — pass everything through verbatim:

```
~/.claude/skills/track-contrib/track-contrib add "$@"
```

The reference is a GitHub URL, `owner/repo#number`, a bare number resolved against the
repository the shell is standing in, or `.` for the current branch's pull request.
Everything after the reference is stored as a note. Adding prints the table too.

Do not reformat, summarise, or re-sort the output. The script renders the finished table,
so it is byte-identical on every run.

The store is `items.jsonl` in the tracker directory. Removing an item or fixing a note is a
hand edit of that file. There is no command for it.
