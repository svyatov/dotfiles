# Common
safe_alias l 'ls -lhAG'
safe_alias lm 'l *.mp4'
safe_alias h 'cd ~'
safe_alias b 'cd -'
safe_alias c 'clear'
safe_alias ll 'c && l'
safe_alias q 'exit'
safe_alias v 'vim'
safe_alias s 'subl'
safe_alias sn 'subl --new-window'
safe_alias o 'open'
safe_alias t 'tmux new -A -s local'
safe_alias tw 'my-tmux-rails'
safe_alias edf 'v "+lcd ~/.dotfiles" -- ~/.dotfiles'
safe_alias ea 'v "+lcd ~/.dotfiles" ~/.dotfiles/zsh/aliases.sh'
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

# Update ZPrezto
safe_alias zpu 'pushd ~/.zprezto && git pull && git submodule update --init --recursive && popd'

# Copy public ssh key
safe_alias cpk 'cat ~/.ssh/id_rsa.pub | pbcopy && echo "Public ssh key copied to clipboard!"'

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
safe_alias pj 'python -m json.tool'

# Upgrade all pip packages to the newest available version
safe_alias pup "pip freeze | grep -v '\-e' | cut -d= -f1 | xargs pip install -U"

# Exercism
safe_alias exf 'cd ~/Projects/Playground/exercism && exercism fetch'
safe_alias exs 'exercism submit'

# Git
safe_alias gps 'g ps'
safe_alias gg 'g g'

# Git extras (https://github.com/tj/git-extras)
safe_alias ginf 'git info'        # Show information about the repo
safe_alias gsum 'git summary'     # Outputs a repo summary
safe_alias gch 'git changelog'    # Populate a file whose name matches change|history -i_ with commits since the previous tag
safe_alias gc 'git count'         # Output commit count
safe_alias gu 'git undo'          # Remove the latest commit
safe_alias gset 'git setup'       # Set up a git repository (if one doesn't exist), add all files, and make an initial commit
safe_alias gobl 'git obliterate'  # Completely remove a file from the repository, including past commits and tags

# Heroku
safe_alias he 'heroku'
safe_alias hel 'heroku logs --tail'

# PHP
safe_alias cm 'php composer.phar'
safe_alias sf 'php app/console'
safe_alias sfcl 'php app/console cache:clear'
safe_alias sfroute 'php app/console router:debug'
safe_alias sfgb 'php app/console generate:bundle'

# Ruby and Rails
safe_alias gmi 'gem install'
safe_alias gmu 'gem update'
safe_alias gmo 'gem outdated'
safe_alias gmus 'gem update --system'
safe_alias gmrm 'gem uninstall'
safe_alias r 'rails' override # r - is a zsh builtin
safe_alias rk 'rake'
safe_alias rkt 'rake -T'
safe_alias rkm 'rake db:migrate'
safe_alias rkb 'rake build'
safe_alias rkr 'rake release'
safe_alias rki 'rake install'
safe_alias rrg 'rake routes | grep'
safe_alias rrp 'rake routes | sed -e "1d" -e "s,^[^/]*,,g" | awk ''{print $1}'' | sort | uniq'
safe_alias ba 'bundle-audit'
safe_alias bau 'bundle-audit update'
safe_alias be 'bundle exec'
safe_alias bu 'bundle update'
safe_alias bo 'bundle outdated'
safe_alias bos 'bundle outdated --strict'
safe_alias bi 'bundle install'
safe_alias bp 'bundle package'
safe_alias bpa 'bundle package --all'
safe_alias rbp 'rails_best_practices'
safe_alias capd 'cap deploy'
safe_alias capdm 'cap deploy:migrations'
safe_alias caps 'bundle exec cap staging'
safe_alias capsc 'bundle exec cap staging rails:console'
safe_alias capsd 'caps deploy'
safe_alias capsdm 'caps deploy:migrations'
safe_alias capr 'bundle exec cap production'
safe_alias caprc 'bundle exec cap production rails:console'
safe_alias caprd 'capr deploy'
safe_alias caprdm 'capr deploy:migrations'

# Vagrant
safe_alias vg 'vagrant'
safe_alias vu 'vagrant up'
safe_alias vs 'vagrant ssh'
safe_alias vst 'vagrant status'
safe_alias vsus 'vagrant suspend'
safe_alias voff 'vagrant halt'
safe_alias vdel 'vagrant destroy'
safe_alias vp 'vagrant provision'

# Brew
safe_alias ew 'brew'
safe_alias ewu 'brew update'
safe_alias ewi 'brew install'
safe_alias ews 'brew info'
safe_alias ewd 'brew doctor'
safe_alias ewo 'brew outdated'
safe_alias ewc 'brew cleanup'
safe_alias ewuo 'brew update && brew outdated'
safe_alias ewup 'brew upgrade'
safe_alias ewuu 'brew upgrade --all'

# Other
safe_alias jn 'jasmine-node'
safe_alias memc '/usr/local/opt/memcached/bin/memcached -l 127.0.0.1'
safe_alias ytd 'youtube-dl --ignore-errors --continue'
safe_alias myip 'dig +short myip.opendns.com @resolver1.opendns.com'
