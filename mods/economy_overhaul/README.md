# Economy Overhaul

Rebalances the resource economy so **space outproduces planets** — making *systems*
(not just planets) worth fighting over, planets scarce defensible anchors rather than
self-sufficient engines. Implements Track 1 (bulk minerals/energy) of the full design.

> **Read [`docs/economy-overhaul-design.md`](../../docs/economy-overhaul-design.md) first** —
> specifically the **"v2 — Revised decisions (2026-06-23)"** section, which is authoritative.
>
> ⚠️ **v2 changes (2026-06-23) not yet fully reflected in the slice text below — design doc wins:**
> - Space strength now comes from **buffed deposit yields** (`common/deposits/01_orbital_deposits.txt`),
>   with **per-resource** multipliers (v2.5/2026-06-26): **minerals ×1.40, energy ×1.60, research ×1.15**;
>   alloys/food/consumer_goods/trade left at vanilla. (Was a uniform ×1.75 → ×1.40 to fix the
>   mineral/energy glut.) The old **flat +50% station modifier was REMOVED**.
> - **Housing is now CUT** (`planet_housing_mult −25%` + tighter overcrowding defines), not kept as a
>   surplus — 4.4 makes *houseless* the real pressure, *jobless* pops just become civilians.
> - **Specialist job VOLUME** cut via zone vars (`@scaling_district_* −~30%`); city districts grant no
>   jobs in 4.4 (housing only) — specialists come from zones.
> - Rural jobs **200→150**; Arc Furnace / Dyson Swarm output **×0.4** (deeper).
> - Planet-size cap (`@habitable_planet_max_size`) is **under in-game test**; if it doesn't cap
>   procedural worlds it's replaced by an `on_game_start` resize event.

## What's built

### Slice 1 — Bulk structural (planet-down) — PRIMARY lever
The "space > planets" goal is achieved by **bringing planets down, not inflating space**
(inflating base yields compounds with multipliers into late-game bloat). Two vanilla
scripted-variable changes, shipped as **whole-file replacements** of their defining files
(`common/scripted_variables/00_scripted_variables.txt` and `100_scripted_variables_zones.txt`):

| Lever | Vanilla → New | Effect |
|---|---|---|
| `@habitable_planet_max_size` | **25 → 18** | Planets generate at 12–18; truncating the range drops the average size for free → fewer districts (#districts ≈ planet size) → lower per-planet output ceiling → wide > tall, mega-planets capped. |
| `@base_rural_district_jobs` | **200 → 160** | Rural (mining/generator/farming) districts grant 160 jobs instead of 200. **Housing stays 200** (separate hardcoded literal — verified) → +40 surplus housing/district → overpopulation/unemployment pressure → housing & amenities finally matter. |

> **Why whole-file replacement, not a targeted `zzz_` redefinition?** Scripted variables
> **cannot be overridden by redefinition** — Stellaris is first-definition-wins, a mod loads after
> vanilla, so a redefinition is rejected (`error.log`: `Variable name X is already taken`) and
> vanilla's value is kept. Verified in-game 2026-06-23 (the original `zzz_` approach silently did
> nothing). The defining file must be replaced wholesale: each is a **verbatim copy of vanilla
> 4.4.3 with only the target value changed**, so all other variables in it stay vanilla. Cost:
> high conflict surface (any other mod replacing these files wins entirely) + re-sync on version
> bumps. See [`docs/vanilla/economy.md`](../../docs/vanilla/economy.md) → Override Mechanics. Logged
> in [`docs/compatibility.md`](../../docs/compatibility.md).

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

All numbers are tunable in `common/scripted_variables/` (planet size in the replaced
`00_scripted_variables.txt`, rural jobs in the replaced `100_scripted_variables_zones.txt`, the
station buffs in `econ_space_economy_variables.txt`).

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

