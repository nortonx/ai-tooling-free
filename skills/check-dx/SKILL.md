---
name: check-dx
description: "Audit enabled eslint / prettier / biome rules and rank keep / tune / drop via Wilson consensus across 5 independent lenses. Args: <eslint | prettier | biome>"
argument-hint: "<eslint | prettier | biome>"
---

<!-- Note: $ARGUMENTS is substituted by Claude commands only. In Copilot,
     the user must include their argument inline in the prompt; the skill
     body sees the literal text "$ARGUMENTS" unsubstituted. -->

## Arguments

`<eslint | prettier | biome>`

- Required. Exactly one tool name. Validation in Step 1 stops the run if missing or invalid.
- **Examples**: `/check-dx eslint`, `/check-dx biome`

> Copilot CLI note: `$ARGUMENTS` doesn't substitute in skills — include the argument inline in your prompt.

# Check DX rules

Audit the enabled rules of a static-analysis / formatting tool in this repo and produce a ranked recommendation of which rules to **keep**, **tune**, or **drop**, based on multi-lens consensus.

**Tool from $ARGUMENTS** — must be exactly one of: `eslint`, `prettier`, `biome`.

## Why Wilson works here

This task ranks *many comparable binary events* (per-rule "keep" votes from independent lenses), which is exactly what the Wilson Score Lower Bound is for. Each rule receives 5 independent yes/no/partial votes from 5 specialist lenses; Wilson lower bound on the keep-proportion ranks rules by confidence in the "keep" recommendation, penalizing rules with thin or split evidence.

## Step 1 — Validate input

If `$ARGUMENTS` is empty, missing, or not one of `eslint` | `prettier` | `biome`, output:

> Usage: `/check-dx-rules [eslint | prettier | biome]`
> Pass exactly one tool name.

Then stop.

## Step 2 — Discover config

| Tool | Config locations (first match wins) |
|---|---|
| eslint | `.eslintrc`, `.eslintrc.json`, `.eslintrc.js`, `.eslintrc.cjs`, `.eslintrc.yaml`, `.eslintrc.yml`, `eslint.config.js`, `eslint.config.mjs`, `eslint.config.cjs`, `eslint.config.ts`, or `eslintConfig` key in `package.json` |
| prettier | `.prettierrc`, `.prettierrc.json`, `.prettierrc.js`, `.prettierrc.cjs`, `.prettierrc.yaml`, `.prettierrc.yml`, `prettier.config.js`, `prettier.config.cjs`, or `prettier` key in `package.json` |
| biome | `biome.json`, `biome.jsonc` |

If no config exists, stop with:
> No <tool> config found in this repo.

## Step 3 — Run the tool (if installed)

Run the tool to collect real firing data. If the binary is not installed locally or globally, fall back to **config-only analysis** and note that limitation in the final output.

