# Vue upgrade reference

## Detection cues

- `vue` in `package.json`. Current major = resolved `vue` in the lockfile.
- The **2 → 3 jump is the dividing line** and is by far the biggest migration — treat Vue 2.x → 3.x as a
  category of its own (see below). Within Vue 3 (e.g. 3.2 → 3.4), upgrades are minor and low-risk.
- Toolchain: Vite (`vite.config.*` + `@vitejs/plugin-vue`), Vue CLI (`vue.config.js` + `@vue/cli-service` —
  deprecated, migrating to Vite is part of the plan), or **Nuxt** (`nuxt.config.*` — Nuxt 2 uses Vue 2,
  Nuxt 3 uses Vue 3; the Nuxt major is the real driver, plan that upgrade as the lead).

## Vue 2 → 3: the migration build path

Vue 2 reached EOL (Dec 2023) — being on Vue 2 is a security finding, not just a modernization nicety.
Vue 3 has no `ng update` equivalent; the supported path is the **migration build**:

1. Move to the latest **Vue 2.7** first (back-ports the Composition API and `<script setup>`, easing the gap).
2. Switch to `@vue/compat` (the Vue 3 build running in Vue-2-compatible mode). It emits **deprecation
   warnings at runtime** for every Vue-2-ism still in the code.
3. Work the warnings down to zero, then drop `@vue/compat` and run on real Vue 3.

This is incremental by design — the app keeps running while warnings are burned down, which suits
"must stay shippable" constraints.

## Lockstep packages — move together (Vue 3 targets)

| Package | Notes |
|---|---|
| `vue` | The framework. |
| `vue-router` | v3 = Vue 2, **v4 = Vue 3**. `createRouter`/`createWebHistory` replace `new VueRouter`. |
| State: `vuex` v3→v4 (Vue 3), or migrate to **Pinia** (the recommended store for Vue 3) | Vuex is in maintenance; Pinia is the path forward. |
| `@vitejs/plugin-vue` (or `@vue/cli-service`) | Build plugin, matches Vue 3. |
| `vue-tsc` + `@vue/tsconfig` | Type-checking for SFCs on Vue 3. |
| UI libs — **Vuetify** (2→3 is a near-rewrite), Element (`element-ui`→`element-plus`), Quasar, PrimeVue, BootstrapVue (`bootstrap-vue`→`bootstrap-vue-next`) | These gate the pace; some have no drop-in Vue 3 release. |

## Breaking-change themes (Vue 2 → 3)

Confirm against the official Vue 3 migration guide:

- **App init** — `new Vue({...})` → `createApp(App)`; global API (`Vue.use`, `Vue.component`, `Vue.prototype`)
  → app-instance methods (`app.use`, `app.component`, `app.config.globalProperties`).
- **v-model** — prop/event renamed (`value`/`input` → `modelValue`/`update:modelValue`); `.sync` removed in
  favor of multiple `v-model`.
- **Filters removed** — replace with methods/computed.
- **Reactivity** — Proxy-based; mutating arrays by index / adding props now works without `Vue.set`
  (`Vue.set`/`Vue.delete` removed).
- **Functional components / `functional` attr** changes; `$listeners` merged into `$attrs`.
- **Lifecycle renames** — `beforeDestroy`/`destroyed` → `beforeUnmount`/`unmounted`.
- **Fragments** — multiple root nodes now allowed (affects attribute inheritance).

## Tooling

- **Volar replaces Vetur** for editor/type support; `vue-tsc` for CLI type-checking. Note this in the guide
  if the project still references Vetur.
- Vue CLI → Vite migration mirrors the React CRA→Vite step; sequence it separately.

## Per-hop / phase verification

```
npm run build        # vite build
npm test
npm run dev          # smoke test; watch the browser console for @vue/compat deprecation warnings
npx vue-tsc --noEmit # SFC type check (Vue 3)
```

During the `@vue/compat` phase, **zero runtime deprecation warnings in the console** is the gate for
dropping compat mode.

## Gotchas

- **Vuetify 2 has no in-place upgrade to 3** — components were redesigned; budget real time or stay on
  Vuetify 2 until ready. This single library often dictates the whole timeline — surface it first.
- **Nuxt** — don't upgrade Vue under Nuxt directly; upgrade Nuxt (2→3 is itself a major migration via
  Nuxt Bridge) and let it pull the right Vue.
