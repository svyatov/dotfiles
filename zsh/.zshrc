# Environment files loading order:
# 1 - .zshenv
# 2 - .zshrc
# 3 - .profile
# 4 - .zlogin

# Source Prezto
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

source $HOME/.dotfiles/zsh/unalias_prezto.sh
source $HOME/.dotfiles/zsh/functions.sh
source $HOME/.dotfiles/zsh/aliases.sh

# unsetopt EXTENDED_GLOB # Fixing problem with git reset HEAD^ not found and many others
# unsetopt AUTO_NAME_DIRS # Auto adding variable-stored paths to ~ list conflicts with RVM

[[ -d "$HOME/.rvm/bin" ]] && export PATH=$HOME/.rvm/bin:$PATH
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*
