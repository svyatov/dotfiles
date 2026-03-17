# Shortens a directory path: ~/Projects/My/.hidden/something -> ~/P/M/.h/something
# Compatible with both bash and zsh. Used by aliases and statusline.
shorten_path() {
    local p="${1:-$PWD}"
    p="${p/#$HOME/~}"
    echo "$p" | awk -F/ '{
        for (i=1; i<NF; i++) {
            if ($i == "~") printf "~"
            else if ($i == "") printf ""
            else if (substr($i,1,1) == ".") printf "%s", substr($i,1,2)
            else printf "%s", substr($i,1,1)
            printf "/"
        }
        print $NF
    }'
}
