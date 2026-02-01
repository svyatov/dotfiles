# Common
safe_alias l 'ls -lhAG'
safe_alias lm 'l *.mp4'
safe_alias h 'cd ~'
safe_alias b 'cd -'
safe_alias c 'clear'
safe_alias ll 'c && l'
safe_alias q 'exit'
safe_alias v 'nvim'
safe_alias z 'zed'
safe_alias o 'open'
safe_alias edf 'v ~/.dotfiles'
safe_alias ea 'v ~/.dotfiles/zsh/aliases.sh'
safe_alias ear 'v ~/.dotfiles/zsh/aliases_ruby.sh'
safe_alias eab 'v ~/.dotfiles/zsh/aliases_bun.sh'
safe_alias eah 'v ~/.dotfiles/zsh/aliases_heroku.sh'
safe_alias ead 'v ~/.dotfiles/zsh/aliases_docker.sh'
safe_alias ef 'v ~/.dotfiles/zsh/functions.sh'
safe_alias ez 'v ~/.zshrc'
safe_alias esc 'v ~/.ssh/config'
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
safe_alias ai 'claude'

# Update ZPrezto
safe_alias zpu 'pushd ~/.zprezto && git pull && git submodule update --init --recursive && popd'

# Copy public ssh key (TODO: change this to use 1P)
safe_alias cpk 'cat ~/.ssh/id_rsa.pub | pbcopy && echo "Public ssh key copied to clipboard!"'

# My public IP
safe_alias myip 'dig +short myip.opendns.com @resolver1.opendns.com'

# YouTube-dl
safe_alias ytd "yt-dlp"
safe_alias ytd-default "yt-dlp --ignore-errors --continue --format \"bestvideo[ext=mp4]+bestaudio[ext=m4a]/bestvideo+bestaudio/best\""
safe_alias ytds "ytd-default --output '%(title)s.%(ext)s'"
safe_alias ytdp "ytd-default --output '%(playlist)s/%(playlist_index)s - %(title)s.%(ext)s'"

for alias_file in $HOME/.dotfiles/zsh/aliases_*.sh(N); do
  source "$alias_file"
done
