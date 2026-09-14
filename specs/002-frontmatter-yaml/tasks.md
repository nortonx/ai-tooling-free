# Tasks: YAML Frontmatter and Agent Skills Standard Compliance

**Branch**: `002-frontmatter-yaml` | **Spec**: [spec.md](file:///home/norton/workspace/projects/ai-tooling-free/specs/002-frontmatter-yaml/spec.md) | **Plan**: [plan.md](file:///home/norton/workspace/projects/ai-tooling-free/specs/002-frontmatter-yaml/plan.md)

## Phase 1: Setup and Test Harness (TDD Red)

**Purpose**: Build automated test suite to capture frontmatter discrepancies before applying fixes.

- [x] T001 Create automated test suite `tests/test_frontmatter.py` validating YAML syntax, scalar types, character bounds, and em dash absence across all 18 skills.
- [x] T002 Execute `python3 tests/test_frontmatter.py` to observe and verify expected failures on current catalog (Red Gate).

---

## Phase 2: User Story 1 - Scalar Typing in ship-it (Priority: P1) 🎯 MVP

**Goal**: Fix invalid YAML list typing in `argument-hint` and remove em dash from description.

- [x] T003 [US1] Update `skills/ship-it/SKILL.md` frontmatter with `argument-hint: "[<branch-name-or-card>]"` and clean description text.

---

## Phase 3: User Story 2 - Complete Metadata in takeaways (Priority: P1)

**Goal**: Add missing `argument-hint` and `Args:` documentation trailer to `takeaways`.

- [x] T004 [US2] Update `skills/takeaways/SKILL.md` frontmatter with `argument-hint: "<url | text>"` and append `Args: <url | text>` to description.

---

## Phase 4: User Story 3 - Robust String Quoting in fanout-review (Priority: P1)

**Goal**: Quote description string and remove em dash in `fanout-review`.

- [x] T005 [US3] Update `skills/fanout-review/SKILL.md` frontmatter with double-quoted description and comma replacement for em dash.

---

## Phase 5: User Story 4 - Token Optimization in framework-upgrade-guide (Priority: P1)

**Goal**: Condense hypertrophic description (<200 characters) while retaining framework triggers and removing em dash.

- [x] T006 [US4] Update `skills/framework-upgrade-guide/SKILL.md` frontmatter with concise description retaining Angular, React, Vue, TypeScript, and Node keywords.

---

## Phase 6: User Story 5 - Frontmatter Style Hygiene Across Catalog (Priority: P2)

**Goal**: Clean remaining em dashes in frontmatter descriptions across the catalog.

- [x] T007 [US5] Remove em dash from `skills/create-commit-message/SKILL.md` frontmatter description.
- [x] T008 [US5] Remove em dash from `skills/fix-security-audit/SKILL.md` frontmatter description.

---

## Phase 7: Verification and Gate (TDD Green)

**Purpose**: Confirm all tests pass across all skills with zero regressions.

- [x] T009 Run `python3 tests/test_frontmatter.py` to confirm all 18 skills pass validation (Green Gate).
- [x] T010 Run existing `./tests/test_uninstall.sh` to confirm uninstaller safety suite remains green.
- [x] T011 Update `tasks.md` and prepare branch handoff.

---

## Dependencies & Execution Order

- **Phase 1 (Test Harness)**: Blocks all implementation phases (TDD mandatory).
- **Phases 2-6 (User Stories 1-5)**: Can proceed independently across skill files.
- **Phase 7 (Verification)**: Final gate verifying all assertions green.
