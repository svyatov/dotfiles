#!/bin/bash
# Claude Code skills installation commands (via skills.sh)
# Run with: ~/.dotfiles/claude/install-skills.sh
# Requires: skills.sh installed (https://skills.sh)

set -e

if ! command -v skills &> /dev/null; then
    echo "Error: skills.sh is not installed"
    echo "Install it from: https://skills.sh"
    exit 1
fi

echo "Installing skills.sh skills..."

skills install ai-sdk
skills install find-skills
skills install logging-best-practices
skills install reducing-entropy
skills install requirements-clarity
skills install ui-ux-pro-max
skills install vercel-composition-patterns
skills install vercel-react-best-practices
skills install web-design-guidelines
skills install writing-clearly-and-concisely

echo ""
echo "All skills.sh skills installed successfully!"
echo ""
echo "Note: Local skills (ensure-docs, eol-check) are not tracked in dotfiles."
echo "These are managed separately in ~/.claude/skills/ and may contain sensitive info."
