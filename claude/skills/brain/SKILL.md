---
name: brain
description: Reads and writes Leonid's personal knowledge base, a store of his own notes, ideas, references, people, projects and todos at ~/Projects/Brain. Answers what he already knows, has read, has decided or has saved, and files new material he wants to keep.
when_to_use: Use when the user asks what he knows, has saved or has written down about a topic ("what do I know about X", "did I save anything on Y", "have I got notes on Z"). ALSO check it BEFORE answering from the web or from your own knowledge whenever the question asks which tool, library, service, data source, format or approach to use, or touches his own past decisions, preferences or opinions: he has probably already picked one and written down why. Recommending something without checking what he already chose is the failure this skill exists to prevent. Not for reading arbitrary project files.
allowed-tools: Bash(${CLAUDE_SKILL_DIR}/brain-search.rb *)
---

# brain

A second brain in Open Knowledge Format: markdown with YAML frontmatter at `~/Projects/Brain`.
That path is fixed here. `$BRAIN_DIR` overrides the location for `brain-search.rb` only: a
session does not inherit it, so it is not a way to point this skill at a test copy.

**The rules live in `~/Projects/Brain/CLAUDE.md`.** You MUST read that file in full before any
write. It is the only authority on the ingest and query procedure, the type vocabulary and the
commit conventions. Nothing here restates it.

**Capture runs only when Leonid types `/brain`.** Claude Code's auto memory owns "remember this"
and its neighbours from the system prompt, and it is a separate store that stays separate: never
migrate memory files into the brain, and never point `autoMemoryDirectory` at it. Auto memory
holds how the agent should behave in one repo. The brain holds what Leonid knows, across all of
them.

## Which mode applies

- **Working directory is inside the brain repo**: its own `CLAUDE.md` governs completely, and
  its Stop hook guards the commit. Follow it. Ignore the foreign-session policy below.
- **Anywhere else**: this is a foreign session. Query is read-only and capture is inbox-only,
  per the policy below.

## Query

Same in both modes, except for the last line.

1. Read `~/Projects/Brain/index.md` and pick out the notes that look relevant. Titles and
   one-line descriptions are the whole triage surface, and you are the relevance judge. There is
   no score threshold anywhere in this system.
2. Read the notes you picked.
3. Only if `index.md` was not enough, run this to search note bodies:

   ```
   ${CLAUDE_SKILL_DIR}/brain-search.rb "query words"
   ```

   One ranked hit per line, `score<TAB>path<TAB>title<TAB>description`. Expand the query with
   synonyms and aliases first: it is BM25 with no stemming, so "gems" misses "gem".
4. Answer. In a foreign session that is the end of it: do not offer to file the answer back as a
   note. If Leonid explicitly asks to save it, that takes the capture path below.

## Capture in a foreign session: inbox only

No grep for duplicates, no classification, no cross-links, no enrichment. That work is deferred
to the brain's own lint pass on purpose, because this session does not hold the brain's context.
An explicit "save that" about an answer takes this same path.

Write exactly three files.

**1. `inbox/<kebab-slug>.md`**

```markdown
---
type: inbox
title: <short title>
description: <one sentence>
timestamp: <ISO 8601, today>
---

<the raw text, verbatim>

Captured from `<repo name>` while <what this session was doing>.
```

**2. `inbox/index.md`**: add `* [<Title>](/inbox/<slug>.md) - <description>`. If the file does
not exist yet, create it with an `# Inbox` heading and no frontmatter.

**3. `log.md`**: insert `## [YYYY-MM-DD] ingest | Captured to inbox: <slug>` directly below the
`# Log` heading. The file is append-at-top, newest first.

Inbox items get **no** line in the root `index.md`. They earn one when they graduate into a real
type.

Then commit immediately, staged by path only:

```
git -C ~/Projects/Brain add inbox/<slug>.md inbox/index.md log.md \
  && git -C ~/Projects/Brain commit -m "chore(inbox): capture <slug>"
```

Immediately, because the brain's Stop hook does not protect this session, and a dirty brain repo
blocks the next real brain session.

**One attempt only.** If anything fails, stop, report the file path and the git error, and
change nothing else. No retry, no `--no-verify`, and never `git stash`, `checkout` or `reset`:
other sessions may be working in that repo at the same time.

**Never report a capture as saved unless that commit exited clean.** The commit is the proof: it
stages three paths, so a write that silently did nothing makes it fail. Leonid's zsh sets
`noclobber`, and a bare `>` onto an existing path writes nothing while the next command still
exits 0, so "I wrote the file" is not evidence of anything.
