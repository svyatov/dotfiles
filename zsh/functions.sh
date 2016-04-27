# Safe alias
safe_alias() {
    if [[ $3 == 'override' ]]; then
        alias "$1"="$2"
    elif ! type "$1" &> /dev/null; then
        alias "$1"="$2"
    else
        echo "Unable to create alias: $(type "$1")"
    fi
}

source $HOME/.dotfiles/zsh/functions_jumps.sh
source $HOME/.dotfiles/zsh/functions_ruby.sh
source $HOME/.dotfiles/zsh/functions_php.sh
source $HOME/.dotfiles/zsh/functions_git.sh
source $HOME/.dotfiles/zsh/functions_tmux.sh

mkcd() { mkdir -p "$1" && cd "$1" }

safe_alias ff "noglob _f f"
safe_alias fd "noglob _f d"
_f() {
    noglob find . -type $1 -iname "$2"
}

_directories_list() { find $1 -type d -maxdepth 1 -not -name '.' -not -name '..' -exec basename {} + }

u() {
    if [[ -n $1 ]]; then
        cd ../$1
    else
        cd ..
    fi
}
_u() { reply=("${(@f)$(_directories_list ..)}") }
compctl -M 'm:{a-z}={A-Z}' -K _u u

uu() {
    if [[ -n $1 ]]; then
        cd ../../$1
    else
        cd ../..
    fi
}
_uu() { reply=("${(@f)$(_directories_list ../..)}") }
compctl -M 'm:{a-z}={A-Z}' -K _uu uu

proxysh() {
    if [[ $1 == 'off' ]]; then
        export http_proxy=
        export https_proxy=
        echo 'Shell proxies disabled.'
    else
        export http_proxy=127.0.0.1:8123
        export https_proxy=127.0.0.1:8123
        echo 'Shell proxies enabled!'
    fi
}

# Shows most often used shell commands
cmdtop() {
    local list_limit=10 # show top 10 commands by default
    if [[ -n $1 ]]; then
        local list_limit=$1
    fi
    history 1 | awk '{print $2}' | awk 'BEGIN {FS="|"} {print $1}' | sort | uniq -c | sort -r | head -n $list_limit
}

# Function for updating Wordpress plugins
uwpp() {
    if [[ -n $1 ]]; then
        local archive=${1##*/}
        wget $1 && rm -r ${archive%%.*} && unzip -quo $archive && rm $archive && echo 'Done.'
    else
        echo 'Please, provide url for plugin archive.'
    fi
}

resolve_apache_file_permissions() {
    if [[ -z $1 ]]; then
        echo 'You forget to specify directory!'
        return 1
    fi
    # allow apache to access user's files
    sudo chmod -R +a 'group:_www allow read,write,delete,add_file,add_subdirectory,file_inherit,directory_inherit' $1
    # allow user to access files created by apache
    sudo chmod -R +a 'group:staff allow read,write,delete,add_file,add_subdirectory,file_inherit,directory_inherit' $1
}

volume() {
    if [[ -z $1 ]]; then
        echo 'You forget to specify value!'
        return 1
    fi

    osascript -e "set Volume $1" 
}
