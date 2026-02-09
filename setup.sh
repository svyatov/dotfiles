#!/bin/bash

set -e

DOTFILES_DIR="${HOME}/.dotfiles"
# Git
GIT_CONFIG_FILE="${HOME}/.gitconfig"
# Ruby
GEM_CONFIG_FILE="${HOME}/.gemrc"
IRB_CONFIG_FILE="${HOME}/.irbrc"
RAILS_CONFIG_FILE="${HOME}/.railsrc"
# Zsh
ZSH_RC_FILE="${HOME}/.zshrc"
ZSH_ENV_FILE="${HOME}/.zshenv"
ZSH_PROFILE_FILE="${HOME}/.zprofile"
ZSH_LOGIN_FILE="${HOME}/.zlogin"
# Zsh Prezto
ZPREZTO_DIR="${HOME}/.zprezto"
ZPREZTO_RC_FILE="${HOME}/.zpreztorc"
# Others
TMUX_CONFIG_FILE="${HOME}/.tmux.conf"
NEOVIM_CONFIG_DIR="${HOME}/.config/nvim"
NEOVIM_CONFIG_FILE="${NEOVIM_CONFIG_DIR}/init.vim"
# VIM_CONFIG_FILE="${HOME}/.vimrc"
# VIM_VUNDLE_DIR="${HOME}/.vim/bundle/Vundle.vim"
# Cursor
CURSOR_CONFIG_DIR="${HOME}/Library/Application Support/Cursor/User"
CURSOR_DOT_DIR="${HOME}/.cursor"
SECRETS_FILE="${HOME}/.secrets"

### Options
###########
DRY_RUN=false
CONFIRM=false
HELP=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --confirm)
            CONFIRM=true
            shift
            ;;
        --help|-h)
            HELP=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

if [[ "$HELP" == true ]]; then
    cat << EOF
Usage: setup.sh [OPTIONS]

Sets up dotfiles by creating symlinks from this repo to home directory locations.
Existing files are backed up with .orig extension.

Options:
    --dry-run   Show what would be done without making changes
    --confirm   Ask for confirmation before each symlink
    --help, -h  Show this help message

