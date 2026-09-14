# Tasks: Instructional Refactoring and Fragile Command Cleanup

**Branch**: `004-instructional-refactoring` | **Spec**: [spec.md](spec.md) | **Plan**: [plan.md](plan.md)

## Phase 1: Test Harness (TDD Red Gate)

**Purpose**: Create an automated test harness to detect instructional flaws before refactoring.

- [x] T001 [P] Create test validator `tests/test_instructional.py` checking takeaways arguments and output template, learn operational persona and validation, optimize scope consistency and report-only rule, check-tests foreign text removal, and em dash absence across all 4 files.
- [x] T002 Execute `python3 tests/test_instructional.py` and confirm red gate failure against current repository state.

---

## Phase 2: User Story 1 - Comprehensive Restructuring of takeaways (Priority: P1)

**Goal**: Transform `takeaways` into a robust, deterministic skill with realistic extraction handling.

- [x] T003 [US1] Align arguments in `skills/takeaways/SKILL.md` with `<url | text>`, add Copilot CLI note, and document transcript vs. URL handling.
- [x] T004 [US1] Add canonical output template with Premise, Direct Verdict, Comparison, and Key Takeaways to `skills/takeaways/SKILL.md`.

---

## Phase 3: User Story 2 - Operational Agent Persona and Pedagogy in learn (Priority: P1)

**Goal**: Convert `learn` from user-first-person prompt to operational agent directive with validation.

- [x] T005 [US2] Add input validation and error handling for missing `$ARGUMENTS` in `skills/learn/SKILL.md`.
- [x] T006 [US2] Structure `skills/learn/SKILL.md` into multi-level pedagogical sections (ELI5, Technical Mechanics, Analogy, Code Example, Pitfalls, Best Practices).

---

## Phase 4: User Story 3 - Scope Harmonization and Report-Only in optimize (Priority: P1)

**Goal**: Harmonize scope behavior, add report-only rule, and expand frontend guidance to Vue SFCs.

- [x] T007 [US3] Harmonize scope handling in `skills/optimize/SKILL.md` so empty arguments consistently prompt the menu.
- [x] T008 [US3] Add explicit "DO NOT implement fixes. DO NOT edit any files. Report only." rule to `skills/optimize/SKILL.md`.
- [x] T009 [US3] Add Vue SFC reactivity and framework-agnostic frontend performance criteria to `skills/optimize/SKILL.md`.

---

## Phase 5: User Story 4 - Sanitization of check-tests (Priority: P2)

**Goal**: Remove foreign repository references and eliminate em dashes in `check-tests`.

- [x] T010 [US4] Remove "this repo's prior bugs" and foreign context references in `skills/check-tests/SKILL.md`.
- [x] T011 [US4] Clean up em dashes and formatted text in `skills/check-tests/SKILL.md`.

---

## Phase 6: Verification & Gate Validation (TDD Green Gate)

**Purpose**: Verify all tests pass, zero regressions, zero em dashes, and YAML frontmatter compliance.

- [x] T012 Run `python3 tests/test_instructional.py` and verify 100% pass.
- [x] T013 Run `python3 tests/test_cross_platform.py` to ensure cross-platform compatibility is preserved.
- [x] T014 Run `python3 tests/test_frontmatter.py` to verify frontmatter compliance across all 18 skills.
- [x] T015 Run `./tests/test_uninstall.sh` to ensure uninstaller safety tests remain green.
- [ ] T016 Request user confirmation to commit and push branch `004-instructional-refactoring`.
