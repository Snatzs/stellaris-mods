# Migration Overhaul

## Overview

Reworks population movement and species relations toward the "species relations should matter" and
"realistic migration" goals. Implements **Angle A** (inter-empire phenotype distrust),
**species-clustering** (intra-empire minority discomfort), and **timed forced resettlement**
(cost + settling-in time for manual pop-shuffling). Migration restrictions and Angle B
(intra-empire cohesion → ethnic secession) are planned — see
[`docs/species-relations-design.md`](../../docs/species-relations-design.md) and
[`docs/ROADMAP.md`](../../docs/ROADMAP.md).

## Design Goals

Addresses [design-vision.md](../../docs/design-vision.md) pillars **#5 Diplomacy with teeth** and
**Population & Migration**: different species phenotypes should distrust each other, modulated by
ethics, so geopolitics reflects who you are — not just what you do.

## Changes

### Angle A — phenotype distrust (inter-empire opinion)
- Adds three auto-applied opinion modifiers graded by **phenotype family distance**:
  - `migr_opinion_phenotype_near` — same family, different class (e.g. mammalian vs reptilian)
  - `migr_opinion_phenotype_far` — different organic family (e.g. mammalian vs fungoid / lithoid)
  - `migr_opinion_phenotype_alien` — organic vs synthetic (most alien)
- Each is **laddered by the observer's ethics**: fanatic xenophobe harshest → fanatic xenophile zero.
- Phenotype families defined in `common/scripted_triggers/migr_phenotype_triggers.txt`
  (animalic / flora / mineral / synthetic), reusable by future Angle B.
- **Additive** over vanilla's mild `triggered_opinion_xenophobes/xenophiles`; values are first-pass
  and TUNABLE (see [multiplayer-balance.md](../../docs/multiplayer-balance.md)).

### Species-clustering — minority discomfort (intra-empire)
Pops who are a small minority of their **own species** on a planet take a happiness penalty, nudging
empires to keep species clustered rather than scattering them into a melting pot. The engine exposes
no migration-target weighting (see [population.md](../../docs/vanilla/population.md)), so this is a
**soft** discouragement (unhappy → emigration push + lower output), not a hard block.

- **Fraction-based** (`common/scripted_effects/migr_clustering_effects.txt`): a species is a minority
  when its pop count is below 1/4 of the planet (minor) or 1/10 (severe). Tunable in
  `common/scripted_variables/migr_clustering_variables.txt`.
- Applied as **timed static modifiers** (`migr_local_minority_minor/severe`) directly to minority pop
  groups during iteration — self-expiring, refreshed each recompute. **No vanilla file overridden.**
- Recompute is **event-driven + debounced** (`on_pop_group_added`/`_resettled`, 90-day cooldown) with
  a **yearly full sweep** for drift. Freshly **conquered** planets get a 10-year grace exemption.
- **v1 scope notes:** gestalt empires skipped; penalty is flat per tier (not yet graded by Angle A
  phenotype distance). This recompute is the shared composition engine **Angle B** will reuse.

### Timed forced resettlement — cost + time for manual pop-shuffling
Vanilla resettlement is instant and nearly free. This makes **intra-empire (manual/forced)**
resettlement a deliberate, costly choice, addressing the "realistic migration" goal. Both levers are
applied **event-side** from `on_pop_group_resettled` — no polling (negligible performance), **no
vanilla file overridden** (the cost system lives in vanilla `pop_categories`, so we add cost on top
rather than editing it).

