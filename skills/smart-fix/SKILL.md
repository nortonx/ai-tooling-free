---
name: smart-fix
description: "Intelligently diagnose and fix issues. Args: <issue description>"
argument-hint: "<issue description>"
---

<!-- Note: $ARGUMENTS is substituted by Claude commands only. In Copilot,
     the user must include their argument inline in the prompt; the skill
     body sees the literal text "$ARGUMENTS" unsubstituted. -->

## Arguments

`<issue description>`

- Required. Free-text description of the bug, perf issue, security concern, or feature ask.
- **Examples**: `/smart-fix login throws NullReferenceException on empty email`, `/smart-fix the search page takes 8s to render`

> Copilot CLI note: `$ARGUMENTS` doesn't substitute in skills — include the argument inline in your prompt.

# Intelligently fix: $ARGUMENTS

Route the request to the right skill based on the keywords in the description. Apply rules in order — first match wins.

## Routing table

| Trigger keywords (case-insensitive) in `$ARGUMENTS` | Route to |
|---|---|
| `throws`, `error`, `exception`, `crash`, `null`, `undefined`, `NaN`, `fails`, `broken`, `wrong output`, `regression` | Treat as a bug — reproduce it first, isolate the root cause, write a failing regression test, then fix. (If the `superpowers` plugin is installed, invoke `superpowers:systematic-debugging` instead.) |
| `slow`, `takes Xs`, `Xms`, `lag`, `freezes`, `hangs`, `memory leak`, `OOM`, `bundle size`, `re-render` | Invoke `/optimize` with the file or area from the description as scope |
| `CVE`, `vuln`, `vulnerability`, `XSS`, `SQLi`, `injection`, `auth bypass`, `leak`, `secret`, `token`, `unsafe` | Perform an OWASP-Top-10-oriented security review of the affected area and propose the patch; if a specific CVE/advisory is named, also propose the dependency or code patch |
| `add`, `support`, `new`, `enable`, `allow`, `should be able to`, `as a user I want` | Treat as feature work — clarify intent and requirements with the user before coding, then implement. (If the `superpowers` / `feature-dev` plugins are installed, invoke `superpowers:brainstorming` then `feature-dev:feature-dev` instead.) |
| None of the above match | Stop and ask the user to clarify which of the four buckets it falls under (bug, performance, security, feature) — do not guess |

## After routing

Whichever skill is invoked, prepend one line summarizing the route decision:

`Routed to <skill> because `$ARGUMENTS` matched: <quoted keyword(s)>.`

If multiple buckets match (e.g., a security-sensitive performance bug), pick the bucket of the **most severe** keyword family (security > bug > performance > feature) and note the other matches in the routing line so the user can redirect.
