export EDITOR=vim
export LANG=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8
export LC_ALL=en_US.UTF-8

export no_proxy="localhost,127.0.0.0/8,*.local"

if [[ -d /Applications/RubyMine\ EAP.app ]]; then
	export RUBYMINE_HOME=/Applications/RubyMine\ EAP.app
else
	export RUBYMINE_HOME=/Applications/RubyMine.app
fi

# PHP from Liip
#export PATH=/usr/local/php5/bin:$PATH

# Brew bin
export PATH=/usr/local/bin:$PATH

# Home bin
export PATH=$HOME/bin:$PATH

# Postgres.app
export PATH=$PATH:/Applications/Postgres.app/Contents/Versions/latest/bin
