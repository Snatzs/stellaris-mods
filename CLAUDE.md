# Stellaris Mods — AI Agent Instructions

## Project Context

This is a monorepo containing multiple Stellaris mods for a 7-player multiplayer campaign. Three developers collaborate using AI coding agents as primary developers. All mods in this repo are designed to be used together — compatibility matters.

## Game Version

**Target:** Stellaris 4.3

## Design Vision

**Read `docs/design-vision.md` before starting any mod work.** It defines the project's goals, design pillars, and specific changes the player group wants. This is a living document — it evolves as the group discusses. All mod decisions should align with its pillars:

1. Geography matters — territory worth fighting over
2. Scarcity drives strategy — resources force trade-offs and conflict
3. Wide > tall — more planets/pops/systems should always be good
4. Kill the "build" meta — no exploitable civic/origin/trait combos
5. Diplomacy with teeth — borders, federations, diplomacy have strategic weight

## Repository Layout

- `mods/<mod-name>/` — each mod is a self-contained Stellaris mod
- `docs/` — shared research, modding references, balance notes
- `docs/design-vision.md` — **design goals and specific changes** (read first)
- `docs/ROADMAP.md` — what's done, in progress, and still to do
- `tools/` — helper scripts (see **Tools** section below)

## Tools

### `tools/new-mod.sh` — Scaffold a new mod
**Use this whenever creating a new mod.** Do not manually create mod directories.
```bash
bash tools/new-mod.sh <mod-name> ["Display Name"]
# Example: bash tools/new-mod.sh economy_overhaul "Economy Overhaul"
```
Creates the full directory structure, `descriptor.mod`, localisation stub (UTF-8 with BOM), and README template under `mods/<mod-name>/`.

### `tools/validate.sh` — Validate mod files
**Run this before every commit.** Checks for:
- Mismatched brackets `{}` in `.txt` and `.mod` files
- Localisation keys referenced in scripts but not defined in `localisation/`
- Missing or malformed `descriptor.mod`
```bash
bash tools/validate.sh              # validate all mods
bash tools/validate.sh economy_overhaul  # validate one mod
```
Exit code 1 on errors, 0 on success (warnings don't fail).

### `tools/deploy.sh` — Deploy mods to Stellaris
Creates symlinks from the Stellaris mod directory to each mod in this repo, so changes are immediately reflected in-game.
```bash
bash tools/deploy.sh
```
Requires admin/Developer Mode on Windows.

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
supported_version = "4.3.*"
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

## Reference Documentation

Local wiki references are stored in `docs/wiki/`. Use these instead of web-fetching common modding topics.

### When to Consult References

| You're doing... | Read first |
|-----------------|-----------|
| Working on economy/resources/districts | `docs/vanilla/economy.md`, then `docs/wiki/modifiers.md` |
| Working on war goals/claims/combat | `docs/vanilla/warfare.md`, then `docs/wiki/effects.md` |
| Working on diplomacy/federations/ethics | `docs/vanilla/diplomacy.md`, then `docs/wiki/conditions.md` |
| Working on slavery/pops/migration | `docs/vanilla/population.md`, then `docs/wiki/scopes.md` |
| Writing any script logic | `docs/wiki/scopes.md`, `docs/wiki/effects.md`, `docs/wiki/conditions.md` |
| Adding modifiers to anything | `docs/wiki/modifiers.md` |
| Creating or modifying events | `docs/wiki/event_modding.md`, `docs/wiki/on_actions.md` |
| Adding technologies | `docs/wiki/technology_modding.md` |
| Adding buildings | `docs/wiki/building_modding.md` |
| Working with variables/counters | `docs/wiki/variables.md` |
| Writing reusable script blocks | `docs/wiki/dynamic_modding.md` |
| Adding player-visible text | `docs/wiki/localisation_modding.md` |
| Overriding vanilla files | `docs/compatibility.md` first |

### Vanilla 4.3 Architecture Docs

`docs/vanilla/` contains verified architecture references for vanilla game systems — key file paths, modifier names, on_actions, modding levers, and known engine limitations. **Read the relevant file before starting work on any mod.** These save significant research time. See `docs/vanilla/README.md` for the full index.

### Version Caveat

The wiki references cover versions 3.1–3.7. Core scripting (effects, conditions, scopes, modifiers) is stable, but **v4.0+ features** (Phoenix update zones, district rework, pop groups) may not be fully covered. For 4.0+ specifics, cross-reference against vanilla game files in `<Steam>/Stellaris/common/` or web-fetch the latest wiki page.

### When to Web Fetch

Only web-fetch for content guides **not** stored locally (ship, district, government, ethics, empire, army, war, diplomacy, portrait, interface, music modding) or when working with v4.0+ features not covered in local docs. URL pattern: `https://stellaris.paradoxwikis.com/<Topic>_modding`

See `docs/modding-reference.md` for a full index with cross-references.

## Vanilla Game Files

When you need to reference vanilla Stellaris files (to understand default values, override behavior, or check 4.0+ features), they are located in the Steam installation directory:

| Platform | Path |
|----------|------|
| Windows (this machine) | `D:\Stellaris\` |
| Windows (default Steam) | `C:\Program Files (x86)\Steam\steamapps\common\Stellaris\` |
| macOS | `~/Library/Application Support/Steam/steamapps/common/Stellaris/` |
| Linux | `~/.steam/steam/steamapps/common/Stellaris/` |

Key subdirectories mirror the mod structure: `common/`, `events/`, `localisation/`, etc. Always check vanilla files before overriding — understand the default before changing it.

## Branching Convention

- **`master`** — stable, tested, ready-to-play state
- **`mod/<mod-name>`** — feature branch for developing a specific mod (e.g. `mod/economy-overhaul`)
- **`fix/<description>`** — quick fix branches (e.g. `fix/bracket-mismatch-economy`)
- **`docs/<description>`** — documentation-only changes

**Workflow:**
1. Branch from `master` using the appropriate prefix
2. Make changes, run `bash tools/validate.sh` before committing
3. Merge back to `master` when the mod/fix is tested and ready
4. Delete the branch after merge

## When Working on This Project

1. **Read `docs/design-vision.md`** to understand what we're building and why
2. **Check `docs/ROADMAP.md`** to see what's done, in progress, and planned
3. **Read `docs/vanilla/<system>.md`** for the system you're modifying — understand vanilla architecture before changing it
4. **Read the mod's README** before modifying it
5. **Consult `docs/wiki/`** for scripting syntax — don't guess at effect/trigger names
6. **Check `docs/compatibility.md`** before overriding any vanilla game file
7. **Update `docs/compatibility.md`** after adding vanilla file overrides
8. **Update `docs/vanilla/`** if you discover new modifiers, on_actions, limitations, or workarounds not yet documented (see `docs/vanilla/README.md` for guidelines)
9. **Log balance decisions** in `docs/multiplayer-balance.md`
10. **Run `bash tools/validate.sh`** before committing — fix all errors
11. **Use `bash tools/new-mod.sh`** to create new mods — don't create mod directories manually
12. **Test changes** by describing what manual testing steps are needed
13. **Keep mods independent** where possible — minimize cross-mod dependencies
