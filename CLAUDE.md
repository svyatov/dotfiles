# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

Personal dotfiles for macOS web development (Ruby/Rails, Node.js, Docker). Uses Zsh with Prezto framework, symlink-based configuration management.

## Installation

```bash
git clone git://github.com/svyatov/dotfiles.git ~/.dotfiles
brew bundle --file=~/.dotfiles/Brewfile  # Install dependencies
~/.dotfiles/setup.sh
```

The setup script creates symlinks from `~/.dotfiles/*` to home directory locations, backs up existing files with `.orig` extension, and clones Prezto if needed.

Setup script options:
- `--help` - Show usage and list of symlinks
- `--dry-run` - Preview changes without modifying anything
- `--confirm` - Ask before creating each symlink

After setup, install Claude plugins and skills:
```bash
~/.dotfiles/claude/install-plugins.sh
~/.dotfiles/claude/install-skills.sh
```

To uninstall (removes symlinks, restores backups):
```bash
~/.dotfiles/uninstall.sh          # Run uninstall
~/.dotfiles/uninstall.sh --dry-run # Preview what would be removed
```

## Common Commands

| Command | Description |
|---------|-------------|
| `shrl` | Reload shell (`exec $SHELL -l`) |
| `edf` | Edit dotfiles in nvim |
| `sca` | Source aliases after editing |
| `scf` | Source functions after editing |
| `zpu` | Update Prezto framework |

## Architecture

### Loading Order

```
.zshenv (environment: PATH, Homebrew, asdf, Postgres, secrets)
    ↓
.zshrc (interactive)
    ├── Prezto framework
    ├── set_terminal_titles.sh
    ├── unalias_prezto.sh
    ├── functions.sh → sources all functions_*.sh (incl. functions_local.sh)
    ├── aliases.sh → sources all aliases_*.sh (incl. aliases_local.sh)
    ├── fzf/fd configuration (guarded, warns if missing)
    ├── asdf configuration (guarded, warns if missing)
    └── ~/.zshrc.local (machine-specific, optional)
```

### Modular File Pattern

Domain-specific configuration uses auto-discovery via glob expansion:

```bash
# In functions.sh - loads functions_jumps.sh, functions_git.sh, functions_ruby.sh
for function_file in $HOME/.dotfiles/zsh/functions_*.sh(N); do
  source "$function_file"
done

# In aliases.sh - loads aliases_git.sh, aliases_ruby.sh, aliases_docker.sh, etc.
for alias_file in $HOME/.dotfiles/zsh/aliases_*.sh(N); do
  source "$alias_file"
done
```

To add new domain: create `aliases_newdomain.sh` or `functions_newdomain.sh` - it will be auto-sourced.

### Local Customizations

Machine-specific configuration that shouldn't be committed:

| File | Purpose |
|------|---------|
| `~/.zshrc.local` | Machine-specific shell config (sourced at end of .zshrc) |
| `zsh/aliases_local.sh` | Local aliases (auto-sourced, gitignored) |
| `zsh/functions_local.sh` | Local functions (auto-sourced, gitignored) |
| `~/.secrets` | Environment variables with secrets (permission-checked) |

Example templates are provided: `aliases_local.sh.example` and `functions_local.sh.example`.

### Symlink Structure

| Source | Destination |
|--------|-------------|
| `zsh/.zshrc` | `~/.zshrc` |
| `zsh/.zshenv` | `~/.zshenv` |
| `zsh/.zpreztorc` | `~/.zpreztorc` |
| `zsh/prompt_svyatov_setup` | `~/.zprezto/modules/prompt/functions/prompt_svyatov_setup` |
| `git/.gitconfig` | `~/.gitconfig` |
| `ruby/.gemrc`, `.irbrc`, `.railsrc` | `~/.*` |
| `zsh/.zlogin` | `~/.zlogin` |
| `nvim/init.vim` | `~/.config/nvim/init.vim` |
| `claude/settings.json` | `~/.claude/settings.json` |
| `claude/statusline-command.sh` | `~/.claude/statusline-command.sh` |

### Key Utilities

**`safe_alias()`** (in `functions.sh`): Prevents clobbering existing commands. Use third arg `'override'` to force.

```bash
safe_alias l 'ls -lhAG'           # Only creates if 'l' doesn't exist
safe_alias g 'git' 'override'     # Forces creation
```

**Jump shortcuts** (in `functions_jumps.sh`): Persistent directory bookmarks stored as symlinks in `~/.jump_shortcuts/`.

| Command | Action |
|---------|--------|
| `j name` | Jump to bookmark |
| `ja name` | Add bookmark for cwd |
| `jd name` | Delete bookmark |
| `jl` | List all bookmarks |
| `jb` | Jump back to previous |

## Key Files

| File | Purpose |
|------|---------|
| `setup.sh` | Bootstrap script with --help, --dry-run, --confirm options |
| `uninstall.sh` | Remove symlinks and restore backups |
| `Brewfile` | Homebrew dependencies (install with `brew bundle`) |
| `zsh/.zpreztorc` | Prezto modules and theme configuration |
| `zsh/prompt_svyatov_setup` | Custom prompt with Ruby/Node/Python versions |
| `zsh/aliases_local.sh.example` | Template for machine-specific aliases |
| `zsh/functions_local.sh.example` | Template for machine-specific functions |
| `git/.gitconfig` | 90+ git aliases, 1Password SSH signing, diff tools |
| `nvim/init.vim` | Neovim config with Claude Code integration |
| `claude/settings.json` | Claude Code permissions and plugins |
| `claude/statusline-command.sh` | Custom status line showing git, Ruby, Node versions |
| `claude/install-plugins.sh` | Install Claude Code plugins from settings |
| `claude/install-skills.sh` | Install Claude Code skills from superpowers repo |
| `servers/install.sh` | One-line installer for server shell config |
| `servers/README.md` | Server shell config documentation |

## Server Shell Configuration

Lightweight shell configs for remote Linux servers (separate from macOS Zsh config).

**Install on a server:**
```bash
curl -fsSL https://raw.githubusercontent.com/svyatov/dotfiles/master/servers/install.sh | bash
```

See `servers/README.md` for full documentation.

## Conventions

- Use `safe_alias()` instead of raw `alias` to avoid overwriting commands
- Keep domain-specific aliases in separate `aliases_*.sh` files
- Keep domain-specific functions in separate `functions_*.sh` files
- Keep machine/project-specific config in local files (`aliases_local.sh`, `functions_local.sh`, `~/.zshrc.local`)
- Secrets go in `~/.secrets` (not tracked, auto-sourced, must have 600 permissions)
- The `archive/` directory contains deprecated configs (vim, tmux) - do not use
