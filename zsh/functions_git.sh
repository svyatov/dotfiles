safe_alias g 'noglob _g'
_g() {
    if [[ -n $1 ]]; then
        git "$@"
    else
        git st
    fi
}

# git clone & cd (accepts only ssh url format: git@github.com:svyatov/dotfiles.git)
gclcd() {
    local repo=${1##*/}
    local dirname=${repo%\.git}

    if [[ -n $2 ]]; then
        dirname=$2
    fi

    git clone "$1" "$dirname" && cd "$dirname"
}
