# Feature Specification: Instructional Refactoring and Fragile Command Cleanup

**Feature Branch**: `004-instructional-refactoring`

**Created**: 2026-09-13

**Status**: Draft

**Input**: User description: "Instructional refactoring and cleanup of fragile external commands in takeaways, learn, optimize, and check-tests"

## User Scenarios & Testing *(mandatory)*

### User Story 1: Comprehensive Restructuring of takeaways (Priority: P1)

As a developer or researcher passing a video transcript, article text, or URL, I want `takeaways` to have clear argument definitions (`<url | text>`), actionable transcript handling instructions without magical scraping assumptions, and a deterministic structured output format (Premise, Key Takeaways Comparison, Pros/Cons, and Final Verdict).

**Why this priority**: The original `takeaways` skill is skeletal (22 lines), contradicts its frontmatter arguments, lacks an output template, and fails when attempting magical video/audio scraping without CLI/MCP utilities.

**Independent Test**:
Inspect `skills/takeaways/SKILL.md` to verify it defines `$ARGUMENTS` consistently with `argument-hint: "<url | text>"`, provides explicit fallback to request transcripts if web scraping is unavailable or blocked, and includes a full output template with zero em dashes.

**Acceptance Scenarios**:

1. **Given** `skills/takeaways/SKILL.md`, **When** the arguments section is read, **Then** it references `<url | text>` rather than disconnected individual parameter names.
2. **Given** `skills/takeaways/SKILL.md`, **When** extraction steps are reviewed, **Then** it instructs using web/browser tools if available and explicitly prompts the user for transcript/text if direct extraction is impossible.
3. **Given** `skills/takeaways/SKILL.md`, **When** the output section is reviewed, **Then** a clear markdown template (Verdict, Premise, Key Takeaways, Pros & Cons) is specified.

---

### User Story 2: Operational Agent Persona and Pedagogy in learn (Priority: P1)

As a developer asking for an explanation of a technical concept, I want `learn` written as an operational agent skill with input validation and a multi-level pedagogical structure (ELI5, Technical Mechanics, Real-World Analogy, Code Example, Pitfalls, Best Practices).

**Why this priority**: `learn` is skeletal (34 lines) and written with an inverted persona in the user's first person ("# Help me understand: $ARGUMENTS"), lacking input validation and structured contracts.

**Independent Test**:
Verify `skills/learn/SKILL.md` addresses the agent as an operator, validates `$ARGUMENTS`, stops and prompts when concept is missing, and provides a structured output schema with zero em dashes.

**Acceptance Scenarios**:

1. **Given** `skills/learn/SKILL.md`, **When** input validation is inspected, **Then** missing `$ARGUMENTS` triggers a usage error and stops.
2. **Given** `skills/learn/SKILL.md`, **When** heading and tone are inspected, **Then** first-person phrasing is replaced with declarative agent directives.
3. **Given** `skills/learn/SKILL.md`, **When** output format is inspected, **Then** it defines clear hierarchical sections for explanations.

---

### User Story 3: Scope Harmonization and Report-Only Directives in optimize (Priority: P1)

As a developer auditing performance bottlenecks, I want `optimize` to consistently prompt with a scope menu when arguments are omitted, explicitly enforce a report-only policy, and provide concrete Vue SFC and framework-agnostic frontend performance guidance.

**Why this priority**: `optimize` contains an internal contradiction (prompting with a menu on empty arguments vs scanning the entire codebase), lacks an explicit "Report only" rule, and omits Vue SFC guidance despite mentioning it in description.

**Independent Test**:
Verify `skills/optimize/SKILL.md` harmonizes scope behavior, includes "DO NOT edit files. Report only.", adds Vue SFC and modern reactivity performance criteria, and contains zero em dashes.

**Acceptance Scenarios**:

1. **Given** `skills/optimize/SKILL.md`, **When** empty arguments are passed, **Then** the skill instructions consistently prompt with the numbered scope menu.
2. **Given** `skills/optimize/SKILL.md`, **When** rules are inspected, **Then** it explicitly states "DO NOT implement fixes. DO NOT edit any files. Report only."
3. **Given** `skills/optimize/SKILL.md`, **When** frontend analysis is reviewed, **Then** Vue SFC reactivity (computed vs watch, v-memo) is included alongside React patterns.

---

### User Story 4: Sanitization of Inherited Artifacts in check-tests (Priority: P2)

As a user running test coverage auditing, I want `check-tests` free of inherited boilerplate referencing foreign repository bugs, with clean punctuation and formatting.

**Why this priority**: Text in `check-tests` references "this repo's prior bugs" copied from a previous source project.

**Independent Test**:
Inspect `skills/check-tests/SKILL.md` and verify all references to "this repo's prior bugs" are replaced with general software engineering context, and zero em dashes remain.

**Acceptance Scenarios**:

1. **Given** `skills/check-tests/SKILL.md`, **When** coverage threshold rationale is read, **Then** it references general regression prevention rather than "this repo's prior bugs".
2. **Given** `skills/check-tests/SKILL.md`, **When** text is scanned, **Then** zero em dashes or spaced hyphens exist.

---

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: `skills/takeaways/SKILL.md` MUST unify its arguments documentation with `argument-hint: "<url | text>"` and describe fallback handling when URL scraping/transcription is unavailable.
- **FR-002**: `skills/takeaways/SKILL.md` MUST provide a canonical output template containing Premise/Question, Direct Verdict, Comparison, and Key Points.
- **FR-003**: `skills/learn/SKILL.md` MUST be written as an agent directive, validate `$ARGUMENTS`, and provide structured pedagogical sections.
- **FR-004**: `skills/optimize/SKILL.md` MUST resolve the scope contradiction: empty arguments MUST prompt the user with the scope selection menu.
- **FR-005**: `skills/optimize/SKILL.md` MUST add an explicit rule: "DO NOT implement fixes. DO NOT edit any files. Report only."
- **FR-006**: `skills/optimize/SKILL.md` MUST include Vue SFC and modern framework reactivity analysis in the frontend category.
- **FR-007**: `skills/check-tests/SKILL.md` MUST remove inherited foreign project references ("this repo's prior bugs").
- **FR-008**: All modified skills MUST contain zero em dashes (`—` or spaced `" - "`) and maintain valid YAML frontmatter.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Automated test harness `tests/test_instructional.py` validates all four target skills against the requirements.
- **SC-002**: 100% of the 18 skills pass `tests/test_frontmatter.py`.
- **SC-003**: Zero em dashes across all modified skill files.
- **SC-004**: `tests/test_cross_platform.py` and `tests/test_uninstall.sh` remain 100% passing.
