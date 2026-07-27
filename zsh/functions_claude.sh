# Scaffold .claude/settings.local.json with every plugin & direct skill
# listed and disabled, for per-repo opt-in. Edit the file to flip on what
# this repo needs.
ailocal() {
  local out=".claude/settings.local.json"
  [[ -e $out ]] && { echo "$out already exists — aborting." >&2; return 1; }
  local json skills
  json=$(claude plugin list --json) || { echo "claude plugin list failed" >&2; return 1; }
  # Direct skills: top-level dirs in ~/.claude/skills/ that hold a SKILL.md.
  skills=$(find -L "$HOME/.claude/skills" -maxdepth 2 -name SKILL.md 2>/dev/null \
    | sed -E "s#.*/skills/([^/]+)/SKILL.md#\1#" | sort -u | jq -R . | jq -s .)
  mkdir -p .claude
  jq --argjson skills "${skills:-[]}" '{
    enabledPlugins: ((map({(.id): false}) | add) // {}),
    enableAllProjectMcpServers: false,
    enabledMcpjsonServers: [],
    disabledMcpjsonServers: [],
    disableClaudeAiConnectors: true,
    permissions: { deny: ($skills | map("Skill(\(.))")) }
  }' <<< "$json" > "$out" \
    && echo "Created $out — $(jq '.enabledPlugins | length' "$out") plugins & $(jq '.permissions.deny | length' "$out") direct skills disabled."
}
