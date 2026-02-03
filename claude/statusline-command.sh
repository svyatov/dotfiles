#!/bin/bash

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

    # Compare versions and output with appropriate color
    if [ "$current_version" = "$latest_version" ]; then
        # Up-to-date: muted grey
        printf '\033[38;5;243mv%s\033[0m' "$current_version"
    else
        # Outdated: warmer shade (tan/gold)
        printf '\033[38;5;180mv%s\033[0m' "$current_version"
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
    if [ "$current" -ge 1000 ]; then
        tokens_num=$((current / 1000))
        current_display=$(printf "%3sk" "$tokens_num")
    else
        current_display=$(printf "%4s" "${current}")
    fi

    # Braille Density progress bar with 7-level smooth gradient (8 cells)
    # Gradient: ⣀ → ⣄ → ⣤ → ⣦ → ⣶ → ⣷ → ⣿ (0-6 dots, empty shows ⣀)
    braille_gradient=("⣀" "⣄" "⣤" "⣦" "⣶" "⣷" "⣿")
    bar_width=8
    levels_per_cell=7
    total_steps=$((bar_width * levels_per_cell))

    # Calculate current step based on percentage (0 to total_steps)
    current_step=$((pct * total_steps / 100))

    # Build braille progress bar with smooth gradient
    bar=""
    for ((i=0; i<bar_width; i++)); do
        # Calculate the step range for this cell
        cell_start=$((i * levels_per_cell))
        cell_end=$(((i + 1) * levels_per_cell))

        if [ "$current_step" -ge "$cell_end" ]; then
            # Cell is fully filled - use ⣿ (index 6) in soft grey
            bar="${bar}\033[38;5;245m${braille_gradient[6]}\033[0m"
        elif [ "$current_step" -le "$cell_start" ]; then
            # Cell is empty - use ⣀ (index 0) in dark grey (track visible)
            bar="${bar}\033[38;5;239m${braille_gradient[0]}\033[0m"
        else
            # Cell is partially filled - calculate gradient level (0-6)
            steps_into_cell=$((current_step - cell_start))
            # Use medium grey for partial/transition cells
            bar="${bar}\033[38;5;242m${braille_gradient[$steps_into_cell]}\033[0m"
        fi
    done

    # Token count - soft teal
    context_info="${bar} \033[38;5;109m${current_display}/${size_display}\033[0m"
else
    # No usage data yet - show empty braille bar (8 cells)
    # Right-align "0" to match token display width
    bar="\033[38;5;239m⣀⣀⣀⣀⣀⣀⣀⣀\033[0m"
    context_info="${bar} \033[38;5;109m$(printf "%4s" "0")/${size_display}\033[0m"
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
        git_status=" \033[38;5;71m${branch}\033[0m"

        # Check if repo is clean or dirty
        if ! git -C "$workspace_dir" --no-optional-locks diff --quiet 2>/dev/null || \
           ! git -C "$workspace_dir" --no-optional-locks diff --cached --quiet 2>/dev/null || \
           [ -n "$(git -C "$workspace_dir" --no-optional-locks ls-files --others --exclude-standard 2>/dev/null)" ]; then
            # Dirty - muted coral-red ✗
            git_status="${git_status} \033[38;5;167m✗\033[0m"
        else
            # Clean - muted sage ✓
            git_status="${git_status} \033[38;5;71m✓\033[0m"
        fi

        # Get detailed status indicators
        indicators=""

        # Added files (staged new files) - muted sage green ✚
        added=$(git -C "$workspace_dir" --no-optional-locks diff --cached --numstat 2>/dev/null | grep -c "^0.*0" || true)
        if [ "$added" -gt 0 ]; then
            indicators="${indicators} \033[38;5;71m✚\033[0m"
        fi

        # Deleted files - muted coral-red ✖
        deleted=$(git -C "$workspace_dir" --no-optional-locks diff --name-status 2>/dev/null | grep -c "^D" || true)
        deleted_cached=$(git -C "$workspace_dir" --no-optional-locks diff --cached --name-status 2>/dev/null | grep -c "^D" || true)
        if [ "$((deleted + deleted_cached))" -gt 0 ]; then
            indicators="${indicators} \033[38;5;167m✖\033[0m"
        fi

        # Modified files - soft teal ✱
        modified=$(git -C "$workspace_dir" --no-optional-locks diff --name-only 2>/dev/null | wc -l | tr -d ' ')
        if [ "$modified" -gt 0 ]; then
            indicators="${indicators} \033[38;5;109m✱\033[0m"
        fi

        # Renamed files - magenta ➜
        renamed=$(git -C "$workspace_dir" --no-optional-locks diff --cached --name-status 2>/dev/null | grep -c "^R" || true)
        if [ "$renamed" -gt 0 ]; then
            indicators="${indicators} \033[1;35m➜\033[0m"
        fi

        # Untracked files - white ◼
        untracked=$(git -C "$workspace_dir" --no-optional-locks ls-files --others --exclude-standard 2>/dev/null | wc -l | tr -d ' ')
        if [ "$untracked" -gt 0 ]; then
            indicators="${indicators} \033[1;37m◼\033[0m"
        fi

        # Stashed changes - soft teal ✭
        stashed=$(git -C "$workspace_dir" --no-optional-locks stash list 2>/dev/null | wc -l | tr -d ' ')
        if [ "$stashed" -gt 0 ]; then
            indicators="${indicators} \033[38;5;109m✭\033[0m"
        fi

        # Unmerged files - muted gold ═
        unmerged=$(git -C "$workspace_dir" --no-optional-locks diff --name-only --diff-filter=U 2>/dev/null | wc -l | tr -d ' ')
        if [ "$unmerged" -gt 0 ]; then
            indicators="${indicators} \033[38;5;179m═\033[0m"
        fi

        # Ahead/behind - muted gold ⬆⬇
        upstream=$(git -C "$workspace_dir" --no-optional-locks rev-parse --abbrev-ref @{upstream} 2>/dev/null)
        if [ -n "$upstream" ]; then
            ahead=$(git -C "$workspace_dir" --no-optional-locks rev-list --count @{upstream}..HEAD 2>/dev/null || echo "0")
            behind=$(git -C "$workspace_dir" --no-optional-locks rev-list --count HEAD..@{upstream} 2>/dev/null || echo "0")

            if [ "$ahead" -gt 0 ]; then
                indicators="${indicators} \033[38;5;179m⬆\033[0m"
            fi
            if [ "$behind" -gt 0 ]; then
                indicators="${indicators} \033[38;5;179m⬇\033[0m"
            fi
        fi

        git_info="${git_status}${indicators}"
    fi
fi

# Get current time in 24h format
current_time=$(date '+%H:%M')

# Memory indicator - show 󰈙 if CLAUDE.md exists in workspace (muted grey)
memory_indicator=""
if [ -f "$workspace_dir/CLAUDE.md" ]; then
    memory_indicator=" \033[38;5;243m󰈙\033[0m"
fi

# Build version segment (only if version is available)
version_segment=""
if [ -n "$version_display" ]; then
    version_segment=" \033[38;5;237m│\033[0m ${version_display}"
fi

# Build status line: clock (muted gold), separator, model (muted teal), memory, separator, version, separator, progress bar, tokens, separator, path (soft teal), git branch
output="\033[38;5;179m${current_time}\033[0m \033[38;5;237m│\033[0m \033[38;5;66m${model_name}\033[0m${memory_indicator}${version_segment} \033[38;5;237m│\033[0m ${context_info} \033[38;5;237m│\033[0m \033[38;5;73m${short_path}\033[0m${git_info}"

# Print the status line
printf "%b" "$output"
