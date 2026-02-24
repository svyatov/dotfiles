_alias_stats_log=$HOME/.dotfiles/data/command_log

_alias_stats_preexec() {
    [[ $1 == [[:space:]]* ]] && return
    [[ -d ${_alias_stats_log:h} ]] || mkdir -p ${_alias_stats_log:h}
    print -r -- "$(date +%s) $1" >>| "$_alias_stats_log"
}
preexec_functions+=_alias_stats_preexec

alias_stats() {
    printf '%s\n' ${(k)aliases} | ruby ~/.dotfiles/bin/alias_stats "${1:-30}"
}
