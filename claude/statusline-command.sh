#!/bin/bash

# =============================================================================
# Color Palette - ANSI 256 escape sequences
# =============================================================================
C_RESET='\033[0m'

# Primary (bright)
C_SAGE='\033[38;5;71m'           # muted sage green - git branch, clean status
C_GOLD='\033[38;5;179m'          # muted gold - time, unmerged, ahead/behind
C_CORAL='\033[38;5;167m'         # muted coral-red - dirty status, deleted files

# Teal variants
C_TEAL_SOFT='\033[38;5;73m'      # soft teal - path
C_TEAL_MID='\033[38;5;109m'      # mid teal - modified files, stashed

# Dim variants
C_SAGE_DIM='\033[38;5;65m'       # dim sage - threshold (safe zone)
C_GOLD_DIM='\033[38;5;136m'      # dim gold - threshold (caution zone)
C_CORAL_DIM='\033[38;5;131m'     # dim coral - threshold (danger zone)

# UI chrome
C_SEPARATOR='\033[38;5;237m'     # dark grey - separators
C_DUSTY_BLUE='\033[38;5;67m'     # dusty blue - model name
C_MUTED='\033[38;5;243m'         # muted grey - version, memory indicator
C_MUTED_BRIGHT='\033[38;5;250m' # bright grey - C/S/W prefixes

# Bold colors
C_BOLD_MAGENTA='\033[1;35m'      # git renamed
C_BOLD_WHITE='\033[1;37m'        # git untracked

# =============================================================================

# Read JSON input from stdin
input=$(cat)

# Extract version
cc_version=$(echo "$input" | jq -r '.version // empty')

# Extract model: first letter, version, context size -> O:4.6/1M
model_letter=$(echo "$input" | jq -r '.model.display_name' | sed 's/^\(.\).*/\1/')
model_ver=$(echo "$input" | jq -r '.model.display_name' | sed -n 's/^[A-Za-z]* \([0-9.]*\).*/\1/p')
model_ctx=$(echo "$input" | jq -r '.model.display_name' | sed -n 's/.*(\([0-9]*[KMG]\) context).*/\1/p')

# Context remaining percentage
context_info=""
usage=$(echo "$input" | jq '.context_window.current_usage')
size=$(echo "$input" | jq '.context_window.context_window_size')

if [ "$usage" != "null" ]; then
    current=$(echo "$usage" | jq '.input_tokens + .output_tokens + .cache_creation_input_tokens + .cache_read_input_tokens')
    ctx_remaining=$((100 - current * 100 / size))
    if [ "$ctx_remaining" -ge 40 ]; then
        ctx_color=$C_SAGE
    elif [ "$ctx_remaining" -ge 20 ]; then
        ctx_color=$C_GOLD
    else
        ctx_color=$C_CORAL
    fi
    context_info="${C_MUTED_BRIGHT}C${C_RESET}${C_SEPARATOR}:${C_RESET}${ctx_color}${ctx_remaining}%${C_RESET}"
else
    context_info="${C_MUTED_BRIGHT}C${C_RESET}${C_SEPARATOR}:${C_RESET}${C_SAGE}100%${C_RESET}"
fi

# Rate limit usage from Anthropic OAuth API (cached)
usage_cache="/tmp/claude-usage-cache.json"
cache_ttl=600
now=$(date +%s)

# Background refresh if cache is stale or missing
cache_mtime=$(stat -f "%m" "$usage_cache" 2>/dev/null || echo 0)
if [ $((now - cache_mtime)) -gt $cache_ttl ]; then
    (
        token=$(security find-generic-password -s "Claude Code-credentials" -a "$(whoami)" -w 2>/dev/null | jq -r '.claudeAiOauth.accessToken')
        [ -z "$token" ] || [ "$token" = "null" ] && exit 1
        tmp="${usage_cache}.tmp.$$"
        http_code=$(curl -s --max-time 3 "https://api.anthropic.com/api/oauth/usage" \
            -H "Authorization: Bearer $token" \
            -H "anthropic-beta: oauth-2025-04-20" \
            -H "Accept: application/json" \
            -o "$tmp" -w "%{http_code}")
        [ "$http_code" = "200" ] && mv "$tmp" "$usage_cache" || rm -f "$tmp"
    ) &>/dev/null &
    disown 2>/dev/null
fi

