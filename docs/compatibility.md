# Mod Compatibility Tracker

This file tracks which vanilla files are overridden by our mods. **Always check here before overriding a vanilla file** — if two mods override the same file, they will conflict.

## How to Use

Before overriding a vanilla file in your mod:
1. Search this document for the file path.
2. If another mod already overrides it, coordinate with that mod's developer.
3. After adding an override, add an entry below.

## File Override Registry

| Vanilla File Path | Overridden By Mod | What It Changes | Date Added |
|---|---|---|---|
| _(none — planet size cap)_ | `economy_overhaul` | **NOT an override.** `@habitable_planet_max_size` doesn't govern procedural generation (tested 2026-06-24), so the 00_scripted_variables.txt replacement was DROPPED. Size cap is now an `on_game_start` event (`econ_overhaul.2`) that resizes colonizable worlds to 16–18. Additive, zero override. | 2026-06-24 |
| _(none — job cuts)_ | `economy_overhaul` | **REVERTED 2026-06-27.** The `100_scripted_variables_zones.txt` whole-file override (rural jobs 200→150 + zone specialist jobs −30%) was **DROPPED** — too many planet-down levers stacked (size cap + housing + job cuts → double-nerf risk). Planet-down is now carried by **size cap (16–18) + housing scarcity** alone; the high Planetary-Deficit-Logistics galaxy setting handles anti-sprawl. Re-add only if playtest shows planets still over-produce. | 2026-06-27 |
| `common/deposits/01_orbital_deposits.txt` | `economy_overhaul` | ⚠️ **WHOLE-FILE replacement** (verbatim vanilla copy) with **per-resource** `produces` multipliers (v2.5/2026-06-26; richer deposits = space is the primary BULK economy, replaces the removed flat +50% station modifier): **minerals ×1.40, energy ×1.60, research ×1.15**; **alloys/food/consumer_goods/trade left at vanilla ×1.0** (alloys kept scarce by design; food/CG barely-or-never spawn). Was a uniform ×1.75 (v2) → ×1.40 (v2.4). `drop_weight`/`habitat_modifier` untouched. | 2026-06-26 |
| `common/districts/00_urban_districts.txt` | `economy_overhaul` | ⚠️ **WHOLE-FILE replacement** (verbatim vanilla copy): `planet_housing_add` in the **urban** districts (city/hive/nexus + variants) **×0.70 (−30%)**. Rural + special districts untouched. Replaced the old global `planet_housing_mult` (which also cut rural/wide housing). | 2026-06-24 |
| `common/technology/00_eng_tech_repeatable.txt` (tech `tech_repeatable_improved_tile_mineral_output`) | `economy_overhaul` | Redefines the tech: per-level `planet_jobs_minerals_produces_mult` **0.05 → 0.03** (`@econ_repeatable_per_level`). All other fields faithful to vanilla. | 2026-06-22 |
| `common/technology/00_phys_tech_repeatable.txt` (tech `tech_repeatable_improved_tile_energy_output`) | `economy_overhaul` | Redefines the tech: per-level `planet_jobs_energy_produces_mult` **0.05 → 0.03**. | 2026-06-22 |
| `common/technology/00_soc_tech_repeatable.txt` (tech `tech_repeatable_improved_tile_food_output`) | `economy_overhaul` | Redefines the tech: per-level `planet_jobs_food_produces_mult` **0.05 → 0.03**. | 2026-06-22 |
| `common/technology/00_eng_tech.txt` (techs `tech_space_mining_1`…`_5`) | `economy_overhaul` | **Lever #6** — redefines the 5 finite mining techs: `station_gatherers_produces_mult` (and the nomad-swap `tech_space_mining_nomads_mult`) flat **0.10 → escalating 0.10/0.20/0.30/0.40/0.50** (`@econ_station_mining_t1..5`, +150% cumulative vs vanilla +50%). Buffs minerals AND energy (shared category). All other fields faithful to vanilla. File `zzz_econ_finite_station_techs.txt`. | 2026-06-27 |
| `common/technology/00_phys_tech.txt` (techs `tech_space_science_1`…`_5`) | `economy_overhaul` | **Lever #6** — redefines the 5 finite research techs: `station_researchers_produces_mult` (and nomad-swap `tech_space_science_nomads_mult`) flat **0.10 → escalating 0.10/0.15/0.20/0.25/0.30** (`@econ_station_research_t1..5`, +100% cumulative; gentler than mining per Track 2 planet-primary research). Faithful otherwise. File `zzz_econ_finite_station_techs.txt`. | 2026-06-27 |
| `common/governments/civics/02_gestalt_civics.txt` (civic `civic_machine_astromining_drones`) | `economy_overhaul` | Redefines the civic: `playable`/`ai_playable` → `{ always = no }` (disabled from selection). Rest faithful to vanilla. | 2026-06-22 |
| `common/governments/civics/03_corporate_civics.txt` (civic `civic_privatized_exploration`) | `economy_overhaul` | Redefines the civic: `station_gatherers`/`station_researchers_produces_mult` **0.25 → 0.10**. Rest faithful to vanilla. | 2026-06-22 |
| `common/scripted_variables/07_scripted_variables_machine_age.txt` | `economy_overhaul` | ⚠️ **WHOLE-FILE replacement** (verbatim vanilla copy) changing only `@arc_furnace_1-4_mod_value` + `@dyson_swarm_1-3_mod_value`, each cut **~60% (×0.4)**. All other vars (paperclip quotas, etc.) untouched. | 2026-06-23 |
| `common/defines/00_defines.txt` (`NGameplay.PLANET_ASCENSION_MODIFIER_SCALE`; `NPop` overcrowding thresholds) | `economy_overhaul` | Merge-override: ascension scale **0.10 → 0.05**; `OVERCROWDING_NO_GROWTH/DECLINE` (+ machine variants) **1.15→1.10 / 1.25→1.20** (housing scarcity bites sooner). Merge — only these keys change. | 2026-06-23 |
| `common/economic_categories/00_common_categories.txt` (category `planet_resource_deficit`) | `economy_overhaul` | Single-key redefine (`common/economic_categories/zz_econ_deficit_category.txt`): adds `generate_mult_modifiers = { cost upkeep }` + `modifier_category = colony` to the otherwise modifier-less `planet_resource_deficit` category, so `planet_resource_deficit_cost_mult`/`_upkeep_mult` become real modifiers. Used to AI-exempt the "Planetary Deficit Logistics Costs" galaxy setting via `econ_ai_planet_relief` (`is_ai`, −1.0). `parent = planets` re-stated. ⚠️ Assumes economic categories override **per-key** (DB-object behaviour) — VERIFY error.log clean; fall back to whole-file replace if not. | 2026-06-28 |

