# Shortens a directory path: ~/Projects/My/.hidden/something -> ~/P/M/.h/something
# Compatible with both bash and zsh. Used by aliases and statusline.
shorten_path() {
    local p="${1:-$PWD}"
    p="${p/#$HOME/~}"
    local result="" segment="" rest="$p"

    while [[ "$rest" == */* ]]; do
        segment="${rest%%/*}"
        rest="${rest#*/}"
        if [[ "$segment" == "~" ]]; then
            result+="~/"
        elif [[ -n "$segment" ]]; then
            if [[ "$segment" == .* ]]; then
                result+="${segment:0:2}/"
            else
                result+="${segment:0:1}/"
            fi
        else
            result+="/"
        fi
    done
    result+="$rest"
    echo "$result"
}
