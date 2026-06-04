# Svelte upgrade reference

## Detection cues

- `svelte` in `package.json`. Current major = resolved `svelte` in the lockfile.
- Toolchain: **SvelteKit** (`@sveltejs/kit` + `svelte.config.js` with an adapter), or plain Svelte + Vite
  (`vite.config.*` + `@sveltejs/vite-plugin-svelte`).
- Two distinct migration lines exist and may both apply: **Sapper → SvelteKit** (legacy, rare now) and
  **SvelteKit pre-1.0 → 1.0+**, plus the framework's own **Svelte 3/4 → 5**.

## Svelte 4 → 5: runes

Svelte 5 introduces **runes** (`$state`, `$derived`, `$effect`, `$props`) — a new reactivity model. Svelte 5
runs most Svelte 4 code in a compatibility mode, so the version bump and the rune migration can be
**decoupled**: upgrade to 5 first (legacy mode keeps working), then migrate components to runes incrementally.

Official migration tooling:

```
npx sv migrate svelte-5      # current CLI (the `sv` tool)
# older projects: npx svelte-migrate svelte-5
```

The migration script converts components to runes where it can and annotates the rest. Confirm the current
command (`sv migrate` vs `svelte-migrate`) against the official docs — the CLI was renamed.

## Svelte 3 → 4

Mostly a tooling/peer-dependency bump (min Node, updated Vite plugin, removed long-deprecated options)
rather than authoring changes. `npx svelte-migrate svelte-4` handles the mechanical parts. Treat 3→4 as a
prerequisite hop before 4→5.

## Lockstep packages — move together

| Package | Notes |
|---|---|
| `svelte` | The compiler/runtime. |
| `@sveltejs/kit` | SvelteKit pins a `svelte` peer range; the Kit major often gates which Svelte you can run. |
| `@sveltejs/vite-plugin-svelte` | Must match the Svelte major. |
| `@sveltejs/adapter-*` (`-auto`, `-node`, `-static`, `-vercel`, `-cloudflare`…) | Adapter major matches the Kit major; the deploy target dictates which adapter. |
| `svelte-check` + `svelte-preprocess` (TS projects) | Type-checking; match the Svelte major. |
| `vite` | Kit majors raise the min Vite — verify the floor. |

## Breaking-change themes

Confirm against the official Svelte 5 + SvelteKit migration guides:

- **Svelte 5** — runes replace the `let`-is-reactive / `$:` model (legacy still supported in compat mode);
  event handlers move from `on:click` to `onclick` properties; component instantiation API changed
  (`new Component()` → `mount`/`createRoot`); slots → snippets (`{#snippet}` / `{@render}`); stores still
  work but runes are preferred.
- **SvelteKit 1.0** — finalized `load` signatures, `+page`/`+layout` file conventions, adapter API; if the
  project predates 1.0, this is the larger migration of the two.

## Per-hop verification

```
npm run build        # vite build / svelte-kit build
npm test
npm run dev          # smoke test
npx svelte-check     # type + template diagnostics — highest signal for rune/slot breakage
```

`svelte-check` is the key gate: it surfaces rune-migration gaps, removed slot syntax, and event-handler
changes as diagnostics.

## Gotchas

- **Adapters are deploy-target-specific** — upgrading the adapter without re-checking the deploy config
  (Node version on the host, edge runtime limits) can break deploys even when the build passes locally.
- **Component libraries** (`skeleton`, `flowbite-svelte`, `svelte-headlessui`, etc.) lag Svelte majors; pin
  each in the ecosystem risk table and confirm a Svelte-5-compatible release exists before committing to 5.
- The `sv` / `svelte-migrate` script handles the mechanical 80%; the runes conversion of complex reactive
  statements (`$:` with side effects, derived chains) usually needs manual review — call that out per hop.
