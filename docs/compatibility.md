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

> **Override mechanism (not whole-file replacement):** both overrides live in
> `economy_overhaul/common/scripted_variables/zzz_economy_overhaul_overrides.txt`, which
> **redefines two scripted variables** rather than replacing the vanilla files. Scripted
> variables resolve **last-loaded-wins** by filename; the `zzz_` prefix sorts after every
> vanilla numeric-prefixed file, so our values win while every other vanilla variable in those
> files stays vanilla (patch-safe). **Conflict risk:** any *other* mod that redefines these same
> two variables in a file sorting after `zzz_` (or loading later in the playset) would win
> instead — coordinate here if that ever happens. ⚠️ Load-order win is file-inspection-reasoned;
> confirm in-game (error.log + actual planet sizes / district job counts).

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
