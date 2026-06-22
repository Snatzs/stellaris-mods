# Economy Overhaul

> ⚠️ **The slice-1 design below is SUPERSEDED.** After a full design pass (2026-06-20),
> the flat per-pop output nerf is replaced by a structural approach (planet size cap +
> unpaired jobs-per-district cut) and a three-track model. **Read
> [`docs/economy-overhaul-design.md`](../../docs/economy-overhaul-design.md) before building
> further.** The slice-1 files (`econ_space_primacy` country modifier etc.) remain in the mod
> only until the bulk-structural slice replaces them — do **not** test or ship slice 1 as-is.

## Overview

Rebalances the economy so that **space outproduces planets**. Mining and research
stations get a large output buff; planetary primary-resource jobs (minerals,
energy, food) get a matching nerf. The net effect: a mineral-rich asteroid belt
or a star's energy should dwarf what a planet's pops can dig or harvest — planets
become scarce, valuable, and worth fighting *systems* over, rather than
self-sufficient resource engines.

This is **slice 1** of the economy overhaul (the "Space > Planets" rebalance).
Later slices — space-yield era scaling, strategic-resource concentration, planet
size caps, fewer jobs per district, harsher housing/amenity deficits,
mega-planet penalties — are tracked in `docs/ROADMAP.md`.

## Design Goals

Addresses `docs/design-vision.md` pillars:

- **1 — Geography matters** / **2 — Scarcity drives strategy**: making space the
  primary resource source means *systems* (not just planets) are worth fighting
  over, and planetary output alone can't make an empire self-sufficient.
- **3 — Wide > tall**: nerfing per-pop planetary output (without touching
  station output) pushes empires to expand across many systems rather than
  hyper-optimise a few tall worlds.

Directly implements the Economy section's "Space Resources" and "Planetary
Economy" bullets ("space should be the primary resource source, not planets";
"planetary primary and strategic resource collection should be LESS efficient").

## Changes

All effects are applied via a single permanent **country** static modifier,
`econ_space_primacy`, granted to **every empire** (player + AI) at game start
through `on_game_start_country`. Symmetric across all empires, so it gives **no
single player an advantage** (MP-balance rule) and uses no randomness (MP-safe).

| Lever | Modifier | Default value |
|---|---|---|
| Mining-station output (minerals/energy/space strategic resources) | `station_gatherers_produces_mult` | **+50%** |
| Research-station output | `station_researchers_produces_mult` | **+50%** |
| Planetary mineral jobs | `planet_miners_minerals_produces_mult` | **−50%** |
| Planetary energy jobs | `planet_technician_energy_produces_mult` | **−50%** |
| Planetary food jobs | `planet_farmers_food_produces_mult` | **−50%** |

All five numbers are **tunable in one place**:
`common/scripted_variables/econ_space_economy_variables.txt`.

Planetary **research** is intentionally left untouched in this slice — the design
vision targets *primary* resources, and an empire-wide planetary-research nerf
would slow the whole game's tech pace rather than shift the space-vs-planet
balance.

### Files (zero vanilla overrides)

- `common/scripted_variables/econ_space_economy_variables.txt` — tunable values
- `common/static_modifiers/econ_space_economy_modifiers.txt` — `econ_space_primacy`
- `common/on_actions/econ_on_actions.txt` — appends to `on_game_start_country`
- `localisation/english/economy_overhaul_l_english.yml`

## Compatibility

**No vanilla files overridden.** The only vanilla touch-point is `on_game_start_country`,
and on_actions **merge** (our `effect` block runs *alongside* vanilla's, it does
not replace it). Safe to run beside `migration_overhaul`. See `docs/compatibility.md`.

## ⚠️ Runtime-verification checklist (logic-untested in-game)

Built by file-inspection against vanilla 4.4.3; **not yet tested in-game.** Verify
in the batched test session. Watch `error.log` throughout.

1. **Modifier applies to all empires.** Start a game, open the player country's
   modifier list → confirm **"Galactic Resource Distribution"** is present. (AI
   empires get it via the same on_action; spot-check via console `tweakergui` /
   observer mode if desired.)
2. **#1 KEY UNKNOWN — planet job nerf cascades from country scope.** Confirm a
   colony's miner jobs actually produce ~50% less mineral output and technician
   jobs ~50% less energy. This relies on country-scope `planet_<job>_<resource>_produces_mult`
   cascading to all owned planets. *Strong evidence it works* (vanilla economy
   techs use exactly these modifiers at country scope, e.g.
   `planet_miners_minerals_produces_mult` in `00_eng_tech.txt`), but confirm the
   actual per-planet job tooltip shows the reduction. If it does NOT apply:
   fallback is a `planet_modifier` granted to every owned planet via an
   `on_yearly_pulse_country` / colony on_action instead of a country modifier.
3. **Station buff applies.** Confirm a mining station's mineral output and a
   research station's output are ~50% higher than vanilla (check the station
   deposit tooltip / planet-orbit view).
4. **Net balance feel.** With defaults, is space clearly the better resource
   source without making early-game planets feel worthless? Tune the five
   variables (design target for mining is ~−66%, "3 → 1 minerals per 100 pops").
5. **No `error.log` spam** referencing `econ_space_primacy`, the on_action, or
   any of the five modifier names.
