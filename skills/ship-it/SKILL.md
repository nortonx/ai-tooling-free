---
name: ship-it
description: "Branch (if needed), commit, and push the current changes to remote in one step. Invoke only when the user explicitly runs /ship-it or asks to branch-commit-push — it reminds you to review first, then commits and pushes. Args: [branch-name-or-issue-id]"
argument-hint: [branch-name-or-issue-id]
---

# Ship it

> ⚠️ **Review the changes first.** Show the working-tree status and the commit message you're about to use, and confirm the changes are what's intended — this stages everything, commits, and pushes to remote. Running `/ship-it` is the user's explicit authorization to commit and push for this run (it waives the usual "ask before committing/pushing" rule for this invocation only).

## Arguments

`[branch-name-or-issue-id]` — optional. Overrides the **branch name** only; the commit message is always auto-derived from the diff.

- A full branch name (`feat/checkout-retry`) is used verbatim.
- A bare issue/ticket id (`123`) becomes `<type>/<issue-id>-<slug>`.
- Omitted → `<type>/<slug>` derived from the diff.

(Copilot CLI and skills don't substitute `$ARGUMENTS` — include the branch name or issue id inline in your prompt when you want to override.)

## Steps

1. **Gather context** — run:
   ```bash
   git branch --show-current
   git status --short
   git diff --stat HEAD
   git log --oneline -10
   ```
   Resolve the default branch: `git symbolic-ref --quiet --short refs/remotes/origin/HEAD` (strip the `origin/` prefix); fall back to `main`, else `master`.
2. **If the working tree is clean, stop** and say "nothing to ship". Do nothing else.
3. **Branch**:
   - On the **default branch** (`main`/`master`) → create and switch to a new branch (`git switch -c <name>`). Name it from the argument if given, else derive `<type>/<slug>` — `<type>` ∈ `feat|fix|refactor|docs|test|chore|perf|ci`, `<slug>` = short kebab summary of the change. An issue-id argument like `123` → `<type>/<issue-id>-<slug>`.
   - On a **feature branch** already → reuse it; do **not** create another.
4. **Stage** everything: `git add -A`.
5. **Commit** following the `create-commit-message` convention: `<type>: <imperative summary, ≤72 chars>` — reference the issue id from the branch name when present (e.g. `(#123)` suffix). Focus the summary on the *why*. One commit only; do not split. Single quotes only if quoting.
6. **Push** with upstream tracking: `git push -u origin HEAD`.
7. **Report** in 2–3 lines: branch name, commit subject, and push result (include any PR-create hint git prints).

## Rules

- **Never** force-push, amend, rebase, or touch any branch other than the one being shipped.
- If the push is **rejected** (remote ahead, protected branch, etc.), stop and report the error verbatim — do not rebase, pull, or force to recover.
- Invoke only on explicit user request; never auto-trigger a commit or push.
