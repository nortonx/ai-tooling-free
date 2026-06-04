---
name: generate-spec
description: "Scaffold a feature spec in ./specs/ using a reusable 9-section template. Args: <feature name>"
argument-hint: "<feature name>"
---

<!-- Note: $ARGUMENTS is substituted by Claude commands only. In Copilot,
     the user must include their argument inline in the prompt; the skill
     body sees the literal text "$ARGUMENTS" unsubstituted. -->

## Arguments

`<feature name>`

- Required. The feature name in plain language; drives the slug, title, and reference-spec heuristic.
- **Examples**: `/generate-spec User Bulk Import`, `/generate-spec rate-limited webhook delivery`

> Copilot CLI note: `$ARGUMENTS` doesn't substitute in skills — include the argument inline in your prompt.

# Generate Spec: $ARGUMENTS

Interview the user, draft a spec that follows the canonical template below (and mirrors any existing specs in this repo), and write it to disk only after the user approves. Specs are saved in `./specs/` (relative to the current working directory).

The user can stop the interview at any time. Respect that: partial specs are acceptable — omit empty sections rather than padding them with "TBD".

## Step 1 — Orient

Before asking anything, discover the local spec conventions:

1. **Check for an existing `./specs/` directory.** If it doesn't exist, tell the user you'll create it at write-time and ask whether they want a specific subdirectory (e.g., `frontend/`, `backend/`, `api/`) or a flat layout.

2. **List existing specs** by globbing `./specs/**/*.md`. If any exist:
   - Note the subdirectory structure (flat vs. scoped like `frontend/`/`backend/`).
   - Pick **one** existing spec closest in shape to `$ARGUMENTS` and read it as your reference. Use keyword heuristics on `$ARGUMENTS`:
     - "page", "component", "dialog", "form", "view", "UI", "composable", "hook" → prefer a frontend/UI-style spec.
     - "endpoint", "API", "service", "handler", "guard", "middleware", "controller", "DTO" → prefer a backend/server-style spec.
     - "database", "migration", "CI", "build", "release", "infra", "logging", "validation" → prefer an infra-style spec.
   - **Heuristic-override path**: if the user's prompt also contains `as <scope>` or `--scope=<scope>` (e.g., `/generate-spec User Bulk Import as backend`), use that scope and skip the keyword heuristic.
   - **Ambiguous match**: if two or more buckets match the keywords (e.g., "API page component"), list the candidates and ask the user which to use rather than guessing.
   - If no clear match, read the first 2-3 existing specs to establish the tone.

3. **Check for a `./specs/README.md` or `./CLAUDE.md`** — either may document project-specific template overrides. If found, treat its guidance as higher priority than this command's default template.

4. After orienting, tell the user in one sentence: how many existing specs were found, which (if any) you'll use as a reference, and the detected subdirectory layout.

If no existing specs are present, announce that you'll use the canonical 9-section template described in Step 3 and continue.

## Step 2 — Interview

Ask the questions below **one at a time, in order**. After each answer, move on. Every question must end with this exact footer:

> *Reply with your answer, `skip` to leave this section blank, `stop` to finalize with what we have, `auto` to let me propose a draft, or `learn <concept>` if you want me to explain a term (e.g., `learn user story`, `learn non-functional requirement`) via the `/learn` command before answering.*

Response handling:
- `stop` → jump to Step 3 with whatever has been gathered. Do not ask remaining questions.
- `skip` → record the section as empty and continue.
- `auto` → draft the section from `$ARGUMENTS`, the reference spec, and prior answers. Show the draft, ask for approval or edits, then continue.
- `learn <concept>` → invoke the `/learn` command on `<concept>`, then re-ask the same question after the explanation.

**Q1. Scope / subdirectory.** Propose a target subdirectory based on Step 1's detection (e.g., "Save under `specs/frontend/`?"). If no subdirectories exist in `./specs/`, propose flat placement (`./specs/<slug>.spec.md`). Let the user override.

**Q2. Filename slug.** Propose a kebab-case slug derived from `$ARGUMENTS` (e.g., "User Bulk Import" → `user-bulk-import`). Confirm the final target path: `./specs/<scope>/<slug>.spec.md` or `./specs/<slug>.spec.md`. Before continuing, check whether the target file already exists. If it does, surface the collision and require a different slug — never overwrite.

**Q3. Purpose.** "In 1-2 sentences: what does this feature do and who does it serve?"

**Q4. User stories / use cases.** "List the roles and actions in the form `As a <role>, I want <action> so that <outcome>.` Reply `skip` if this is pure infrastructure (CI, tooling, schema) — the section will be omitted entirely."

