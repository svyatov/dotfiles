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

for function_file in $HOME/.dotfiles/zsh/functions_*.sh(N); do
  source "$function_file"
done

mkcd() { mkdir -p "$1" && cd "$1" }

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

volume() {
    if [[ -z $1 ]]; then
        echo 'You forget to specify value!'
        return 1
    fi

    osascript -e "set Volume $1"
}
