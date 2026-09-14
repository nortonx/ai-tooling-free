# Tasks: Catalog Synchronization, Governance, and Automated Verification

**Branch**: `006-catalog-sync` | **Spec**: [spec.md](spec.md) | **Plan**: [plan.md](plan.md)

## Phase 1: Test Harness (TDD Red Gate)

**Purpose**: Create an automated test harness to detect catalog synchronization gaps and script header issues.

- [x] T001 [P] Create test validator `tests/test_catalog_sync.py` checking README counts ("18 skills, 10 agents"), all 18 skills and 10 agents listed in tables, absence of zombie headers in `setup.sh` and `setup.ps1`, and zero em dashes.
- [x] T002 Execute `python3 tests/test_catalog_sync.py` and confirm red gate failure against current repository state.

---

## Phase 2: Documentation & Governance Cleanup (Priority: P1)

**Goal**: Synchronize `README.md` and clean up installer script headers.

- [x] T003 Update `README.md` with accurate counts ("18 skills, 10 agents"), a catalog table listing all 18 skills, and a table listing all 10 subagents.
- [x] T004 Clean up `setup.sh` to remove zombie template headers and em dashes.
- [x] T005 Clean up `setup.ps1` to remove zombie template headers and em dashes.

---

## Phase 3: Consolidated Test Runner & CI Automation (Priority: P1)

**Goal**: Establish a single master test runner and a GitHub Actions CI pipeline.

- [x] T006 [P] Create executable `tests/run_all.sh` that runs all test suites with proper exit code aggregation.
- [x] T007 [P] Create `.github/workflows/ci.yml` to run the test suite on push and pull requests.

---

## Phase 4: Verification & Gate Validation (TDD Green Gate)

**Purpose**: Verify all tests pass, zero regressions, zero em dashes, and complete catalog alignment.

- [x] T008 Run `python3 tests/test_catalog_sync.py` and verify 100% pass.
- [x] T009 Run `./tests/run_all.sh` and verify all test suites pass.
- [ ] T010 Request user confirmation to commit and push branch `006-catalog-sync`.
