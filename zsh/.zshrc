# Environment files loading order: .zshenv => .zshrc => .profile => .zlogin

# Colors pallete for VIM gruvbox theme
# $HOME/.cache/dein/repos/github.com/morhetz/gruvbox/gruvbox_256palette_osx.sh

# Source Prezto
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# My stuff
source $HOME/.dotfiles/zsh/set_terminal_titles.sh
source $HOME/.dotfiles/zsh/unalias_prezto.sh
source $HOME/.dotfiles/zsh/functions.sh
source $HOME/.dotfiles/zsh/aliases.sh

# Heroku
export PATH=$PATH:/usr/local/heroku/bin

# NVM
export NVM_DIR=~/.nvm
source $(brew --prefix nvm)/nvm.sh
export NODE_PATH=$NVM_BIN

# rbenv
eval "$(rbenv init -)"

# Elixir
export PATH=$PATH:~/.mix/escripts
