# Implementation Plan: Systematic Style Sanitization and Em Dash Removal

**Branch**: `005-style-sanitization` | **Date**: 2026-09-13 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/005-style-sanitization/spec.md`

## Summary

Perform a systematic, whole-catalog elimination of em dashes (`\u2014`) and prose spaced hyphens across the 6 remaining skills that contain them:
1. `skills/create-commit-message/SKILL.md` (2 instances)
2. `skills/framework-upgrade-guide/SKILL.md` (26 instances)
3. `skills/plan-or-execute/SKILL.md` (3 instances)
4. `skills/pr-description/SKILL.md` (8 instances)
5. `skills/ship-it/SKILL.md` (7 instances)
6. `skills/update-claude-md/SKILL.md` (7 instances)

Achieve exactly 0 em dashes and 0 prose spaced hyphens across all 18 skills in `skills/`.

## Technical Context

**Language/Version**: Python 3.10+ (for validation scripts), Markdown (Agent Skills)

**Primary Dependencies**: PyYAML

**Storage**: Local git repository

**Testing**: Automated test suites (`tests/test_style_sanitization.py`, `tests/test_instructional.py`, `tests/test_cross_platform.py`, `tests/test_frontmatter.py`, `tests/test_uninstall.sh`)

**Target Platform**: Cross-platform (Linux, macOS, Windows)

**Constraints**: Strict compliance with Constitution (zero em dashes, English-only, Agent Skills standard)

**Scale/Scope**: 6 skills modified, 1 new automated test harness, reaching 100% em dash eradication catalog-wide

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

1. **Agent Skills Standard**: Preserved across all 18 skills.
2. **Zero Em Dashes**: Catalog-wide enforcement (0 across all 18 skills).
3. **English Only**: Preserved.
4. **Superpowers TDD Mandate**: Red gate test harness created and failing before implementation, green gate verified before completion.

## Project Structure

### Documentation (this feature)

```text
specs/005-style-sanitization/
├── plan.md              # This file
├── spec.md              # Feature specification
└── tasks.md             # Task breakdown
```

### Source Code and Tests

```text
skills/
├── create-commit-message/SKILL.md # 2 em dashes removed
├── framework-upgrade-guide/SKILL.md # 26 em dashes removed
├── plan-or-execute/SKILL.md       # 3 em dashes removed
├── pr-description/SKILL.md        # 8 em dashes removed
├── ship-it/SKILL.md               # 7 em dashes removed
└── update-claude-md/SKILL.md      # 7 em dashes removed

tests/
├── test_style_sanitization.py # New automated validator for whole-catalog em dash eradication
├── test_instructional.py      # Existing instructional tests
├── test_cross_platform.py     # Existing cross-platform tests
├── test_frontmatter.py        # Existing frontmatter validation
└── test_uninstall.sh          # Existing uninstaller validation
```

## Complexity Tracking

No constitution violations.
