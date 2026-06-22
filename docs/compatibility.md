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
| (no overrides yet) | | | |

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
