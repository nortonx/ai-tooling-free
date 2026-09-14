#!/usr/bin/env bash
# ────────────────────────────────────────────────────────────────────────────
# Master test runner for ai-tooling-free
# Executes all test suites and validates 100% gate pass.
# ────────────────────────────────────────────────────────────────────────────
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

info() { printf '\033[32m[PASS]\033[0m %s\n' "$1"; }
error() { printf '\033[31m[FAIL]\033[0m %s\n' "$1"; }

FAILED=0

run_suite() {
  local name="$1"
  shift
  echo ""
  echo "=================================================="
  echo "Running: $name"
  echo "=================================================="
  if "$@"; then
    info "$name passed"
  else
    error "$name failed"
    FAILED=$((FAILED + 1))
  fi
}

run_suite "Catalog Synchronization & Governance" python3 tests/test_catalog_sync.py
run_suite "Catalog Style Sanitization (0 Em Dashes)" python3 tests/test_style_sanitization.py
run_suite "Instructional Quality & Personas" python3 tests/test_instructional.py
run_suite "Cross-Platform Portability & Multi-Runtime" python3 tests/test_cross_platform.py
run_suite "Agent Skills YAML Frontmatter Validation" python3 tests/test_frontmatter.py
run_suite "Uninstaller Safety & Backup Preservation" ./tests/test_uninstall.sh

echo ""
echo "=================================================="
if [ "$FAILED" -eq 0 ]; then
  printf '\033[32mALL 6 TEST SUITES PASSED (100%% GREEN GATE)\033[0m\n'
  exit 0
else
  printf '\033[31m%d TEST SUITE(S) FAILED\033[0m\n' "$FAILED"
  exit 1
fi
