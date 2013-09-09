# Path to your oh-my-zsh configuration.
ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
# robbyrussell, bira, crunch, juanghurtado, philips
ZSH_THEME="crunch"

# Set to this to use case-sensitive completion
# CASE_SENSITIVE="true"

# Comment this out to disable weekly auto-update checks
# DISABLE_AUTO_UPDATE="true"

# Uncomment following line if you want to disable colors in ls
# DISABLE_LS_COLORS="true"

# Uncomment following line if you want to disable autosetting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment following line if you want red dots to be displayed while waiting for completion
# COMPLETION_WAITING_DOTS="true"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
plugins=(brew capistrano gem vagrant) #(git brew gem vagrant knife)

export EDITOR=vim
export LANG=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8
export LC_ALL=en_US.UTF-8

if [[ -d /Applications/RubyMine\ EAP.app ]]; then
	export RUBYMINE_HOME=/Applications/RubyMine\ EAP.app
else
	export RUBYMINE_HOME=/Applications/RubyMine.app
fi

source $ZSH/oh-my-zsh.sh
source $HOME/.dotfiles/zsh/functions
source $HOME/.dotfiles/zsh/aliases

# cd $HOME/ansible && source ./hacking/env-setup -q && cd
# alias an='ansible -i ./hosts.ini'
# alias ap='ansible-playbook -i ./hosts.ini'
#
unalias run-help
autoload run-help
HELPDIR=/usr/local/share/zsh/helpfiles

unsetopt EXTENDED_GLOB # Fixing problem with git reset HEAD^ not found and many others
