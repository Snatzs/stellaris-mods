# Migration Overhaul

## Overview

Reworks population movement and species relations toward the "species relations should matter" and
"realistic migration" goals. Currently implements **Angle A** of the species-relations system
(inter-empire phenotype distrust). Timed resettlement, migration restrictions, and Angle B
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

## Compatibility

**No vanilla files overridden** — pure additions to `common/` subfolders (the clustering hooks use
`on_actions` *merge* semantics, not override). No `docs/compatibility.md` entry required. Angle A
opinion values stack with the vanilla xeno opinion modifiers by design (revisit if double-counting is
too strong).

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