Files that will be symlinked:
    ~/.gitconfig     <- git/.gitconfig
    ~/.zshrc         <- zsh/.zshrc
    ~/.zshenv        <- zsh/.zshenv
    ~/.zlogin        <- zsh/.zlogin
    ~/.zpreztorc     <- zsh/.zpreztorc
    ~/.gemrc         <- ruby/.gemrc
    ~/.irbrc         <- ruby/.irbrc
    ~/.railsrc       <- ruby/.railsrc
    ~/.config/nvim/init.vim <- nvim/init.vim
    ~/.claude/settings.json <- claude/settings.json
    ~/.claude/statusline-command.sh <- claude/statusline-command.sh
    ~/.claude/CLAUDE.md <- claude/CLAUDE.md
    ~/.claude/skills/*  <- claude/skills/* (auto-discovered)
    ~/Library/Application Support/Cursor/User/settings.json <- cursor/settings.json
    ~/Library/Application Support/Cursor/User/keybindings.json <- cursor/keybindings.json
    ~/.cursor/mcp.json <- cursor/mcp.json
EOF
    exit 0
fi

### Pre-flight checks
#####################
echo "Running pre-flight checks..."

if ! command -v git &> /dev/null; then
    echo "ERROR: git is not installed"
    exit 1
fi

if ! command -v zsh &> /dev/null; then
    echo "WARNING: zsh is not installed (shell configs will still be symlinked)"
fi

if [[ ! -d "$DOTFILES_DIR" ]]; then
    echo "ERROR: Dotfiles directory not found: $DOTFILES_DIR"
    exit 1
fi

echo "Pre-flight checks passed."
echo ""

### Helpers
############
function backup_file() {
    local file="$1"
    local backup="${file}.orig"

    if [[ -f "$file" && ! -L "$file" ]]; then
        if [[ -f "$backup" ]]; then
            if [[ "$DRY_RUN" == true ]]; then
                echo "[DRY RUN] WARNING: Backup already exists: $backup (would be overwritten)"
            else
                echo "WARNING: Backup already exists: $backup (will be overwritten)"
            fi
        fi
        if [[ "$DRY_RUN" == true ]]; then
            echo "[DRY RUN] Would backup: $file -> $backup"
        else
            if /bin/mv "${file}" "${backup}"; then
                echo "Backed up: $file -> $backup"
            fi
        fi
    fi
}

function symlink_from_dotfiles() {
    local source="${DOTFILES_DIR}/${1}"
    local target="${2}"

    if [[ "$CONFIRM" == true && "$DRY_RUN" != true ]]; then
        read -p "Create symlink $target -> $source? [y/N] " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "Skipped: $target"
            return
        fi
    fi

    if [[ "$DRY_RUN" == true ]]; then
        echo "[DRY RUN] Would symlink: $target -> $source"
    else
        # s - symlink
        # h - do not follow symlink if exists
        # f - overwrite symlink if exists
        /bin/ln -shf "$source" "$target"
        echo "Symlinked: $target -> $source"
    fi
}

function verify_symlink() {
    local target="$1"
    local expected_source="$2"

    if [[ -L "$target" ]]; then
        local actual_source
        actual_source=$(readlink "$target")
        if [[ "$actual_source" == "$expected_source" ]]; then
            echo "  OK: $target"
            return 0
        else
            echo "  MISMATCH: $target points to $actual_source (expected $expected_source)"
            return 1
        fi
    else
        echo "  MISSING: $target is not a symlink"
        return 1
    fi
}

if [[ "$DRY_RUN" == true ]]; then
    echo "=== DRY RUN MODE ==="
    echo ""
fi

### Setting up git
###################
echo "Setting up git..."
backup_file "${GIT_CONFIG_FILE}"
symlink_from_dotfiles "git/.gitconfig" "${GIT_CONFIG_FILE}"

### Setting up zsh
###################
echo ""
echo "Setting up zsh..."
if [[ ! -d ${ZPREZTO_DIR} ]]; then
    if [[ "$DRY_RUN" == true ]]; then
        echo "[DRY RUN] Would clone Prezto to ${ZPREZTO_DIR}"
    else
        /usr/bin/env git clone --recursive "https://github.com/sorin-ionescu/prezto.git" "${ZPREZTO_DIR}"
    fi
fi
backup_file "${ZSH_RC_FILE}"
symlink_from_dotfiles "zsh/.zshrc" "${ZSH_RC_FILE}"
backup_file "${ZSH_ENV_FILE}"
symlink_from_dotfiles "zsh/.zshenv" "${ZSH_ENV_FILE}"
backup_file "${ZSH_LOGIN_FILE}"
symlink_from_dotfiles "zsh/.zlogin" "${ZSH_LOGIN_FILE}"
backup_file "${ZPREZTO_RC_FILE}"
symlink_from_dotfiles "zsh/.zpreztorc" "${ZPREZTO_RC_FILE}"
symlink_from_dotfiles "zsh/prompt_svyatov_setup" "${ZPREZTO_DIR}/modules/prompt/functions/prompt_svyatov_setup"
backup_file "${ZSH_PROFILE_FILE}" # just "remove" .zprofile because it's useless

### Setting up ruby: rails, irb, gem
#####################################
echo ""
echo "Setting up ruby..."
backup_file "${GEM_CONFIG_FILE}"
symlink_from_dotfiles "ruby/.gemrc" "${GEM_CONFIG_FILE}"
backup_file "${IRB_CONFIG_FILE}"
symlink_from_dotfiles "ruby/.irbrc" "${IRB_CONFIG_FILE}"
backup_file "${RAILS_CONFIG_FILE}"
symlink_from_dotfiles "ruby/.railsrc" "${RAILS_CONFIG_FILE}"

### Setting up vim
##################
# backup_file "${VIM_CONFIG_FILE}"
# symlink_from_dotfiles "other/.vimrc" "${VIM_CONFIG_FILE}"
# if [[ ! -d ${VIM_VUNDLE_DIR} ]]; then
#     /usr/bin/env git clone "https://github.com/gmarik/vundle.git" "${VIM_VUNDLE_DIR}"
#     /usr/bin/env vim +BundleInstall +qall

### Setting up neovim
#################
echo ""
echo "Setting up neovim..."
if [[ "$DRY_RUN" != true ]]; then
    mkdir -p "${NEOVIM_CONFIG_DIR}"
fi
backup_file "${NEOVIM_CONFIG_FILE}"
symlink_from_dotfiles "nvim/init.vim" "${NEOVIM_CONFIG_FILE}"

### Setting up Cursor
#####################
echo ""
echo "Setting up Cursor..."
if [[ "$DRY_RUN" != true ]]; then
    mkdir -p "${CURSOR_CONFIG_DIR}"
    mkdir -p "${CURSOR_DOT_DIR}"
fi
backup_file "${CURSOR_CONFIG_DIR}/settings.json"
symlink_from_dotfiles "cursor/settings.json" "${CURSOR_CONFIG_DIR}/settings.json"
backup_file "${CURSOR_CONFIG_DIR}/keybindings.json"
symlink_from_dotfiles "cursor/keybindings.json" "${CURSOR_CONFIG_DIR}/keybindings.json"
backup_file "${CURSOR_DOT_DIR}/mcp.json"
symlink_from_dotfiles "cursor/mcp.json" "${CURSOR_DOT_DIR}/mcp.json"

### Setting up others
######################
# backup_file "${TMUX_CONFIG_FILE}"
# symlink_from_dotfiles "other/.tmux.conf" "${TMUX_CONFIG_FILE}"
if [[ "$DRY_RUN" != true ]]; then
    touch "${SECRETS_FILE}"
fi

### Setting up Claude Code
##########################
echo ""
echo "Setting up Claude Code..."
CLAUDE_CONFIG_DIR="${HOME}/.claude"
if [[ "$DRY_RUN" != true ]]; then
    mkdir -p "${CLAUDE_CONFIG_DIR}"
fi

# Symlink settings and statusline
backup_file "${CLAUDE_CONFIG_DIR}/settings.json"
symlink_from_dotfiles "claude/settings.json" "${CLAUDE_CONFIG_DIR}/settings.json"
symlink_from_dotfiles "claude/statusline-command.sh" "${CLAUDE_CONFIG_DIR}/statusline-command.sh"
backup_file "${CLAUDE_CONFIG_DIR}/CLAUDE.md"
symlink_from_dotfiles "claude/CLAUDE.md" "${CLAUDE_CONFIG_DIR}/CLAUDE.md"

# Symlink skills
CLAUDE_SKILLS_DIR="${CLAUDE_CONFIG_DIR}/skills"
if [[ "$DRY_RUN" != true ]]; then
    mkdir -p "${CLAUDE_SKILLS_DIR}"
fi
for skill_dir in "${DOTFILES_DIR}"/claude/skills/*/; do
    skill_name=$(basename "$skill_dir")
    symlink_from_dotfiles "claude/skills/${skill_name}" "${CLAUDE_SKILLS_DIR}/${skill_name}"
