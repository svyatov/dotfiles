#!/bin/bash

# =============================================================================
# Color Palette - ANSI 256 escape sequences
# =============================================================================
C_RESET='\033[0m'

# Primary (bright)
C_SAGE='\033[38;5;71m'           # muted sage green - git branch, clean status, added files
C_GOLD='\033[38;5;179m'          # muted gold - time, unmerged, ahead/behind
C_CORAL='\033[38;5;167m'         # muted coral-red - dirty status, deleted files

# Teal variants
C_TEAL='\033[38;5;66m'           # muted teal - model name
C_TEAL_SOFT='\033[38;5;73m'      # soft teal - path
C_TEAL_MID='\033[38;5;109m'      # mid teal - modified files, stashed

# Dim variants
C_SAGE_DIM='\033[38;5;65m'       # dim sage - token count (safe zone)
C_GOLD_DIM='\033[38;5;136m'      # dim gold - token count (caution zone)
C_CORAL_DIM='\033[38;5;131m'     # dim coral - token count (danger zone)

# Olive tones
C_OLIVE='\033[38;5;101m'         # dim olive/khaki - version (up-to-date)
C_OLIVE_DIM='\033[38;5;59m'      # dim olive-grey - context size
C_TAN='\033[38;5;180m'           # tan/gold - version (outdated)

# Progress bar empty states
C_GREEN_EMPTY='\033[38;5;22m'    # dim green
C_YELLOW_EMPTY='\033[38;5;94m'   # dim yellow/brown
C_RED_EMPTY='\033[38;5;52m'      # dim red

# UI chrome
C_SEPARATOR='\033[38;5;237m'     # dark grey - separators
C_MUTED='\033[38;5;243m'         # muted grey - memory indicator

# Bold colors
C_BOLD_MAGENTA='\033[1;35m'      # git renamed
C_BOLD_WHITE='\033[1;37m'        # git untracked

# =============================================================================

# Read JSON input from stdin
input=$(cat)

# Extract model display name
model_name=$(echo "$input" | jq -r '.model.display_name')

# Get Claude Code version display with update check
get_version_display() {
    local cache_file="$HOME/.claude/cache/version-check.json"
    local checker_script="$HOME/.dotfiles/claude/claude-version-check.sh"
    local stale_threshold=10800  # 3 hours in seconds

    # If no cache exists, spawn background check and return empty
    if [ ! -f "$cache_file" ]; then
        if [ -x "$checker_script" ]; then
            nohup "$checker_script" > /dev/null 2>&1 &
        fi
        return
    fi

    # Read cache
    local current_version latest_version checked_at
    current_version=$(jq -r '.current_version // empty' "$cache_file" 2>/dev/null)
    latest_version=$(jq -r '.latest_version // empty' "$cache_file" 2>/dev/null)
    checked_at=$(jq -r '.checked_at // 0' "$cache_file" 2>/dev/null)

    # If cache is corrupt or empty, spawn background check and return empty
    if [ -z "$current_version" ] || [ -z "$latest_version" ]; then
        if [ -x "$checker_script" ]; then
            nohup "$checker_script" > /dev/null 2>&1 &
        fi
        return
    fi

    # Check if cache is stale
    local now=$(date +%s)
    local age=$((now - checked_at))
    if [ "$age" -gt "$stale_threshold" ]; then
        # Spawn background update (non-blocking)
        if [ -x "$checker_script" ]; then
            nohup "$checker_script" > /dev/null 2>&1 &
        fi
    fi

    # Compare versions and output with appropriate color (no "v" prefix)
    if [ "$current_version" = "$latest_version" ]; then
        printf "${C_OLIVE}%s${C_RESET}" "$current_version"
    else
        printf "${C_TAN}%s${C_RESET}" "$current_version"
    fi
}

version_display=$(get_version_display)

# Calculate context usage percentage and tokens
context_info=""
usage=$(echo "$input" | jq '.context_window.current_usage')
size=$(echo "$input" | jq '.context_window.context_window_size')

# Format size (e.g., 200000 -> 200k)
if [ "$size" -ge 1000 ]; then
    size_display="$((size / 1000))k"
else
    size_display="${size}"
fi

if [ "$usage" != "null" ]; then
    current=$(echo "$usage" | jq '.input_tokens + .output_tokens + .cache_creation_input_tokens + .cache_read_input_tokens')
    pct=$((current * 100 / size))

# Format current token count (e.g., 50000 -> 50k)
    # Right-align to 4 characters to prevent jumping (max 999k)
    # Always show 'k' suffix for consistency (0k, 1k, 50k, etc.)
    tokens_num=$((current / 1000))
    current_display=$(printf "%3sk" "$tokens_num")