| Tool | Command |
|---|---|
| eslint | `npx eslint . --format json --no-error-on-unmatched-pattern 2>/dev/null` |
| prettier | `npx prettier --list-different . 2>/dev/null` *(prettier rules are options, not granular rules — evaluate each option set in config)* |
| biome | `npx @biomejs/biome lint . --reporter=json 2>/dev/null` *(if biome's linter is disabled, this returns zero firings — that is expected; the formatter-options path still produces evaluable items in Step 4)* |

For eslint and biome: parse violations to build a map `rule_id → { count, sample_locations[], severity }`. Cap sample locations at 5 per rule. For biome formatter-only setups, skip this step's biome row and rely on config-only analysis (matching the prettier code path).

## Step 4 — Enumerate evaluable items

| Tool | Items |
|---|---|
| eslint | Each rule with `error` or `warn` severity (skip `off` / `0`) |
| biome | Each enabled rule under `linter.rules` (when `linter.enabled !== false`) **and** each non-default option under `formatter` and language-specific `<language>.formatter` blocks (when `formatter.enabled !== false`, e.g., `formatter.indentStyle`, `formatter.indentWidth`, `formatter.lineWidth`, `javascript.formatter.quoteStyle`, `json.formatter.trailingCommas`). If both linter and formatter are enabled, evaluate both. If neither is enabled, stop with: `Biome config exists but neither linter nor formatter is enabled — nothing to evaluate.` |
| prettier | Each non-default option set in config (e.g., `printWidth`, `singleQuote`, `trailingComma`, `semi`, `tabWidth`, `bracketSpacing`, `arrowParens`) |

If there are **fewer than 10 evaluable items**, proceed but note in the final summary that Wilson rankings are noisier than usual at small N.

## Step 5 — Dispatch 5 evaluations in parallel per item

Use the Agent tool with `subagent_type: general-purpose`. For each item, send **5 evaluations in a single message with 5 tool calls** so they run concurrently. Each evaluation receives:

- The rule/option ID + its current setting
- A sample of firing locations (or "no firings observed in this codebase") if the tool was run
- One of the five evaluation prompts below
- The return contract (JSON, below)

**Evaluation prompts** — each subagent receives exactly one of these as its task:

| Name | Task description sent to the subagent |
|---|---|
| **correctness** | Decide whether this rule catches real bugs (type errors, dead code, unreachable paths, unhandled rejections, use-after-free patterns) or is pure style preference. Vote `keep` if it catches real bugs, `drop` if pure style, `tune` if mixed. |
| **noise** | Estimate the false-positive rate. Inspect sample firings — are they actionable issues or things devs would commonly suppress (`// eslint-disable-next-line`, `// biome-ignore`, etc.)? Vote `keep` if firings are actionable, `tune` if it needs option adjustment, `drop` if mostly noise. |
| **autofixable** | Decide whether this rule is auto-fixable. Auto-fixable rules have near-zero human cost regardless of strictness (just run `--fix`). Vote `keep` if auto-fixable AND non-controversial; otherwise weight the human fix-cost against the benefit before voting. |
| **team-fit** | Decide whether the rule aligns with the project's existing code patterns. If the rule fires hundreds of times on existing code, the team has implicitly rejected it — vote `tune` or `drop`. If it fires rarely on existing code (clean pattern adherence), vote `keep`. |
| **maintenance** | Decide whether this rule is deprecated, recently flagged for removal, or known to churn between major versions of the tool. Vote `drop` if deprecated or unstable; `keep` if stable and broadly recommended; `tune` if the recommended settings have changed recently. |

Each lens MUST return a JSON object, no surrounding prose:

```json
{
  "rule_id": "no-unused-vars",
  "vote": "keep | tune | drop",
  "rationale": "one-line explanation (max 120 chars)",
  "tune_suggestion": "if vote=tune, the suggested adjustment; else null"
}
```

## Step 6 — Compute Wilson lower bound per rule

**Per-item dispatch checkpoint (run before any Wilson math):**

For each evaluable item, confirm all 5 evaluations returned a JSON object before computing the score. If fewer than 5 returned for an item:

- If 3 or 4 returned, compute Wilson on `n = <returned>` instead of 5 and append `(partial: <n>/5)` to that item's row in Step 7's output.
- If 0, 1, or 2 returned, do not score the item — list it in a `## Items dropped` section at the end of the output with the count returned and the reason (timeout, invalid JSON, no response).

Do not silently treat a missing evaluation as a `drop` vote.

Then for each scored item, collect the available votes:

- `votes_to_keep = (count of "keep") + 0.5 * (count of "tune")`
- `p = votes_to_keep / n`  (n is the number of returned votes, normally 5)
- Compute Wilson lower bound (n=5, z=1.96):

  ```
  wilson_lower = (p + 0.384 − 1.96·√(p(1−p)/5 + 0.0768)) / 1.768
  ```

  Reference values (compute mentally):

  | votes_to_keep | p | wilson_lower |
  |---|---|---|
  | 5.0 (5×keep) | 1.0 | ≈ 0.566 |
  | 4.5 (4×keep, 1×tune) | 0.9 | ≈ 0.464 |
  | 4.0 (4×keep, 1×drop) | 0.8 | ≈ 0.376 |
  | 3.5 (3×keep, 1×tune, 1×drop) | 0.7 | ≈ 0.299 |
  | 3.0 (3×keep, 2×drop) | 0.6 | ≈ 0.231 |
  | 2.5 (2×keep, 1×tune, 2×drop) | 0.5 | ≈ 0.187 |
  | 2.0 (2×keep, 3×drop) | 0.4 | ≈ 0.118 |
  | 1.0 (1×keep, 4×drop) | 0.2 | ≈ 0.036 |
  | 0.0 (5×drop) | 0.0 | ≈ 0.000 |

## Step 7 — Bucket and output

Split rules into 3 buckets by Wilson lower bound:

| Bucket | Wilson range |
|---|---|
| **Keep (high consensus)** | ≥ 0.30 |
| **Tune (mixed signals)** | 0.10 – 0.30 |
| **Drop (low value)** | < 0.10 |

Output in this exact format, nothing before or after:

```markdown
# DX-rule evaluation: <tool>

Config discovered: <path>
Firings analyzed: <N> (or: "config-only — <tool> not installed locally")
  — For biome: indicate which mode(s) were evaluated, e.g.,
    "Firings analyzed: 47 (linter rules) + 6 formatter options evaluated config-only"

## Recommended: keep (high consensus)

| Rule | Current setting | Wilson | Rationale |
|---|---|---|---|
| `rule-id-1` | `error` | 0.566 | <short merged rationale across keeping lenses> |

## Candidates to tune

| Rule | Current setting | Wilson | Suggested adjustment |
|---|---|---|---|
| `rule-id-2` | `error` | 0.187 | <suggested tune, e.g., "downgrade to warn", "set option X=Y"> |

## Candidates to drop

| Rule | Current setting | Wilson | Why drop |
|---|---|---|---|
| `rule-id-3` | `warn` | 0.036 | <merged rationale from drop-voting lenses> |

## Summary

- Rules evaluated: N
- High-consensus keep: X
- Tune candidates: Y
- Drop candidates: Z
- Items dropped (fewer than 3 evaluations returned): D — see `## Items dropped` below if non-zero.
- Items scored on partial votes (3 or 4 of 5): P
- (Optional) Note about small sample: "Fewer than 10 rules evaluated — Wilson rankings are noisier at small N."
- (Optional) Note about config-only mode if tool wasn't installed.
- (Optional, biome) Note which sides were evaluated: "Linter disabled — formatter options only," or "Both linter rules and formatter options evaluated."

## Items dropped

(Omit this section entirely if D = 0.)

| Item | Evaluations returned | Reason |
|---|---|---|
| `rule-id` | <n>/5 | <timeout | invalid JSON | no response> |
```

## Rules

- **DO NOT modify the config file.** Output is recommendations only.
- For each "drop" recommendation, the rationale column must capture WHY the drop-voting lenses voted drop (so the user can verify before acting).
- For each "tune" recommendation, the suggested adjustment column must be concrete (an option name + new value, not vague advice).
- If the tool isn't installed and the fallback config-only analysis runs, every Wilson score is necessarily less reliable — say so explicitly in the summary.
- Sort each bucket by Wilson DESC.
