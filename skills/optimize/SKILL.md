---
name: optimize
description: "Analyze code for performance bottlenecks and recommend optimizations. Args: [branch | backend | frontend | <path>]"
argument-hint: "[branch | backend | frontend | <path>]"
---

<!-- Note: $ARGUMENTS is substituted by Claude commands only. In Copilot,
     the user must include their argument inline in the prompt; the skill
     body sees the literal text "$ARGUMENTS" unsubstituted. -->

## Arguments

`[branch | backend | frontend | <path>]`

- Optional. Picks the analysis scope; the skill prompts with a numbered menu if omitted.
- **Examples**: `/optimize branch`, `/optimize backend`, `/optimize src/services/payments.ts`

> Copilot CLI note: `$ARGUMENTS` doesn't substitute in skills — include the argument inline in your prompt.

# Optimize: $ARGUMENTS

Analyze for performance bottlenecks. **Only flag a finding when the fix meets BOTH of these:**

1. The fix removes a measurable cost — algorithmic complexity drop (e.g., O(n²) → O(n)), one fewer DB/HTTP round-trip per call, one fewer React re-render per interaction, ≥ 5% bundle-size reduction, or eliminated allocation in a hot path.
2. The fix is ≤ 30 lines of code change OR is a one-line config/index change.

Skip:
- Stylistic-only changes (rename, reorder, reformat).
- Micro-optimizations whose impact you cannot estimate.
- "Defensive" caching of values that aren't measured to be hot.
- Anything that adds a new dependency unless the dependency replaces ≥ 100 lines of in-repo code.

## Scope

If `$ARGUMENTS` is empty, **stop and ask the user** which scope to analyze before doing anything else. Present this numbered menu verbatim and wait for a reply:

```
Which scope should I analyze?
  1. branch       — diff between this branch and main/master
  2. backend      — server-side code only (API, DB, services)
  3. frontend     — client-side code only (components, bundles, assets)
  4. <file path>  — a specific file (e.g. src/foo.ts)
  5. <component>  — a component or module name
```

Otherwise interpret `$ARGUMENTS` as:

- **`branch`** — diff between this branch and `main`/`master`
- **`backend`** — server-side code only
- **`frontend`** — client-side code only
- **file path** — analyze that file
- **anything else** — treat as a component or module name and locate it
- **`full` or explicit omission** — full codebase

## Analysis Areas

Apply the categories relevant to the detected scope:

- **Algorithms** — O(n²) or worse, redundant calculations, memory leaks
- **Database** — N+1 queries, missing indexes, query optimization, caching strategies
- **API** — response times, chatty interfaces, pagination, caching headers
- **Frontend** — unnecessary re-renders, missing memoization (`useMemo`/`useCallback`/`React.memo`), large bundle contributions, code-splitting, lazy loading, inefficient state management, expensive computations in render path, unoptimized images
- **Async** — `await` misuse, missing parallelism, memoization opportunities

## Output

For each finding:

- **Severity:** Critical / High / Medium
- **Location:** file:line
- **Current** vs **optimized** code
- **Expected improvement**
- **Complexity:** Easy / Medium / Hard