# Braille Density progress bar with 7-level smooth gradient (8 cells)
    # Gradient: ⣀ → ⣄ → ⣤ → ⣦ → ⣶ → ⣷ → ⣿ (0-6 dots, empty shows ⣀)
    # Zone-based coloring:
    #   - Green zone: cells 0-3 (0-50%) - safe
    #   - Yellow zone: cells 4-5 (50-75%) - caution
    #   - Red zone: cells 6-7 (75-100%) - danger, compaction at ~82.5%
    braille_gradient=("⣀" "⣄" "⣤" "⣦" "⣶" "⣷" "⣿")
    bar_width=8
    levels_per_cell=7
    total_steps=$((bar_width * levels_per_cell))

    # Calculate current step based on percentage (0 to total_steps)
    current_step=$((pct * total_steps / 100))

    # Zone colors - use palette variables
    green_filled=$C_SAGE
    yellow_filled=$C_GOLD
    red_filled=$C_CORAL
    green_empty=$C_GREEN_EMPTY
    yellow_empty=$C_YELLOW_EMPTY
    red_empty=$C_RED_EMPTY

    # Build braille progress bar with zone-based coloring
    bar=""
    for ((i=0; i<bar_width; i++)); do
        # Determine zone colors based on cell position
        if [ "$i" -lt 4 ]; then
            # Green zone (cells 0-3, 0-50%)
            filled_color=$green_filled
            empty_color=$green_empty
        elif [ "$i" -lt 6 ]; then
            # Yellow zone (cells 4-5, 50-75%)
            filled_color=$yellow_filled
            empty_color=$yellow_empty
        else
            # Red zone (cells 6-7, 75-100%)
            filled_color=$red_filled
            empty_color=$red_empty
        fi

        # Calculate the step range for this cell
        cell_start=$((i * levels_per_cell))
        cell_end=$(((i + 1) * levels_per_cell))

        if [ "$current_step" -ge "$cell_end" ]; then
            # Cell is fully filled
            bar="${bar}${filled_color}${braille_gradient[6]}${C_RESET}"
        elif [ "$current_step" -le "$cell_start" ]; then
            # Cell is empty - use dimmed zone color (heat map visible)
            bar="${bar}${empty_color}${braille_gradient[0]}${C_RESET}"
        else
            # Cell is partially filled - calculate gradient level (0-6)
            steps_into_cell=$((current_step - cell_start))
            bar="${bar}${filled_color}${braille_gradient[$steps_into_cell]}${C_RESET}"
        fi
    done

    # Token count color based on percentage zone
    if [ "$pct" -lt 50 ]; then
        token_color=$C_SAGE_DIM
    elif [ "$pct" -lt 75 ]; then
        token_color=$C_GOLD_DIM
    else
        token_color=$C_CORAL_DIM
    fi
    context_info="${bar} ${token_color}${current_display}${C_RESET}${C_OLIVE_DIM}/${size_display}${C_RESET}"
else
    # No usage data yet - show empty braille bar (8 cells) with zone colors
    bar="${C_GREEN_EMPTY}⣀⣀⣀⣀${C_RESET}${C_YELLOW_EMPTY}⣀⣀${C_RESET}${C_RED_EMPTY}⣀⣀${C_RESET}"
    context_info="${bar} ${C_SAGE_DIM}  0k${C_RESET}${C_OLIVE_DIM}/${size_display}${C_RESET}"
fi

# Get current directory and apply zsh-style shortening
cwd=$(echo "$input" | jq -r '.workspace.current_dir')
# Replace home directory with ~
cwd="${cwd/#$HOME/~}"

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
            # Shorten to first letter
            result="${result}/${parts[$i]:0:1}"
        fi
    done
    echo "$result"
}

short_path=$(shorten_path "$cwd")

