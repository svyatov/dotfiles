export EDITOR=vim
export LANG=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8
export LC_ALL=en_US.UTF-8

if [[ -d /Applications/RubyMine\ EAP.app ]]; then
	export RUBYMINE_HOME=/Applications/RubyMine\ EAP.app
else
	export RUBYMINE_HOME=/Applications/RubyMine.app
fi

export PATH=$HOME/bin:/usr/local/bin:/usr/local/sbin:$PATH

if [[ -d "/usr/local/php5/bin" ]]; then
    export PATH=/usr/local/php5/bin:$PATH
fi

if [[ -d "/usr/local/share/npm/bin" ]]; then
    export PATH=$PATH:/usr/local/share/npm/bin
fi

if [[ -d "/Applications/Postgres.app/Contents/MacOS/bin" ]]; then
    export PATH="/Applications/Postgres.app/Contents/MacOS/bin:$PATH"
fi

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*
