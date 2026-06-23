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
| `common/scripted_variables/100_scripted_variables_zones.txt` | `economy_overhaul` | ⚠️ **WHOLE-FILE replacement** (verbatim vanilla copy): `@base_rural_district_jobs` **200 → 150** (basic-resource planet nerf) AND `@scaling_*`/`@bonus_*`/`@doubled_*` zone (specialist) job vars **−~30%** (cap specialist VOLUME, not output). Nomad + building job vars untouched. | 2026-06-23 |
| `common/deposits/01_orbital_deposits.txt` | `economy_overhaul` | ⚠️ **WHOLE-FILE replacement** (verbatim vanilla copy) with every `produces` value **×1.75** (richer deposits = space is primary; replaces the removed flat +50% station modifier). `drop_weight`/`habitat_modifier` untouched. | 2026-06-23 |
| `common/districts/00_urban_districts.txt` | `economy_overhaul` | ⚠️ **WHOLE-FILE replacement** (verbatim vanilla copy): `planet_housing_add` in the **urban** districts (city/hive/nexus + variants) **×0.70 (−30%)**. Rural + special districts untouched. Replaced the old global `planet_housing_mult` (which also cut rural/wide housing). | 2026-06-24 |
| `common/technology/00_eng_tech_repeatable.txt` (tech `tech_repeatable_improved_tile_mineral_output`) | `economy_overhaul` | Redefines the tech: per-level `planet_jobs_minerals_produces_mult` **0.05 → 0.03** (`@econ_repeatable_per_level`). All other fields faithful to vanilla. | 2026-06-22 |
| `common/technology/00_phys_tech_repeatable.txt` (tech `tech_repeatable_improved_tile_energy_output`) | `economy_overhaul` | Redefines the tech: per-level `planet_jobs_energy_produces_mult` **0.05 → 0.03**. | 2026-06-22 |
| `common/technology/00_soc_tech_repeatable.txt` (tech `tech_repeatable_improved_tile_food_output`) | `economy_overhaul` | Redefines the tech: per-level `planet_jobs_food_produces_mult` **0.05 → 0.03**. | 2026-06-22 |
| `common/governments/civics/02_gestalt_civics.txt` (civic `civic_machine_astromining_drones`) | `economy_overhaul` | Redefines the civic: `playable`/`ai_playable` → `{ always = no }` (disabled from selection). Rest faithful to vanilla. | 2026-06-22 |
| `common/governments/civics/03_corporate_civics.txt` (civic `civic_privatized_exploration`) | `economy_overhaul` | Redefines the civic: `station_gatherers`/`station_researchers_produces_mult` **0.25 → 0.10**. Rest faithful to vanilla. | 2026-06-22 |
| `common/scripted_variables/07_scripted_variables_machine_age.txt` | `economy_overhaul` | ⚠️ **WHOLE-FILE replacement** (verbatim vanilla copy) changing only `@arc_furnace_1-4_mod_value` + `@dyson_swarm_1-3_mod_value`, each cut **~60% (×0.4)**. All other vars (paperclip quotas, etc.) untouched. | 2026-06-23 |
| `common/defines/00_defines.txt` (`NGameplay.PLANET_ASCENSION_MODIFIER_SCALE`; `NPop` overcrowding thresholds) | `economy_overhaul` | Merge-override: ascension scale **0.10 → 0.05**; `OVERCROWDING_NO_GROWTH/DECLINE` (+ machine variants) **1.15→1.10 / 1.25→1.20** (housing scarcity bites sooner). Merge — only these keys change. | 2026-06-23 |

> **Override mechanism — two distinct kinds, do NOT confuse them (verified in-game 2026-06-23):**
> - **Scripted variables CANNOT be overridden by redefinition.** They are a flat global namespace
>   resolved **FIRST-definition-wins**; a mod always loads *after* vanilla, so a redefinition is
>   rejected (`error.log`: `Variable name X is already taken`) and vanilla's value is kept. Our
>   original `zzz_economy_overhaul_overrides.txt` approach silently failed for ALL its vars. The
>   **only** working method is a **whole-file replacement** (a mod file with the same name as the
>   vanilla file → vanilla file is not loaded at all → no duplicate). Hence the three
>   `00_/100_/07_` scripted_variables files above are full verbatim copies with only target values
>   changed. **Cost: heavy conflict surface (any other mod replacing them wins entirely) + must be
>   re-synced on any game-version bump.** This is unavoidable for scripted-variable changes.
> - **Technologies** (3 tile repeatables) live in
>   `economy_overhaul/common/technology/zzz_econ_repeatable_techs.txt`, and **civics** (Astro-Mining,
>   Privatized Exploration) live in `…/common/governments/civics/zzz_econ_civic_overrides.txt`. Both
>   are keyed DB objects: a same-key definition in our (later-loading) mod **replaces** that one
>   object. Each is a faithful copy of vanilla 4.4.3 with only the marked change; we are version-
>   pinned to 4.4.3 so copy-staleness is moot, but re-sync if the pin moves. (The tech file also
>   *adds* two new station repeatables — additive, not overrides.)
> - **Defines** live in `…/common/defines/zzz_econ_defines.txt`. Defines **merge**: restating
>   `NGameplay = { PLANET_ASCENSION_MODIFIER_SCALE = … }` changes only that key, vanilla keeps the rest.
>
> **Conflict risk:** the three whole-file scripted_variables replacements are the highest-risk
> overrides in the repo — any other mod touching those files conflicts outright. The DB-object
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

## Cross-Mod Dependencies

Track any cases where one mod depends on or interacts with another:

| Mod A | Mod B | Interaction | Notes |
|---|---|---|---|
| (none yet) | | | |
