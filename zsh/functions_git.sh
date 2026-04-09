safe_alias g 'noglob _g'
_g() {
    if [[ -n $1 ]]; then
        git $@
    else
        git sts
    fi
}
compdef _g=git

# Git repo reconnaissance (https://piechowski.io/post/git-commands-before-reading-code/)
gsilos() {
    git log --format='%aN' --name-only --since="1 year ago" \
        | awk '/^$/{next} /^[^ ]/{author=$0; next} {files[$0][author]++} END {for(f in files) if(length(files[f])==1) for(a in files[f]) print files[f][a], f, "("a")"}' \
        | sort -nr | head -20
}

grecon() {
    echo "=== Churn Hotspots (most-changed files, last year) ==="
    gchurn

    echo "\n=== Directory Churn (most-changed areas, last year) ==="
    gdchurn

    echo "\n=== Recent Focus (last 2 weeks) ==="
    gfocus

    echo "\n=== Contributors ==="
    gcontrib

    echo "\n=== Knowledge Silos (single-author files, last year) ==="
    gsilos

    echo "\n=== Bug Clusters (files tied to bug fixes) ==="
    gbugs

    echo "\n=== Commit Velocity (monthly) ==="
    gvel

    echo "\n=== Firefighting (emergencies, last year) ==="
    gfire || echo "  (none found)"

    echo "\n=== Stale Code (oldest untouched files) ==="
    gstale
}