### Slice 3 — Multiplier taming
Anything that multiplies station output in the same category compounds with slices 1–2. Left
unchecked, two civics become near-auto-picks and two scaling kilostructures (plus planetary
ascension) re-inflate the late game. Tamed (design levers #10–#13):

| Lever | Change | Mechanism |
|---|---|---|
| **Astro-Mining Drones** civic | **Disabled** from selection (`playable`/`ai_playable` → `always = no`) — cutting its +50% station buff would leave only a planet self-nerf (trap pick). | civic override |
| **Privatized Exploration** civic | Station bonuses **+0.25 → +0.10** (kept as a balanced pick). | civic override |
| **Orbital Arc Furnace** (4 tiers) | Per-tier `station_gatherers` output cut ~40% (0.25/0.50/0.75/1.00 → 0.15/0.30/0.45/0.60); build cap −1. | whole-file replace of `07_…machine_age.txt` + country modifier |
| **Dyson Swarm** (3 tiers) | Per-tier `station_gatherers`+`station_researchers` output cut ~40% (5/15/30 → 3/9/18); build cap −1. | whole-file replace of `07_…machine_age.txt` + country modifier |
| **Planetary Ascension** | `PLANET_ASCENSION_MODIFIER_SCALE` **0.10 → 0.05** (halve the per-tier designation amplifier; hard cap left at 10). | defines merge |

Fixed-output megastructures (Dyson **Sphere**, Matter Decompressor) are deliberately left alone —
their output is a separate silo untouched by our station buffs. The kilostructure build caps are
lowered via a negative `*_limit_add` country modifier on `econ_space_primacy` (additive, no override),
since the vanilla cap is `base 0 + sum of modifier:*_limit_add`. Tuning knobs:
`@arc_furnace_*_mod_value` / `@dyson_swarm_*_mod_value` (in the replaced
`07_scripted_variables_machine_age.txt`) and `@econ_kilostructure_limit_reduction`. Files:
`common/governments/civics/zzz_econ_civic_overrides.txt`, `common/defines/zzz_econ_defines.txt`.

## MP-fairness
All effects are **symmetric** across every empire (player + AI) and use no randomness — no single
player gains an advantage, no desync risk. The structural variables are galaxy-gen / district
constants (identical for everyone); the station modifier is applied to every empire identically.

## Files
- `common/scripted_variables/00_scripted_variables.txt` — ⚠️ whole-file vanilla replacement (planet size cap 18)
- `common/scripted_variables/100_scripted_variables_zones.txt` — ⚠️ whole-file vanilla replacement (rural jobs 160)
- `common/scripted_variables/07_scripted_variables_machine_age.txt` — ⚠️ whole-file vanilla replacement (kilostructure per-tier values)
- `common/scripted_variables/econ_space_economy_variables.txt` — station-buff values, repeatable per-level rate, + (unused) fine-tune nerf vars
- `common/static_modifiers/econ_space_economy_modifiers.txt` — `econ_space_primacy` (station buffs)
- `common/on_actions/econ_on_actions.txt` — appends to `on_game_start_country` (fires `econ_overhaul.1`)
- `events/econ_overhaul_events.txt` — `econ_overhaul.1`: applies `econ_space_primacy` to every empire
- `common/technology/zzz_econ_repeatable_techs.txt` — slice-2 tile-repeatable overrides + new station repeatables
- `common/governments/civics/zzz_econ_civic_overrides.txt` — slice-3 civic overrides (Astro-Mining, Privatized Exploration)
- `common/defines/zzz_econ_defines.txt` — slice-3 ascension-scale override
- `localisation/english/economy_overhaul_l_english.yml`

## What's NOT built yet (later slices — see design doc build order)
- **Slice 2 follow-up (optional):** amplify the finite vanilla station techs further (lever #6) —
  deferred; the slice-1 +50% station baseline is assumed sufficient until playtest says otherwise.
- **Slice 4 — strategic resources:** refining nerf + strategic repeatable + deposit concentration.

## ⚠️ Runtime-verification checklist (logic-untested in-game)

Built by file-inspection against vanilla 4.4.3; **not yet tested in-game.** Verify in the batched
test session. Watch `error.log` throughout.

### Structural overrides (slice 1) — #1 priority
1. **Whole-file replacement wins.** Start a **new** game; confirm habitable planets generate no
   larger than **18** (check several home/colonisable worlds) and that a rural district grants
   **160 jobs** (planet view → build a mining/generator/farming district → job count). If sizes are
   still up to 25 or districts still grant 200, another mod in the playset is also replacing
   `00_/100_` scripted_variables and winning load order — coordinate; see `docs/compatibility.md`.
   (Note: a `zzz_` *redefinition* does NOT work here — `error.log` `Variable name … already taken`;
   that was the original bug. These are full-file replacements now.)
2. **Housing stays 200 (unpaired).** Confirm a rural district still adds **200 housing** while
   granting only 160 jobs → a visible housing surplus / unemployment pressure as the planet fills.
3. **No death spiral.** Watch whether mid-size colonies tip into runaway unemployment/stability
   collapse. If so, soften `@base_rural_district_jobs` toward 170–180. (This is the #1 calibration
   target.)
4. **No `error.log` spam** referencing the scripted_variables files, the on_actions/event, or
   `econ_space_primacy`. Specifically there should be **no** `Variable name … already taken` and
   **no** `Unexpected token: effect` (those were the two original bugs, now fixed).

### Bulk scaling parity (slice 2)
4a. **Tile-repeatable overrides win.** Research one level of a vanilla tile repeatable (e.g.
   "Improved Mineral Tile Output") and confirm the bonus is **+3%**, not +5%. If +5%, another mod
   redefined the same tech and won load order — check error.log. (Tech DB objects DO override by
   last-wins, unlike scripted variables, so our `zzz_` tech file is correct here.)
4b. **New station repeatables appear.** After completing the finite chains (`tech_space_mining_5` /
   `tech_space_science_5`), confirm "Orbital Extraction Optimisation" and "Deep-Space Survey
   Networks" show up as repeatable research options, each granting **+3%** station output/level.
4c. **No broken-prerequisite / duplicate-key errors** in error.log referencing the five techs.

### Multiplier taming (slice 3)
4d. **Astro-Mining Drones gone.** In empire creation as a Machine Intelligence MegaCorp, confirm
   "Astro-Mining Drones" is **not** an available civic. (Also confirm AI machine empires don't roll it.)
4e. **Privatized Exploration cut.** As a corporate empire with that civic, its tooltip shows
   **+10%** station gatherers/researchers, not +25%.
4f. **Kilostructure output cut.** Build/observe an Orbital Arc Furnace and a Dyson Swarm; per-tier
   station output bonus matches the cut values (arc tier 1 = +15%, dyson tier 1 = +3% etc.).
4g. **Kilostructure caps −1.** With the relevant techs, the Arc Furnace / Dyson Swarm build limit
   is one lower than vanilla (check the "requires less than X" build tooltip).
4h. **Ascension scale halved.** A planet's ascension designation bonus grows by **+5%/tier**, not +10%.
4i. **No `error.log` errors** referencing the two civics, the kilostructure variables, the defines
   file, or `econ_space_primacy` (now also carries the two `*_limit_add` lines).

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