# Format a single rate limit window
# Args: $1=utilization $2=resets_at_epoch $3=window_seconds $4=label
format_rate_window() {
    local util="$1" reset_at="$2" window_dur="$3" label="$4"
    local remaining_s elapsed_pct ratio_x100 pct_color remaining_pct

    remaining_s=$((reset_at - now))
    [ "$remaining_s" -lt 0 ] && remaining_s=0

    remaining_pct=$((100 - ${util%.*}))
    [ "$remaining_pct" -lt 0 ] && remaining_pct=0

    # Burn rate ratio: utilization / elapsed_pct (x100 for integer math)
    elapsed_pct=$(( (window_dur - remaining_s) * 100 / window_dur ))
    [ "$elapsed_pct" -lt 10 ] && elapsed_pct=10
    ratio_x100=$(( ${util%.*} * 100 / elapsed_pct ))

    # Threshold: remaining % with perfectly even usage
    local threshold_pct=$((100 - elapsed_pct))

    if [ "$ratio_x100" -lt 100 ]; then
        pct_color=$C_SAGE
        threshold_color=$C_SAGE_DIM
    elif [ "$ratio_x100" -lt 150 ]; then
        pct_color=$C_GOLD
        threshold_color=$C_GOLD_DIM
    else
        pct_color=$C_CORAL
        threshold_color=$C_CORAL_DIM
    fi

    printf "%b" "${C_MUTED_BRIGHT}${label}${C_RESET}${C_SEPARATOR}:${C_RESET}${pct_color}${remaining_pct}%${C_RESET}${C_SEPARATOR}/${C_RESET}${threshold_color}${threshold_pct}%${C_RESET}"
}

