# Implementation Plan: YAML Frontmatter and Agent Skills Standard Compliance

**Branch**: `002-frontmatter-yaml` | **Date**: 2026-09-13 | **Spec**: [spec.md](file:///home/norton/workspace/projects/ai-tooling-free/specs/002-frontmatter-yaml/spec.md)

**Input**: Feature specification from `specs/002-frontmatter-yaml/spec.md`

## Summary

Correct YAML frontmatter syntax, field types, and descriptions across skills in `skills/` to achieve 100% compliance with the Agent Skills open standard (`npx skills`). Specifically: fix scalar typing of `argument-hint` in `ship-it`, add missing argument discovery metadata to `takeaways`, wrap multi-clause description in quotes in `fanout-review`, trim hypertrophic description in `framework-upgrade-guide` to reduce prompt token bloat, and eliminate all em dashes from all skill frontmatters. Implement an automated validation test harness (`tests/test_frontmatter.py`) to verify all 18 skills.

## Technical Context

**Language/Version**: Python 3.10+ (for YAML test validation) / Node.js or POSIX bash  
**Primary Dependencies**: PyYAML / standard library  
**Storage**: Skill markdown files (`skills/*/SKILL.md`)  
**Testing**: Automated test harness (`tests/test_frontmatter.py`) validating YAML parsing, types, character limits, and em dash absence  
**Target Platform**: Universal across AI agent runtimes (Claude Code, GitHub Copilot CLI, Antigravity, Gemini CLI)  
**Project Type**: Agent Skills catalog configuration  
**Constraints**: Zero em dashes (Unicode U+2014 or spaced hyphens); all skills and docs in English; no breaking changes to skill execution logic

## Constitution Check

- **I. Agent Skills Standard and Portability**: Pass. Directly achieves strict conformance with the standard schema.
- **II. Operational Safety**: Pass. Only touches metadata in `SKILL.md` frontmatter, zero runtime script risks.
- **III. Simplicity (YAGNI)**: Pass. Minimal changes directly targeting audited discrepancies.
- **IV. Superpowers Handoff**: Pass. Executed via TDD (automated test harness written first to catch failures).

## Project Structure

### Documentation (this feature)

```text
specs/002-frontmatter-yaml/
├── spec.md              # Functional specification
├── plan.md              # Technical implementation plan
└── tasks.md             # Ordered tasks for Superpowers execution
```

### Source Code and Tests

```text
skills/
├── ship-it/SKILL.md                    # Fix argument-hint scalar typing and em dash
├── takeaways/SKILL.md                  # Add argument-hint and Args trailer
├── fanout-review/SKILL.md              # Quote description string and remove em dash
├── framework-upgrade-guide/SKILL.md    # Condense description (<220 chars) and remove em dash
├── create-commit-message/SKILL.md      # Remove em dash from description
└── fix-security-audit/SKILL.md         # Remove em dash from description
tests/
└── test_frontmatter.py                 # Automated test suite validating all 18 skills
```

## Technical Decisions and Changes

### 1. `skills/ship-it/SKILL.md`
- Target: `argument-hint: [branch-name-or-issue-id]`
- Fix: `argument-hint: "[<branch-name-or-card>]"`
- Target in `description`: `asks to branch-commit-push — it reminds you`
- Fix: `asks to branch-commit-push, it reminds you`

### 2. `skills/takeaways/SKILL.md`
- Target: Missing `argument-hint` and arguments hint in description.
- Fix:
  - Add `argument-hint: "<url | text>"`
  - Update `description`: `"Extract conclusions and key takeaways from YouTube videos, Instagram Reels/posts, or long-form content, providing a fast comparison and a clear final verdict that directly answers the question or premise in the video's title. Args: <url | text>"`

### 3. `skills/fanout-review/SKILL.md`
- Target: Unquoted description with em dash.
- Fix: Enclose description in double quotes and replace `—` with `, `.

### 4. `skills/framework-upgrade-guide/SKILL.md`
- Target: 566-character description with em dash.
- Fix: Condense to:
  `"Stepwise major-by-major upgrade guide for TypeScript and Node projects (Angular, React, Vue), analyzing dependencies, deprecations, and EOL packages. Args: [<path-to-repo-or-package.json>]"`
  (Length: 181 characters, retains all key triggers).

### 5. `skills/create-commit-message/SKILL.md` and `skills/fix-security-audit/SKILL.md`
- Target: Em dashes in descriptions.
- Fix: Replace em dashes with commas or colons.

### 6. Automated Frontmatter Test Harness (`tests/test_frontmatter.py`)
- Iterates over all directories in `skills/`.
- Extracts YAML frontmatter between `---` delimiters.
- Parses with `yaml.safe_load()`.
- Asserts:
  1. `name` is present, matches directory name, is a string in kebab-case.
  2. `description` is present, is a non-empty string, length < 300 characters, zero em dashes.
  3. `argument-hint` (if present) is a scalar string (`isinstance(v, str)`).
  4. Delimiters are valid.

**Structure Decision**: In-place edits to existing `skills/*/SKILL.md` frontmatters. Automated validator added to `tests/test_frontmatter.py`. No complexity violations.
