---
description: Commit all changes on the current branch and push
disable-model-invocation: true
argument-hint: [message hint]
allowed-tools: Bash(git status:*), Bash(git diff:*), Bash(git add:*), Bash(git commit:*), Bash(git log:*), Bash(git push:*)
---

Branch and status: !`git status --short --branch`
Changed files: !`git diff HEAD --stat`
Recent subjects: !`git log --oneline -10`

Commit everything above on the current branch, then push. Do not switch or create a branch, even on
main.

1. Read the full diff (`git diff HEAD`) before writing anything.
2. Scan it for credentials, tokens, private keys, and any value that does not belong in this
   repository. If you find one, stop, commit nothing, and report what you found.
3. Stage the changes. Prefer explicit paths over `git add -A`.
4. Write a Conventional Commit `type(scope): description`, matching the subject style already in
   `git log`. Follow the `oss-writing` skill for the wording. $ARGUMENTS is a hint at what the change
   is about, not the message itself.
5. Commit, then `git push` (add `-u origin HEAD` when the branch has no upstream).
6. Report the subject, the short hash, and the branch pushed to.

Split into several commits when the diff covers unrelated changes.
