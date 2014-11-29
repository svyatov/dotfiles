# Common
alias l='ls -lhAG'
alias lm='l *.mp4'
alias h='cd ~'
alias b='cd -'
alias c='clear'
alias ll='c && l'
alias q='exit'
alias v='vim'
alias s='subl'
alias sn='subl --new-window'
alias o='open'
alias tm='tmux new -A -s local'
alias edf='v ~/.dotfiles'
alias dfe='edf'
alias ea='v ~/.dotfiles/zsh/aliases.sh'
alias ae='ea'
alias ef='v ~/.dotfiles/zsh/functions.sh'
alias fe='ef'
alias ez='v ~/.zshrc'
alias ze='ez'
alias egc='v ~/.gitconfig'
alias gce='egc'
alias sig='v .gitignore'
alias sca='source ~/.dotfiles/zsh/aliases.sh'
alias scf='source ~/.dotfiles/zsh/functions.sh'
alias shrl='exec $SHELL -l' # shell reload

# Update ZPrezto
alias zpu='pushd ~/.zprezto && git pull && git submodule update --init --recursive && popd'

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

# Git extras (https://github.com/tj/git-extras)
alias ginf='git info'        # Show information about the repo
alias gsum='git summary'     # Outputs a repo summary
alias gch='git changelog'    # Populate a file whose name matches change|history -i_ with commits since the previous tag
alias gc='git count'         # Output commit count
alias gu='git undo'          # Remove the latest commit
alias gset='git setup'       # Set up a git repository (if one doesn't exist), add all files, and make an initial commit
alias gobl='git obliterate'  # Completely remove a file from the repository, including past commits and tags

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
alias caps='bundle exec cap staging'
alias capsd='caps deploy'
alias capsdm='caps deploy:migrations'
alias capr='bundle exec cap production'
alias caprd='capr deploy'
alias caprdm='capr deploy:migrations'

# Vagrant
alias vg='vagrant'
alias vu='vagrant up'
alias vs='vagrant ssh'
alias vst='vagrant status'
alias vsus='vagrant suspend'
alias voff='vagrant halt'
alias vdel='vagrant destroy'
alias vp='vagrant provision'

# Brew
alias ew='brew'
alias ewu='brew update'
alias ewi='brew install'
alias ewf='brew info'
alias ewd='brew doctor'
alias ewo='brew outdated'
alias ewc='brew cleanup'
alias ewuo='brew update && brew outdated'
alias ewuu='brew upgrade'

# Other
alias jn='jasmine-node'
alias memc='/usr/local/opt/memcached/bin/memcached -l 127.0.0.1'
alias ytd='youtube-dl --ignore-errors --continue'
alias myip='dig +short myip.opendns.com @resolver1.opendns.com'
