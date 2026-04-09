# Git typos
safe_alias gps 'g ps'
safe_alias gpl 'g pl'
safe_alias gg 'g g'


# Git extras (https://github.com/tj/git-extras)
safe_alias ginf 'git info'        # Show information about the repo
# safe_alias gsum 'git summary'     # Outputs a repo summary
safe_alias gch 'git changelog'    # Populate a file whose name matches change|history -i_ with commits since the previous tag
safe_alias gc 'git count'         # Output commit count
safe_alias gu 'git undo'          # Remove the latest commit
safe_alias gset 'git setup'       # Set up a git repository (if one doesn't exist), add all files, and make an initial commit
safe_alias gobl 'git obliterate'  # Completely remove a file from the repository, including past commits and tags


# Graphite (https://graphite.com)
safe_alias gtc 'gt create'
safe_alias gts 'gt submit'
safe_alias gtss 'gt submit --stack'
safe_alias gtm 'gt modify'
safe_alias gtre 'gt restack'
safe_alias gtl 'gt log'
safe_alias gtu 'gt up'
safe_alias gtd 'gt down'
safe_alias gtco 'gt checkout'
safe_alias gtdl 'gt delete'
safe_alias gty 'gt sync'


# Code archaeology (https://piechowski.io/post/git-commands-before-reading-code/)
safe_alias gchurn 'git log --format=format: --name-only --since="1 year ago" | sort | uniq -c | sort -nr | head -20'
safe_alias gcontrib 'git shortlog -sn --no-merges'
safe_alias gbugs 'git log -i -E --grep="fix|bug|broken" --name-only --format= | sort | uniq -c | sort -nr | head -20'
safe_alias gvel 'git log --format="%ad" --date=format:"%Y-%m" | sort | uniq -c'
safe_alias gfire 'git log --oneline --since="1 year ago" | grep -iE "revert|hotfix|emergency|rollback"'
safe_alias gfocus 'git log --format=format: --name-only --since="2 weeks ago" | sort | uniq -c | sort -nr | head -20'
safe_alias gdchurn 'git log --format=format: --name-only --since="1 year ago" | sed "s|/[^/]*$||" | sort | uniq -c | sort -nr | head -15'
safe_alias gstale 'git log --format=format: --name-only --diff-filter=AMRC | sort -u | while read f; do [ -f "$f" ] && echo "$(git log -1 --format="%ai" -- "$f" | cut -d" " -f1) $f"; done | sort | head -20'
