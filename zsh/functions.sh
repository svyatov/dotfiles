source $HOME/.dotfiles/zsh/functions_jumps.sh
source $HOME/.dotfiles/zsh/functions_ruby.sh

mkcd() { mkdir -p "$1" && cd "$1" }

# Shows most often used shell commands
cmdtop() {
    local list_limit=10 # show top 10 commands by default
    if [[ -n $1 ]]; then
        local list_limit=$1
    fi
    history | awk '{print $2}' | awk 'BEGIN {FS="|"} {print $1}' | sort | uniq -c | sort -r | head -n $list_limit
}

# Function for updating Wordpress plugins
uwpp() {
    if [[ -n $1 ]]; then
        local archive=${1##*/}
        wget $1 && unzip -quo $archive && rm $archive && echo 'Done.'
    else
        echo 'Please, provide url for plugin archive.'
    fi
}

speedup-skype() {
    if [[ -n $1 ]]; then
        if [[ -d "${HOME}/Library/Application Support/Skype/${1}" ]]; then
            sqlite3 "${HOME}/Library/Application Support/Skype/${1}/main.db" "vacuum; reindex;"
        else
            echo "There is no data for username '${1}' in Skype folder."
        fi
    else
        echo 'Please, provide Skype username to speed up.'
    fi
}

g() {
    if [[ -n $1 ]]; then
        git $@
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