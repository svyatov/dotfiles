#!/usr/bin/env bash
set -e

INSTALL_DIR="$HOME/.config/svyatov"
BASE_URL="https://raw.githubusercontent.com/svyatov/dotfiles/master/servers/.config"

echo "Installing Svyatov's server shell configuration..."

# Create directory (including ~/.config if it doesn't exist)
mkdir -p "$INSTALL_DIR"
if [[ ! -w "$INSTALL_DIR" ]]; then
    echo "Error: Cannot write to $INSTALL_DIR" >&2
    exit 1
fi

# Download base files
curl -fsSL "$BASE_URL/aliases" -o "$INSTALL_DIR/aliases"
curl -fsSL "$BASE_URL/vimrc" -o "$INSTALL_DIR/vimrc"
curl -fsSL "$BASE_URL/README.md" -o "$INSTALL_DIR/README.md"

# Ask about admin aliases
SOURCE_FILE="aliases"
if sudo -l -n &>/dev/null 2>&1; then
    read -p "Install admin aliases (package management, etc.)? [Y/n] " admin_choice
    if [[ ! "$admin_choice" =~ ^[Nn]$ ]]; then
        curl -fsSL "$BASE_URL/admin_aliases" -o "$INSTALL_DIR/admin_aliases"
        SOURCE_FILE="admin_aliases"
        echo "Admin aliases installed."
    fi
fi

# Fix .bashrc conflicts
if grep -q "^alias l=" ~/.bashrc 2>/dev/null; then
    sed -i.bak "s/^alias l=/#alias l=/" ~/.bashrc
    echo "Commented out conflicting 'alias l' in .bashrc"
fi

# Add source line (if not already present)
SOURCE_LINE=". $INSTALL_DIR/$SOURCE_FILE"
if ! grep -qF "$SOURCE_LINE" ~/.bashrc 2>/dev/null; then
    echo "" >> ~/.bashrc
    echo "# Svyatov's server shell configuration" >> ~/.bashrc
    echo "$SOURCE_LINE" >> ~/.bashrc
fi

echo "Installation complete! Run 'source ~/.bashrc' or start a new shell."
