#!/usr/bin/env bash
# ai-tooling-free setup — macOS / Linux / WSL2
#
# Symlinks each skill into ~/.claude/skills, ~/.copilot/skills and
# ~/.agents/skills (the Agent Skills open-standard dir — Codex CLI, Cursor,
# Gemini CLI, Antigravity, etc.), and each agent into ~/.claude/agents.
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
    echo "  Install git with your package manager, e.g. apt install git"
  fi
fi

# ── Safety gate ─────────────────────────────────────────────────────
# This script writes ONLY inside your home directory: it symlinks skills and
# copies agents, backing up anything already there to <name>.bak. It uses no
# sudo, and never writes settings.json, models, themes, or instruction files.
# Read the whole script before running. Skip the prompt with -y/--yes or
# ASSUME_YES=1.
case " $* " in *" -y "*|*" --yes "*) ASSUME_YES=1 ;; esac
if [ "${ASSUME_YES:-}" != "1" ]; then
  printf '\n\033[33m'
  echo "This script modifies ONLY your home directory ($HOME):"
  echo "  - symlinks each skill into ~/.claude/skills, ~/.copilot/skills, ~/.agents/skills"
  echo "  - symlinks each agent into ~/.claude/agents"
  echo "  - backs up anything already there to <name>.bak"
  echo "It uses NO sudo and never writes settings.json, models, themes, or"
  printf 'instruction files. Please READ THE FULL SCRIPT before continuing.\033[0m\n'
  printf 'Proceed? [y/N]: '
  read -r ans || ans=""
  case "$ans" in [Yy]*) ;; *) warn "Aborted."; exit 1 ;; esac
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

# Skills → Claude Code, Copilot CLI, plus the Agent Skills standard dir
# (~/.agents/skills). Gemini CLI and Antigravity also read ~/.agents/skills, so
# we do NOT also link into ~/.gemini/skills — Gemini treats it as a same-tier
# alias and would warn that every skill "overrides" its duplicate.
for target in "$HOME/.claude/skills" "$HOME/.copilot/skills" "$HOME/.agents/skills"; do
  mkdir -p "$target"
  for d in "$REPO/skills"/*/; do
    name="$(basename "$d")"
    link "${d%/}" "$target/$name"
  done
done

# Self-healing: an older version of this script linked skills into
# ~/.gemini/skills. Remove the symlinks we created there (those pointing into
# $REPO/skills), leave any user-added skills, and drop the dir if empty.
if [ -d "$HOME/.gemini/skills" ]; then
  for l in "$HOME/.gemini/skills"/*; do
    [ -L "$l" ] || continue
    case "$(readlink -f "$l" 2>/dev/null)" in
      "$REPO/skills/"*) rm -f "$l" && info "Unlinked stale Gemini skill: $l" ;;
    esac
  done
  rmdir "$HOME/.gemini/skills" 2>/dev/null && info "Removed empty ~/.gemini/skills" || true
fi

# Agents → Claude Code only (per-file, so your own agents are untouched)
mkdir -p "$HOME/.claude/agents"
for f in "$REPO/agents"/*.md; do
  link "$f" "$HOME/.claude/agents/$(basename "$f")"
done

info "Done. Restart your CLI sessions to pick up the skills."
