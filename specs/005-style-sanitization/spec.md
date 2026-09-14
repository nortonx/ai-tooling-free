# Feature Specification: Systematic Style Sanitization and Em Dash Removal

**Feature Branch**: `005-style-sanitization`

**Created**: 2026-09-13

**Status**: Draft

**Input**: User description: "Systematic em dash removal and style sanitization across remaining skill bodies"

## User Scenarios & Testing *(mandatory)*

### User Story 1: Complete Elimination of Em Dashes Across Skills Catalog (Priority: P1)

As a developer and repository maintainer, I want zero em dashes (`\u2014` or spaced `" - "`) in all 18 skills across the entire catalog, so that the repository strictly complies with the global user style rules and project constitution.

**Why this priority**: The audit detected widespread usage of em dashes across the repository. Previous batches cleaned up 12 skills; the remaining 6 skills (`create-commit-message`, `framework-upgrade-guide`, `plan-or-execute`, `pr-description`, `ship-it`, `update-claude-md`) still contain 53 em dashes that must be surgically sanitized.

**Independent Test**:
Run an automated Python test scanning every `SKILL.md` file in `skills/` to confirm exactly 0 unicode em dashes and 0 prose spaced hyphens.

**Acceptance Scenarios**:

1. **Given** all 18 `SKILL.md` files, **When** scanned for `\u2014`, **Then** 0 occurrences are detected.
2. **Given** all 18 `SKILL.md` files, **When** scanned for prose spaced hyphens, **Then** 0 occurrences are detected.
3. **Given** all 18 `SKILL.md` files, **When** YAML frontmatter is validated, **Then** 100% pass without syntax errors.

---

### User Story 2: Preserved Semantic Meaning and Punctuation Clarity (Priority: P1)

As a user reading skill instructions, I want replaced em dashes to use natural, idiomatic punctuation (colons, semicolons, parentheses, or separate sentences) that preserve the exact technical meaning of each guideline.

**Why this priority**: Mechanical replacement of em dashes with hyphens or awkward commas can degrade instructional readability. Each replacement must be context-sensitive.

**Independent Test**:
Inspect modified files to ensure grammar and formatting flow naturally without broken syntax.

**Acceptance Scenarios**:

1. **Given** Copilot CLI notes, **When** rewritten, **Then** semicolons or commas separate clauses clearly.
2. **Given** definition lists and table cells, **When** rewritten, **Then** colons separate keys from descriptions.

---

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: `skills/create-commit-message/SKILL.md` MUST eliminate all em dashes.
- **FR-002**: `skills/framework-upgrade-guide/SKILL.md` MUST eliminate all em dashes.
- **FR-003**: `skills/plan-or-execute/SKILL.md` MUST eliminate all em dashes.
- **FR-004**: `skills/pr-description/SKILL.md` MUST eliminate all em dashes.
- **FR-005**: `skills/ship-it/SKILL.md` MUST eliminate all em dashes.
- **FR-006**: `skills/update-claude-md/SKILL.md` MUST eliminate all em dashes.
- **FR-007**: All 18 skills MUST maintain 100% compliance with Agent Skills YAML frontmatter validation.
- **FR-008**: All modified files MUST remain in English.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Automated regex inspection across ALL 18 `SKILL.md` files confirms 0 occurrences of `\u2014` and 0 prose spaced hyphens.
- **SC-002**: Automated test suite `tests/test_style_sanitization.py` passes 100%.
- **SC-003**: All previous test suites (`test_instructional.py`, `test_cross_platform.py`, `test_frontmatter.py`, `test_uninstall.sh`) pass 100% with zero regressions.
