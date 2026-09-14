#!/usr/bin/env bash
# Test harness for uninstall.sh safety and idempotency
set -euo pipefail

REPO="$(cd "$(dirname "$0")/.." && pwd)"
FAILED_TESTS=0
TOTAL_TESTS=0

pass() {
  printf '\033[32m[PASS]\033[0m %s\n' "$1"
}

fail() {
  printf '\033[31m[FAIL]\033[0m %s\n' "$1"
  FAILED_TESTS=$((FAILED_TESTS + 1))
}

run_test() {
  TOTAL_TESTS=$((TOTAL_TESTS + 1))
  local test_name="$1"
  printf '\n=== Test %d: %s ===\n' "$TOTAL_TESTS" "$test_name"
}

# Test 1: Shared symlink directory between ~/.agents/skills and ~/.claude/skills
run_test "Prevent backup deletion when ~/.agents/skills symlinks to ~/.claude/skills"
TEST_HOME="$(mktemp -d)"
trap 'rm -rf "$TEST_HOME"' EXIT

mkdir -p "$TEST_HOME/.claude/skills" "$TEST_HOME/.claude/agents"
mkdir -p "$TEST_HOME/.agents"
ln -s "$TEST_HOME/.claude/skills" "$TEST_HOME/.agents/skills"

# Pick first skill from repo
FIRST_SKILL="$(basename "$(find "$REPO/skills" -mindepth 1 -maxdepth 1 -type d | head -n 1)")"

# Simulate user backup and installed symlink
echo "PRESERVED_USER_SKILL_DATA" > "$TEST_HOME/.claude/skills/$FIRST_SKILL.bak"
ln -s "$REPO/skills/$FIRST_SKILL" "$TEST_HOME/.claude/skills/$FIRST_SKILL"

# Execute uninstaller with simulated HOME
HOME="$TEST_HOME" bash "$REPO/uninstall.sh"

# Verify backup was restored and NOT deleted by subsequent .agents pass
if [ ! -e "$TEST_HOME/.claude/skills/$FIRST_SKILL" ]; then
  fail "Restored skill $FIRST_SKILL was deleted by double-removal!"
elif [ "$(cat "$TEST_HOME/.claude/skills/$FIRST_SKILL")" != "PRESERVED_USER_SKILL_DATA" ]; then
  fail "Restored skill content does not match backup data!"
else
  pass "Restored user backup was successfully preserved despite shared symlink."
fi

# Test 2: Dangling symlinks are cleanly removed without failure
run_test "Clean removal of dangling symlinks"
TEST_HOME_DANGLING="$(mktemp -d)"
mkdir -p "$TEST_HOME_DANGLING/.claude/skills" "$TEST_HOME_DANGLING/.claude/agents"
mkdir -p "$TEST_HOME_DANGLING/.agents/skills"

ln -s "/nonexistent/path/for/dangling/skill" "$TEST_HOME_DANGLING/.claude/skills/$FIRST_SKILL"

if HOME="$TEST_HOME_DANGLING" bash "$REPO/uninstall.sh"; then
  if [ -L "$TEST_HOME_DANGLING/.claude/skills/$FIRST_SKILL" ]; then
    fail "Dangling symlink was not removed!"
  else
    pass "Dangling symlink was removed cleanly."
  fi
else
  fail "Uninstaller failed when encountering dangling symlink!"
fi
rm -rf "$TEST_HOME_DANGLING"

# Test 3: Idempotent execution (running uninstall twice causes no errors)
run_test "Idempotent execution on repeated runs"
TEST_HOME_IDEM="$(mktemp -d)"
mkdir -p "$TEST_HOME_IDEM/.claude/skills" "$TEST_HOME_IDEM/.claude/agents"
mkdir -p "$TEST_HOME_IDEM/.agents/skills"

echo "USER_SKILL_BACKUP" > "$TEST_HOME_IDEM/.claude/skills/$FIRST_SKILL.bak"
ln -s "$REPO/skills/$FIRST_SKILL" "$TEST_HOME_IDEM/.claude/skills/$FIRST_SKILL"

HOME="$TEST_HOME_IDEM" bash "$REPO/uninstall.sh"
if HOME="$TEST_HOME_IDEM" bash "$REPO/uninstall.sh"; then
  if [ "$(cat "$TEST_HOME_IDEM/.claude/skills/$FIRST_SKILL")" = "USER_SKILL_BACKUP" ]; then
    pass "Second uninstall invocation succeeded and preserved restored file."
  else
    fail "Second uninstall invocation corrupted user file!"
  fi
else
  fail "Second uninstall invocation exited with error!"
fi
rm -rf "$TEST_HOME_IDEM"

# Test 4: Independent directories (both are real folders, not symlinks)
run_test "Independent real directories uninstall and restore separately"
TEST_HOME_INDEP="$(mktemp -d)"
mkdir -p "$TEST_HOME_INDEP/.claude/skills" "$TEST_HOME_INDEP/.claude/agents"
mkdir -p "$TEST_HOME_INDEP/.agents/skills"

echo "CLAUDE_USER_BACKUP" > "$TEST_HOME_INDEP/.claude/skills/$FIRST_SKILL.bak"
echo "AGENTS_USER_BACKUP" > "$TEST_HOME_INDEP/.agents/skills/$FIRST_SKILL.bak"
ln -s "$REPO/skills/$FIRST_SKILL" "$TEST_HOME_INDEP/.claude/skills/$FIRST_SKILL"
ln -s "$REPO/skills/$FIRST_SKILL" "$TEST_HOME_INDEP/.agents/skills/$FIRST_SKILL"

HOME="$TEST_HOME_INDEP" bash "$REPO/uninstall.sh"

if [ "$(cat "$TEST_HOME_INDEP/.claude/skills/$FIRST_SKILL")" = "CLAUDE_USER_BACKUP" ] && \
   [ "$(cat "$TEST_HOME_INDEP/.agents/skills/$FIRST_SKILL")" = "AGENTS_USER_BACKUP" ]; then
  pass "Both independent locations were uninstalled and restored correctly."
else
  fail "Independent directories failed to restore respective backups properly!"
fi
rm -rf "$TEST_HOME_INDEP"

# Summary
printf '\n========================================\n'
printf 'Total tests: %d | Passed: %d | Failed: %d\n' "$TOTAL_TESTS" "$((TOTAL_TESTS - FAILED_TESTS))" "$FAILED_TESTS"
printf '========================================\n'

if [ "$FAILED_TESTS" -gt 0 ]; then
  exit 1
fi
