# React upgrade reference

## Detection cues

- `react` + `react-dom` in `package.json`. Current major = resolved `react` in the lockfile.
- Toolchain: Vite (`vite.config.*` + `@vitejs/plugin-react`), Create React App (`react-scripts` — note: CRA
  is deprecated/unmaintained, treat migrating off it as part of the plan), or a meta-framework: **Next.js**
  (`next` — has its own upgrade path, see below), Remix/React Router, Gatsby.
- If `next` is present, the React upgrade is largely governed by Next.js — the Next major dictates the
  supported React version. Plan the Next.js upgrade as the driver and let React follow.

## How React versioning differs from Angular

React majors are less frequent and you can often jump more than one at a time, **but** each major ships
deprecation removals and codemods. Don't blindly jump — for each major between current and target, read
its release notes and apply its codemods. Split into hops when a codemod for an intermediate major must
run on intermediate code (running v19 codemods on v17 source can miss or mis-transform).

## Lockstep packages — move together

| Package | Notes |
|---|---|
| `react`, `react-dom` | Always identical versions. Never mismatch. |
| `@types/react`, `@types/react-dom` | TS projects: bump to match the React major. v18 and v19 changed types significantly (v18: `children` no longer implicit in `FC`; v19: ref-as-prop, removed legacy types). |
| `react-test-renderer` (if used) | Matches React major. |
| The renderer/meta-framework — `next`, `react-router`/`react-router-dom`, `@remix-run/*`, `gatsby` | Each pins a React-version range. The framework major is usually the real gate. |

## Codemods

React ships official codemods. Run them per target major:

```
npx codemod react/19/migration-recipe      # React 19 recipe (the current tooling)
# legacy: npx react-codemod <transform> <path>
```

Confirm the current codemod entry point against the official upgrade guide (the tooling moved from
`react-codemod` to the `codemod` runner). `--dry` previews where supported.

## Breaking-change themes by major

Confirm specifics against the official "Upgrading to React N" guide:

- **18** — `ReactDOM.render` → `createRoot` (and `hydrate` → `hydrateRoot`); **automatic batching**
  (state updates batch in more places — can surface ordering assumptions); `StrictMode` double-invokes
  effects in dev (exposes missing cleanup); new concurrent features (`useTransition`, `useDeferredValue`);
  `@types/react` v18 drops implicit `children`.
- **19** — Actions / `useActionState` / `useFormStatus`; `use()` API; **ref as a regular prop** (the
  `forwardRef` ceremony is going away); the React Compiler (opt-in); removal of long-deprecated APIs
  (`propTypes`/`defaultProps` on function components, legacy context, `ReactDOM.render`, string refs).

## CRA → Vite migration (do it as part of the upgrade if on `react-scripts`)

CRA is unmaintained and blocks modern React tooling. The migration:
- Add `vite` + `@vitejs/plugin-react`; move `index.html` to the project root with the `<script type="module">`
  entry; rename JSX-containing `.js` files to `.jsx` (Vite/esbuild requires it); replace `%PUBLIC_URL%` and
  `process.env.REACT_APP_*` with `import.meta.env.VITE_*`; swap `react-scripts` scripts for `vite` / `vite build`.
- This is independent of the React major bump — sequence it as its own step so a failure is isolated.

## Per-hop verification

```
npm run build        # or vite build / next build
npm test
npm run dev          # smoke test
npx tsc --noEmit     # TS projects: catches the @types/react breakages
```

The TypeScript check is the highest-signal step for React major bumps — most v18/v19 breakage shows up
as type errors first.

## Gotchas

- **State libraries / data layer** — Redux Toolkit, Zustand, React Query (`@tanstack/react-query`), MobX
  each declare React peer ranges. Pin them in the ecosystem risk table; React Query in particular has had
  its own breaking majors.
- **UI libraries** — MUI, Chakra, Ant Design ship a major per React major and are often the slowest mover.
- **Enzyme** — never supported React 18; if the project still uses Enzyme, migrating tests to React Testing
  Library is a prerequisite, not an afterthought. Flag it loudly.
