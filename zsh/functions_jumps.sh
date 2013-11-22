export JUMPS_PATH=$HOME/.jump_shortcuts
_jumps_usage_help() {
    echo "You can use following commands:"
    echo "     jump [shortcut] - change directory to the specified shortcut"
    echo " jump-add [shortcut] - create a shortcut for the current directory"
    echo " jump-del [shortcut] - remove the specified shortcut"
    echo "jump-list            - list all available jump shortcuts"
}
jump() {
    if [[ -z $1 ]]; then _jumps_usage_help; return 1; fi
    cd -P $JUMPS_PATH/$1 2> /dev/null || echo "No such jump shortcut: $1"
}
jump-add() {
    if [[ -z $1 ]]; then _jumps_usage_help; return 1; fi
    if [[ ! -d $JUMPS_PATH ]]; then
        mkdir -p $JUMPS_PATH;
    fi
    if [[ -L $JUMPS_PATH/$1 ]]; then
        local jump_destination=$(readlink $JUMPS_PATH/$1)
        echo "Shortcut \"${1}\" already exists and points to: ${jump_destination}"
    else
        ln -s "$(pwd)" $JUMPS_PATH/$1
    fi
}
jump-del() {
    if [[ -z $1 ]]; then _jumps_usage_help; return 1; fi
    if [[ -L $JUMPS_PATH/$1 ]]; then
        rm $JUMPS_PATH/$1
    else
        echo "No such jump shortcut: $1"
    fi
}
jump-list() {
    \ls -l $JUMPS_PATH | tail -n +2 | sed 's/  / /g' | cut -d' ' -f9- | awk -F ' -> ' '{printf "%-10s -> %s\n", $1, $2}'
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
