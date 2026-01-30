# dotfiles ![macOS](https://img.shields.io/badge/macOS-000000?style=flat&logo=apple&logoColor=white) ![Zsh](https://img.shields.io/badge/Zsh-F15A24?style=flat&logo=zsh&logoColor=white) ![Neovim](https://img.shields.io/badge/Neovim-57A143?style=flat&logo=neovim&logoColor=white) ![MIT License](https://img.shields.io/badge/License-MIT-blue.svg)

> Personal shell configuration for productive web development on macOS

## 📋 Overview

A curated collection of shell configurations, aliases, and functions optimized for Ruby/Rails, Node.js, and Docker development workflows. Built around Zsh with Prezto, featuring 100+ productivity aliases and seamless integration with modern tools like Graphite, 1Password commit signing, and Claude Code.

## ✨ Features at a Glance

| Category | Highlights |
|----------|------------|
| **Shell** | Zsh + Prezto, jump shortcuts, FZF fuzzy finding |
| **Git** | 90+ aliases, Graphite stacked diffs, 1Password SSH signing |
| **Editor** | Neovim with built-in cheatsheet, Claude Code integration |
| **Ruby/Rails** | 80+ aliases for Bundler, Rails, Rake, Rubocop, Capistrano |
| **JavaScript** | npm, pnpm, Bun aliases |
| **DevOps** | Docker, Docker Compose, Heroku, Homebrew |

## 📁 Repository Structure

```
~/.dotfiles/
├── zsh/              # Shell config, aliases, functions
│   ├── .zshrc        # Main Zsh configuration
│   ├── .zpreztorc    # Prezto framework settings
│   ├── aliases.sh    # Common aliases
│   ├── aliases_*.sh  # Domain-specific aliases (git, ruby, docker, etc.)
│   └── functions.sh  # Custom shell functions
├── git/              # Git config and global gitignore
├── ruby/             # Ruby, Rails, IRB configuration
├── nvim/             # Neovim configuration with cheatsheet
├── bash/             # Legacy/server bash config
└── archive/          # Deprecated configs (vim, tmux)
```

## 🛠 Prerequisites

