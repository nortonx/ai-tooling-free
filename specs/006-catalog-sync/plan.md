# Implementation Plan: Catalog Synchronization, Governance, and Automated Verification

**Branch**: `006-catalog-sync` | **Date**: 2026-09-13 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/006-catalog-sync/spec.md`

## Summary

Complete the remediation backlog by establishing catalog synchronization, governance cleanliness, and automated CI verification:
1. Update `README.md` to reflect the true catalog size (18 skills and 10 agents), embedding full discovery tables with command triggers and concise descriptions.
2. Remove confusing zombie template headers and em dashes in `setup.sh` and `setup.ps1`.
3. Create a master test runner `tests/run_all.sh` and a GitHub Actions workflow `.github/workflows/ci.yml` to ensure perpetual automated validation of all quality gates.

## Technical Context

**Language/Version**: Python 3.10+, Bash, PowerShell, YAML

**Primary Dependencies**: PyYAML

**Storage**: Git repository documentation and configuration files

**Testing**: Unified test runner executing `tests/test_catalog_sync.py`, `tests/test_style_sanitization.py`, `tests/test_instructional.py`, `tests/test_cross_platform.py`, `tests/test_frontmatter.py`, and `tests/test_uninstall.sh`

**Target Platform**: Linux, macOS, Windows

**Constraints**: Strict adherence to Constitution (zero em dashes, English-only, Agent Skills standard)

**Scale/Scope**: `README.md`, `setup.sh`, `setup.ps1`, `tests/run_all.sh`, `.github/workflows/ci.yml`, `tests/test_catalog_sync.py`

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

1. **Agent Skills Standard**: Preserved across all 18 skills.
2. **Zero Em Dashes**: Verified on all modified and newly created files.
3. **English Only**: All documentation and scripts in English.
4. **Superpowers TDD Mandate**: Red gate test harness created and failing before implementation, green gate verified before completion.

## Project Structure

### Documentation (this feature)

```text
specs/006-catalog-sync/
├── plan.md              # This file
├── spec.md              # Feature specification
└── tasks.md             # Task breakdown
```

### Source Code, Workflows, and Tests

```text
README.md                    # 18 skills, 10 agents, catalog tables
setup.sh                     # Zombie header removed, clean comments
setup.ps1                    # Zombie header removed, clean comments
.github/workflows/ci.yml     # Automated CI verification workflow
tests/
├── run_all.sh               # Master test runner
├── test_catalog_sync.py     # New automated validator for Batch 6
├── test_style_sanitization.py
├── test_instructional.py
├── test_cross_platform.py
├── test_frontmatter.py
└── test_uninstall.sh
```

## Complexity Tracking

No constitution violations.
