# Claude Code
# ~/.claude/settings.json has several writers, so it is synced, not symlinked.
# csync shows drift, csync --pull snapshots before committing, csync --push applies.
safe_alias csync "${HOME}/.dotfiles/claude/settings-sync.sh"
