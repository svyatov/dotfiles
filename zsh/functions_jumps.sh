export JUMPS_PATH=$HOME/.jump_shortcuts

alias j='nocorrect jump'
alias ja='nocorrect jump-add'
alias jd='nocorrect jump-del'
alias jl='jump-list'

_jumps_usage_help() {
    echo "You can use following commands:"
    echo " j [shortcut] - jump to shortcutted directory"
    echo "ja [shortcut] - add shortcut for current directory"
    echo "jd [shortcut] - delete shortcut"
    echo "jl            - list all available jump shortcuts"
}

_jumps_no_such_shortcut() {
    print -P -- "${FX[reset]}${FG[196]}No such jump shortcut: ${FX[reset]}${FG[009]}${1}"
}

_jumps_no_shortcuts() {
    print -P -- "${FX[reset]}${FG[196]}There are no shortcuts, yet. You should add some first!${FX[reset]}"
}

jump() {
    if [[ -z $1 ]]; then _jumps_usage_help; return 1; fi
    if [[ -L $JUMPS_PATH/$1 ]]; then
        clear
        cd -P $JUMPS_PATH/$1 2> /dev/null && ls -lhAG
    else
        _jumps_no_such_shortcut $1
    fi
}

jump-add() {
    if [[ -z $1 ]]; then _jumps_usage_help; return 1; fi
    if [[ ! -d $JUMPS_PATH ]]; then
        mkdir -p $JUMPS_PATH;
    fi
    if [[ -L $JUMPS_PATH/$1 ]]; then
        local jump_destination=$(readlink $JUMPS_PATH/$1)
        print -P -- "${FX[reset]}${FG[196]}Shortcut \"${FX[reset]}${FG[009]}${1}${FX[reset]}${FG[196]}\" already exists and points to: ${FX[reset]}${FG[009]}${jump_destination}${FX[reset]}"
    else
        ln -s "$(pwd)" $JUMPS_PATH/$1 && \
            print -P -- "${FX[reset]}${FG[076]}Shortcut \"${FX[reset]}${FG[014]}${1}${FX[reset]}${FG[076]}\" pointing to ${FX[reset]}${FG[014]}$(pwd)${FX[reset]}${FG[076]} successfully added${FX[reset]}"
    fi
}

jump-del() {
    if [[ -z $1 ]]; then _jumps_usage_help; return 1; fi
    if [[ -L $JUMPS_PATH/$1 ]]; then
        rm $JUMPS_PATH/$1 && \
            print -P -- "${FX[reset]}${FG[076]}Shortcut \"${FX[reset]}${FG[014]}${1}${FX[reset]}${FG[076]}\" successfully deleted"
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

    max_shortcut_length=$(($max_shortcut_length + 16)) # adding 16 for color codes

    local delimiter="${FX[reset]}-->"

    for shortcut in $shortcuts; do
        shortcut_basename="${FX[reset]}${FG[014]}${shortcut:t}"
        shortcut_link="${FX[reset]}${FG[242]}$(readlink $shortcut)"
        print -P -f "  %-${max_shortcut_length}s %s %s\n" $shortcut_basename $delimiter $shortcut_link
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
