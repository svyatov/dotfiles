# Rubygems
safe_alias gmi 'gem install'
safe_alias gmu 'gem update'
safe_alias gmo 'gem outdated'
safe_alias gmus 'gem update --system'
safe_alias gmdel 'gem uninstall'
safe_alias gmb 'rake build'
safe_alias gmr 'rake release'
safe_alias gmgi 'rake install'

# Rake
safe_alias rk 'rake'
safe_alias rkt 'rake -T'

# Bundler
safe_alias be 'bundle exec'
safe_alias bu 'bundle update'
safe_alias bo 'bundle outdated'
safe_alias bos 'bundle outdated --strict'
safe_alias bi 'bundle install'
safe_alias bp 'bundle package'
safe_alias bpa 'bundle package --all'

# Ruby and Rails
safe_alias r 'rails' override # r - is a zsh builtin
safe_alias rce 'rails credentials:edit'
safe_alias rdc 'rails dev:cache'
safe_alias rrg 'rails routes | grep'
safe_alias rrp 'rails routes | sed -e "1d" -e "s,^[^/]*,,g" | awk ''{print $1}'' | sort | uniq'
safe_alias rkra 'rails rubocop:auto_correct'
safe_alias rksl 'rails scss_lint'
safe_alias rkcl 'rails coffeelint'
safe_alias rksp 'rails spec'
safe_alias bea 'bundle exec annotate'
safe_alias ber 'bundle exec rake'
safe_alias bes 'bundle exec sidekiq'
safe_alias wds 'bin/webpack-dev-server'

# Rubocop
safe_alias rcp 'bundle exec rubocop --parallel'
safe_alias rca 'bundle exec rubocop --auto-correct'
safe_alias rcaf 'bundle exec rubocop --auto-correct --fail-fast'

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
