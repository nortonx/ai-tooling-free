# Tasks: Cross-Platform Portability and Runtime Interoperability

**Branch**: `003-cross-platform-runtimes` | **Spec**: [spec.md](spec.md) | **Plan**: [plan.md](plan.md)

## Phase 1: Test Harness (TDD Red Gate)

**Purpose**: Create an automated test harness to verify defects before fixing and guarantee no regressions.

- [x] T001 [P] Create test validator `tests/test_cross_platform.py` checking for `2>/dev/null`, single quotes in git log format, directory creation patterns, subagent runtime instructions, and decoupled plugin references.
- [x] T002 Execute `python3 tests/test_cross_platform.py` and confirm red gate failure against current repository state.

---

## Phase 2: User Story 1 - Shell-Agnostic Tool Execution in check-dx (Priority: P1)

**Goal**: Eliminate `2>/dev/null` in `check-dx` and fix `/check-dx-rules` typo.

- [x] T003 [US1] Remove `2>/dev/null` from tool execution commands in `skills/check-dx/SKILL.md` and add shell-agnostic stderr handling notes.
- [x] T004 [US1] Fix typo in `skills/check-dx/SKILL.md` Step 1 from `/check-dx-rules` to `/check-dx`.

---

## Phase 3: User Story 2 - Cross-Platform Directory Creation (Priority: P1)

**Goal**: Remove POSIX-specific `mkdir -p` shell commands from ADR and spec generators.

- [x] T005 [P] [US2] Update Step 4 in `skills/generate-adr/SKILL.md` to specify tool-agnostic directory creation.
- [x] T006 [P] [US2] Update Step 4 in `skills/generate-spec/SKILL.md` to specify tool-agnostic directory creation without hardcoded `mkdir -p via Bash`.

---

## Phase 4: User Story 3 - Multi-Runtime Subagent Guidance (Priority: P1)

**Goal**: Enable subagent execution across Claude Code (`Agent`), Antigravity (`invoke_subagent`), and single-agent runtimes (sequential fallback).

- [x] T007 [P] [US3] Update Step 2 in `skills/fanout-review/SKILL.md` with multi-runtime subagent dispatch instructions and replace single quotes in `git log` with double quotes.
- [x] T008 [P] [US3] Update Step 5 in `skills/check-dx/SKILL.md` with multi-runtime subagent dispatch instructions and sequential fallback.

---

## Phase 5: User Story 4 - Decoupled Agent and Plugin References (Priority: P2)

**Goal**: Generalize `@test-automator` and decouple proprietary plugin namespaces.

- [x] T009 [P] [US4] Update `skills/create-unit-tests/SKILL.md` to generalize `@test-automator` to the test automation role.
- [x] T010 [P] [US4] Update `skills/check-dry/SKILL.md` to decouple the `/feature-dev` reference in Next Steps.
- [x] T011 [P] [US4] Update `skills/smart-fix/SKILL.md` to decouple `superpowers:*` and `feature-dev:*` references.

---

## Phase 6: Verification & Gate Validation (TDD Green Gate)

**Purpose**: Verify all tests pass, zero regressions, zero em dashes, and YAML frontmatter compliance.

- [x] T012 Run `python3 tests/test_cross_platform.py` and verify 100% pass.
- [x] T013 Run `python3 tests/test_frontmatter.py` to verify frontmatter compliance across all 18 skills.
- [x] T014 Run `./tests/test_uninstall.sh` to ensure uninstaller safety tests remain green.
- [x] T015 Verify zero em dashes across modified files.
- [ ] T016 Request user confirmation to commit and push branch `003-cross-platform-runtimes`.
