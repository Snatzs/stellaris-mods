# Stellaris Mods — AI Agent Instructions

## Project Context

This is a monorepo containing multiple Stellaris mods for a 7-player multiplayer campaign. Three developers collaborate using AI coding agents as primary developers. All mods in this repo are designed to be used together — compatibility matters.

## Game Version

**Target:** Stellaris 3.x (update to exact version + DLCs owned)

## Repository Layout

- `mods/<mod-name>/` — each mod is a self-contained Stellaris mod
- `docs/` — shared research, modding references, balance notes
- `tools/` — helper scripts (deploy, validation)

## Stellaris Mod Structure

Each mod under `mods/` must follow the standard Stellaris mod directory layout:

```
mods/<mod-name>/
├── descriptor.mod          # Required — mod metadata
├── README.md               # Mod-specific documentation
├── common/                 # Game data definitions
│   ├── buildings/
│   ├── technologies/
│   ├── traditions/
│   ├── civics/
│   ├── traits/
│   ├── governments/
│   ├── pop_jobs/
│   ├── districts/
│   ├── megastructures/
│   ├── ship_sizes/
│   ├── component_templates/
│   ├── policies/
│   ├── edicts/
│   ├── decisions/
│   ├── diplomatic_actions/
│   ├── species_rights/
│   ├── static_modifiers/
│   ├── scripted_effects/
│   ├── scripted_triggers/
│   ├── scripted_variables/
│   ├── on_actions/
│   └── ...
├── events/                 # Event definitions
├── localisation/           # Text strings (english/ subfolder)
│   └── english/
├── gfx/                    # Graphics and icons
├── interface/              # UI definitions (.gui files)
├── prescripted_countries/  # Pre-made empires
├── map/                    # Galaxy generation
├── sound/                  # Audio
└── flags/                  # Empire flags
```

## Coding Conventions

### File Naming
- Use **snake_case** for all file names: `my_building.txt`, `my_event.txt`
- Prefix mod-specific files with the mod's short identifier to avoid conflicts: `<mod_prefix>_buildings.txt`

### Scripting Style
- Use **tabs** for indentation in Stellaris script files (`.txt`, `.mod`)
- Use `#` comments to explain non-obvious logic
- Group related entries in the same file rather than splitting into many tiny files
- Always include localisation keys for any player-visible text

### Localisation
- Always provide English localisation at minimum
- Localisation files must be UTF-8 with BOM encoding
- File format: `l_english:` header, then `KEY:0 "value"` entries

### descriptor.mod Format
```
name = "Mod Display Name"
path = "mod/<mod-folder-name>"
supported_version = "3.x.*"
tags = {
	"Gameplay"
}
```

## Multiplayer Considerations

- **Balance**: mods should not give any single player a disproportionate advantage
- **Determinism**: avoid randomness that could cause multiplayer desyncs
- **Performance**: minimize event polling; prefer on_action triggers over `mean_time_to_happen`
- **Compatibility**: check `docs/compatibility.md` before overriding vanilla files — another mod may already modify them

## Common Pitfalls to Avoid

- Do NOT use `mean_time_to_happen` in multiplayer mods (desync risk) — use `on_action` triggers instead
- Do NOT forget to add localisation for every key — missing loc shows raw keys to players
- Do NOT overwrite entire vanilla files — use targeted additions/overrides when possible
- Do NOT use hardcoded empire/country IDs — use scopes and event targets
- Do NOT create circular event chains without exit conditions
- Ensure every `if` block has proper bracket closure — Stellaris parser errors are cryptic

## When Working on This Project

1. **Read the mod's README** before modifying it
2. **Check `docs/compatibility.md`** before overriding any vanilla game file
3. **Update `docs/compatibility.md`** after adding vanilla file overrides
4. **Test changes** by describing what manual testing steps are needed
5. **Keep mods independent** where possible — minimize cross-mod dependencies
