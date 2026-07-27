# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## ⚠️ Public Repository: Secrets Safety

**This repo is public on GitHub.** Before staging, committing, or pushing any change:

- Never commit `~/.secrets`, API keys, tokens, credentials, private SSH keys, or anything machine-specific that wasn't already in the repo.
- Local-only configuration belongs in gitignored files: `zsh/aliases_local.sh`, `zsh/functions_local.sh`, `~/.zshrc.local`, `~/.secrets`.
- Inspect `git diff --cached` before every commit. If a diff contains an email beyond `leonid@svyatov.com`, an absolute path with another username, a host name, an IP, a token-shaped string, or any value that looks like a secret, stop and ask the user.
- Prefer `git add <specific paths>` over `git add -A` / `git add .` to avoid sweeping in untracked files by accident.
- If a secret slips through, treat it as compromised: rotate the credential first, then rewrite history.

## Repository Overview

Personal dotfiles for macOS web development (Ruby/Rails, Node.js, Go, Elixir, Docker). Zsh with the Prezto framework, symlink-based configuration management.

Installation steps, setup script options, the full symlink table, and the alias/function reference all live in `README.md`. Read it there rather than duplicating it here, and update it when you change any of them.

## Local Customizations

Machine-specific configuration that must not be committed:

| File | Purpose |
|------|---------|
| `~/.zshrc.local` | Machine-specific shell config (sourced at end of .zshrc) |
| `zsh/aliases_local.sh` | Local aliases (auto-sourced, gitignored) |
| `zsh/functions_local.sh` | Local functions (auto-sourced, gitignored) |
| `~/.secrets` | Environment variables with secrets (permission-checked, must be 600) |

Templates: `aliases_local.sh.example`, `functions_local.sh.example`.

## Non-obvious Facts

- `aliases.sh` and `functions.sh` glob-source every `aliases_*.sh` / `functions_*.sh` sibling. A new domain file is picked up automatically, so never register it in a list anywhere. This is also how the gitignored `*_local.sh` files load.
- `archive/` holds deprecated vim and tmux configs. Do not use or update it.
- `mise/config.toml` pins `node = "latest"`, which tracks Node **Current**, not LTS. This is deliberate.
- `claude/skills/` holds repo-hosted Claude Code skills. `setup.sh` links each one individually into `~/.claude/skills/`, because that directory also holds skills installed by `npx skills` and other tools, so it cannot be a whole-directory symlink. `setup.sh` also prunes symlinks there that point at skills no longer in the repo.
- `claude/CLAUDE.md` imports `claude/RTK.md` via `@RTK.md`. Both must be symlinked into `~/.claude/` or the import silently fails to expand.
- `~/.claude/settings.json` is the one config that is **synced, not symlinked**. Claude Code rewrites it at runtime and supacode injects hooks into it; supacode writes atomically, which replaces a symlink with a regular file. `claude/settings-sync.sh` reconciles instead: `--pull` snapshots live into the repo minus foreign hooks, `--push` applies the repo copy while keeping the foreign hooks that are live. `setup.sh` calls `--push`.
- Claude Code drops `enabledPlugins` entries for plugins it cannot resolve, so a missing key there is never a decision (disabling writes `false`). `settings-sync.sh --pull` re-adds repo-only entries rather than committing the loss.
- `skillOverrides` in `claude/settings.json` controls skill visibility per skill: `on`, `name-only`, `user-invocable-only`, `off`. Absent means `on`. `user-invocable-only` hides a skill from the model while keeping `/name`, which is how the unused ones are parked without uninstalling anything. Keys accept `plugin:skill` or the bare name. `/skills` is the interactive editor for the same key.
- Every skill's `description` frontmatter is injected into the system prompt on every session, so an unused enabled plugin costs tokens continuously, not just disk. Check usage before adding one: `grep -oh '"skill":"[^"]*"' ~/.claude/projects/*/*.jsonl | sort | uniq -c | sort -rn`.
- Most plugins are registered with `scope: local` against whatever project directory they were installed from, not user scope. `claude plugin uninstall` therefore refuses without `--scope local`, and the plugin cache is shared, so a plugin disabled globally may still be `true` in a project's `.claude/settings.local.json`. Check every project before deleting anything from `~/.claude/plugins/cache/`.
- Jump shortcuts (`functions_jumps.sh`) store bookmarks as symlinks in `~/.jump_shortcuts/`.
- `bin/alias_stats` reports which aliases are actually used, grouped by file. Useful before pruning.

## Conventions

- Use `safe_alias()` (in `functions.sh`) rather than raw `alias`; it refuses to clobber an existing command unless you pass `'override'` as the third arg.
- Keep domain-specific aliases and functions in their own `aliases_*.sh` / `functions_*.sh` files.
- Keep machine-specific config in the local files listed above.
- Secrets go in `~/.secrets`, never in the repo.
- `setup.sh` lists each symlink in **three** places: the `--help` heredoc, a `symlink_from_dotfiles` call, and a `verify_symlink` call. `uninstall.sh` keeps a fourth list. Adding a symlink means touching all four.
- `README.md` documents symlinks and synced files in separate tables. Moving a file between them means updating both.

## Verifying a Change

- Edited a `zsh/*.sh` file: `zsh -n <file>` to syntax check, then `sca` (aliases) or `scf` (functions) to reload, then run the affected alias or function.
- Edited `setup.sh` or `uninstall.sh`: `bash -n <file>` (both are bash, not zsh, so zsh glob qualifiers will not work), then `./setup.sh --dry-run` and `./uninstall.sh --dry-run`. Read the output and confirm only the intended lines changed.
- Edited a symlinked config: check the live target picked it up, e.g. `readlink ~/.claude/CLAUDE.md`.
- Broad shell changes: `shrl` for a full login-shell reload.
- Before committing: `git diff --cached`, per the secrets rule above.