# Get git information if in a git repository
git_info=""
workspace_dir=$(echo "$input" | jq -r '.workspace.project_dir')
if [ -d "$workspace_dir/.git" ] || git -C "$workspace_dir" rev-parse --git-dir > /dev/null 2>&1; then
    # Get branch name (muted sage green)
    branch=$(git -C "$workspace_dir" --no-optional-locks branch --show-current 2>/dev/null)

    if [ -n "$branch" ]; then
        git_status=" ${C_SAGE}${branch}${C_RESET}"

        # Check if repo is clean or dirty
        if ! git -C "$workspace_dir" --no-optional-locks diff --quiet 2>/dev/null || \
           ! git -C "$workspace_dir" --no-optional-locks diff --cached --quiet 2>/dev/null || \
           [ -n "$(git -C "$workspace_dir" --no-optional-locks ls-files --others --exclude-standard 2>/dev/null)" ]; then
            git_status="${git_status} ${C_CORAL}✗${C_RESET}"
        else
            git_status="${git_status} ${C_SAGE}✓${C_RESET}"
        fi

        # Get detailed status indicators
        indicators=""

        # Added files (staged new files)
        added=$(git -C "$workspace_dir" --no-optional-locks diff --cached --numstat 2>/dev/null | grep -c "^0.*0" || true)
        if [ "$added" -gt 0 ]; then
            indicators="${indicators} ${C_SAGE}✚${C_RESET}"
        fi

        # Deleted files
        deleted=$(git -C "$workspace_dir" --no-optional-locks diff --name-status 2>/dev/null | grep -c "^D" || true)
        deleted_cached=$(git -C "$workspace_dir" --no-optional-locks diff --cached --name-status 2>/dev/null | grep -c "^D" || true)
        if [ "$((deleted + deleted_cached))" -gt 0 ]; then
            indicators="${indicators} ${C_CORAL}✖${C_RESET}"
        fi

        # Modified files
        modified=$(git -C "$workspace_dir" --no-optional-locks diff --name-only 2>/dev/null | wc -l | tr -d ' ')
        if [ "$modified" -gt 0 ]; then
            indicators="${indicators} ${C_TEAL_MID}✱${C_RESET}"
        fi

        # Renamed files
        renamed=$(git -C "$workspace_dir" --no-optional-locks diff --cached --name-status 2>/dev/null | grep -c "^R" || true)
        if [ "$renamed" -gt 0 ]; then
            indicators="${indicators} ${C_BOLD_MAGENTA}➜${C_RESET}"
        fi

        # Untracked files
        untracked=$(git -C "$workspace_dir" --no-optional-locks ls-files --others --exclude-standard 2>/dev/null | wc -l | tr -d ' ')
        if [ "$untracked" -gt 0 ]; then
            indicators="${indicators} ${C_BOLD_WHITE}◼${C_RESET}"
        fi

        # Stashed changes
        stashed=$(git -C "$workspace_dir" --no-optional-locks stash list 2>/dev/null | wc -l | tr -d ' ')
        if [ "$stashed" -gt 0 ]; then
            indicators="${indicators} ${C_TEAL_MID}✭${C_RESET}"
        fi

        # Unmerged files
        unmerged=$(git -C "$workspace_dir" --no-optional-locks diff --name-only --diff-filter=U 2>/dev/null | wc -l | tr -d ' ')
        if [ "$unmerged" -gt 0 ]; then
            indicators="${indicators} ${C_GOLD}═${C_RESET}"
        fi

        # Ahead/behind
        upstream=$(git -C "$workspace_dir" --no-optional-locks rev-parse --abbrev-ref @{upstream} 2>/dev/null)
        if [ -n "$upstream" ]; then
            ahead=$(git -C "$workspace_dir" --no-optional-locks rev-list --count @{upstream}..HEAD 2>/dev/null || echo "0")
            behind=$(git -C "$workspace_dir" --no-optional-locks rev-list --count HEAD..@{upstream} 2>/dev/null || echo "0")

            if [ "$ahead" -gt 0 ]; then
                indicators="${indicators} ${C_GOLD}⬆${C_RESET}"
            fi
            if [ "$behind" -gt 0 ]; then
                indicators="${indicators} ${C_GOLD}⬇${C_RESET}"
            fi
        fi

        git_info="${git_status}${indicators}"
    fi
fi

# Get current time in 24h format
current_time=$(date '+%H:%M')

# Memory indicator - show 󰈙 if CLAUDE.md exists in workspace
memory_indicator=""
if [ -f "$workspace_dir/CLAUDE.md" ]; then
    memory_indicator=" ${C_MUTED}󰈙${C_RESET}"
fi

# Build version segment (only if version is available)
version_segment=""
if [ -n "$version_display" ]; then
    version_segment=" ${C_SEPARATOR}│${C_RESET} ${version_display}"
fi

# Build status line
output="${C_GOLD}${current_time}${C_RESET} ${C_SEPARATOR}│${C_RESET} ${C_TEAL}${model_name}${C_RESET}${memory_indicator} ${C_SEPARATOR}│${C_RESET} ${context_info}${version_segment} ${C_SEPARATOR}│${C_RESET} ${C_TEAL_SOFT}${short_path}${C_RESET}${git_info}"

# Print the status line
printf "%b" "$output"
