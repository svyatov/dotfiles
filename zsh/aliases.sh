# Common
alias l='ls -lahG'
alias д=l
alias lm='l *.mp4'
alias дь=lm
alias h='cd ~'
alias р=h
alias b='cd -'
alias и=b
alias c='clear'
alias с=c
alias cl='c && l'
alias сд=cl
alias q='exit'
alias й=q
alias v='vim'
alias м=v
alias s='subl'
alias ы=s
alias sn='subl --new-window'
alias ыт=sn
alias п=g
alias edf='sn ~/.dotfiles'
alias dfe='edf'
alias ea='sn ~/.dotfiles/zsh/aliases.sh'
alias ae='ea'
alias ef='sn ~/.dotfiles/zsh/functions.sh'
alias fe='ef'
alias ez='sn ~/.zshrc'
alias ze='ez'
alias egc='sn ~/.gitconfig'
alias gce='egc'
alias sig='sn .gitignore'
alias sca='source ~/.dotfiles/zsh/aliases.sh'
alias scf='source ~/.dotfiles/zsh/functions.sh'
alias shrl='exec $SHELL -l' # shell reload

# Copy public ssh key
alias cpk='cat ~/.ssh/id_rsa.pub | pbcopy && echo "Public ssh key copied to clipboard!"'

# Pretty print json in shell, example:
# $ echo '[1, 2, 3, {"6": 7, "4": 5}]' | pj
#   [
#       1,
#       2,
#       3,
#       {
#           "4": 5,
#           "6": 7
#       }
#   ]
alias pj='python -m json.tool'

# Upgrade all pip packages to the newest available version
alias pup="pip freeze | grep -v '\-e' | cut -d= -f1 | xargs pip install -U"

# Global aliases
alias -g G='| grep'
alias -g L='| wc -l'

# Jumps
alias j='nocorrect jump'
alias ja='nocorrect jump-add'
alias jd='nocorrect jump-del'
alias jl='jump-list'

# Exercism
alias exf='cd ~/Projects/Playground/exercism && exercism fetch'
alias exs='exercism submit'

# Ruby and Rails
alias gm='gem'
alias gmi='gem install'
alias gmu='gem update'
alias gmus='gem update --system'
alias r='rails'
alias rk='rake'
alias rkm='rake db:migrate'
alias be='bundle exec'
alias bu='bundle update'
alias bi='bundle install'
alias bp='bundle package'
alias bpa='bundle package --all'
alias rbp='rails_best_practices'
alias capd='cap deploy'
alias capdm='cap deploy:migrations'

# Other
alias jn='jasmine-node'
alias memc='/usr/local/opt/memcached/bin/memcached -l 127.0.0.1'
alias ytd='youtube-dl --ignore-errors --continue'
