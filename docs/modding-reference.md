# Stellaris Modding Reference

A quick-reference guide for Stellaris mod development. This is a living document — update as we learn more.

## Key Concepts

### How Stellaris Loads Mods

- Mods override vanilla files by matching the same path. If your mod has `common/buildings/my_buildings.txt`, it **adds** to the buildings list.
- If your mod has a file with the **same name** as a vanilla file (e.g., `common/buildings/00_capital_buildings.txt`), it **replaces** the vanilla file entirely.
- Load order matters — later mods override earlier ones for same-name files.

### Scopes

Stellaris scripting uses a scope system. Common scopes:

| Scope | Description |
|-------|-------------|
| `country` | An empire |
| `planet` | A planet |
| `pop` | A population unit |
| `leader` | A leader |
| `fleet` | A fleet |
| `ship` | A ship |
| `galactic_object` | A star system |
| `sector` | A sector |
| `federation` | A federation |
| `species` | A species |

### Common Scripted Conditions

```
is_ai = yes/no
has_technology = <tech_key>
has_building = <building_key>
has_modifier = <modifier_key>
has_civic = <civic_key>
has_trait = <trait_key>
num_pops > X
is_at_war = yes/no
```

### Common Effects

```
add_modifier = { modifier = <key> days = X }
add_resource = { minerals = X energy = X }
remove_building = <key>
set_planet_flag = <flag>
create_pop = { species = owner_main_species }
```

## Useful Resources

- [Stellaris Wiki — Modding](https://stellaris.paradoxwikis.com/Modding) — official modding docs
- [Stellaris Wiki — Conditions](https://stellaris.paradoxwikis.com/Conditions) — full conditions list
- [Stellaris Wiki — Effects](https://stellaris.paradoxwikis.com/Effects) — full effects list
- [Stellaris Wiki — Scopes](https://stellaris.paradoxwikis.com/Scopes) — scope documentation
- Vanilla game files (best reference) — typically at `<Steam>/Stellaris/common/`

## Tips

- When in doubt, look at how vanilla does it. Copy a vanilla file and modify it.
- Use `error.log` in `Documents/Paradox Interactive/Stellaris/logs/` for debugging.
- The game console (`~` key) is essential for testing: `event <event_id>`, `research_all_technologies`, `cash 10000`, etc.
