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

# Bindings
# bindkey '^ ' autosuggest-accept

# asdf
source "$(brew --prefix asdf)/libexec/asdf.sh"

# Heroku
# export PATH=$PATH:/usr/local/heroku/bin

# Disables warnings for Ruby 2.7
# export RUBYOPT="-W:no-deprecated -W:no-experimental"

# Elixir
# export PATH=$PATH:~/.mix/escripts

# GoLang
# export PATH=$PATH:$HOME/go/bin

# Starship (https://starship.rs)
# eval "$(starship init zsh)"

# bun completions
[ -s "/Users/leonid/.bun/_bun" ] && source "/Users/leonid/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
