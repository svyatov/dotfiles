#!/bin/bash
# Background version checker for Claude Code
# Writes current and latest versions to cache file

CACHE_DIR="$HOME/.claude/cache"
CACHE_FILE="$CACHE_DIR/version-check.json"

# Ensure cache directory exists
mkdir -p "$CACHE_DIR"

# Get current installed version
current_version=$(claude --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)

# Get latest version from npm (with timeout)
latest_version=$(timeout 10 npm view @anthropic-ai/claude-code@latest version 2>/dev/null)

# Only write cache if we got valid versions
if [ -n "$current_version" ] && [ -n "$latest_version" ]; then
    checked_at=$(date +%s)
    cat > "$CACHE_FILE" << EOF
{
  "current_version": "$current_version",
  "latest_version": "$latest_version",
  "checked_at": $checked_at
}
EOF
fi
