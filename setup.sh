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

echo "Installing skills globally using the Agent Skills CLI..."
npx -y skills add "$REPO" -g -y

echo "Linking subagents to Claude Code..."
mkdir -p "$HOME/.claude/agents"
for f in "$REPO/agents"/*.md; do
  ln -sf "$f" "$HOME/.claude/agents/$(basename "$f")"
done

echo "Setup complete!"
