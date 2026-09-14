# Tasks: Systematic Style Sanitization and Em Dash Removal

**Branch**: `005-style-sanitization` | **Spec**: [spec.md](spec.md) | **Plan**: [plan.md](plan.md)

## Phase 1: Test Harness (TDD Red Gate)

**Purpose**: Create an automated test harness to detect em dashes across all 18 skills.

- [x] T001 [P] Create test validator `tests/test_style_sanitization.py` scanning all 18 skills for `\u2014` and prose spaced hyphens.
- [x] T002 Execute `python3 tests/test_style_sanitization.py` and confirm red gate failure against current repository state (reporting exactly 6 failing skills and 53 em dashes).

---

## Phase 2: Systematic Em Dash Removal Across 6 Remaining Skills (Priority: P1)

**Goal**: Remove all em dashes from the 6 remaining skills with natural, context-aware punctuation.

- [x] T003 [P] Remove 2 em dashes from `skills/create-commit-message/SKILL.md`.
- [x] T004 [P] Remove 26 em dashes from `skills/framework-upgrade-guide/SKILL.md`.
- [x] T005 [P] Remove 3 em dashes from `skills/plan-or-execute/SKILL.md`.
- [x] T006 [P] Remove 8 em dashes from `skills/pr-description/SKILL.md`.
- [x] T007 [P] Remove 7 em dashes from `skills/ship-it/SKILL.md`.
- [x] T008 [P] Remove 7 em dashes from `skills/update-claude-md/SKILL.md`.

---

## Phase 3: Verification & Gate Validation (TDD Green Gate)

**Purpose**: Verify all tests pass, zero em dashes across all 18 skills, and YAML frontmatter compliance.

- [x] T009 Run `python3 tests/test_style_sanitization.py` and verify 100% pass across all 18 skills.
- [x] T010 Run `python3 tests/test_instructional.py` and verify 100% pass.
- [x] T011 Run `python3 tests/test_cross_platform.py` and verify 100% pass.
- [x] T012 Run `python3 tests/test_frontmatter.py` and verify 100% pass.
- [x] T013 Run `./tests/test_uninstall.sh` and verify 100% pass.
- [ ] T014 Request user confirmation to commit and push branch `005-style-sanitization`.
