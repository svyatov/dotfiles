safe_alias g 'noglob _g'
_g() {
    if [[ -n $1 ]]; then
        git $@
    else
        git sts
    fi
}
compdef _g=git
