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

source "$HOME/.dotfiles/zsh/shorten_path.sh"

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

now=$(date +%s)

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

# Parse rate limits from input JSON
rate_display=""
read -r util5 reset5 util7 reset7 <<< $(echo "$input" | jq -r '[
    .rate_limits.five_hour.used_percentage // empty,
    .rate_limits.five_hour.resets_at // empty,
    .rate_limits.seven_day.used_percentage // empty,
    .rate_limits.seven_day.resets_at // empty
] | @tsv' 2>/dev/null)

if [ -n "$util5" ] && [ -n "$reset5" ]; then
    five_h=$(format_rate_window "$util5" "$reset5" 18000 "S")
    seven_d=""
    if [ -n "$util7" ] && [ -n "$reset7" ]; then
        seven_d=" $(format_rate_window "$util7" "$reset7" 604800 "W")"
    fi
    rate_display="${five_h}${seven_d}"
fi
[ -z "$rate_display" ] && rate_display="${C_GOLD_DIM}?${C_RESET}"

# Get current directory and apply zsh-style shortening
raw_cwd=$(echo "$input" | jq -r '.workspace.current_dir')
# Replace home directory with ~
cwd="${raw_cwd/#$HOME/~}"

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

# Caveman mode indicator - shown when ~/.claude/.caveman-active flag exists
caveman_info=""
caveman_flag="$HOME/.claude/.caveman-active"
if [ -f "$caveman_flag" ]; then
    cvm_mode=$(cat "$caveman_flag" 2>/dev/null)
    [ -z "$cvm_mode" ] && cvm_mode="full"
    cvm_letter=$(printf '%s' "${cvm_mode:0:1}" | tr '[:lower:]' '[:upper:]')
    caveman_info=" ${C_SEPARATOR}•${C_RESET} ${C_MUTED_BRIGHT}CVM${C_RESET}${C_SEPARATOR}:${C_RESET}${C_GOLD}${cvm_letter}${C_RESET}"
fi

# Build status line
model_display="${C_DUSTY_BLUE}${model_letter}${C_RESET}${C_SEPARATOR}:${C_RESET}${C_DUSTY_BLUE}${model_ver}${C_RESET}${C_SEPARATOR}/${C_RESET}${C_DUSTY_BLUE}${model_ctx}${C_RESET}"
output="${C_GOLD}${current_time}${C_RESET} ${C_SEPARATOR}•${C_RESET} ${C_MUTED}${cc_version}${C_RESET} ${C_SEPARATOR}•${C_RESET} ${model_display}${memory_indicator}${caveman_info} ${C_SEPARATOR}•${C_RESET} ${context_info} ${C_SEPARATOR}•${C_RESET} ${rate_display} ${C_SEPARATOR}•${C_RESET} ${C_TEAL_SOFT}${short_path}${C_RESET}${git_info}"

# Print the status line
printf "%b" "$output"
