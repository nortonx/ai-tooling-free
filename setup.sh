#!/usr/bin/env bash
# ────────────────────────────────────────────────────────────────────────────
# GENERATED FILE — do not edit the copy in ai-tooling-free/.
# Source of truth: ai-tooling/templates/ai-tooling-free.setup.sh
# ai-tooling/setup.sh rewrites ai-tooling-free/setup.sh from this template on
# every run (when that sibling repo is present). Edit the template, then re-run.
# ────────────────────────────────────────────────────────────────────────────
# ai-tooling-free setup — macOS / Linux / WSL2
#
# Installs skills globally utilizing the Agent Skills CLI (npx skills)
# and symlinks Claude Code subagents into ~/.claude/agents/.
set -euo pipefail

REPO="$(cd "$(dirname "$0")" && pwd)"

# Backup helper
backup_if_exists() {
  local target="$1"
  local source="$2"
  if [ -e "$target" ] || [ -L "$target" ]; then
    if [ -L "$target" ] && [ "$(readlink "$target")" = "$source" ]; then
      return
    fi
    mv "$target" "$target.bak"
    echo "Backed up existing $(basename "$target") to $(basename "$target").bak"
  fi
}

echo "Backing up pre-existing skills and agents..."
for d in "$REPO/skills"/*/; do
  name="$(basename "$d")"
  backup_if_exists "$HOME/.claude/skills/$name" "${d%/}"
  backup_if_exists "$HOME/.agents/skills/$name" "${d%/}"
done

echo "Installing skills globally using the Agent Skills CLI..."
npx -y skills add "$REPO" -g -y

echo "Linking subagents to Claude Code..."
mkdir -p "$HOME/.claude/agents"
for f in "$REPO/agents"/*.md; do
  name="$(basename "$f")"
  backup_if_exists "$HOME/.claude/agents/$name" "$f"
  ln -sf "$f" "$HOME/.claude/agents/$name"
done

echo "Setup complete!"
echo "You can revert this by running the \`uninstall.sh\` script."
