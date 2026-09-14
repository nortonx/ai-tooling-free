# Feature Specification: Catalog Synchronization, Governance, and Automated Verification

**Feature Branch**: `006-catalog-sync`

**Created**: 2026-09-13

**Status**: Draft

**Input**: User description: "Catalog synchronization, documentation updates, and CI test runner consolidation"

## User Scenarios & Testing *(mandatory)*

### User Story 1: Comprehensive and Accurate README Catalog (Priority: P1)

As a developer discovering or using `ai-tooling-free`, I want the `README.md` to accurately state that the repository contains 18 skills and 10 agents, with a complete catalog table detailing every skill, its command invocation, argument hints, and purpose, so that I can see the full value of the suite and know how to run every skill.

**Why this priority**: The `README.md` has been outdated since v0.2.0 ("16 skills, 10 agents"), completely omitting `fix-security-audit` and `takeaways` and lacking a discoverable catalog table.

**Independent Test**:
Inspect `README.md` to confirm:
- The count states "18 skills, 10 agents".
- A complete Markdown table enumerates all 18 skills with names, descriptions, arguments, and command shortcuts.
- A table lists all 10 subagents with their specializations.
- Zero em dashes exist in `README.md`.

**Acceptance Scenarios**:

1. **Given** `README.md`, **When** the introductory counts are read, **Then** it states "18 skills, 10 agents".
2. **Given** `README.md`, **When** the skills section is read, **Then** all 18 skills (including `fix-security-audit` and `takeaways`) are listed with command triggers and summaries.
3. **Given** `README.md`, **When** the agents section is read, **Then** all 10 agents are listed with roles.

---

### User Story 2: Sanitization of Setup Script Headers (Priority: P1)

As a contributor inspecting `setup.sh` and `setup.ps1`, I want the header comments clean and self-contained, without confusing references to non-existent private sibling repositories (`ai-tooling/templates/...`) or em dashes, so that project governance is transparent.

**Why this priority**: Header comments claiming `setup.sh` is generated from a private sibling repository that is not part of this open-source project mislead contributors and prevent direct maintenance.

**Independent Test**:
Inspect `setup.sh` and `setup.ps1` to confirm zombie template headers are removed and no em dashes remain.

**Acceptance Scenarios**:

1. **Given** `setup.sh`, **When** header lines are inspected, **Then** no references to `ai-tooling/templates` exist.
2. **Given** `setup.ps1`, **When** header lines are inspected, **Then** no references to `ai-tooling\templates` exist.

---

### User Story 3: Consolidated Test Runner and CI Automation (Priority: P1)

As a developer or CI pipeline executing quality checks, I want a single deterministic test runner script (`tests/run_all.sh` or `./scripts/check.sh`) and a GitHub Actions CI workflow, so that all 5 test harnesses run automatically and enforce zero regressions on every branch.

**Why this priority**: Currently tests are run individually. A unified entrypoint and CI pipeline prevents silent regressions in frontmatter, cross-platform compatibility, instructional quality, and style rules.

**Independent Test**:
Execute `./tests/run_all.sh` and verify it executes all 5 test suites, returning exit code 0 on success.

**Acceptance Scenarios**:

1. **Given** `tests/run_all.sh`, **When** executed, **Then** it runs `test_style_sanitization.py`, `test_instructional.py`, `test_cross_platform.py`, `test_frontmatter.py`, and `test_uninstall.sh`.
2. **Given** `.github/workflows/ci.yml`, **When** triggered on push/PR, **Then** it executes the full verification suite.

---

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: `README.md` MUST update the count to "18 skills, 10 agents".
- **FR-002**: `README.md` MUST include a complete reference table for all 18 skills with names, slash commands, argument hints, and descriptions.
- **FR-003**: `README.md` MUST include a reference table for all 10 Claude Code subagents.
- **FR-004**: `setup.sh` and `setup.ps1` MUST remove zombie template generator headers.
- **FR-005**: `tests/run_all.sh` MUST be created and executable, running all 5 test harnesses.
- **FR-006**: `.github/workflows/ci.yml` MUST be created to run the test suite on pull requests and pushes to feature branches.
- **FR-007**: All modified and created files MUST contain zero em dashes (`—` or spaced `" - "`) and remain in English.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Automated test `tests/test_catalog_sync.py` validates `README.md` counts, table completeness (18 skills, 10 agents), and clean setup script headers.
- **SC-002**: `./tests/run_all.sh` runs and passes 100% across all 5 test suites.
- **SC-003**: Zero em dashes across all 18 skills, scripts, and documentation files.
