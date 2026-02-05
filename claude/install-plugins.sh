#!/bin/bash
# Claude Code plugin installation commands
# Run with: ~/.dotfiles/claude/install-plugins.sh

set -e

echo "Installing Claude Code plugins..."

# Official plugins (from anthropics/claude-plugins-official)
claude plugin install frontend-design
claude plugin install feature-dev
claude plugin install commit-commands
claude plugin install typescript-lsp
claude plugin install pyright-lsp
claude plugin install gopls-lsp
claude plugin install security-guidance
claude plugin install pr-review-toolkit
claude plugin install superpowers

# Marketplace plugins
claude plugin install upstash/context7 context7-plugin
claude plugin install obra/superpowers-marketplace elements-of-style

echo ""
echo "All plugins installed successfully!"
echo "Note: Some plugins may need to be enabled in ~/.claude/settings.json"
