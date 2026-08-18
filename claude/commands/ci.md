---
description: Report CI status for the current branch or its pull request
disable-model-invocation: true
allowed-tools: Bash(gh pr:*), Bash(gh run:*), Bash(git status:*), Bash(git branch:*)
---

Branch: !`git status --short --branch`
PR checks: !`gh pr checks 2>&1 || true`
Recent runs: !`gh run list --branch "$(git branch --show-current)" --limit 5 2>&1 || true`

Summarise, in a few lines: what failed, what is still running, what passed. Pull the failing job's log
(`gh run view --log-failed`) only when something is red, and quote the smallest excerpt that shows the
cause.

Read-only. Do not fix anything, do not push, do not merge. End with what you would do next, and let me
decide.
