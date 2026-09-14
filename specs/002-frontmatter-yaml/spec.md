# Feature Specification: YAML Frontmatter and Agent Skills Standard Compliance

**Feature Branch**: `002-frontmatter-yaml`

**Created**: 2026-09-13

**Status**: Draft

**Input**: User description: "Correcoes de frontmatter YAML e conformidade Agent Skills"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Scalar Typing for Argument Hint in ship-it (Priority: P1)

As a developer using Agent Skills CLI (`npx skills add`) or AI terminal agents, I want `skills/ship-it/SKILL.md` to declare its `argument-hint` as a quoted scalar string instead of an unquoted YAML sequence, so that schema validators parse it correctly without type errors.

**Why this priority**: Unquoted brackets `[foo]` parse as a list `["foo"]` in standard YAML parsers, violating the Agent Skills scalar string requirement.

**Independent Test**:
Parse `skills/ship-it/SKILL.md` YAML frontmatter with a standard YAML parser (e.g. Python `yaml.safe_load`) and verify that `type(data['argument-hint']) == str`.

**Acceptance Scenarios**:

1. **Given** `skills/ship-it/SKILL.md`, **When** the frontmatter is parsed as YAML, **Then** `argument-hint` is a string scalar and matches `"[<branch-name-or-card>]"`.
2. **Given** `skills/ship-it/SKILL.md`, **When** the description is read, **Then** it contains no em dashes (Unicode U+2014 or spaced hyphens).

---

### User Story 2 - Complete Arguments Metadata in takeaways (Priority: P1)

As an agent runtime and user requesting video/content takeaways, I want `skills/takeaways/SKILL.md` to provide `argument-hint: "<url | text>"` and an `Args: <url | text>` trailer in its description, so that parameter discovery and auto-completion function reliably.

**Why this priority**: Without `argument-hint` and description arg notes, coding agents cannot anticipate required inputs before invoking the skill.

**Independent Test**:
Parse `skills/takeaways/SKILL.md` frontmatter and assert `argument-hint` exists with value `"<url | text>"` and `description` ends with `Args: <url | text>`.

**Acceptance Scenarios**:

1. **Given** `skills/takeaways/SKILL.md`, **When** frontmatter is inspected, **Then** `argument-hint` is present as `"<url | text>"`.
2. **Given** `skills/takeaways/SKILL.md`, **When** description is inspected, **Then** it documents arguments using the conventional `Args: <url | text>` format.

---

### User Story 3 - Robust String Quoting and Delimitation in fanout-review (Priority: P1)

As a maintainer of the skills catalog, I want `skills/fanout-review/SKILL.md` to wrap its `description` in double quotes and eliminate unescaped em dashes, ensuring syntactic robustness across diverse YAML parsers.

**Why this priority**: Complex multi-clause strings without quotes risk parsing anomalies when modified or interpreted by strict YAML engines.

**Independent Test**:
Validate that `skills/fanout-review/SKILL.md` frontmatter has a double-quoted description string and zero occurrences of Unicode U+2014.

**Acceptance Scenarios**:

1. **Given** `skills/fanout-review/SKILL.md`, **When** the frontmatter is scanned, **Then** `description` is enclosed in double quotes.
2. **Given** `skills/fanout-review/SKILL.md`, **When** checked for em dashes, **Then** zero occurrences of U+2014 are found.

---

### User Story 4 - Token Optimization for framework-upgrade-guide (Priority: P1)

As an AI assistant loading skills into system prompt context, I want the description of `skills/framework-upgrade-guide/SKILL.md` trimmed from 566 characters down to under 200 characters while preserving all key framework triggers (Angular, React, Vue, TypeScript, Node), so that token consumption and latency are minimized.

**Why this priority**: Descriptions are injected into agent system prompts on every turn. A 566-character description is nearly 5 times the median length of the catalog.

**Independent Test**:
Measure character length of `description` in `skills/framework-upgrade-guide/SKILL.md` and ensure length is under 220 characters with all framework names retained.

**Acceptance Scenarios**:

1. **Given** `skills/framework-upgrade-guide/SKILL.md`, **When** character count is checked, **Then** length is under 220 characters.
2. **Given** the new description, **When** searched for keywords, **Then** `Angular`, `React`, `Vue`, `TypeScript`, and `Node` are present.

---

### User Story 5 - Frontmatter Style Hygiene Across Catalog (Priority: P2)

As a contributor, I want all frontmatter descriptions across the skills catalog (specifically `create-commit-message` and `fix-security-audit`) free of em dashes (Unicode U+2014 or spaced hyphens), ensuring strict compliance with global repository style rules.

**Why this priority**: Eliminates style debt and ensures clean character encoding on all terminals.

**Independent Test**:
Run regex search for `\u2014` and spaced hyphens across all `SKILL.md` frontmatters and confirm zero matches.

**Acceptance Scenarios**:

1. **Given** any `SKILL.md` file in `skills/`, **When** frontmatter is checked, **Then** zero em dashes are present.

---

### Edge Cases

- **Strict YAML Parsers**: Python `yaml.safe_load`, Node.js `js-yaml`, and Ruby YAML must all parse the frontmatters with identical scalar string types.
- **Single Quotes vs Double Quotes**: Double quotes must properly escape internal double quotes if present.
- **Existing Triggers Preservation**: Shortening descriptions must not remove activation keywords used by LLMs to select the skill.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: `skills/ship-it/SKILL.md` MUST define `argument-hint` as scalar string `"[<branch-name-or-card>]"`.
- **FR-002**: `skills/takeaways/SKILL.md` MUST define `argument-hint: "<url | text>"` and include `Args: <url | text>` in its description.
- **FR-003**: `skills/fanout-review/SKILL.md` MUST enclose its `description` in double quotes and eliminate em dashes.
- **FR-004**: `skills/framework-upgrade-guide/SKILL.md` MUST condense its `description` to under 220 characters while retaining Angular, React, Vue, TypeScript, and Node keywords.
- **FR-005**: All frontmatter descriptions in `skills/*/SKILL.md` MUST be free of em dash characters (Unicode U+2014 or spaced hyphens).
- **FR-006**: All skills frontmatters and documentation MUST be written in English.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of the 18 skills in `skills/` pass automated YAML frontmatter validation verifying scalar string types for `name`, `description`, and `argument-hint` (when present).
- **SC-002**: Automated test suite (`tests/test_frontmatter.py` or `tests/test_frontmatter.sh`) passes with 0 errors across all 18 skills.
- **SC-003**: Description length in `framework-upgrade-guide` reduced by at least 60% (from 566 to <220 characters).
- **SC-004**: Zero occurrences of Unicode U+2014 in any frontmatter across the entire `skills/` directory.

## Assumptions

- All skills conform to the Agent Skills open standard schema.
- Frontmatter is delimited by `---` on the first line and closing `---`.
- Automated test harness can use Python 3 `yaml` module or node/bash parsers available on the system.
