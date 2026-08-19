# Claude Code
# ~/.claude/settings.json has several writers, so it is synced, not symlinked.
# csync asks which side wins for every difference, csync --status just lists them.
safe_alias csync "${HOME}/.dotfiles/claude/settings-sync.rb"
