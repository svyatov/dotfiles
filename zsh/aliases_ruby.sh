# Rubygems
safe_alias gmi 'gem install'
safe_alias gmu 'gem update'
safe_alias gmo 'gem outdated'
safe_alias gmus 'gem update --system'
safe_alias gmdel 'gem uninstall'
safe_alias gmb 'rake build'
safe_alias gmr 'rake release'
safe_alias gmgi 'rake install'
safe_alias c 'bin/console'

# Rake
safe_alias rk 'rake'
safe_alias rkt 'rake -T'
safe_alias brk 'bundle exec rake'
safe_alias brkt 'bundle exec rake -T'

# Bundler
safe_alias be 'bundle exec'
safe_alias bu 'bundle update'
safe_alias bo 'bundle outdated'
safe_alias bos 'bundle outdated --strict'
safe_alias bi 'bundle install'
safe_alias bp 'bundle package'
safe_alias bpa 'bundle package --all'

# Ruby and Rails
safe_alias r 'bundle exec rails' override # r - is a zsh builtin
safe_alias rce 'r credentials:edit'
safe_alias rdc 'r dev:cache'
safe_alias rrg 'r routes | grep'
safe_alias rrp 'r routes | sed -e "1d" -e "s,^[^/]*,,g" | awk ''{print $1}'' | sort | uniq'
safe_alias rkra 'r rubocop:auto_correct'
safe_alias rksl 'r scss_lint'
safe_alias rkcl 'r coffeelint'
safe_alias rksp 'r spec'
safe_alias bea 'bundle exec annotate'
safe_alias ber 'bundle exec rake'
safe_alias bes 'bundle exec sidekiq'
safe_alias wds 'bin/webpack-dev-server'

# Rubocop
safe_alias rcp 'bundle exec rubocop --parallel'
safe_alias rca 'rcp --autocorrect-all'
safe_alias rcas 'rcp --autocorrect'
safe_alias rcaf 'rcas --fail-fast'

# Capistrano
safe_alias caps 'bundle exec cap staging'
safe_alias capsc 'caps rails:console'
safe_alias capsd 'caps deploy'
safe_alias capsdm 'caps deploy:migrations'
safe_alias capr 'bundle exec cap production'
safe_alias caprc 'capr rails:console'
safe_alias caprd 'capr deploy'
safe_alias caprdm 'capr deploy:migrations'
safe_alias prd 'g ps && caprd'
safe_alias psd 'g ps && capsd'

# Bundle Audit
safe_alias ba 'bundle-audit'
safe_alias bau 'bundle-audit update'
