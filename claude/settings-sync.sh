#!/bin/bash

# Reconcile ~/.claude/settings.json with the copy in this repo.
#
# This file can't be symlinked like the rest of the dotfiles: it has several
# writers. Claude Code rewrites it (/config, /model, plugin toggles), and
# supacode injects its own hooks into it. supacode is a native app, so it
# writes atomically, which replaces a symlink with a regular file.
#
# So the live file is runtime-owned and the repo keeps a curated snapshot.
# --pull takes a snapshot without the foreign hooks, --push puts the repo
# copy back while keeping whatever foreign hooks are live right now.

set -euo pipefail

DOTFILES_DIR="${HOME}/.dotfiles"
REPO_SETTINGS="${DOTFILES_DIR}/claude/settings.json"
LIVE_SETTINGS="${HOME}/.claude/settings.json"

# Hooks owned by other tools. They are guarded no-ops when their app is
# absent, but they churn on every app update, so the repo copy stays clean.
# Add a marker here when another tool starts injecting.
FOREIGN_HOOK_PATTERN='supacode-managed-hook|orca'

### Options
###########
MODE=status
DRY_RUN=false
HELP=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --status)
            MODE=status
            shift
            ;;
        --pull)
            MODE=pull
            shift
            ;;
        --push)
            MODE=push
            shift
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --help|-h)
            HELP=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

if [[ "$HELP" == true ]]; then
    cat << EOF
Usage: settings-sync.sh [--status|--pull|--push] [--dry-run]

Reconciles ~/.claude/settings.json with claude/settings.json in this repo.
That file has several writers, so it is synced rather than symlinked.

Options:
    --status    Show hook ownership and any drift (default, read-only)
    --pull      Live -> repo, dropping hooks owned by other tools
    --push      Repo -> live, keeping the foreign hooks already live
    --dry-run   Show the resulting diff without writing
    --help, -h  Show this help message

Hooks matching this pattern are treated as foreign:
    ${FOREIGN_HOOK_PATTERN}
EOF
    exit 0
fi

### Pre-flight checks
#####################
if ! command -v jq &> /dev/null; then
    echo "ERROR: jq is not installed"
    exit 1
fi

