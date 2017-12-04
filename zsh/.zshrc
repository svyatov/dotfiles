# Environment files loading order: .zshenv => .zshrc => .profile => .zlogin

# Colors pallete for VIM gruvbox theme
$HOME/.vim/bundle/gruvbox/gruvbox_256palette_osx.sh

# Source Prezto
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# My stuff
source $HOME/.dotfiles/zsh/set_terminal_titles.sh
source $HOME/.dotfiles/zsh/unalias_prezto.sh
source $HOME/.dotfiles/zsh/functions.sh
source $HOME/.dotfiles/zsh/aliases.sh

# Go
export GOPATH=$HOME/Projects/Go
export GOBIN=$GOPATH/bin
export PATH=$PATH:$GOPATH/bin

# Heroku
export PATH=$PATH:/usr/local/heroku/bin

# NVM
export NVM_DIR=~/.nvm
source $(brew --prefix nvm)/nvm.sh
export NODE_PATH=$NVM_BIN

# rbenv
eval "$(rbenv init -)"

# Python 3
export PATH=$(python3 -m site --user-base)/bin:$PATH

# RVM
# [[ -d "$HOME/.rvm/bin" ]] && export PATH=$HOME/.rvm/bin:$PATH
# [[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*

# unsetopt EXTENDED_GLOB # Fixing problem with git reset HEAD^ not found and many others
# unsetopt AUTO_NAME_DIRS # Auto adding variable-stored paths to ~ list conflicts with RVM