- **Resource surcharge** (`common/scripted_effects/migr_resettlement_effects.txt`): an extra
  energy/unity cost charged per resettlement, **scaled by pops moved, by civics/traits/ethics, and by
  empire size** — cheaper for gestalts (`×0.4`), `civic_corvee_system` / Adaptability finisher (`×0.5`),
  and `trait_nomadic` species (`×0.5`); pricier for `trait_sedentary` (`×1.5`). On top of that, an
  **empire-size multiplier** uses the same *shape* as vanilla tech/tradition cost growth but a steeper
  slope (`1 + (empire_size − 100) × 0.01`, i.e. 5× vanilla's 0.002 — size 300 → ×3, size 600 → ×6)
  so the surcharge stays relevant late-game instead of going flat as income inflates. Steeper than
  vanilla because our surcharge has a flat base, unlike tech whose base cost balloons through the tree.
  This is
  what lets the cost scale up/down by faction *and* over time without touching vanilla cost files.
  Vanilla's own flat cost (already scaled by the native `pop_resettlement_cost_mult`) still applies
  up-front; this is additive. (Note: `civic_corvee_system` only gives vanilla `−0.1` cost + a unity
  waiver — it does *not* zero resettlement cost — so we discount it but don't waive our surcharge.)
- **Settling-in time penalty** (`migr_recent_relocation`): since the engine has no native travel
  time, resettled pops get a timed happiness + bonus-workforce debuff (~5 years) — they move instantly
  but are unhappy and underproductive while adjusting, so resettlement effectively "takes time."
  **Waived** for gestalt empires and nomadic species. Applied via the same flag→iterate pattern as
  clustering (no bare-pop-group `add_modifier` exists).
- **Scope:** restricted to intra-empire resettlement (`from.owner == owner`) so cross-empire refugee /
  migration-treaty inflows are **not** taxed. All values tunable in
  `common/scripted_variables/migr_resettlement_variables.txt`.

## ⚠️ Runtime-verification checklist (species-clustering)

The clustering system passes bracket validation but is **logic-untested** — these vanilla API points
were verified by file inspection and need an in-game confirm (watch `error.log`):
1. `on_actions` with `effect = {}` blocks **merge** with vanilla rather than overriding.
2. `count_owned_pop_amount` with `parameters = { limit = { always = yes } }` returns planet total.
3. The synchronous set→use→remove `migr_cluster_current` species-flag pattern filters correctly
   (species flags are global, so this relies on synchronous effect execution).
4. `subtract_variable` + `check_variable { value < 0 }` evaluate as intended.
5. `planet = {}` resolves from pop-group scope in the on_actions.
6. Penalty actually appears on minority pops and clears when they become a majority.

## ⚠️ Runtime-verification checklist (timed resettlement)

Passes bracket validation but logic is **file-inspection-verified only** — confirm in-game (watch `error.log`):
1. `add_resource = { … mult = migr_resettle_factor }` accepts a **plain country variable** for `mult`
   (vanilla examples use `mult = trigger:…` / `mult = -1`; the how-to-variables doc says variables work).
   If it errors, the surcharge won't scale — fall back to a literal-tiered surcharge.
2. `root.local_pop_amount` reads correctly from inside `owner = {}` scope (cross-scope var reference),
   and `export_trigger_value_to_variable = { trigger = empire_size … }` returns the live empire size.
3. `from = { owner = { is_same_value = root.owner } }` correctly isolates intra-empire resettlement
   (surcharge/penalty should NOT fire on incoming refugees from another empire).
4. `pop_bonus_workforce_mult` is valid inside a static modifier applied to a pop group (it's a
   `pop_group_modifier` key elsewhere; clustering only used `pop_happiness`).
5. The `migr_just_resettled` flag→iterate applies `migr_recent_relocation` to exactly the moved group.
6. Surcharge magnitude actually scales: a sedentary-species move costs visibly more than a nomadic one.

## Compatibility

**No vanilla files overridden** — pure additions to `common/` subfolders. The clustering *and*
resettlement hooks use `on_actions` *merge* semantics; the resettlement cost is applied event-side
(additive surcharge) rather than by editing vanilla `pop_categories` cost files. No
`docs/compatibility.md` entry required. Angle A opinion values stack with the vanilla xeno opinion
modifiers by design, and the resettlement surcharge stacks on top of vanilla's own resettlement cost
(revisit if either is too strong).

## Manual Testing

1. `bash tools/deploy.sh`, enable the mod, start a game with empires of differing phenotypes
   (e.g. a Mammalian and a Fungoid and a Machine empire).
2. Open the diplomacy view between two empires and check the opinion breakdown shows
   "Unfamiliar Phenotype" / "Alien Phenotype" / "Wholly Alien Biology" at the expected tier.
3. Verify magnitude scales with ethics: a xenophobe should show a much larger penalty than a
   xenophile toward the same target; a fanatic xenophile should show none.
4. Confirm two same-class empires (e.g. both Mammalian) show **no** phenotype modifier (Tier 0).

### Species-clustering
5. Find/create a planet with a clear majority species plus a few pops of another species.
6. Confirm the minority pops show "Few of Our Kind" (or "Stranded Among Aliens" if <10%) as a
   happiness modifier; majority-species pops on the same planet show nothing.
7. Resettle more of the minority species in until they exceed 25% and confirm the penalty clears
   (within a recompute cycle / by the next yearly sweep).
8. Conquer a mixed planet and confirm the grace period suppresses penalties for ~10 years.
9. Check `error.log` for scope/variable errors from the recompute (see Runtime-verification checklist).

### Timed resettlement
10. Manually resettle a batch of pops within your empire; confirm energy + unity drop by the surcharge
    (roughly `20 energy × pops × factor`) on top of vanilla's normal resettlement cost.
11. Confirm the moved pops show "Recent Relocation" as a happiness/output penalty for ~5 years, and
    that it self-expires.
12. Compare cost scaling: resettle a **sedentary** species vs. a **nomadic** species (or as a gestalt
    vs. a normal empire) and confirm the surcharge is larger / smaller accordingly.
13. Confirm gestalt empires and nomadic species take the surcharge but **no** "Recent Relocation"
    penalty.
14. Trigger a cross-empire refugee/migration inflow and confirm it is **not** surcharged or penalized
    (only intra-empire resettlement is).