### jq programs
###############
# Drop foreign hooks, then drop matcher groups and event keys left empty.
JQ_STRIP='
def foreign: (.command // "") | test($pat; "i");
.hooks |= (
    with_entries(.value |= (
        map(.hooks |= map(select(foreign | not)))
        | map(select((.hooks | length) > 0))
    ))
    | with_entries(select((.value | length) > 0))
)'

# Append the foreign hook groups from $live to the repo copy on stdin.
JQ_MERGE='
def foreign: (.command // "") | test($pat; "i");
($live[0].hooks // {}) as $lh
| .hooks = (
    reduce ($lh | to_entries[]) as $e ((.hooks // {});
        ($e.value
            | map(.hooks |= map(select(foreign)))
            | map(select((.hooks | length) > 0))) as $groups
        | if ($groups | length) > 0
          then .[$e.key] = ((.[$e.key] // []) + $groups)
          else . end
    )
)'

# Re-add enabledPlugins entries the runtime pruned. Claude Code drops keys for
# plugins it cannot currently resolve, so a missing key is never a decision:
# disabling a plugin writes false, it does not remove the entry. Live values win
# where both have the key, repo-only keys survive.
JQ_PRESERVE='
($repo[0].enabledPlugins // {}) as $rp
| if ($rp | length) > 0
  then .enabledPlugins = ($rp + (.enabledPlugins // {}))
  else . end'

# One line per hook: event, owner, command excerpt.
JQ_INVENTORY='
.hooks // {} | to_entries[] | .key as $ev | .value[] | .hooks[]
| "\($ev)\t\(if ((.command // "") | test($pat; "i")) then "foreign" else "own" end)\t\((.command // "") | gsub("\\s+"; " ") | .[0:56])"'

### Helpers
###########
function require_file() {
    local file="$1"
    if [[ ! -f "$file" ]]; then
        echo "ERROR: not found: $file"
        exit 1
    fi
    if ! jq -e . "$file" > /dev/null 2>&1; then
        echo "ERROR: not valid JSON: $file"
        exit 1
    fi
}

function inventory() {
    local file="$1"
    jq -r --arg pat "$FOREIGN_HOOK_PATTERN" "$JQ_INVENTORY" "$file"
}

function hook_summary() {
    local file="$1" label="$2" own foreign
    own=$(inventory "$file" | grep -c $'\town\t' || true)
    foreign=$(inventory "$file" | grep -c $'\tforeign\t' || true)
    printf "  %-8s %2d own, %2d foreign\n" "$label" "$own" "$foreign"
}

# Refuse to write anything that silently loses a top-level key.
function assert_keys_kept() {
    local source="$1" candidate="$2" missing
    missing=$(jq -rn --slurpfile a "$source" --slurpfile b "$candidate" \
        '(($a[0] | keys) - ($b[0] | keys)) | join(", ")')
    if [[ -n "$missing" ]]; then
        echo "ERROR: refusing to write, these top-level keys would be lost: $missing"
        exit 1
    fi
}

# Write through the destination rather than replacing it. mv would clobber a
# symlink, which is exactly how this file stopped being one in the first place.
function apply() {
    local candidate="$1" dest="$2"

    if ! diff -q "$candidate" "$dest" > /dev/null 2>&1; then
        if [[ "$DRY_RUN" == true ]]; then
            echo "[DRY RUN] Would update: $dest"
            diff -u "$dest" "$candidate" || true
        else
            cat "$candidate" >| "$dest"
            echo "Updated: $dest"
        fi
    else
        echo "Already up to date: $dest"
    fi
}

TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

### Main
########
case "$MODE" in
    status)
        require_file "$REPO_SETTINGS"
        require_file "$LIVE_SETTINGS"

        echo "Claude settings"
        echo "  repo     ${REPO_SETTINGS}"
        echo "  live     ${LIVE_SETTINGS}"
        echo ""

        if [[ -L "$LIVE_SETTINGS" ]]; then
            echo "WARNING: live settings is a symlink. It is meant to be a regular"
            echo "         file; another tool will replace the link sooner or later."
            echo ""
        fi

        echo "Hooks:"
        hook_summary "$REPO_SETTINGS" "repo"
        hook_summary "$LIVE_SETTINGS" "live"
        echo ""

        echo "Foreign hooks live (not committed):"
        inventory "$LIVE_SETTINGS" | awk -F'\t' '$2 == "foreign" { printf "  %-16s %s\n", $1, $3 }' \
            || true
        echo ""

        pruned=$(jq -rn --slurpfile a "$REPO_SETTINGS" --slurpfile b "$LIVE_SETTINGS" \
            '((($a[0].enabledPlugins // {}) | keys) - (($b[0].enabledPlugins // {}) | keys))[]')
        if [[ -n "$pruned" ]]; then
            echo "Plugin entries the runtime pruned (benign, --pull keeps them):"
            echo "$pruned" | sed 's/^/  /'
            echo ""
        fi

        echo "Drift outside hooks:"
        if diff -q <(jq -S 'del(.hooks)' "$REPO_SETTINGS") \
                   <(jq -S 'del(.hooks)' "$LIVE_SETTINGS") > /dev/null; then
            echo "  none"
        else
            diff -u <(jq -S 'del(.hooks)' "$REPO_SETTINGS") \
                    <(jq -S 'del(.hooks)' "$LIVE_SETTINGS") \
                | sed '1,2d;s/^/  /' || true
        fi
        echo ""

        echo "Drift in your own hooks:"
        if diff -q <(inventory "$REPO_SETTINGS" | grep $'\town\t' | sort) \
                   <(inventory "$LIVE_SETTINGS" | grep $'\town\t' | sort) > /dev/null; then
            echo "  none"
        else
            diff -u <(inventory "$REPO_SETTINGS" | grep $'\town\t' | sort) \
                    <(inventory "$LIVE_SETTINGS" | grep $'\town\t' | sort) \
                | sed '1,2d;s/^/  /' || true
        fi
        ;;

    pull)
        require_file "$LIVE_SETTINGS"
        require_file "$REPO_SETTINGS"
        jq -S --arg pat "$FOREIGN_HOOK_PATTERN" --slurpfile repo "$REPO_SETTINGS" \
            "${JQ_STRIP} | ${JQ_PRESERVE}" \
            "$LIVE_SETTINGS" > "${TMP_DIR}/pulled.json"
        assert_keys_kept "$LIVE_SETTINGS" "${TMP_DIR}/pulled.json"

        pruned=$(jq -rn --slurpfile a "$REPO_SETTINGS" --slurpfile b "$LIVE_SETTINGS" \
            '((($a[0].enabledPlugins // {}) | keys) - (($b[0].enabledPlugins // {}) | keys))[]')
        if [[ -n "$pruned" ]]; then
            echo "Kept plugin entries the runtime had pruned:"
            echo "$pruned" | sed 's/^/  /'
            echo ""
        fi

        echo "Stripped foreign hooks:"
        inventory "$LIVE_SETTINGS" | awk -F'\t' '$2 == "foreign" { printf "  %-16s %s\n", $1, $3 }' \
            || true
        echo "Kept your hooks:"
        inventory "$LIVE_SETTINGS" | awk -F'\t' '$2 == "own" { printf "  %-16s %s\n", $1, $3 }' \
            || true
        echo ""

        apply "${TMP_DIR}/pulled.json" "$REPO_SETTINGS"
        ;;

    push)
        require_file "$REPO_SETTINGS"
        if [[ -f "$LIVE_SETTINGS" ]] && jq -e . "$LIVE_SETTINGS" > /dev/null 2>&1; then
            jq -S --arg pat "$FOREIGN_HOOK_PATTERN" \
                --slurpfile live "$LIVE_SETTINGS" "$JQ_MERGE" \
                "$REPO_SETTINGS" > "${TMP_DIR}/merged.json"
        else
            # Fresh machine: nothing live to preserve.
            echo "No usable live settings, installing the repo copy as-is."
            jq -S . "$REPO_SETTINGS" > "${TMP_DIR}/merged.json"
            mkdir -p "$(dirname "$LIVE_SETTINGS")"
            if [[ "$DRY_RUN" != true ]]; then
                : >> "$LIVE_SETTINGS"
            fi
        fi
        assert_keys_kept "$REPO_SETTINGS" "${TMP_DIR}/merged.json"

        if [[ "$DRY_RUN" == true && ! -f "$LIVE_SETTINGS" ]]; then
            echo "[DRY RUN] Would create: $LIVE_SETTINGS"
        else
            apply "${TMP_DIR}/merged.json" "$LIVE_SETTINGS"
        fi
        ;;
esac
