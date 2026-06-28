#!/usr/bin/env bash
# ────────────────────────────────────────────────────────────────────────────
# ai-tooling-free uninstall — macOS / Linux / WSL2
#
# Removes installed skills and Claude Code subagents, and restores pre-existing
# backups (.bak) if they exist.
set -euo pipefail

REPO="$(cd "$(dirname "$0")" && pwd)"

info() { printf '\033[32m[OK]\033[0m %s\n' "$1"; }
warn() { printf '\033[33m[WARN]\033[0m %s\n' "$1"; }

# Helper to remove link and restore backup
remove_and_restore() {
  local target="$1"
  if [ -L "$target" ] || [ -e "$target" ]; then
    rm -rf "$target"
    info "Removed: $target"
  fi
  
  if [ -e "$target.bak" ] || [ -L "$target.bak" ]; then
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
