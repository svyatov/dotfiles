export EDITOR=vim
export VISUAL=vim
export LANG=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export ERL_AFLAGS="-kernel shell_history enabled" # Enables history for Elixir iex console

# export no_proxy="localhost,127.0.0.0/8,*.local"

# Set PATH, MANPATH, etc., for Homebrew.
eval "$(/opt/homebrew/bin/brew shellenv)"

# https://github.com/asdf-vm/asdf-nodejs#partial-and-codename-versions
export ASDF_NODEJS_LEGACY_FILE_DYNAMIC_STRATEGY=latest_available

# Home bin
export PATH="$HOME/bin:$PATH"

# Sublime Text CLI
export PATH="$PATH:/Applications/Sublime Text.app/Contents/SharedSupport/bin"

# Postgres.app
export PATH="$PATH:/Applications/Postgres.app/Contents/Versions/16/bin"

# Added by Toolbox App
export PATH="$PATH:/Users/leonid/Library/Application Support/JetBrains/Toolbox/scripts"

