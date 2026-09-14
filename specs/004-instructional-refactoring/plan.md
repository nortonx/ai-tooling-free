# Implementation Plan: Instructional Refactoring and Fragile Command Cleanup

**Branch**: `004-instructional-refactoring` | **Date**: 2026-09-13 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/004-instructional-refactoring/spec.md`

## Summary

Execute instructional quality refactoring across four skills:
1. Re-architect `takeaways` into a robust skill with aligned arguments (`<url | text>`), explicit handling for URLs vs. transcripts, and a canonical output format.
2. Refactor `learn` to use a professional agent directive persona, input validation, and structured pedagogical breakdown.
3. Harmonize `optimize` to resolve internal scope contradictions (empty argument requires menu selection), enforce "Report only" rules, expand frontend coverage to Vue SFCs and modern reactivity, and eliminate em dashes.
4. Clean up `check-tests` to remove inherited external project references and eliminate em dashes.

## Technical Context

**Language/Version**: Python 3.10+ (for test suites), Markdown (Agent Skills specification)

**Primary Dependencies**: PyYAML

**Storage**: Local repository markdown skill files

**Testing**: Automated test suites (`tests/test_instructional.py`, `tests/test_cross_platform.py`, `tests/test_frontmatter.py`, `tests/test_uninstall.sh`)

**Target Platform**: Cross-platform (Linux, macOS, Windows)

**Project Type**: Agent skills and CLI automation

**Performance Goals**: Test suite execution completes under 5 seconds

**Constraints**: Strict adherence to Constitution (zero em dashes, English-only content, Agent Skills frontmatter standard)

**Scale/Scope**: 4 skills modified, 1 new automated test suite, zero regressions

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

1. **Agent Skills Standard**: Preserved across all 4 skill files with valid frontmatter.
2. **Zero Em Dashes**: Enforced across all modified skills and artifacts.
3. **English Only**: All skills, comments, tests, and documentation in English.
4. **Superpowers TDD Mandate**: Red gate test harness created and failing before implementation, green gate verified before completion.

## Project Structure

### Documentation (this feature)

```text
specs/004-instructional-refactoring/
├── plan.md              # This file
├── spec.md              # Feature specification
└── tasks.md             # Task breakdown
```

### Source Code and Tests

```text
skills/
├── takeaways/SKILL.md   # Unified argument hint, realistic scraping/transcript flow, output template
├── learn/SKILL.md       # Operational directive, validation, pedagogical sections
├── optimize/SKILL.md    # Scope harmonization, report-only directive, Vue SFC support
└── check-tests/SKILL.md # Sanitized inherited text, zero em dashes

tests/
├── test_instructional.py    # New automated validator for Batch 4
├── test_cross_platform.py   # Existing cross-platform tests
├── test_frontmatter.py      # Existing frontmatter validation
└── test_uninstall.sh        # Existing uninstaller validation
```

**Structure Decision**: Direct edits to targeted skill markdown definitions with automated assertions in `tests/test_instructional.py`.

## Complexity Tracking

No constitution violations.