# Parse cached data and build rate display
rate_display=""
if [ -f "$usage_cache" ]; then
    read -r util5 reset5 util7 reset7 <<< $(jq -r '[
        .five_hour.utilization // empty,
        (.five_hour.resets_at // empty | .[0:19] + "Z" | fromdateiso8601),
        .seven_day.utilization // empty,
        (.seven_day.resets_at // empty | .[0:19] + "Z" | fromdateiso8601)
    ] | @tsv' "$usage_cache" 2>/dev/null)

    if [ -n "$util5" ] && [ -n "$reset5" ]; then
        five_h=$(format_rate_window "$util5" "$reset5" 18000 "S")
        seven_d=""
        if [ -n "$util7" ] && [ -n "$reset7" ]; then
            seven_d=" $(format_rate_window "$util7" "$reset7" 604800 "W")"
        fi
        rate_display="${five_h}${seven_d}"
    fi
fi
[ -z "$rate_display" ] && rate_display="${C_GOLD_DIM}?${C_RESET}"

# Get current directory and apply zsh-style shortening
raw_cwd=$(echo "$input" | jq -r '.workspace.current_dir')
# Replace home directory with ~
cwd="${raw_cwd/#$HOME/~}"

# Shorten directory path: ~/Projects/My/something -> ~/P/M/something
shorten_path() {
    local path="$1"
    local prefix=""
    local rest=""

    # Check if path starts with ~/
    if [[ "$path" == "~/"* ]]; then
        prefix="~"
        rest="${path:2}"  # Remove "~/"
    elif [[ "$path" == "~" ]]; then
        echo "~"
        return
    elif [[ "$path" == /* ]]; then
        prefix=""
        rest="${path:1}"  # Remove leading /
    else
        echo "$path"
        return
    fi

    # Split by / into array
    IFS='/' read -ra parts <<< "$rest"

    # If only one part, no shortening needed
    if [ ${#parts[@]} -le 1 ]; then
        echo "$path"
        return
    fi

    # Build shortened path
    local result="$prefix"
    local last_idx=$((${#parts[@]} - 1))
    for i in "${!parts[@]}"; do
        if [ $i -eq $last_idx ]; then
            # Keep last part full
            result="${result}/${parts[$i]}"
        else
            # Shorten to first letter (2 chars for dot-prefixed dirs)
            if [[ "${parts[$i]}" == .* ]]; then
                result="${result}/${parts[$i]:0:2}"
            else
                result="${result}/${parts[$i]:0:1}"
            fi
        fi
    done
    echo "$result"
}

short_path=$(shorten_path "$cwd")

# Get git information if in a git repository
git_info=""
workspace_dir=$(echo "$input" | jq -r '.workspace.project_dir')
if [ -d "$workspace_dir/.git" ] || git -C "$workspace_dir" rev-parse --git-dir > /dev/null 2>&1; then
    # Detect worktree and resolve correct git working directory
    git_work_dir="$workspace_dir"
    worktree_info=""
    git_dir=$(git -C "$raw_cwd" --no-optional-locks rev-parse --git-dir 2>/dev/null)
    if [[ "$git_dir" == *"/worktrees/"* ]]; then
        worktree_info=" ${C_TEAL_MID}⎇${C_RESET} "
        git_work_dir="$raw_cwd"
    fi

    # Get branch name (muted sage green)
    branch=$(git -C "$git_work_dir" --no-optional-locks branch --show-current 2>/dev/null)

    if [ -n "$branch" ]; then
        git_status=" ${C_SAGE}${branch}${C_RESET}"

        # Check if repo is clean or dirty
        if ! git -C "$git_work_dir" --no-optional-locks diff --quiet 2>/dev/null || \
           ! git -C "$git_work_dir" --no-optional-locks diff --cached --quiet 2>/dev/null || \
           [ -n "$(git -C "$git_work_dir" --no-optional-locks ls-files --others --exclude-standard 2>/dev/null)" ]; then
            git_status="${git_status} ${C_CORAL}✗${C_RESET}"
        else
            git_status="${git_status} ${C_SAGE}✓${C_RESET}"
        fi

        # Get detailed status indicators
        indicators=""

        # Added files (staged new files)
        added=$(git -C "$git_work_dir" --no-optional-locks diff --cached --numstat 2>/dev/null | grep -c "^0.*0" || true)
        if [ "$added" -gt 0 ]; then
            indicators="${indicators} ${C_SAGE}✚${C_RESET}"
        fi

        # Deleted files
        deleted=$(git -C "$git_work_dir" --no-optional-locks diff --name-status 2>/dev/null | grep -c "^D" || true)
        deleted_cached=$(git -C "$git_work_dir" --no-optional-locks diff --cached --name-status 2>/dev/null | grep -c "^D" || true)
        if [ "$((deleted + deleted_cached))" -gt 0 ]; then
            indicators="${indicators} ${C_CORAL}✖${C_RESET}"
        fi

        # Modified files
        modified=$(git -C "$git_work_dir" --no-optional-locks diff --name-only 2>/dev/null | wc -l | tr -d ' ')
        if [ "$modified" -gt 0 ]; then
            indicators="${indicators} ${C_TEAL_MID}✱${C_RESET}"
        fi

        # Renamed files
        renamed=$(git -C "$git_work_dir" --no-optional-locks diff --cached --name-status 2>/dev/null | grep -c "^R" || true)
        if [ "$renamed" -gt 0 ]; then
            indicators="${indicators} ${C_BOLD_MAGENTA}➜${C_RESET}"
        fi

        # Untracked files
        untracked=$(git -C "$git_work_dir" --no-optional-locks ls-files --others --exclude-standard 2>/dev/null | wc -l | tr -d ' ')
        if [ "$untracked" -gt 0 ]; then
            indicators="${indicators} ${C_BOLD_WHITE}◼${C_RESET}"
        fi

        # Stashed changes
        stashed=$(git -C "$git_work_dir" --no-optional-locks stash list 2>/dev/null | wc -l | tr -d ' ')
        if [ "$stashed" -gt 0 ]; then
            indicators="${indicators} ${C_TEAL_MID}✭${C_RESET}"
        fi

        # Unmerged files
        unmerged=$(git -C "$git_work_dir" --no-optional-locks diff --name-only --diff-filter=U 2>/dev/null | wc -l | tr -d ' ')
        if [ "$unmerged" -gt 0 ]; then
            indicators="${indicators} ${C_GOLD}═${C_RESET}"
        fi

        # Ahead/behind
        upstream=$(git -C "$git_work_dir" --no-optional-locks rev-parse --abbrev-ref @{upstream} 2>/dev/null)
        if [ -n "$upstream" ]; then
            ahead=$(git -C "$git_work_dir" --no-optional-locks rev-list --count @{upstream}..HEAD 2>/dev/null || echo "0")
            behind=$(git -C "$git_work_dir" --no-optional-locks rev-list --count HEAD..@{upstream} 2>/dev/null || echo "0")

            if [ "$ahead" -gt 0 ]; then
                indicators="${indicators} ${C_GOLD}⬆${C_RESET}"
            fi
            if [ "$behind" -gt 0 ]; then
                indicators="${indicators} ${C_GOLD}⬇${C_RESET}"
            fi
        fi

        git_info="${worktree_info}${git_status}${indicators}"
    fi
fi

# Get current time in 24h format
current_time=$(date '+%H:%M')

# Memory indicator - show 󰈙 if CLAUDE.md exists in workspace
memory_indicator=""
if [ -f "$workspace_dir/CLAUDE.md" ]; then
    memory_indicator=" ${C_MUTED}󰈙${C_RESET}"
fi

# Build status line
model_display="${C_DUSTY_BLUE}${model_letter}${C_RESET}${C_SEPARATOR}:${C_RESET}${C_DUSTY_BLUE}${model_ver}${C_RESET}${C_SEPARATOR}/${C_RESET}${C_DUSTY_BLUE}${model_ctx}${C_RESET}"
output="${C_GOLD}${current_time}${C_RESET} ${C_SEPARATOR}•${C_RESET} ${C_MUTED}${cc_version}${C_RESET} ${C_SEPARATOR}•${C_RESET} ${model_display}${memory_indicator} ${C_SEPARATOR}•${C_RESET} ${context_info} ${C_SEPARATOR}•${C_RESET} ${rate_display} ${C_SEPARATOR}•${C_RESET} ${C_TEAL_SOFT}${short_path}${C_RESET}${git_info}"

# Print the status line
printf "%b" "$output"
