# Stellaris Modding Reference

Quick-reference index for Stellaris mod development. Detailed references are in `docs/wiki/`.

For **what** to build, see [design-vision.md](design-vision.md). For **status**, see [ROADMAP.md](ROADMAP.md).

## Local Wiki References

### Core Scripting — consult these when writing any mod logic
- [Effects](wiki/effects.md) — all effects that modify game state (creating objects, setting flags, adding modifiers)
- [Conditions](wiki/conditions.md) — triggers for logic checks (has_technology, is_at_war, num_pops, etc.)
- [Scopes](wiki/scopes.md) — scope system, THIS/FROM/ROOT/PREV, dot notation, event targets
- [Modifiers](wiki/modifiers.md) — modifier types (add/mult/reduction), formula, all modifier keys by category
- [Variables](wiki/variables.md) — set/check/copy variables, arithmetic, export operations
- [On Actions](wiki/on_actions.md) — all vanilla on_actions with scope documentation
- [Dynamic Modding](wiki/dynamic_modding.md) — scripted effects/triggers, inline scripts, script values, flags

### Content Guides — consult these when building specific features
- [Event Modding](wiki/event_modding.md) — event types, structure, options, chaining, pre-triggers, performance
- [Technology Modding](wiki/technology_modding.md) — tech costs/weights/tiers, categories, weight modifiers
- [Building Modding](wiki/building_modding.md) — building properties, jobs, resources, upgrades, v4.0 zones
- [Localisation Modding](wiki/localisation_modding.md) — file format, UTF-8 BOM, bracket commands, color codes, icons

### Not stored locally — fetch on demand via WebFetch
Ship, District, Government, Ethics, Empire, Army, War, Diplomacy, Portrait, Interface, Music modding.
Base URL: `https://stellaris.paradoxwikis.com/<Topic>_modding`

## When to Use Which Reference

| Task | Consult |
|------|---------|
| Writing event logic (if/else, effects) | Effects, Conditions, Scopes |
| Adding modifiers to buildings/techs/traits | Modifiers |
| Creating events | Event Modding, On Actions |
| Adding technologies | Technology Modding |
| Adding buildings | Building Modding |
| Working with variables or counters | Variables |
| Creating reusable script blocks | Dynamic Modding |
| Adding player-visible text | Localisation Modding |
| Overriding vanilla files | [Compatibility Tracker](compatibility.md) first, then relevant content guide |

## Key Concepts

### How Stellaris Loads Mods
- Mods override vanilla files by matching the same path. A new file **adds** to the game.
- A file with the **same name** as a vanilla file **replaces** it entirely.
- Load order matters — later mods override earlier ones for same-name files.
- **Events** are the exception: they use "First In Only Serve" — prefix override files with `!` or `!!`.

### Debugging
- Use `error.log` in `Documents/Paradox Interactive/Stellaris/logs/` for debugging.
- Game console (`~` key): `event <id>`, `research_all_technologies`, `cash 10000`, `debugtooltip`
- When in doubt, look at how vanilla does it in `<Steam>/Stellaris/common/`.
