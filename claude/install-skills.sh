#!/bin/bash
# Claude Code skills installation commands (via skills.sh)

set -e

# Skills this script will install (for comparison)
SCRIPT_SKILLS=(
  "gh-cli"
  "vercel-react-best-practices"
  "vercel-composition-patterns"
  "web-design-guidelines"
  "next-best-practices"
  "next-upgrade"
  "next-cache-components"
)

# Get currently installed skills
echo "Checking currently installed skills..."
INSTALLED_SKILLS=$(npx skills list -g 2>/dev/null | grep -E "^[a-zA-Z]" | awk '{print $1}' || true)

# Find skills that would be removed (installed but not in script)
WOULD_REMOVE=()
for skill in $INSTALLED_SKILLS; do
  if [[ ! " ${SCRIPT_SKILLS[*]} " =~ " ${skill} " ]]; then
    WOULD_REMOVE+=("$skill")
  fi
done

# Show diff
if [[ ${#WOULD_REMOVE[@]} -gt 0 ]]; then
  echo ""
  echo "WARNING: The following skills would be REMOVED:"
  for skill in "${WOULD_REMOVE[@]}"; do
    echo "   - $skill"
  done
  echo ""
  echo "These skills are installed but not in this script."
  echo "Add them to install-skills.sh to preserve them."
  echo ""

  if [[ "$1" != "--force" ]]; then
    read -p "Continue anyway? [y/N] " confirm
    if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
      echo "Aborted. Add missing skills to the script or use --force to override."
      exit 1
    fi
  fi
fi

echo "Removing existing global skills..."
npx skills remove -g --all -y 2>/dev/null || true

echo ""
echo "Installing skills..."
echo ""

# GitHub
npx skills add github/awesome-copilot -s gh-cli -g -a claude-code cursor codex -y

# Vercel Labs
npx skills add vercel-labs/agent-skills -s vercel-react-best-practices -g -a claude-code cursor codex -y
npx skills add vercel-labs/agent-skills -s vercel-composition-patterns -g -a claude-code cursor codex -y
npx skills add vercel-labs/agent-skills -s web-design-guidelines -g -a claude-code cursor codex -y

# Next.js
npx skills add vercel-labs/next-skills -s next-best-practices -g -a claude-code cursor codex -y
npx skills add vercel-labs/next-skills -s next-upgrade -g -a claude-code cursor codex -y
npx skills add vercel-labs/next-skills -s next-cache-components -g -a claude-code cursor codex -y

echo ""
echo "All skills installed."
echo ""
echo "Use --force to skip the removal confirmation prompt."
