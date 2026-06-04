# Angular upgrade reference

## Detection cues

- `@angular/core` in `package.json`; `angular.json` at the root.
- Current major = the major of the **resolved** `@angular/core` in the lockfile (not the `^` range).
- Toolchain is Angular CLI (`@angular/cli`). Nx monorepos wrap it (`nx.json`, `@nx/angular`) — `ng update`
  still drives the migration but Nx has its own `nx migrate` wrapper; prefer the project's existing tool.

## The one rule that matters: one major at a time

Angular **does not support skipping majors**. To go 15 → 19 you run four sequential upgrades
(15→16, 16→17, 17→18, 18→19), each with its own `ng update`, schematics, build, and test. `ng update`
refuses to jump multiple majors and the migration schematics are written per-major. This is non-negotiable
and is the backbone of the guide.

## `ng update` is the source of truth

Per hop, from inside the project:

```
ng update @angular/core@<N> @angular/cli@<N>
```

`ng update` runs the version's migration **schematics** automatically (it rewrites code for many breaking
changes). Preview first with `ng update` (no args) to see what's outdated, and `--dry-run` to see changes
without applying. Commit between hops so each is independently revertible.

If `@angular/cli` and `@angular/core` are not on the same major before you start, fix that first —
`ng update` expects them aligned.

## Lockstep packages — must move together every hop

These are **core** and must all land on the same Angular major `N`:

| Package | Notes |
|---|---|
| `@angular/core`, `@angular/common`, `@angular/compiler`, `@angular/forms`, `@angular/platform-browser`, `@angular/platform-browser-dynamic`, `@angular/router`, `@angular/animations` | All framework packages share the Angular major. |
| `@angular/cli`, `@angular-devkit/build-angular` | Build tooling, same major. |
| `@angular/material`, `@angular/cdk` | Same major as core. `ng update @angular/material` runs Material-specific schematics (e.g. MDC migration in v15). Often the **slowest** thing — if a custom theme is heavy, this gates the pace. |
| `zone.js` | Each Angular major pins a min `zone.js`; `ng update` bumps it. (Zoneless is opt-in from v18+.) |
| `rxjs` | Angular majors raise the min RxJS. v15+ wants RxJS 7+. Verify the floor per hop. |
| `typescript` | **Hard floor per major** — Angular refuses to build on an older TS. Bump `typescript` to the version the target major requires before/with the hop. |

Always confirm the exact min `typescript` / `zone.js` / `rxjs` for each target major against the official
docs (step 2 of the workflow) — the floors move and `ng update` will error out if they're unmet.

## Notable breaking changes / migration themes by era

Confirm specifics against `update.angular.dev` for the exact hops — highlights to look for:

- **v15** — Angular Material MDC migration (component DOM/CSS changes), standalone APIs stabilized.
- **v16** — Required inputs, `takeUntilDestroyed`, esbuild dev server preview, Signals (developer preview).
- **v17** — New **control flow** (`@if`/`@for`/`@switch`) via optional migration schematic, new application
  builder (esbuild/Vite) as default for new apps, deferrable views, `update.angular.dev` becomes the guide.
- **v18** — Zoneless change detection (experimental), Material 3, event replay for SSR hydration.
- **v19** — Standalone-by-default, incremental hydration, `linkedSignal`/`resource` APIs.

`update.angular.dev` lets you pick "from version / to version / app complexity" and emits the exact
checklist — use it as the authoritative per-hop source.

## Per-hop verification

```
ng build           # must compile clean on the new major
npm test           # or the project's runner
ng serve           # smoke test the running app
```

A hop is "done" only when build + tests are green. Don't stack the next hop on a broken one — the
schematics assume a consistent starting state.

## Gotchas

- **Custom/ejected webpack** — apps not on the standard builder won't get the build-tooling schematics; the
  migration becomes partly manual. Flag this in the guide.
- **Third-party Angular libraries** (NgRx, PrimeNG, ng-bootstrap, transloco…) publish one major per Angular
  major. The upgrade can only move as fast as the slowest of these — pin each in the ecosystem risk table.
- **Deprecated APIs** removed mid-sequence (e.g. `ViewEngine` artifacts, old `HttpModule`, `entryComponents`)
  surface as build errors on the hop that removes them; the schematic usually rewrites them, but verify.
