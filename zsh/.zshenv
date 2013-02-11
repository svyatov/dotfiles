export PATH=$HOME/bin:/usr/local/bin:/usr/local/sbin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/X11/bin:/opt/local/bin
if [[ -d "${HOME}/.rvm/bin" ]]; then
    export PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting
fi
