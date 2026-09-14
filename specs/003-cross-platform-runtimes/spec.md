# Feature Specification: Cross-Platform Portability and Runtime Interoperability

**Feature Branch**: `003-cross-platform-runtimes`

**Created**: 2026-09-13

**Status**: Draft

**Input**: User description: "Portabilidade multiplataforma Windows e interoperabilidade agnostica de runtimes"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Shell-Agnostic Tool Execution in check-dx (Priority: P1)

As a developer running `check-dx` on Windows (PowerShell or CMD) or Linux/macOS, I want lint and format commands free of POSIX-only redirections (`2>/dev/null`), so that command execution does not produce syntax errors or unwanted `null` files on Windows.

**Why this priority**: `2>/dev/null` creates a literal file named `null` in CMD and triggers a syntax error in PowerShell, breaking the core evaluation step of `check-dx`.

**Independent Test**:
Inspect command snippets in `skills/check-dx/SKILL.md` and confirm zero occurrences of `2>/dev/null`. Verify commands are written shell-agnostically with explicit guidance on error redirection.

**Acceptance Scenarios**:

1. **Given** `skills/check-dx/SKILL.md`, **When** the tool execution table is reviewed, **Then** commands do not hardcode `2>/dev/null`.
2. **Given** `skills/check-dx/SKILL.md`, **When** Step 1 error messages are reviewed, **Then** references point to `/check-dx` rather than `/check-dx-rules`.

---

### User Story 2 - Cross-Platform Directory Creation in generate-adr and generate-spec (Priority: P1)

As a user running ADR or spec generation on Windows, I want directory creation instructions to use environment-native file tools instead of hardcoded `mkdir -p` shell commands, so that directory creation succeeds regardless of the active shell.

**Why this priority**: `mkdir -p` fails on Windows CMD and PowerShell without emulation, causing the write step to fail.

**Independent Test**:
Verify `skills/generate-adr/SKILL.md` and `skills/generate-spec/SKILL.md` instruct directory creation using file writing tools or platform-appropriate commands without hardcoding `mkdir -p via Bash`.

**Acceptance Scenarios**:

1. **Given** `skills/generate-adr/SKILL.md`, **When** Step 4 is inspected, **Then** directory creation is expressed tool-agnostically.
2. **Given** `skills/generate-spec/SKILL.md`, **When** Step 4 is inspected, **Then** directory creation is expressed tool-agnostically without hardcoding `via Bash`.

---

### User Story 3 - Multi-Runtime Subagent Execution in fanout-review and check-dx (Priority: P1)

As a developer using Claude Code, GitHub Copilot CLI, or Antigravity / Gemini CLI, I want `fanout-review` and `check-dx` to document subagent execution instructions for concurrent runtimes, with a clear sequential fallback for single-agent runtimes, so that the skills do not break outside Claude Code.

**Why this priority**: Hardcoded Claude-only `Agent` tool calls fail immediately on Copilot CLI and Antigravity, preventing multi-perspective review from running.

**Independent Test**:
Verify `skills/fanout-review/SKILL.md` and `skills/check-dx/SKILL.md` define execution instructions covering Claude Code (`Agent`), Antigravity (`invoke_subagent`), and single-agent runtimes (sequential evaluation).

**Acceptance Scenarios**:

1. **Given** `skills/fanout-review/SKILL.md`, **When** dispatch step is inspected, **Then** it provides runtime-agnostic guidance with sequential fallback.
2. **Given** `skills/check-dx/SKILL.md`, **When** Step 5 is inspected, **Then** it provides runtime-agnostic guidance with sequential fallback.

---

### User Story 4 - Decoupled Agent and Plugin References (Priority: P2)

As a user on a non-Claude or non-plugin runtime, I want skills (`create-unit-tests`, `check-dry`, `smart-fix`) to avoid hardcoded dependencies on proprietary plugins or agent aliases, so that instructions remain actionable across all platforms.

**Why this priority**: Prompts that instruct "Use @test-automator" or cite proprietary plugin namespaces like `superpowers:systematic-debugging` fail when those extensions are not configured.

**Independent Test**:
Scan `skills/create-unit-tests/SKILL.md`, `skills/check-dry/SKILL.md`, and `skills/smart-fix/SKILL.md` to confirm proprietary namespaces and aliases are generalized.

**Acceptance Scenarios**:

1. **Given** `skills/create-unit-tests/SKILL.md`, **When** agent dispatch is read, **Then** it instructs acting as or delegating to the test automation role.
2. **Given** `skills/smart-fix/SKILL.md`, **When** routing table is read, **Then** skill references use generic capability names.

---

### Edge Cases

- **Windows CMD Quote Handling**: `git log --pretty=format:"%h %s"` must use double quotes instead of single quotes to avoid literal quote corruption in CMD.
- **Sequential Context Window**: When evaluating 5 or 6 lenses sequentially in single-agent runtimes, instructions must require concise structured outputs to prevent context exhaustion.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: `skills/check-dx/SKILL.md` MUST remove `2>/dev/null` from tool execution commands and document shell-agnostic stderr handling.
- **FR-002**: `skills/check-dx/SKILL.md` MUST correct the error message reference from `/check-dx-rules` to `/check-dx`.
- **FR-003**: `skills/generate-adr/SKILL.md` MUST express directory creation without hardcoded `mkdir -p` shell commands.
- **FR-004**: `skills/generate-spec/SKILL.md` MUST express directory creation without hardcoded `mkdir -p via Bash`.
- **FR-005**: `skills/fanout-review/SKILL.md` MUST support concurrent runtimes (Claude Code, Antigravity) and define a sequential fallback for single-agent runtimes.
- **FR-006**: `skills/fanout-review/SKILL.md` MUST use double quotes for `git log --pretty=format:"%h %s"`.
- **FR-007**: `skills/create-unit-tests/SKILL.md`, `skills/check-dry/SKILL.md`, and `skills/smart-fix/SKILL.md` MUST decouple proprietary plugin and agent references.
- **FR-008**: All skills and documentation MUST be written in English with zero em dashes.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Automated regex inspection confirms zero occurrences of `2>/dev/null` across all 18 `SKILL.md` files.
- **SC-002**: Automated test suite (`tests/test_cross_platform.py`) validates shell command syntax, double quotes in git log, and absence of proprietary tool blockers.
- **SC-003**: 100% of the 18 skills remain fully compliant with Agent Skills YAML frontmatter validation.
- **SC-004**: Zero occurrences of em dash characters across all modified skill files.

## Assumptions

- Users have git and Node.js / Python installed in their environment.
- Runtimes provide either a file writing tool, subagent capability, or single-agent prompt execution.