**Required:**
- macOS (tested on Sonoma+)
- [Homebrew](https://brew.sh)
- Zsh (default on modern macOS)

**Recommended Tools:**

| Tool | Purpose | Install |
|------|---------|---------|
| [asdf](https://asdf-vm.com) | Version manager for Ruby, Node, Python | `brew install asdf` |
| [fzf](https://github.com/junegunn/fzf) | Fuzzy finder for shell history/files | `brew install fzf` |
| [fd](https://github.com/sharkdp/fd) | Fast file finder | `brew install fd` |
| [Neovim](https://neovim.io) | Modern Vim | `brew install neovim` |
| [Graphite](https://graphite.dev) | Stacked diffs workflow | `brew install withgraphite/tap/graphite` |

## 🚀 Installation

```bash
git clone git://github.com/svyatov/dotfiles.git ~/.dotfiles
chmod +x ~/.dotfiles/setup.sh
~/.dotfiles/setup.sh
```

**What the setup script does:**
- Backs up existing configs (adds `.orig` extension)
- Creates symlinks from home directory to dotfiles
- Clones the [Prezto](https://github.com/sorin-ionescu/prezto) framework
- Creates `~/.secrets` for private environment variables

## 📂 Key Files Reference

| Source | Symlinks to | Purpose |
|--------|-------------|---------|
| `zsh/.zshrc` | `~/.zshrc` | Main Zsh configuration |
| `zsh/.zshenv` | `~/.zshenv` | Environment variables |
| `zsh/.zpreztorc` | `~/.zpreztorc` | Prezto settings |
| `git/.gitconfig` | `~/.gitconfig` | Git configuration |
| `ruby/.gemrc` | `~/.gemrc` | RubyGems settings |
| `ruby/.irbrc` | `~/.irbrc` | IRB configuration |
| `ruby/.railsrc` | `~/.railsrc` | Rails generator defaults |
| `nvim/init.vim` | `~/.config/nvim/init.vim` | Neovim configuration |

## ⚡ Jump Shortcuts

One of the most useful features: **persistent directory bookmarks** with tab completion. Instead of typing long paths or relying on shell history, bookmark your frequently-used directories once and jump to them instantly.

| Command | Description |
|---------|-------------|
| `j name` | Jump to bookmarked directory |
| `ja name` | Add bookmark for current directory |
| `jd name` | Delete a bookmark |
| `jl` | List all bookmarks |
| `jb` | Jump back to previous location |

**Example workflow:**

```bash
# You're deep in a project
cd ~/Projects/client-name/app/services/payments

# Bookmark it
ja pay

# Later, from anywhere:
j pay  # Instantly back to ~/Projects/client-name/app/services/payments

# See all your bookmarks
jl
#   pay  -->  ~/Projects/client-name/app/services/payments
#   api  -->  ~/Projects/main-api
#   dots -->  ~/.dotfiles
```

Bookmarks persist across sessions (stored as symlinks in `~/.jump_shortcuts`) and support tab completion.

## 🌟 Highlight Aliases & Functions

### Shell Functions

| Function | Description |
|----------|-------------|
| `mkcd dir` | Create directory and cd into it |
| `u [dir]` | Jump up to parent (with tab completion) |
| `uu [dir]` | Jump up two levels |
| `cmdtop [n]` | Show most-used commands (default: 10) |
| `g` | Smart git: runs `git status` when called without arguments |
| `rncd app` | Create new Rails app and cd into it |

### Common Aliases

| Alias | Command | Description |
|-------|---------|-------------|
| `v` | `nvim` | Open Neovim |
| `l` | `ls -lhAG` | Detailed file listing |
| `cl` | `clear` | Clear terminal |
| `q` | `exit` | Exit shell |
| `edf` | `nvim ~/.dotfiles` | Edit dotfiles |
| `shrl` | `exec $SHELL -l` | Reload shell |
| `myip` | `dig +short myip.opendns.com...` | Show public IP |
| `ai` | `claude` | Launch Claude Code |

### Git Aliases (from `.gitconfig`)

| Alias | Command | Description |
|-------|---------|-------------|
| `g sts` | `git status --short --branch` | Compact status |
| `g co` | `git checkout` | Checkout branch |
| `g cob` | `git checkout -b` | Create and checkout branch |
| `g l` | `git log --graph --pretty=...` | Pretty log graph |
| `g df` | `git diff --word-diff` | Word-level diff |
| `g dfc` | `git diff --cached` | Diff staged changes |
| `g ps` | `git push -u` | Push with upstream |
| `g pl` | `git pull` | Pull with rebase |
| `g st` | `git stash` | Stash changes |
| `g sp` | `git stash pop` | Pop stash |
| `g rb` | `git rebase` | Rebase |
| `g rbi` | `git rebase --interactive` | Interactive rebase |
| `g brclr` | `git branch --merged \| ...` | Clean merged branches |
| `g sync` | Fetch upstream + merge + push | Sync fork with upstream |

### Graphite Aliases

| Alias | Command | Description |
|-------|---------|-------------|
| `gtc` | `gt create` | Create stacked branch |
| `gts` | `gt submit` | Submit PR |
| `gtss` | `gt submit --stack` | Submit entire stack |
| `gtre` | `gt restack` | Restack branches |
| `gty` | `gt sync` | Sync with remote |

### Ruby/Rails Aliases

| Alias | Command | Description |
|-------|---------|-------------|
| `be` | `bundle exec` | Run with bundler |
| `bi` | `bundle install` | Install gems |
| `bu` | `bundle update` | Update gems |
| `bo` | `bundle outdated` | Check outdated gems |
| `r` | `bundle exec rails` | Rails command |
| `rce` | `rails credentials:edit` | Edit credentials |
| `rrg` | `rails routes \| fzf -e` | Search routes with fzf |
| `rcp` | `bundle exec rubocop --parallel` | Run Rubocop |
| `rca` | `rubocop --autocorrect-all` | Rubocop auto-fix |
| `rk` | `rake` | Run rake |
| `ba` | `bundle-audit` | Security audit |
| `capsd` | `cap staging deploy` | Deploy to staging |
| `caprd` | `cap production deploy` | Deploy to production |

### JavaScript Aliases

| Alias | Command | Description |
|-------|---------|-------------|
| `nrd` | `npm run dev` | Run dev server |
| `nrt` | `npm run test` | Run tests |
| `nrb` | `npm run build` | Build project |
| `mm` | `pnpm` | pnpm shortcut |
| `mmd` | `pnpm dev` | pnpm dev server |
| `bb` | `bun` | Bun shortcut |
| `bbi` | `bun install` | Bun install |

### Docker Aliases

| Alias | Command | Description |
|-------|---------|-------------|
| `d` | `docker` | Docker shortcut |
| `di` | `docker images` | List images |
| `drmi` | `docker run --rm -it` | Run interactive container |
| `dcm` | `docker-compose` | Compose shortcut |
| `dcu` | `docker-compose up` | Start services |
| `dce` | `docker-compose exec` | Exec in container |

## 🔐 Secrets

The setup script creates `~/.secrets` which is automatically sourced by the shell. Use it for sensitive environment variables:

```bash
# ~/.secrets
export OPENAI_API_KEY="sk-..."
export GITHUB_TOKEN="ghp_..."
export DATABASE_URL="postgres://..."
```

This file is not tracked by git.

## ⌨️ Neovim Quick Reference

The Neovim config (`nvim/init.vim`) includes a built-in cheatsheet. Key custom mappings:

| Mapping | Action |
|---------|--------|
| `Space cc` | Open Claude Code in split |
| `Space ccr` | Resume Claude Code session |
| `Ctrl+h/j/k/l` | Navigate between splits |
| `Space q` | Close window |
| `Space y` / `Space p` | System clipboard yank/paste |
| `Alt+j/k` | Move lines up/down |
| `Space ve` | Edit Neovim config |

## 📜 License

MIT
