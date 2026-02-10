---
name: update-staging
description: >
  Merge the main branch into staging, push, and return to the original branch.
  Use when the user asks to: (1) update staging, (2) merge main/master into staging,
  (3) sync staging with main. Triggers on: "update staging", "merge to staging",
  "sync staging".
---

# Process

## 1. Detect main branch

1. Check `git rev-parse --verify origin/main` — if it exists, use `main`.
2. Otherwise check `origin/master` — if it exists, use `master`.
3. If neither exists, ask the user which branch to merge from.

## 2. Prepare

```bash
ORIGINAL_BRANCH=$(git rev-parse --abbrev-ref HEAD)
git fetch origin
git checkout staging        # Stop if staging doesn't exist
git pull origin staging
```

## 3. Merge and push

```bash
git merge origin/<main-branch>
```

Merge the remote-tracking branch so local main doesn't need to be up-to-date.

**On merge conflict:** stop and let the user resolve. Do not force or abort.

```bash
git push origin staging
```

## 4. Return

```bash
git checkout $ORIGINAL_BRANCH
```
