my-tmux-rails() {
    if [[ -z $1 ]]; then 
        echo 'You forget to specify session name!'
        return 1
    fi
    tmux new-session -A -s $1 \; \
         new-window -n 'vim' \; \
         send-keys 'v' 'C-m' \; \
         new-window -n 'tests' \; \
         new-window -n 'server' \; \
         select-window -t 2
}
