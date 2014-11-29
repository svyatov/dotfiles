export JUMPS_PATH=$HOME/.jump_shortcuts

alias j='nocorrect jump'
alias ja='nocorrect jump-add'
alias jd='nocorrect jump-del'
alias jl='jump-list'
alias jb='jump-back'

_jumps_usage_help() {
    echo "You can use following commands:"
    echo " j [shortcut] - jump to shortcutted directory"
    echo "ja [shortcut] - add shortcut for current directory"
    echo "jd [shortcut] - delete shortcut"
    echo "jl            - list all available jump shortcuts"
    echo "jb            - return to previous directory (before the last jump)"
}

_jumps_no_such_shortcut() {
    echo "${FX[none]}${FG[196]}No such jump shortcut: ${FX[none]}${FG[9]}${1}"
}

_jumps_no_shortcuts() {
    echo "${FX[none]}${FG[196]}There are no shortcuts, yet. You should add some first!${FX[none]}"
}

jump() {
    if [[ -z $1 ]]; then _jumps_usage_help; return 1; fi
    if [[ -L $JUMPS_PATH/$1 ]]; then
        clear
        JUMPS_BACK=$(pwd)
        cd -P $JUMPS_PATH/$1 2> /dev/null && ls -lhAG
    else
        _jumps_no_such_shortcut $1
    fi
}

jump-back() {
    if [[ -d $JUMPS_BACK ]]; then
        clear
        cd $JUMPS_BACK 2> /dev/null
        JUMPS_BACK=''
    fi
}

jump-add() {
    if [[ -z $1 ]]; then _jumps_usage_help; return 1; fi
    if [[ ! -d $JUMPS_PATH ]]; then
        mkdir -p $JUMPS_PATH;
    fi
    if [[ -L $JUMPS_PATH/$1 ]]; then
        local jump_destination=$(readlink $JUMPS_PATH/$1)
        echo "${FX[none]}${FG[196]}Shortcut \"${FX[none]}${FG[9]}${1}${FX[none]}${FG[196]}\" already exists and points to: ${FX[none]}${FG[9]}${jump_destination}${FX[none]}"
    else
        ln -s "$(pwd)" $JUMPS_PATH/$1 && \
            echo "${FX[none]}${FG[76]}Shortcut \"${FX[none]}${FG[14]}${1}${FX[none]}${FG[76]}\" pointing to ${FX[none]}${FG[14]}$(pwd)${FX[none]}${FG[76]} successfully added${FX[none]}"
    fi
}

jump-del() {
    if [[ -z $1 ]]; then _jumps_usage_help; return 1; fi
    if [[ -L $JUMPS_PATH/$1 ]]; then
        rm $JUMPS_PATH/$1 && \
            echo "${FX[none]}${FG[76]}Shortcut \"${FX[none]}${FG[14]}${1}${FX[none]}${FG[76]}\" successfully deleted"
    else
        _jumps_no_such_shortcut $1
    fi
}

jump-list() {
    if [[ ! -d $JUMPS_PATH ]]; then
        _jumps_no_shortcuts && return 1;
    fi

    local shortcuts
    local shortcut_link
    local shortcut_length
    local shortcut_basename
    local max_shortcut_length=0

    shortcuts=("${(@f)$(find $JUMPS_PATH -type l)}")

    for shortcut in $shortcuts; do
        shortcut_length=${#shortcut:t}
        if [[ $shortcut_length -gt $max_shortcut_length ]]; then
            max_shortcut_length=$shortcut_length
        fi
    done

    if [[ $max_shortcut_length -eq 0 ]]; then
        _jumps_no_shortcuts && return 1;
    fi

    max_shortcut_length=$(($max_shortcut_length + 18)) # adding spaces for color codes

    local delimiter="${FX[none]}-->"

    for shortcut in $shortcuts; do
        shortcut_basename="${FX[none]}${FG[14]}${shortcut:t}"
        shortcut_link="${FX[none]}${FG[242]}$(readlink $shortcut)${FX[none]}"
        echo "$(printf "  %-${max_shortcut_length}s %s  %s\n" $shortcut_basename $delimiter $shortcut_link)"
    done
}

_jump-list() {
    if [[ -d $JUMPS_PATH ]]; then
        reply=($(\ls $JUMPS_PATH))
    else
        reply=()
    fi
}
compctl -K _jump-list jump
compctl -K _jump-list jump-del
