export EDITOR=nvim
export VISUAL=nvim
export LANG=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export ERL_AFLAGS="-kernel shell_history enabled" # Enables history for Elixir iex console

# export no_proxy="localhost,127.0.0.0/8,*.local"

# Set PATH, MANPATH, etc., for Homebrew.
eval "$(/opt/homebrew/bin/brew shellenv)"

# Home bin
export PATH="$HOME/bin:$HOME/.local/bin:$PATH"

# Doom Emacs
export PATH="$PATH:$HOME/.config/emacs/bin"

# Postgres.app
export PATH="$PATH:/Applications/Postgres.app/Contents/Versions/16/bin"

# Added by Toolbox App
export PATH="$PATH:/Users/leonid/Library/Application Support/JetBrains/Toolbox/scripts"

# Source local secrets
if [[ -f "$HOME/.secrets" ]]; then
  if [[ "$(stat -f '%Lp' "$HOME/.secrets" 2>/dev/null)" != "600" ]]; then
    echo "WARNING: ~/.secrets has insecure permissions. Run: chmod 600 ~/.secrets" >&2
  fi
  source "$HOME/.secrets"
fi