done

### Verification
################
if [[ "$DRY_RUN" != true ]]; then
    echo ""
    echo "Verifying symlinks..."
    VERIFY_FAILED=0

    verify_symlink "${GIT_CONFIG_FILE}" "${DOTFILES_DIR}/git/.gitconfig" || VERIFY_FAILED=1
    verify_symlink "${ZSH_RC_FILE}" "${DOTFILES_DIR}/zsh/.zshrc" || VERIFY_FAILED=1
    verify_symlink "${ZSH_ENV_FILE}" "${DOTFILES_DIR}/zsh/.zshenv" || VERIFY_FAILED=1
    verify_symlink "${ZSH_LOGIN_FILE}" "${DOTFILES_DIR}/zsh/.zlogin" || VERIFY_FAILED=1
    verify_symlink "${ZPREZTO_RC_FILE}" "${DOTFILES_DIR}/zsh/.zpreztorc" || VERIFY_FAILED=1
    verify_symlink "${GEM_CONFIG_FILE}" "${DOTFILES_DIR}/ruby/.gemrc" || VERIFY_FAILED=1
    verify_symlink "${IRB_CONFIG_FILE}" "${DOTFILES_DIR}/ruby/.irbrc" || VERIFY_FAILED=1
    verify_symlink "${RAILS_CONFIG_FILE}" "${DOTFILES_DIR}/ruby/.railsrc" || VERIFY_FAILED=1
    verify_symlink "${NEOVIM_CONFIG_FILE}" "${DOTFILES_DIR}/nvim/init.vim" || VERIFY_FAILED=1
    verify_symlink "${CLAUDE_CONFIG_DIR}/settings.json" "${DOTFILES_DIR}/claude/settings.json" || VERIFY_FAILED=1
    verify_symlink "${CLAUDE_CONFIG_DIR}/statusline-command.sh" "${DOTFILES_DIR}/claude/statusline-command.sh" || VERIFY_FAILED=1
    verify_symlink "${CLAUDE_CONFIG_DIR}/CLAUDE.md" "${DOTFILES_DIR}/claude/CLAUDE.md" || VERIFY_FAILED=1
    verify_symlink "${CURSOR_CONFIG_DIR}/settings.json" "${DOTFILES_DIR}/cursor/settings.json" || VERIFY_FAILED=1
    verify_symlink "${CURSOR_CONFIG_DIR}/keybindings.json" "${DOTFILES_DIR}/cursor/keybindings.json" || VERIFY_FAILED=1
    verify_symlink "${CURSOR_DOT_DIR}/mcp.json" "${DOTFILES_DIR}/cursor/mcp.json" || VERIFY_FAILED=1
    for skill_dir in "${DOTFILES_DIR}"/claude/skills/*/; do
        skill_name=$(basename "$skill_dir")
        verify_symlink "${CLAUDE_SKILLS_DIR}/${skill_name}" "${DOTFILES_DIR}/claude/skills/${skill_name}" || VERIFY_FAILED=1
    done

    if [[ $VERIFY_FAILED -eq 1 ]]; then
        echo ""
        echo "WARNING: Some symlinks could not be verified."
    fi
fi

echo ""
if [[ "$DRY_RUN" == true ]]; then
    echo "Dry run complete. No changes were made."
else
    echo "Setup complete."
    echo ""
    echo "To install Claude Code plugins, run: ~/.dotfiles/claude/install-plugins.sh"
    echo "To install Claude Code skills, run: ~/.dotfiles/claude/install-skills.sh"
    echo "To install Cursor extensions, run: ~/.dotfiles/cursor/install-extensions.sh"
fi
