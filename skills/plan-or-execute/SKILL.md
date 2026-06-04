---
name: plan-or-execute
description: "Decide whether to enter plan mode or execute directly for a given task. Args: <task description>"
argument-hint: "<task description>"
---

<!-- Note: $ARGUMENTS is substituted by Claude commands only. In Copilot,
     the user must include their argument inline in the prompt; the skill
     body sees the literal text "$ARGUMENTS" unsubstituted. -->

## Arguments

`<task description>`

- Required. A free-text description of the task you're considering — drives the PLAN vs DIRECT recommendation.
- **Examples**: `/plan-or-execute add a debounce to the search input`, `/plan-or-execute migrate auth middleware to JWT`

> Copilot CLI note: `$ARGUMENTS` doesn't substitute in skills — include the argument inline in your prompt.

# Plan or Execute: $ARGUMENTS

Assess whether the task described by `$ARGUMENTS` needs **plan mode** (codebase exploration + design before changes) or **direct execution** (just do it).

Do **not** enter plan mode yourself. Just recommend.

## Decision criteria

**PLAN** when **any** is true:

- Change will touch 3+ files
- Architectural implication (new pattern, module boundary shift, data-flow change)
- Multiple valid approaches with non-obvious trade-offs
- Scope is unclear — the request implies "research before deciding"
- Migration, restructuring, or library swap

**DIRECT** when **all** are true:

- Single-file or tightly-scoped change
- Clear acceptance criteria
- An established pattern in the codebase to copy
- Low blast radius if wrong

## Output

1. **Decision**: `PLAN` or `DIRECT`
2. **Why**: one sentence naming the criterion that decided it
3. **Next step**:
   - If `PLAN`: what to explore first (file patterns, entry points, existing patterns to mirror)
   - If `DIRECT`: the 1–3 concrete edits to make
