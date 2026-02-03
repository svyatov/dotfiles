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

# fzf - fuzzy finder (brew install fzf)
if command -v fzf &> /dev/null; then
  source <(fzf --zsh)

  # fd integration for fzf (brew install fd)
  if command -v fd &> /dev/null; then
    export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"

    _fzf_compgen_path() {
      fd --hidden --exclude .git . "$1"
    }

    _fzf_compgen_dir() {
      fd --type=d --hidden --exclude .git . "$1"
    }
  else
    echo "dotfiles: fd not found. Install with 'brew install fd' for enhanced fzf completion." >&2
  fi
else
  echo "dotfiles: fzf not found. Install with 'brew install fzf' for fuzzy finding." >&2
fi

# asdf version manager
if [[ -d "${HOME}/.asdf" ]]; then
  export ASDF_DATA_DIR="${HOME}/.asdf"
  export PATH="$ASDF_DATA_DIR/shims:$PATH"
else
  echo "dotfiles: asdf not found. Install with 'brew install asdf' for version management." >&2
fi

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

# Source local customizations (machine-specific, not in git)
[[ -f "${HOME}/.zshrc.local" ]] && source "${HOME}/.zshrc.local"
