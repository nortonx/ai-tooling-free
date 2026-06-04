#!/usr/bin/env bash
# ai-tooling-free setup — macOS / Linux / WSL2
#
# Symlinks each skill into ~/.claude/skills, ~/.copilot/skills and
# ~/.gemini/skills, and each agent into ~/.claude/agents.
# Anything already at a destination is backed up to <name>.bak first.
# It never reads or writes settings.json, models, themes, or global
# instruction files. Re-running is safe (idempotent).
set -euo pipefail

REPO="$(cd "$(dirname "$0")" && pwd)"

info() { printf '\033[32m[OK]\033[0m %s\n' "$1"; }
warn() { printf '\033[33m[WARN]\033[0m %s\n' "$1"; }

case "$(uname -s)" in
  Darwin) OS=macos ;;
  *)      OS=linux ;;
esac

if ! command -v git >/dev/null 2>&1; then
  warn "git not found — several skills (ship-it, pr-description, check-tests) need it."
  if [ "$OS" = macos ]; then
    echo "  Install: xcode-select --install   (or: brew install git)"
  else
    echo "  Install with your package manager, e.g. sudo apt install git"
  fi
fi

# link <src> <dst> — symlink with .bak backup of anything already there
link() {
  local src="$1" dst="$2"
  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
    info "Already linked: $dst"
    return
  fi
  if [ -e "$dst" ] || [ -L "$dst" ]; then
    mv "$dst" "$dst.bak"
    warn "Existing $dst moved to $dst.bak"
  fi
  ln -s "$src" "$dst"
  info "Linked $dst -> $src"
}

# Skills → all three CLIs
for target in "$HOME/.claude/skills" "$HOME/.copilot/skills" "$HOME/.gemini/skills"; do
  mkdir -p "$target"
  for d in "$REPO/skills"/*/; do
    name="$(basename "$d")"
    link "${d%/}" "$target/$name"
  done
done

# Agents → Claude Code only (per-file, so your own agents are untouched)
mkdir -p "$HOME/.claude/agents"
for f in "$REPO/agents"/*.md; do
  link "$f" "$HOME/.claude/agents/$(basename "$f")"
done

info "Done. Restart your CLI sessions to pick up the skills."
