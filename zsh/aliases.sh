# Common
safe_alias l 'ls -lhAG'
safe_alias lm 'l *.mp4'
safe_alias h 'cd ~'
safe_alias b 'cd -'
safe_alias cl 'clear'
safe_alias ll 'c && l'
safe_alias q 'exit'
safe_alias v 'vim'
safe_alias s 'subl'
safe_alias sn 'subl --new-window'
safe_alias o 'open'
safe_alias t 'tmux new -A -s local'
safe_alias edf 'v "+lcd ~/.dotfiles" -- ~/.dotfiles'
safe_alias ea 'v "+lcd ~/.dotfiles" ~/.dotfiles/zsh/aliases.sh'
safe_alias ear 'v "+lcd ~/.dotfiles" ~/.dotfiles/zsh/aliases_ruby.sh'
safe_alias eae 'v "+lcd ~/.dotfiles" ~/.dotfiles/zsh/aliases_elixir.sh'
safe_alias eah 'v "+lcd ~/.dotfiles" ~/.dotfiles/zsh/aliases_heroku.sh'
safe_alias ead 'v "+lcd ~/.dotfiles" ~/.dotfiles/zsh/aliases_docker.sh'
safe_alias ef 'v "+lcd ~/.dotfiles" ~/.dotfiles/zsh/functions.sh'
safe_alias et 'v "+lcd ~/.dotfiles" ~/.dotfiles/other/.tmux.conf'
safe_alias ez 'v ~/.zshrc'
safe_alias egc 'v ~/.gitconfig'
safe_alias egi 'v .gitignore'
safe_alias sca 'source ~/.dotfiles/zsh/aliases.sh'
safe_alias scf 'source ~/.dotfiles/zsh/functions.sh'
safe_alias shrl 'exec $SHELL -l' # shell reload
safe_alias vol 'volume'
safe_alias vol1 'volume 0.01'
safe_alias wh 'which'
safe_alias ws 'whois'
safe_alias m 'mosh'
safe_alias n 'ngrok'

# Update ZPrezto
safe_alias zpu 'pushd ~/.zprezto && git pull && git submodule update --init --recursive && popd'

# Copy public ssh key
safe_alias cpk 'cat ~/.ssh/id_rsa.pub | pbcopy && echo "Public ssh key copied to clipboard!"'

# My public IP
safe_alias myip 'dig +short myip.opendns.com @resolver1.opendns.com'

# YouTube-dl
safe_alias ytd "youtube-dl"
safe_alias ytd-default "youtube-dl --ignore-errors --continue --format \"bestvideo[ext=mp4]+bestaudio[ext=m4a]/bestvideo+bestaudio/best\""
safe_alias ytds "ytd-default --output '%(title)s.%(ext)s'"
safe_alias ytdp "ytd-default --output '%(playlist)s/%(playlist_index)s - %(title)s.%(ext)s'"

source $HOME/.dotfiles/zsh/aliases_brew.sh
source $HOME/.dotfiles/zsh/aliases_git.sh
source $HOME/.dotfiles/zsh/aliases_ruby.sh
source $HOME/.dotfiles/zsh/aliases_elixir.sh
source $HOME/.dotfiles/zsh/aliases_npm.sh
source $HOME/.dotfiles/zsh/aliases_yarn.sh
source $HOME/.dotfiles/zsh/aliases_vagrant.sh
source $HOME/.dotfiles/zsh/aliases_heroku.sh
source $HOME/.dotfiles/zsh/aliases_docker.sh
