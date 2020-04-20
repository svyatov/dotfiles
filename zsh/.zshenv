export EDITOR=vim
export LANG=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export ERL_AFLAGS="-kernel shell_history enabled" # Enables history for Elixir iex console

# export no_proxy="localhost,127.0.0.0/8,*.local"

# NVM
export NVM_DIR=~/.nvm
source /usr/local/opt/nvm/nvm.sh
export NODE_PATH=$NVM_BIN

# Brew bin
export PATH=/usr/local/bin:/usr/local/sbin:$PATH

# Home bin
export PATH=$HOME/bin:$PATH

# Postgres.app
export PATH=$PATH:/Applications/Postgres.app/Contents/Versions/11/bin
