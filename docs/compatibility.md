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
| `common/scripted_variables/00_scripted_variables.txt` (var `@habitable_planet_max_size`) | `economy_overhaul` | Redefines `@habitable_planet_max_size` **25 → 18** (planet size cap). | 2026-06-22 |
| `common/scripted_variables/100_scripted_variables_zones.txt` (var `@base_rural_district_jobs`) | `economy_overhaul` | Redefines `@base_rural_district_jobs` **200 → 160** (rural-district jobs cut; housing stays 200 — separate literal). | 2026-06-22 |
| `common/technology/00_eng_tech_repeatable.txt` (tech `tech_repeatable_improved_tile_mineral_output`) | `economy_overhaul` | Redefines the tech: per-level `planet_jobs_minerals_produces_mult` **0.05 → 0.03** (`@econ_repeatable_per_level`). All other fields faithful to vanilla. | 2026-06-22 |
| `common/technology/00_phys_tech_repeatable.txt` (tech `tech_repeatable_improved_tile_energy_output`) | `economy_overhaul` | Redefines the tech: per-level `planet_jobs_energy_produces_mult` **0.05 → 0.03**. | 2026-06-22 |
| `common/technology/00_soc_tech_repeatable.txt` (tech `tech_repeatable_improved_tile_food_output`) | `economy_overhaul` | Redefines the tech: per-level `planet_jobs_food_produces_mult` **0.05 → 0.03**. | 2026-06-22 |
| `common/governments/civics/02_gestalt_civics.txt` (civic `civic_machine_astromining_drones`) | `economy_overhaul` | Redefines the civic: `playable`/`ai_playable` → `{ always = no }` (disabled from selection). Rest faithful to vanilla. | 2026-06-22 |
| `common/governments/civics/03_corporate_civics.txt` (civic `civic_privatized_exploration`) | `economy_overhaul` | Redefines the civic: `station_gatherers`/`station_researchers_produces_mult` **0.25 → 0.10**. Rest faithful to vanilla. | 2026-06-22 |
| `common/scripted_variables/07_scripted_variables_machine_age.txt` (vars `@arc_furnace_1-4_mod_value`, `@dyson_swarm_1-3_mod_value`) | `economy_overhaul` | Redefines the per-tier kilostructure output values, each cut ~40% (×0.6). | 2026-06-22 |
| `common/defines/00_defines.txt` (`NGameplay.PLANET_ASCENSION_MODIFIER_SCALE`) | `economy_overhaul` | Merge-override: **0.10 → 0.05** (halves the per-tier ascension designation amplifier). | 2026-06-22 |

> **Override mechanism (none are whole-file replacements):** every override is a
> **targeted redefinition** in a `zzz_`-prefixed file, never a replacement of the vanilla file.
> - **Scripted variables** (planet size / rural jobs + the 7 kilostructure mod-values) live in
>   `economy_overhaul/common/scripted_variables/zzz_economy_overhaul_overrides.txt`. Scripted
>   variables resolve **last-loaded-wins** by filename; `zzz_` sorts after every vanilla
>   numeric-prefixed file, so our values win while every other vanilla variable stays vanilla.
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
> **Conflict risk:** any *other* mod that redefines these same variables/techs/civics/defines in a
> file sorting after `zzz_` (or loading later in the playset) would win instead — coordinate here if
> that ever happens. ⚠️ Load-order wins are file-inspection-reasoned; confirm in-game (error.log +
> actual planet sizes, district job counts, repeatable per-level values, civic availability, and
> ascension/kilostructure tooltips).

**Note on additive `on_actions`:** `migration_overhaul` and `economy_overhaul` both
append to vanilla `on_action` hooks (e.g. `on_game_start_country`,
`on_pop_group_resettled`). These are **merges, not overrides** — every mod's
`effect`/`events` block runs alongside vanilla's — so they are not listed in the
override registry. If a future mod ever *replaces* a vanilla on_actions file
wholesale, that IS an override and must be logged.

## Cross-Mod Dependencies

Track any cases where one mod depends on or interacts with another:

| Mod A | Mod B | Interaction | Notes |
|---|---|---|---|
| (none yet) | | | |
