# Common
safe_alias l 'ls -lhAG'
safe_alias lm 'l *.mp4'
safe_alias h 'cd ~'
safe_alias b 'cd -'
safe_alias cl 'clear'
safe_alias ll 'c && l'
safe_alias q 'exit'
safe_alias v 'vim'
safe_alias z 'zed'
safe_alias s 'subl'
safe_alias sn 'subl --new-window'
safe_alias o 'open'
safe_alias t 'tmux new -A -s local'
safe_alias edf 'z ~/.dotfiles'
safe_alias ea 'z ~/.dotfiles ~/.dotfiles/zsh/aliases.sh'
safe_alias ear 'z ~/.dotfiles ~/.dotfiles/zsh/aliases_ruby.sh'
safe_alias eab 'z ~/.dotfiles ~/.dotfiles/zsh/aliases_bun.sh'
safe_alias eah 'z ~/.dotfiles ~/.dotfiles/zsh/aliases_heroku.sh'
safe_alias ead 'z ~/.dotfiles ~/.dotfiles/zsh/aliases_docker.sh'
safe_alias ef 'z ~/.dotfiles ~/.dotfiles/zsh/functions.sh'
safe_alias ez 'z ~/.zshrc'
safe_alias egc 'z ~/.gitconfig'
safe_alias egi 'z .gitignore'
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
safe_alias ytd "yt-dlp"
safe_alias ytd-default "yt-dlp --ignore-errors --continue --format \"bestvideo[ext=mp4]+bestaudio[ext=m4a]/bestvideo+bestaudio/best\""
safe_alias ytds "ytd-default --output '%(title)s.%(ext)s'"
safe_alias ytdp "ytd-default --output '%(playlist)s/%(playlist_index)s - %(title)s.%(ext)s'"

for alias_file in $HOME/.dotfiles/zsh/aliases_*.sh(N); do
  source "$alias_file"
done
