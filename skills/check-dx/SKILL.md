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

> Copilot CLI note: `$ARGUMENTS` doesn't substitute in skills - include the argument inline in your prompt.

# Check DX rules

Audit the enabled rules of a static-analysis / formatting tool in this repo and produce a ranked recommendation of which rules to **keep**, **tune**, or **drop**, based on multi-lens consensus.

**Tool from $ARGUMENTS** - must be exactly one of: `eslint`, `prettier`, `biome`.

## Why Wilson works here

This task ranks many comparable binary events (per-rule "keep" votes from independent lenses), which is exactly what the Wilson Score Lower Bound is for. Each rule receives 5 independent yes/no/partial votes from 5 specialist lenses. The Wilson lower bound on the keep-proportion ranks rules by confidence in the "keep" recommendation, penalizing rules with thin or split evidence.

## Step 1 - Validate input

If `$ARGUMENTS` is empty, missing, or not one of `eslint` | `prettier` | `biome`, output:

> Usage: `/check-dx [eslint | prettier | biome]`
> Pass exactly one tool name.

Then stop.

## Step 2 - Discover config

| Tool | Config locations (first match wins) |
|---|---|
| eslint | `.eslintrc`, `.eslintrc.json`, `.eslintrc.js`, `.eslintrc.cjs`, `.eslintrc.yaml`, `.eslintrc.yml`, `eslint.config.js`, `eslint.config.mjs`, `eslint.config.cjs`, `eslint.config.ts`, or `eslintConfig` key in `package.json` |
| prettier | `.prettierrc`, `.prettierrc.json`, `.prettierrc.js`, `.prettierrc.cjs`, `.prettierrc.yaml`, `.prettierrc.yml`, `prettier.config.js`, `prettier.config.cjs`, or `prettier` key in `package.json` |
| biome | `biome.json`, `biome.jsonc` |

If no config exists, stop with:
> No <tool> config found in this repo.

## Step 3 - Run the tool (if installed)

Run the tool to collect real firing data. If the binary is not installed locally or globally, fall back to **config-only analysis** and note that limitation in the final output.

| Tool | Command |
|---|---|
| eslint | `npx eslint . --format json --no-error-on-unmatched-pattern 2>/dev/null` |
| prettier | `npx prettier --list-different . 2>/dev/null` (prettier rules are options, not granular rules - evaluate each option set in config) |
| biome | `npx @biomejs/biome lint . --reporter=json 2>/dev/null` (if biome's linter is disabled, this returns zero firings - that is expected; the formatter-options path still produces evaluable items in Step 4) |

For eslint and biome: parse violations to build a map `rule_id -> { count, sample_locations[], severity }`. Cap sample locations at 5 per rule. For biome formatter-only setups, skip this step's biome row and rely on config-only analysis (matching the prettier code path).

## Step 4 - Enumerate evaluable items

| Tool | Items |
|---|---|
| eslint | Each rule with `error` or `warn` severity (skip `off` / `0`) |
| biome | Each enabled rule under `linter.rules` (when `linter.enabled !== false`) **and** each non-default option under `formatter` and language-specific `<language>.formatter` blocks (when `formatter.enabled !== false`, e.g., `formatter.indentStyle`, `formatter.indentWidth`, `formatter.lineWidth`, `javascript.formatter.quoteStyle`, `json.formatter.trailingCommas`). If both linter and formatter are enabled, evaluate both. If neither is enabled, stop with: `Biome config exists but neither linter nor formatter is enabled - nothing to evaluate.` |
| prettier | Each non-default option set in config (e.g., `printWidth`, `singleQuote`, `trailingComma`, `semi`, `tabWidth`, `bracketSpacing`, `arrowParens`) |

If there are **fewer than 10 evaluable items**, proceed but note in the final summary that Wilson rankings are noisier than usual at small N.

## Step 5 - Direct multi-lens evaluation

Instead of dispatching parallel subagents, evaluate each item directly within your context across 5 specialist lenses:

1. **correctness** - Does this rule catch real bugs (type errors, dead code, unreachable paths, unhandled rejections, use-after-free patterns) or is it pure style preference? Vote `keep` if it catches bugs, `drop` if pure style, `tune` if mixed.
2. **noise** - Estimate false-positive rate. Inspect sample firings. Are they actionable issues or things devs commonly suppress with comments? Vote `keep` if actionable, `tune` if it needs options tuned, `drop` if mostly noise.
3. **autofixable** - Is the rule auto-fixable? Auto-fixable rules have near-zero human cost (just run with fix flag). Vote `keep` if auto-fixable and non-controversial; otherwise weight human fix-cost against benefit.
4. **team-fit** - Does it align with existing code patterns? If a rule fires hundreds of times on existing code, the team has implicitly rejected it (vote `tune` or `drop`). If it fires rarely (clean adherence), vote `keep`.
5. **maintenance** - Is the rule deprecated, scheduled for removal, or known to churn between major versions? Vote `drop` if deprecated or unstable; `keep` if stable and broadly recommended; `tune` if recommendations have changed recently.

For each rule, aggregate the votes from the 5 lenses:
- `votes_to_keep = (count of "keep") + 0.5 * (count of "tune")`
- `p = votes_to_keep / 5`
- Compute Wilson lower bound (n=5, z=1.96):
  
  ```
  wilson_lower = (p + 0.384 - 1.96 * sqrt(p * (1 - p) / 5 + 0.0768)) / 1.768
  ```

  Use these pre-calculated reference values:
  
  - 5 keeps (p=1.0) -> `0.566`
  - 4 keeps, 1 tune (p=0.9) -> `0.464`
  - 4 keeps, 1 drop (p=0.8) -> `0.376`
  - 3 keeps, 1 tune, 1 drop (p=0.7) -> `0.299`
  - 3 keeps, 2 drops (p=0.6) -> `0.231`
  - 2 keeps, 1 tune, 2 drops (p=0.5) -> `0.187`
  - 2 keeps, 3 drops (p=0.4) -> `0.118`
  - 1 keep, 4 drops (p=0.2) -> `0.036`
  - 5 drops (p=0.0) -> `0.000`

## Step 6 - Bucket and output

Split rules into 3 buckets by Wilson lower bound:

| Bucket | Wilson range |
|---|---|
| **Keep (high consensus)** | >= 0.30 |
| **Tune (mixed signals)** | 0.10 - 0.30 |
| **Drop (low value)** | < 0.10 |

Output in this exact format, nothing before or after:

```markdown
# DX-rule evaluation: <tool>

Config discovered: <path>
Firings analyzed: <N> (or: "config-only - <tool> not installed locally")
  (For biome: indicate which mode(s) were evaluated, e.g.,
  "Firings analyzed: 47 (linter rules) + 6 formatter options evaluated config-only")

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
- (Optional) Note about small sample: "Fewer than 10 rules evaluated - Wilson rankings are noisier at small N."
- (Optional) Note about config-only mode if tool wasn't installed.
- (Optional, biome) Note which sides were evaluated: "Linter disabled - formatter options only," or "Both linter rules and formatter options evaluated."
```

## Rules

- **DO NOT modify the config file.** Output is recommendations only.
- For each "drop" recommendation, the rationale column must capture WHY the drop-voting lenses voted drop.
- For each "tune" recommendation, the suggested adjustment column must be concrete (an option name + new value, not vague advice).
- If the tool isn't installed and the fallback config-only analysis runs, every Wilson score is necessarily less reliable - say so explicitly in the summary.
- Sort each bucket by Wilson DESC.
