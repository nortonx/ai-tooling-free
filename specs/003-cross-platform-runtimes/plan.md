# Implementation Plan: Cross-Platform Portability and Runtime Interoperability

**Branch**: `003-cross-platform-runtimes` | **Date**: 2026-09-13 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/003-cross-platform-runtimes/spec.md`

## Summary

Remediate cross-platform portability and runtime interoperability defects across the `ai-tooling-free` skills catalog. Eliminate POSIX-only syntax (`2>/dev/null`, single quotes in git commands, `mkdir -p via Bash`) to support Windows (CMD, PowerShell) natively, make subagent execution instructions runtime-agnostic across Claude Code (`Agent`), Antigravity (`invoke_subagent`), and single-agent runtimes (sequential execution fallback), and decouple proprietary plugin or agent namespaces (`superpowers:*`, `feature-dev:*`, `@test-automator`).

## Technical Context

**Language/Version**: Python 3.10+ (for validation test harnesses), Markdown (Agent Skills specification)

**Primary Dependencies**: PyYAML (for frontmatter validation)

**Storage**: Local git repository file system

**Testing**: Python test suites (`tests/test_cross_platform.py`, `tests/test_frontmatter.py`) and shell test harness (`tests/test_uninstall.sh`)

**Target Platform**: Cross-platform (Linux, macOS, Windows CMD / PowerShell / WSL2)

**Project Type**: Agent skills and CLI automation repository

**Performance Goals**: Test suite execution completes in under 5 seconds

**Constraints**: Strict compliance with Constitution (zero em dashes, English-only documentation and code comments, strict YAML frontmatter)

**Scale/Scope**: 7 skill files modified, 1 new automated test harness, 0 regressions in existing tests

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

1. **Agent Skills Standard**: All modified files preserve valid YAML frontmatter compliant with Agent Skills specification.
2. **Zero Em Dashes**: No em dash characters (`—` or spaced `" - "`) permitted in any output or file.
3. **English Only**: All skills, documentation, comments, and commit messages in English.
4. **Superpowers TDD Mandate**: Red gate test harness created and failing before implementation, green gate verified before completion.

## Project Structure

### Documentation (this feature)

```text
specs/003-cross-platform-runtimes/
├── plan.md              # This file
├── spec.md              # Feature specification
└── tasks.md             # Task breakdown
```

### Source Code and Tests

```text
skills/
├── check-dx/SKILL.md          # Remove 2>/dev/null, fix /check-dx typo, add multi-runtime subagent guidance
├── generate-adr/SKILL.md      # Tool-agnostic directory creation
├── generate-spec/SKILL.md     # Tool-agnostic directory creation
├── fanout-review/SKILL.md     # Double quotes in git log format, multi-runtime subagent guidance
├── create-unit-tests/SKILL.md # Generalize @test-automator
├── check-dry/SKILL.md         # Decouple /feature-dev
└── smart-fix/SKILL.md         # Decouple superpowers:* and feature-dev:* namespaces

tests/
├── test_cross_platform.py     # New automated validator for cross-platform and multi-runtime compliance
├── test_frontmatter.py        # Existing frontmatter validation
└── test_uninstall.sh          # Existing uninstaller validation
```

**Structure Decision**: In-place edits to existing skill markdown definitions with targeted automated verification script under `tests/`.

## Complexity Tracking

No constitution violations.
