#!/usr/bin/env bash
# ────────────────────────────────────────────────────────────────────────────
# ai-tooling-free uninstall (macOS / Linux / WSL2)
#
# Removes installed skills and Claude Code subagents, and restores pre-existing
# backups (.bak) if they exist.
set -euo pipefail

REPO="$(cd "$(dirname "$0")" && pwd)"

info() { printf '\033[32m[OK]\033[0m %s\n' "$1"; }
warn() { printf '\033[33m[WARN]\033[0m %s\n' "$1"; }

# Track canonical paths already processed to prevent circular double-removal in shared symlink setups
PROCESSED_CANONICAL_TARGETS=" "

get_canonical_target() {
  local path="$1"
  local dir
  dir="$(dirname "$path")"
  local base
  base="$(basename "$path")"

  if [ -d "$dir" ]; then
    local real_dir
    real_dir="$(cd "$dir" && pwd -P)"
    echo "$real_dir/$base"
  else
    echo "$path"
  fi
}

# Helper to remove link and restore backup safely
remove_and_restore() {
  local target="$1"
  local canon
  canon="$(get_canonical_target "$target")"

  # If this canonical target was already handled during this uninstallation run, skip it
  if [[ "$PROCESSED_CANONICAL_TARGETS" == *" $canon "* ]]; then
    return 0
  fi
  PROCESSED_CANONICAL_TARGETS+="$canon "

  local has_backup=false
  if [ -e "$target.bak" ] || [ -L "$target.bak" ]; then
    has_backup=true
  fi

  # Only remove target if it is a symlink or if a backup exists to replace it
  if [ -L "$target" ]; then
    rm -f "$target"
    info "Removed link: $target"
  elif [ "$has_backup" = true ] && [ -e "$target" ]; then
    rm -rf "$target"
    info "Removed installed target: $target"
  fi

  if [ "$has_backup" = true ]; then
    mv "$target.bak" "$target"
    info "Restored backup: $target"
  fi
}

echo "Uninstalling skills and subagents..."

# Skills cleanup
for d in "$REPO/skills"/*/; do
  name="$(basename "$d")"
  remove_and_restore "$HOME/.claude/skills/$name"
  remove_and_restore "$HOME/.agents/skills/$name"
done

# Agents cleanup
for f in "$REPO/agents"/*.md; do
  name="$(basename "$f")"
  remove_and_restore "$HOME/.claude/agents/$name"
done

info "Uninstall complete!"
