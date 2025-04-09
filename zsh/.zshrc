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

# brew install fzf
# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)

# brew install fd
# Use fd instead of fzf
export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"

# Use fd (https://github.com/sharkdp/fd) for listing path candidates.
# - The first argument to the function ($1) is the base path to start traversal
# - See the source code (completion.{bash,zsh}) for the details.
_fzf_compgen_path() {
  fd --hidden --exclude .git . "$1"
}

# Use fd to generate the list for directory completion
_fzf_compgen_dir() {
  fd --type=d --hidden --exclude .git . "$1"
}

# asdf for v0.15
# source /opt/homebrew/opt/asdf/libexec/asdf.sh
export ASDF_DATA_DIR=/Users/leonid/.asdf
export PATH="$ASDF_DATA_DIR/shims:$PATH"

# Elixir
# export PATH=$PATH:~/.mix/escripts

# GoLang
# export PATH=$PATH:$HOME/go/bin

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"


