#!/usr/bin/env bash
set -e

INSTALL_DIR="$HOME/.config/svyatov"
BASE_URL="https://raw.githubusercontent.com/svyatov/dotfiles/master/servers/.config"

echo "Updating Svyatov's server shell configuration..."

mkdir -p "$INSTALL_DIR"

# Download base files
curl -fsSL "$BASE_URL/aliases" -o "$INSTALL_DIR/aliases"
curl -fsSL "$BASE_URL/vimrc" -o "$INSTALL_DIR/vimrc"
curl -fsSL "$BASE_URL/README.md" -o "$INSTALL_DIR/README.md"

# Download admin aliases if user has sudo access
if sudo -l -n &>/dev/null 2>&1; then
    curl -fsSL "$BASE_URL/admin_aliases" -o "$INSTALL_DIR/admin_aliases"
    echo "Updated: aliases, admin_aliases, vimrc"
    source "$INSTALL_DIR/admin_aliases"
else
    echo "Updated: aliases, vimrc"
    source "$INSTALL_DIR/aliases"
fi

echo "Update complete!"
