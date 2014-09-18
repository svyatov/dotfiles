# Common
alias l='ls -lhAG'
alias д=l
alias lm='l *.mp4'
alias дь=lm
alias h='cd ~'
alias р=h
alias b='cd -'
alias и=b
alias c='clear'
alias с=c
alias ll='c && l'
alias дд=ll
alias q='exit'
alias й=q
alias v='vim'
alias м=v
alias s='subl'
alias ы=s
alias sn='subl --new-window'
alias ыт=sn
alias п=g
alias o='open'
alias щ=o
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

# Exercism
alias exf='cd ~/Projects/Playground/exercism && exercism fetch'
alias exs='exercism submit'

# PHP
alias cm='php composer.phar'
alias sf='php app/console'
alias sfcl='php app/console cache:clear'
alias sfroute='php app/console router:debug'
alias sfgb='php app/console generate:bundle'

# Ruby and Rails
alias gm='gem'
alias gmi='gem install'
alias gmu='gem update'
alias gmus='gem update --system'
alias gmrm='gem uninstall'
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

# Vagrant
alias va='vagrant'
alias мф=va
alias vu='vagrant up'
alias мг=vu
alias vs='vagrant ssh'
alias мы=vs
alias vst='vagrant status'
alias vsus='vagrant suspend'
alias voff='vagrant halt'
alias vdel='vagrant destroy'
alias vp='vagrant provision'

# Brew
alias ew='brew'
alias уц=ew
alias ewu='brew update'
alias ewi='brew install'
alias ewf='brew info'
alias ewd='brew doctor'
alias ewo='brew outdated'
alias ewuo='brew update && brew outdated'
alias ewuu='brew upgrade'

# Other
alias jn='jasmine-node'
alias memc='/usr/local/opt/memcached/bin/memcached -l 127.0.0.1'
alias ytd='youtube-dl --ignore-errors --continue'
alias myip='dig +short myip.opendns.com @resolver1.opendns.com'
