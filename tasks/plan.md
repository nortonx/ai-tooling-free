# Implementation Plan: Skills Analysis and Optimization

## Overview
A comprehensive analysis of all 17 skills in the `ai-tooling-free` repository to evaluate which ones are candidates for improvement, which ones should be retired (dropped), and how to optimize the remaining skills for cross-platform and cross-LLM utility.

## Architecture Decisions
- **Evaluation Rubric**: We will evaluate each skill against four main criteria: redundancy (overlap with LLM-native commands), overlap (duplication with other skills), actionability (clarity and detail of instructions), and cross-platform compatibility (such as handling limitations of the Copilot CLI).
- **Em Dash Elimination**: In accordance with user rules, we will scan and document all occurrences of em dashes (`—` or spaced ` - ` connectors) inside the skill files. These can trigger unwanted AI generation patterns.
- **Reporting Format**: Findings will be structured clearly using tables, categorizing each skill as Keep, Improve, or Drop, alongside clear rationale.

## Task List

### Phase 1: Scan and Categorize
- [ ] Task 1: Read and map all 17 skills to functional categories (such as Git workflow, documentation, testing, analysis).

### Checkpoint: Scan and Categorize
- [ ] All 17 skills are mapped and their functional profiles are documented.

### Phase 2: Evaluate and Analyze
- [ ] Task 2: Run a detailed assessment to identify skills that have redundant logic, overlap with other skills, or contain obsolete patterns.
- [ ] Task 3: Identify specific improvements for retained skills (such as prompt formatting, fixing arguments support, and removing em dashes).

### Checkpoint: Evaluate and Analyze
- [ ] Draft evaluations for all 17 skills are complete.

### Phase 3: Final Analysis Report
- [ ] Task 4: Synthesize findings into a final report detailing which skills can be improved, which ones can be dropped, and the specific reasons for each.

### Checkpoint: Complete
- [ ] Full analysis report is completed.
- [ ] Ready for user review.

## Risks and Mitigations
| Risk | Impact | Mitigation |
|------|--------|------------|
| Analyzing skills out of context of their usage | Medium | Cross-reference skills with how the user (and agents) typically interact with them in standard workflows. |
| Suggesting to drop a skill that is still useful for some CLI clients | High | Provide a clear justification for any suggested drop, considering both Claude Code and Copilot CLI differences. |

## Open Questions
- Are there any specific new skills the user wants to introduce, or should we focus exclusively on cleanup and optimization of the existing 17 skills?
