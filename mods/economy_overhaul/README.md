# Economy Overhaul

Rebalances the resource economy so **space outproduces planets** — making *systems*
(not just planets) worth fighting over, planets scarce defensible anchors rather than
self-sufficient engines. Implements Track 1 (bulk minerals/energy) of the full design.

> **Read [`docs/economy-overhaul-design.md`](../../docs/economy-overhaul-design.md) first.**
> It defines the three-track model and the build-order slices. This mod currently implements
> **slice 1 (bulk structural)** plus the surviving station-buff half of the original flat slice.

## What's built

### Slice 1 — Bulk structural (planet-down) — PRIMARY lever
The "space > planets" goal is achieved by **bringing planets down, not inflating space**
(inflating base yields compounds with multipliers into late-game bloat). Two **targeted
vanilla scripted-variable overrides** in
`common/scripted_variables/zzz_economy_overhaul_overrides.txt`:

| Lever | Vanilla → New | Effect |
|---|---|---|
| `@habitable_planet_max_size` | **25 → 18** | Planets generate at 12–18; truncating the range drops the average size for free → fewer districts (#districts ≈ planet size) → lower per-planet output ceiling → wide > tall, mega-planets capped. |
| `@base_rural_district_jobs` | **200 → 160** | Rural (mining/generator/farming) districts grant 160 jobs instead of 200. **Housing stays 200** (separate hardcoded literal — verified) → +40 surplus housing/district → overpopulation/unemployment pressure → housing & amenities finally matter. |

Both are **targeted variable redefinitions**, not whole-file replacements — the `zzz_`
filename sorts after every vanilla scripted-variable file so it wins last-loaded, while every
other vanilla variable stays vanilla (patch-safe). Logged in
[`docs/compatibility.md`](../../docs/compatibility.md) (the mod's first real vanilla overrides).

### Station-buff modifier (`econ_space_primacy`) — the surviving half of the original flat slice
A permanent **country** static modifier granted to **every empire** at game start via
additive `on_game_start_country` (zero vanilla overrides — on_actions merge):

| Lever | Modifier | Default |
|---|---|---|
| Mining-station output (minerals/energy/space strategics) | `station_gatherers_produces_mult` | **+50%** |
| Research-station output | `station_researchers_produces_mult` | **+50%** |

> The original flat **planetary per-pop nerf** (`planet_miners_minerals` / `planet_technician_energy`
> / `planet_farmers_food` `_produces_mult` −50%) is **removed from this modifier** — the structural
> cuts above now do the planet-down work, and stacking both risks an unemployment death spiral. The
> three `@econ_planet_*_nerf` variables remain (default **0**) as an optional fine-tune lever; re-wire
> them into `econ_space_primacy` only if playtest shows planets still over-produce *after* the
> structural cuts. Planetary **research** is deliberately never nerfed (vision targets PRIMARY
> resources; an empire-wide research nerf would just slow global tech pace).

All numbers are tunable in `common/scripted_variables/` (the two overrides in `zzz_…`, the station
buffs in `econ_space_economy_variables.txt`).

### Slice 2 — Bulk scaling parity (repeatable techs)
Slice 1 sets the space>planet *ratio*; slice 2 makes that ratio **hold over the whole game**
instead of eroding. Vanilla ships infinite tile-output repeatables (planet jobs +5%/level,
`levels = -1`) but **no station repeatable** — so left alone, planets out-scale stations late.
Fix, all at one shared gentle rate (`@econ_repeatable_per_level`, default **+3%/level**):

| Change | Tech(s) | Effect |
|---|---|---|
| **Nerf** vanilla tile repeatables (override) | `tech_repeatable_improved_tile_{mineral,energy,food}_output` | per-level 0.05 → **0.03** (bloat control, Cetus-safe) |
| **Add** station-gatherers repeatable | `tech_repeatable_econ_station_gatherers_output` (after `tech_space_mining_5`) | `station_gatherers_produces_mult` **+0.03/level** |
| **Add** research-station repeatable | `tech_repeatable_econ_station_researchers_output` (after `tech_space_science_5`) | `station_researchers_produces_mult` **+0.03/level** |

One rate for all five = planet and space scaling "climb together but gently," so the ratio set by
slice 1 is preserved as tech advances. The three tile overrides are faithful copies of vanilla
4.4.3 with only the per-level value changed (logged in `compatibility.md`); the two new techs are
additive. File: `common/technology/zzz_econ_repeatable_techs.txt`.

## MP-fairness
All effects are **symmetric** across every empire (player + AI) and use no randomness — no single
player gains an advantage, no desync risk. The structural variables are galaxy-gen / district
constants (identical for everyone); the station modifier is applied to every empire identically.

## Files
- `common/scripted_variables/zzz_economy_overhaul_overrides.txt` — the two vanilla-variable overrides
- `common/scripted_variables/econ_space_economy_variables.txt` — station-buff values, repeatable per-level rate, + (unused) fine-tune nerf vars
- `common/static_modifiers/econ_space_economy_modifiers.txt` — `econ_space_primacy` (station buffs)
- `common/on_actions/econ_on_actions.txt` — appends to `on_game_start_country`
- `common/technology/zzz_econ_repeatable_techs.txt` — slice-2 tile-repeatable overrides + new station repeatables
- `localisation/english/economy_overhaul_l_english.yml`

## What's NOT built yet (later slices — see design doc build order)
- **Slice 2 follow-up (optional):** amplify the finite vanilla station techs further (lever #6) —
  deferred; the slice-1 +50% station baseline is assumed sufficient until playtest says otherwise.
- **Slice 3 — multiplier taming:** disable Astro-Mining Drones + Privatized Exploration civics;
  nerf+limit Arc Furnace / Dyson Swarm; halve `PLANET_ASCENSION_MODIFIER_SCALE`.
- **Slice 4 — strategic resources:** refining nerf + strategic repeatable + deposit concentration.

## ⚠️ Runtime-verification checklist (logic-untested in-game)

Built by file-inspection against vanilla 4.4.3; **not yet tested in-game.** Verify in the batched
test session. Watch `error.log` throughout.

### Structural overrides (slice 1) — #1 priority
1. **Load-order win.** Start a game; confirm habitable planets generate no larger than **18**
   (check several home/colonisable worlds) and that a rural district grants **160 jobs** (planet
   view → build a mining/generator/farming district → job count). If sizes are still up to 25 or
   districts still grant 200, the `zzz_` override lost load order — escalate the filename or
   coordinate playset load order; see `docs/compatibility.md`.
2. **Housing stays 200 (unpaired).** Confirm a rural district still adds **200 housing** while
   granting only 160 jobs → a visible housing surplus / unemployment pressure as the planet fills.
3. **No death spiral.** Watch whether mid-size colonies tip into runaway unemployment/stability
   collapse. If so, soften `@base_rural_district_jobs` toward 170–180. (This is the #1 calibration
   target.)
4. **No `error.log` spam** referencing the two variables or the override file.

### Bulk scaling parity (slice 2)
4a. **Tile-repeatable overrides win.** Research one level of a vanilla tile repeatable (e.g.
   "Improved Mineral Tile Output") and confirm the bonus is **+3%**, not +5%. If +5%, the `zzz_`
   tech file lost load order (or vanilla logged a duplicate but kept its own) — check error.log.
4b. **New station repeatables appear.** After completing the finite chains (`tech_space_mining_5` /
   `tech_space_science_5`), confirm "Orbital Extraction Optimisation" and "Deep-Space Survey
   Networks" show up as repeatable research options, each granting **+3%** station output/level.
4c. **No broken-prerequisite / duplicate-key errors** in error.log referencing the five techs.

### Station-buff modifier
5. **Modifier applies to all empires.** Open the player country's modifier list → confirm
   **"Galactic Resource Distribution"** is present (AI gets it via the same on_action).
6. **Station buff applies.** A mining station's mineral output and a research station's output are
   ~50% higher than vanilla (station deposit tooltip / planet-orbit view).
7. **No leftover planet nerf.** Confirm the modifier no longer shows any `planet_*_produces_mult`
   line (the per-pop nerf was removed; planet-down is structural now).

### Net feel
8. **Aggregate space > planets.** Across a developed empire, is space (stations) clearly the larger
   mineral/energy source vs planets, *without* early-game planets feeling worthless? Tune the size
   cap / jobs cut / station buffs together.
