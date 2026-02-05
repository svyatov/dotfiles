#!/bin/bash
# Claude Code skills installation commands (via skills.sh)
# Installs skills for: Claude Code, Cursor, Codex

set -e

# Skills this script will install (for comparison)
SCRIPT_SKILLS=(
  "ai-sdk"
  "find-skills"
  "vercel-react-best-practices"
  "web-design-guidelines"
  "vercel-composition-patterns"
  "pdf"
  "skill-creator"
  "reducing-entropy"
  "writing-clearly-and-concisely"
  "ui-ux-pro-max"
  "logging-best-practices"
  "requirements-clarity"
  "do-work"
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
  echo "⚠️  WARNING: The following skills would be REMOVED:"
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
echo "Installing skills for: claude-code, cursor, codex"
echo ""

# Vercel AI SDK
npx skills add vercel/ai -g -a claude-code cursor codex -y

# Vercel Labs skills
npx skills add vercel-labs/skills -s find-skills -g -a claude-code cursor codex -y
npx skills add vercel-labs/agent-skills -s vercel-react-best-practices -g -a claude-code cursor codex -y
npx skills add vercel-labs/agent-skills -s web-design-guidelines -g -a claude-code cursor codex -y
npx skills add vercel-labs/agent-skills -s vercel-composition-patterns -g -a claude-code cursor codex -y

# Anthropic official skills
npx skills add anthropics/skills -s pdf -g -a claude-code cursor codex -y
npx skills add anthropics/skills -s skill-creator -g -a claude-code cursor codex -y

# Softaworks toolkit
npx skills add softaworks/agent-toolkit -s reducing-entropy -g -a claude-code cursor codex -y
npx skills add softaworks/agent-toolkit -s writing-clearly-and-concisely -g -a claude-code cursor codex -y

# Other skills
npx skills add nextlevelbuilder/ui-ux-pro-max-skill -g -a claude-code cursor codex -y
npx skills add boristane/agent-skills -s logging-best-practices -g -a claude-code cursor codex -y
npx skills add davila7/claude-code-templates -s requirements-clarity -g -a claude-code cursor codex -y
npx skills add bladnman/do-work -g -a claude-code cursor codex -y

echo ""
echo "All skills installed for: claude-code, cursor, codex"
echo ""
echo "Note: Local skills in ~/.claude/skills/ are preserved."
echo "      Use --force to skip the removal confirmation prompt."
