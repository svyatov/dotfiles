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


# Graphite (https://app.graphite.dev)
safe_alias gtc 'gt create'
safe_alias gts 'gt submit'
safe_alias gtss 'gt submit --stack'
safe_alias gtm 'gt modify'
safe_alias gtre 'gt restack'
safe_alias gtl 'gt log'
safe_alias gtu 'gt up'
safe_alias gtd 'gt down'
safe_alias gtco 'gt checkout'


# Helpers
gtcn() {
  if [ -z "$1" ]; then
    echo "Usage: gtcn <notion_id>"
    return 1
  fi
  if ! gt create -m "$(bin/notion_commit $1 -g)"; then
    gt create -m "$(bin/notion_commit $1 -g)-$(date +"%Y-%m-%d-%H:%M:%S")"
  fi
}

gtt() {
  # Get current git branch name
  local branch=$(git rev-parse --abbrev-ref HEAD)

  # Extract ticket ID from branch name
  if [[ ${branch:l} =~ halo-([0-9]{4,}) ]]; then # `:l` to lowercase branch name
    local ticket_id=${match[1]}

    # Run bin/notion_commit and copy to clipboard
    local commit_message=$(bin/notion_commit "$ticket_id")

    if [ -n "$commit_message" ]; then
      echo -n "$commit_message" | pbcopy
      echo "Copied to clipboard: $commit_message"
    else
      echo "Failed to generate commit message."
      return 1
    fi
  else
    echo "No matching ticket ID found in branch name."
    return 1
  fi
}

gtb() {
  if [ -z "$1" ]; then
    echo "Usage: gtb <branch_name>"
    return 1
  fi

  # Get current git branch name
  local branch=$(git rev-parse --abbrev-ref HEAD)

  # Extract full ticket ID from branch name
  if [[ ${branch:l} =~ (halo-[0-9]{4,}) ]]; then # `:l` to lowercase
    local ticket_id=${match[1]}

    # Convert input string to a valid branch name
    local sanitized_name=$(echo "$1" | tr -d '[:cntrl:]' | tr -s '[:space:]' '-' | tr -cd '[:alnum:]-' | tr '[:upper:]' '[:lower:]')

    # Construct new branch name
    local new_branch="${ticket_id}-${sanitized_name}"

    # Create new branch using gt
    gt create -m "$new_branch"
  else
    echo "No matching ticket ID found in branch name."
    return 1
  fi
}
