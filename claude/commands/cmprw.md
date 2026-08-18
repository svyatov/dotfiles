---
description: Commit, push, open a pull request, wait for green CI, then squash merge
disable-model-invocation: true
argument-hint: [message hint]
allowed-tools: Bash(git status:*), Bash(git diff:*), Bash(git add:*), Bash(git commit:*), Bash(git log:*), Bash(git branch:*), Bash(git switch:*), Bash(git symbolic-ref:*), Bash(git push:*), Bash(gh pr:*), Bash(gh run:*)
---

Branch and status: !`git status --short --branch`
Changed files: !`git diff HEAD --stat`
Recent subjects: !`git log --oneline -10`

Commit everything above, push, open a pull request, and merge it once CI is green. Never commit onto
the default branch.

1. Read the full diff (`git diff HEAD`) before writing anything.
2. Scan it for credentials, tokens, private keys, and any value that does not belong in this
   repository. If you find one, stop, commit nothing, and report what you found.
3. If the current branch is the repository's default branch, create and switch to a new one first:
   `type/kebab-description`, where `type` matches the Conventional Commit type you are about to use
   and the description comes from the change itself.
4. Stage the changes. Prefer explicit paths over `git add -A`.
5. Write a Conventional Commit `type(scope): description`, matching the subject style already in
   `git log`. Follow the `oss-writing` skill for the wording. $ARGUMENTS is a hint at what the change
   is about, not the message itself.
6. Commit, then `git push -u origin HEAD`.
7. `gh pr create` with the commit subject as the title and a body covering what changed and why. Use
   the repository's pull request template when it has one.
8. `gh pr checks --watch` until every check settles. It exits non-zero on failure, so allow that and
   read the result rather than treating it as a crash.
9. Green: `gh pr merge --squash --delete-branch`. Red: stop, name the failing check and the reason,
   and merge nothing. Do not retry, do not fix, do not merge past a failure.
10. Report the PR URL and whether it merged.
