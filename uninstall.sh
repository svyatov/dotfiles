#!/bin/bash

set -e

DOTFILES_DIR="${HOME}/.dotfiles"

# Files to unlink
SYMLINKS=(
    "${HOME}/.gitconfig"
    "${HOME}/.zshrc"
    "${HOME}/.zshenv"
    "${HOME}/.zlogin"
    "${HOME}/.zpreztorc"
    "${HOME}/.zprezto/modules/prompt/functions/prompt_svyatov_setup"
    "${HOME}/.gemrc"
    "${HOME}/.irbrc"
    "${HOME}/.railsrc"
    "${HOME}/.config/nvim/init.vim"
    "${HOME}/.claude/settings.json"
    "${HOME}/.claude/statusline-command.sh"
    "${HOME}/.claude/CLAUDE.md"
)

### Options
###########
DRY_RUN=false
HELP=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --dry-run)
            DRY_RUN=true
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
Usage: uninstall.sh [OPTIONS]

Removes symlinks created by setup.sh and restores backed up files.

Options:
    --dry-run   Show what would be done without making changes
    --help, -h  Show this help message

Files that will be unlinked:
EOF
    for file in "${SYMLINKS[@]}"; do
        echo "    $file"
    done
    exit 0
fi

### Helpers
###########
function remove_symlink() {
    local target="$1"
    local backup="${target}.orig"

    if [[ -L "$target" ]]; then
        if [[ "$DRY_RUN" == true ]]; then
            echo "[DRY RUN] Would remove symlink: $target"
            if [[ -f "$backup" ]]; then
                echo "[DRY RUN] Would restore backup: $backup -> $target"
            fi
        else
            rm "$target"
            echo "Removed symlink: $target"
            if [[ -f "$backup" ]]; then
                mv "$backup" "$target"
                echo "Restored backup: $target"
            fi
        fi
    elif [[ -e "$target" ]]; then
        echo "Skipping (not a symlink): $target"
    else
        echo "Skipping (does not exist): $target"
    fi
}

### Main
########
if [[ "$DRY_RUN" == true ]]; then
    echo "=== DRY RUN MODE ==="
    echo ""
fi

for file in "${SYMLINKS[@]}"; do
    remove_symlink "$file"
done

# Remove skill symlinks (auto-discovered)
for skill_dir in "${DOTFILES_DIR}"/claude/skills/*/; do
    skill_name=$(basename "$skill_dir")
    remove_symlink "${HOME}/.claude/skills/${skill_name}"
done

echo ""
if [[ "$DRY_RUN" == true ]]; then
    echo "Dry run complete. No changes were made."
else
    echo "Uninstall complete."
    echo "Note: Prezto directory (~/.zprezto) was not removed."
fi
