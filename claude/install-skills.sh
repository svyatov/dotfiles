#!/bin/bash
# Claude Code skills installation commands (via skills.sh)
# Installs skills for: Claude Code, Cursor, Codex

set -e

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

echo ""
echo "All skills installed for: claude-code, cursor, codex"
echo ""
echo "Note: Local skills (ensure-docs, eol-check) in ~/.claude/skills/ are preserved."