> **Override mechanism — two distinct kinds, do NOT confuse them (verified in-game 2026-06-23):**
> - **Scripted variables CANNOT be overridden by redefinition.** They are a flat global namespace
>   resolved **FIRST-definition-wins**; a mod always loads *after* vanilla, so a redefinition is
>   rejected (`error.log`: `Variable name X is already taken`) and vanilla's value is kept. Our
>   original `zzz_economy_overhaul_overrides.txt` approach silently failed for ALL its vars. The
>   **only** working method is a **whole-file replacement** (a mod file with the same name as the
>   vanilla file → vanilla file is not loaded at all → no duplicate). Only **one** such replacement
>   now remains — `07_scripted_variables_machine_age.txt` (kilostructure values). The `00_` (size cap)
>   and `100_` (job cuts) whole-file replacements were both DROPPED (size cap → event; job cuts →
>   reverted), removing two high-risk overrides. **Cost of the survivor: heavy conflict surface (any
>   other mod replacing it wins entirely) + must be re-synced on any game-version bump.**
> - **Technologies** — (a) 3 tile repeatables in
>   `economy_overhaul/common/technology/zzz_econ_repeatable_techs.txt` (which also *adds* two new
>   station repeatables — additive), and (b) the **10 finite station techs** (`tech_space_mining_1..5`
>   + `tech_space_science_1..5`) in `…/zzz_econ_finite_station_techs.txt` (lever #6 escalating ramp);
>   and **civics** (Astro-Mining, Privatized Exploration) in
>   `…/common/governments/civics/zzz_econ_civic_overrides.txt`. All are keyed DB objects: a same-key
>   definition in our (later-loading) mod **replaces** that one object. Each is a faithful copy of
>   vanilla 4.4.3 with only the marked change; we are version-pinned to 4.4.3 so copy-staleness is
>   moot, but re-sync if the pin moves.
> - **AI economic relief** (`econ_ai_planet_relief`, `planet_housing_mult +0.30`, AI-only) is a NEW
>   static modifier applied via `econ_overhaul.1` gated `is_ai = yes` — **additive, zero override.**
>   Compensates for the AI being unable to perceive our overcrowding growth-stall (its planner is
>   deficit-driven). All 7 players are human, so the human-facing housing scarcity is untouched.
> - **Defines** live in `…/common/defines/zzz_econ_defines.txt`. Defines **merge**: restating
>   `NGameplay = { PLANET_ASCENSION_MODIFIER_SCALE = … }` changes only that key, vanilla keeps the rest.
>
> **Conflict risk:** the remaining whole-file scripted_variables replacement (`07_…machine_age`) is
> the highest-risk override class in the repo — any other mod replacing that file conflicts outright. The DB-object
> overrides (techs/civics) and the defines merge only conflict with a mod changing the *same* key.
> ✅ Mechanism verified in-game 2026-06-23 (civics + repeatable techs override; scripted-variable
> redefinition does not). Still runtime-verify the actual values (planet sizes, job counts,
> per-level %, tooltips) after any change.

**Note on additive `on_actions`:** `migration_overhaul` and `economy_overhaul` both
append to vanilla `on_action` hooks (e.g. `on_game_start_country`,
`on_pop_group_resettled`). These are **merges, not overrides** — every mod's block runs
alongside vanilla's — so they are not listed in the override registry. ⚠️ **on_actions do NOT
accept a bare `effect = {}` block** in 4.4.3 (parser error `Unexpected token: effect`; vanilla
uses it 0 times). Use `events = { <id> }` + a `hide_window`, `is_triggered_only` event that does
the work (see `economy_overhaul/events/econ_overhaul_events.txt`). If a future mod ever *replaces*
a vanilla on_actions file wholesale, that IS an override and must be logged.

**Note on `galaxy_setup` (additive, no overrides):** adds `map/setup_scenarios/galaxy_setup_1200.txt`
— a NEW 1200-star galaxy-size scenario (does NOT override vanilla `huge.txt` or any file) + its loc key
`galaxy_setup_colossal`. Zero conflict surface. Independent of `economy_overhaul` / `migration_overhaul`.

## Cross-Mod Dependencies

Track any cases where one mod depends on or interacts with another:

| Mod A | Mod B | Interaction | Notes |
|---|---|---|---|
| (none yet) | | | |
