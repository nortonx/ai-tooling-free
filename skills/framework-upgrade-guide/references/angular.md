# Angular upgrade reference

## Detection cues

- `@angular/core` in `package.json`; `angular.json` at the root.
- Current major = the major of the **resolved** `@angular/core` in the lockfile (not the `^` range).
- Toolchain is Angular CLI (`@angular/cli`). Nx monorepos wrap it (`nx.json`, `@nx/angular`) — `ng update`
  still drives the migration but Nx has its own `nx migrate` wrapper; prefer the project's existing tool.

## The one rule that matters: one major at a time

Angular **does not support skipping majors**. To go 15 → 21 you run six sequential upgrades
(15→16, 16→17, 17→18, 18→19, 19→20, 20→21), each with its own `ng update`, schematics, build, and test.
`ng update` refuses to jump multiple majors and the migration schematics are written per-major. This is
non-negotiable and is the backbone of the guide. The example is illustrative — Angular ships a major
roughly every 6 months, so always confirm the current latest stable against `angular.dev/reference/releases`
(step 2 of the workflow) rather than assuming any ceiling written here.

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
| `zone.js` | While present, each Angular major pins a min `zone.js` that `ng update` bumps. Zoneless change detection was experimental in v18, developer preview in v20, stable in v20.2; from v21 newly generated apps are zoneless by default (`ng new` omits zone.js). Existing apps keep zone.js until they opt out. |
| `rxjs` | Angular majors raise the min RxJS. v15+ wants RxJS 7+. Verify the floor per hop. |
| `typescript` | **Hard floor per major** — Angular refuses to build on an older TS. Bump `typescript` to the version the target major requires before/with the hop. |

Always confirm the exact min `typescript` / `zone.js` / `rxjs` for each target major against the official
docs (step 2 of the workflow) — the floors move and `ng update` will error out if they're unmet.
Anchor numbers for recent majors (verify live, per `angular.dev/reference/versions`): v19 = TS 5.5–5.8,
Node 18.19/20.11/22; v20 = TS 5.8+, Node 20.19+; v21 = TS 5.9+, Node 20.19/22.12/24; v22 = TS 6.0,
Node 22.22/24.15/26.

## Notable breaking changes / migration themes by era

Confirm specifics against `update.angular.dev` for the exact hops — highlights to look for:

- **v15** — Angular Material MDC migration (component DOM/CSS changes), standalone APIs stabilized.
- **v16** — Required inputs, `takeUntilDestroyed`, esbuild dev server preview, Signals (developer preview).
- **v17** — New **control flow** (`@if`/`@for`/`@switch`) via optional migration schematic, new application
  builder (esbuild/Vite) as default for new apps, deferrable views, `update.angular.dev` becomes the guide.
- **v18** — Zoneless change detection (experimental), Material 3, event replay for SSR hydration.
- **v19** — Standalone-by-default, incremental hydration, `linkedSignal`/`resource` APIs.
- **v20** — TS 5.8+ / Node 20.19+ floors; `*ngIf`/`*ngFor`/`*ngSwitch` deprecated in favor of
  `@if`/`@for`/`@switch` (removal targeted v22); `effect`/`linkedSignal`/`toSignal` stabilized; Karma
  builder removed (experimental Vitest runner added); zoneless change detection in developer preview
  (stable in v20.2).
- **v21** — TS 5.9+ floor; zoneless-by-default for new apps (`ng new` no longer includes zone.js);
  Vitest is the default/stable test runner (`ng generate @angular/core:karma-to-vitest` migrates);
  Signal Forms (experimental); experimental Jest and Web Test Runner builders deprecated for removal in v22.

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

**The test toolchain itself changes mid-sequence** — don't assume `npm test` keeps working unchanged:
Karma (deprecated since ~v16) loses its builder at the v20 hop — Karma projects hit a "missing builder"
failure on `ng test` unless reconfigured; v21 makes Vitest the default runner (migrate via
`ng generate @angular/core:karma-to-vitest`); Jest and Web Test Runner builders are deprecated for
removal in v22. Projects on Karma should plan the runner migration around the v20/v21 hops.

## Gotchas

- **Custom/ejected webpack** — apps not on the standard builder won't get the build-tooling schematics; the
  migration becomes partly manual. Flag this in the guide.
- **Third-party Angular libraries** (NgRx, PrimeNG, ng-bootstrap, transloco…) publish one major per Angular
  major. The upgrade can only move as fast as the slowest of these — pin each in the ecosystem risk table.
- **Deprecated APIs** removed mid-sequence (e.g. `ViewEngine` artifacts, old `HttpModule`, `entryComponents`)
  surface as build errors on the hop that removes them; the schematic usually rewrites them, but verify.
