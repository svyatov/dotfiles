#!/bin/bash
# Cursor extension installation from extensions.txt
# Run with: ~/.dotfiles/cursor/install-extensions.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
EXTENSIONS_FILE="${SCRIPT_DIR}/extensions.txt"

if [[ ! -f "$EXTENSIONS_FILE" ]]; then
    echo "ERROR: extensions.txt not found at $EXTENSIONS_FILE"
    exit 1
fi

if ! command -v cursor &> /dev/null; then
    echo "ERROR: 'cursor' command not found. Install it from Cursor: Cmd+Shift+P -> 'Install cursor command'"
    exit 1
fi

echo "Installing Cursor extensions..."

while IFS= read -r ext || [[ -n "$ext" ]]; do
    [[ -z "$ext" || "$ext" == \#* ]] && continue
    echo "  Installing: $ext"
    cursor --install-extension "$ext" || echo "  WARNING: Failed to install $ext"
done < "$EXTENSIONS_FILE"

echo ""
echo "Done!"