**Q5. Functional requirements.** "List the behaviors this feature must have. I'll number them as `FR-1`, `FR-2`, …  `auto` proposes 4-6 starter FRs based on the reference spec and your purpose."

**Q6. Non-functional concerns.** "Which categories apply? Pick from: Performance, Security, Accessibility, Observability, Compatibility, UX, Resilience, Theming, Safety, Speed, Isolation, Reliability, Cost, Visibility. For each picked category, provide a one-sentence constraint. `auto` selects sensible defaults for the scope."

**Q7. Technical notes.** "Any known files, modules, commands, env vars, dependencies, or integration points? `skip` is fine — technical details often get filled in during implementation."

**Q8. Acceptance criteria.** "What observable checks prove this works? I'll render them as `- [ ]` checkboxes. `auto` derives them directly from your functional requirements."

**Q9. Open questions / future enhancements.** "Any known gaps, follow-ups, or ideas to flag? `skip` omits the section."

## Step 3 — Assemble

Compose the spec in-memory using the canonical template. Follow these structural rules without exception:

**Section order (omit empty sections, never reorder):**

1. `# <Title Case Feature Name>` — derived from `$ARGUMENTS`, not from the slug.
2. `## Purpose`
3. `## User Stories / Use Cases` *(omit if Q4 was `skip`)*
4. `## Functional Requirements`
5. `## Non-Functional Requirements`
6. `## Technical Notes`
7. `## Acceptance Criteria`
8. `## Current Implementation`
9. `## Open Questions / Future Enhancements` *(omit if Q9 was `skip`)*

**Formatting rules:**

- `## Purpose` — 1-2 prose sentences. No bullets.
- `## User Stories / Use Cases` — bullets, each `- As a <role>, I want <action> so that <outcome>.`
- `## Functional Requirements` — bullets, each prefixed `FR-N:` starting at `FR-1`, sentences end with a period. Nested bullets allowed for compound requirements.
- `## Non-Functional Requirements` — bullets, each prefixed with a category and colon: `Performance: …`, `Security: …`, etc.
- `## Technical Notes` — sub-lists under labels such as `Files:`, `Module:`, `Commands:`, `Env:`, `Dependencies:`, `Test runner:`. Backtick all file paths, module names, commands, and env var names.
- `## Acceptance Criteria` — `- [ ]` checkboxes, one per verifiable claim.
- `## Current Implementation` — always three bolded sub-labels:
  - `- **Files**: …`
  - `- **Tests**: …`
  - `- **Dependencies**: …`

  For a brand-new feature that hasn't been built yet, use `_(to be filled in during implementation)_` for each.
- `## Open Questions / Future Enhancements` — bullets. Include only if the user provided content.

**Consistency with existing repo:** if Step 1 found local specs, match their exact heading casing, bullet style, and any minor idiomatic differences (e.g., some projects label `FR-N` vs. `FR.N`, or use `Required` instead of `Dependencies`). Your reference spec wins over this template's defaults when they conflict.

Show the full rendered markdown to the user and ask:

> *Write to `<target-path>`? Reply `yes`, `edit <section-name>` to revise a section, or `stop` to abort without writing.*

On `edit <section-name>`, re-ask the relevant interview question, regenerate the preview, and ask again.

## Step 4 — Write

On `yes`: use the `Write` tool to create the spec at the agreed target path. If `./specs/` or a proposed subdirectory doesn't exist, create it first with `mkdir -p` via `Bash`.

Confirm in one line: the written relative path and the count of sections included.

On `stop`: reply with a one-line confirmation that no file was written. Do not offer to retry unless the user asks.

## Guardrails

- Never invent file paths, API endpoints, module names, or env var names that aren't grounded in the user's answers or in the reference spec. When uncertain, ask or `skip` rather than guess.
- Never overwrite an existing spec file. If the target path exists, surface the collision in Q2 and require a new slug.
- Do not add emojis, horizontal rules (`---`), introductory prose above the `#` title, or trailing summaries. Keep the generated file pure content.
- Do not fill empty sections with "TBD", "(none)", or similar placeholders. Omit the section entirely.
- Keep section order identical to the list above — omit, do not reorder.
- Do not mention this command, the interview process, or `$ARGUMENTS` inside the generated spec.
- If the user asks a question about Claude Code itself (not about spec contents), point them to `/help` rather than attempting to answer from this command.
- Do **not** auto-update `CLAUDE.md` or `README.md` after writing the spec. If you noticed conventions during the interview that belong in CLAUDE.md, mention them in one line at the end ("CLAUDE.md candidate: <one-sentence convention>") and let the user invoke `/update-claude-md` if they want to capture it.
