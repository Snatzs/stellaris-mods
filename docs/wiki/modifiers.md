# Stellaris Modifier Modding Reference

> Source: https://stellaris.paradoxwikis.com/Modifier_modding

## Overview

A **modifier** influences a scope's gameplay state (country, planet, etc.). Modifiers are applied through `modifier` or `triggered_modifier` fields in various game objects.

## Modifier Types & Calculation

Three modifier types affect resources differently:

- **add**: Direct addition/subtraction of a fixed amount
- **mult**: Percentage-based increase/decrease (1 = +100%)
- **reduction**: Divisor applied after add/mult calculations

### Formula
```
((x + Σadd) × (1 + Σmult)) × (1 - reduction)
```

**Example**: Building costing 400 minerals with `planet_buildings_minerals_cost_mult = 1`:
```
400 × (1 + 1) = 800 minerals
```

## Objects Accepting Modifiers

| Object | Field | Scope | Triggered |
|--------|-------|-------|-----------|
| Agendas | `modifier` | country | No |
| Ascension Perks | `modifier` | country | No |
| Buildings | `planet_modifier`, `country_modifier` | planet/country | Yes (planet) |
| Components | `modifier`, `ship_modifier` | ship | No |
| Deposits | `planet_modifier`, `country_modifier`, `blocked_modifier` | planet/country | Yes |
| Districts | `planet_modifier` | planet | No |
| Edicts | `modifier` | country | No |
| Ethics | `country_modifier` | country | No |
| Federation Laws | `modifier` | Federation | No |
| Megastructures | `country_modifier`, `station_modifier`, `ship_modifier` | multi | No |
| Planet Classes | `modifier` | planet | No |
| Pop Jobs | `pop_modifier`, `planet_modifier`, `country_modifier` | multi | Yes |
| Starbases | `station_modifier`, `country_modifier`, `ship_modifier`, `orbit_modifier`, `system_modifier` | multi | Yes |
| Technologies | `modifier` | country | No |
| Traditions | `modifier` | country | Yes |
| Traits (Species) | `modifier`, `growing_modifier`, `assembling_modifier`, `declining_modifier` | species/planet | No |
| Traits (Leader) | `modifier`, `self_modifier` | leader/scope | No |

## Core Modifiers Reference

### Country-Level Modifiers

| Modifier | Effect |
|----------|--------|
| `all_technology_research_speed` | Multiplier for all tech research (0.10 = +10%) |
| `country_edict_fund_add` | Adds to edict fund pool |
| `country_leader_pool_size` | Number of leaders available to recruit |
| `country_megastructure_build_cap_add` | Simultaneous megastructure builds |
| `country_resource_max_add` | Maximum stockpile (all resources) |
| `country_trust_cap_add` | Maximum trust above 100 |
| `country_war_exhaustion_mult` | War exhaustion accumulation rate |
| `country_x_tech_research_speed` | Branch-specific research (engineering, physics, society) |
| `diplo_weight_mult` | Diplomatic weight modifier |
| `federation_naval_cap_contribution_mult` | Federation naval capacity contribution |

### Planet/Building Modifiers

| Modifier | Effect |
|----------|--------|
| `planet_amenities_x` | Planet amenities (add/mult) |
| `planet_building_capacity_add` | Simultaneous building construction slots |
| `planet_building_build_speed_mult` | All building build speed |
| `planet_buildings_cost_mult` | Building resource costs |
| `planet_buildings_upkeep_mult` | Building resource upkeep |
| `planet_max_buildings_add` | Total building slots allowed |
| `planet_max_districts_x` | District count (add/mult) |
| `planet_stability_add` | Planetary stability |

### District Modifiers

| Modifier | Effect |
|----------|--------|
| `district_x_max` | Maximum districts of type (farming, generator, mining) |
| `planet_district_x_build_speed_mult` | Specific district type build speed |
| `planet_districts_cost_mult` | All district costs |

### Job/Pop Modifiers

| Modifier | Effect |
|----------|--------|
| `job_x_add` | Add jobs to planet |
| `planet_jobs_x_produces_mult` | Specific job output |
| `planet_jobs_produces_mult` | All job production |
| `planet_jobs_upkeep_mult` | Job resource upkeep |
| `pop_amenities_usage_x` | Pop amenity consumption (add/base/mult) |
| `pop_citizen_happiness` | Non-slave population happiness |
| `pop_growth_x` | Population growth (speed, speed_reduction, from_immigration) |
| `pop_happiness` | All population happiness |
| `pop_housing_usage_x` | Housing consumption (add/base/mult) |

### Ship/Fleet Modifiers

| Modifier | Effect |
|----------|--------|
| `ship_x_add` | Ship attributes (armor, hull, shield, evasion, sensor_range, tracking, hyperlane_range) |
| `ship_x_mult` | Ship multipliers (damage, fire_rate, speed, evasion, shield_penetration, tracking, emergency_ftl) |
| `ship_accuracy_x` | Weapon accuracy (add/mult) |
| `ship_armor_reduction` | Armor penetration bonus |
| `ship_speed_x` | Speed modifier (mult/reduction) |
| `ships_upkeep_mult` | Fleet upkeep costs |
| `shipsize_x_build_speed_mult` | Ship class build speed |

### Army Modifiers

| Modifier | Effect |
|----------|--------|
| `armies_x_mult` | Army recruitment/maintenance cost |
| `army_health` | All army health |
| `army_morale` | All army morale |
| `army_x_mult` | Army attributes (damage, morale_damage, disengage_chance, experience_gain) |

### Research/Technology Modifiers

| Modifier | Effect |
|----------|--------|
| `category_x_research_speed_mult` | Tech category speed (biology, computing, materials, etc.) |
| `num_tech_alternatives_add` | Available research options (default 3) |
| `tech_cost_empire_size_mult` | Empire size penalty on tech costs |

### Leader Modifiers

| Modifier | Effect |
|----------|--------|
| `admiral_skill_levels` | Admiral skill point pool |
| `general_skill_levels` | General skill point pool |
| `governor_skill_levels` | Governor skill point pool |
| `leader_cap` | Maximum leaders country-wide |
| `leader_lifespan_add` | Leader lifespan extension |
| `scientist_skill_levels` | Scientist skill points |

### Starbase Modifiers

| Modifier | Effect |
|----------|--------|
| `starbase_building_capacity_add` | Starbase building construction slots |
| `starbase_defense_platform_capacity_add` | Defense platform slots |
| `starbase_module_capacity_add` | Module slots |
| `starbase_shipyard_capacity_add` | Shipyard queue slots |
| `starbase_trade_protection_add` | Trade route protection |
| `starbases_upkeep_mult` | All starbase upkeep |

### Trade & Commerce

| Modifier | Effect |
|----------|--------|
| `country_trade_fee` | Market trading fee percentage |
| `trade_value_x` | Trade value generation (add/mult) |

### Diplomacy Modifiers

| Modifier | Effect |
|----------|--------|
| `country_trust_growth` | AI empire trust accumulation |
| `diplomacy_upkeep_mult` | All diplomatic relations upkeep |
| `subject_integration_influence_cost_mult` | Subject integration cost |

### Combat Modifiers

| Modifier | Effect |
|----------|--------|
| `damage_vs_country_type_x_mult` | Damage against specific empire types |
| `weapon_role_x_mult` | Weapon role modifiers (point_defense, artillery, anti_shield, anti_hull, anti_armor) |
| `weapon_type_x_mult` | Weapon type modifiers (kinetic, explosive, energy, strike_craft) |

### Miscellaneous

| Modifier | Effect |
|----------|--------|
| `ascension_perks_add` | Available ascension perk slots |
| `building_time_mult` | Building construction duration |
| `colony_start_num_pops_add` | Initial colonist population |
| `habitability_x_y` | Habitability floor/ceiling (add/mult) |
| `planet_colony_development_speed_mult` | Colony establishment speed |
| `pop_environment_tolerance` | Habitability tolerance |
| `science_ship_survey_speed` | Survey speed for science ships |
| `terraforming_cost_mult` | Terraforming resource costs |

## Economic Categories

Economic categories define hierarchical modifier structures for resource costs, production, and upkeep.

### Structure Example
```
planet_districts = {
    parent = planet_structures

    generate_mult_modifiers = { cost upkeep produces }

    triggered_cost_modifier = {
        key = planet_districts_hab
        modifier_types = { mult }
        trigger = {
            uses_district_set = habitat
        }
    }
}
```

This generates:
- `planet_districts_cost_mult`
- `planet_districts_upkeep_mult`
- `planet_districts_produces_mult`
- `planet_districts_hab_cost_mult` (triggered)

### Category Fields

| Field | Purpose |
|-------|---------|
| `parent` | Parent category for inheritance |
| `hidden = yes` | Merge display into parent |
| `generate_mult_modifiers` | Create `_mult` variants (cost/upkeep/produces) |
| `generate_add_modifiers` | Create `_add` variants |
| `use_for_ai_budget` | Has own AI budget entry |
| `triggered_cost_modifier` | Conditional cost modifier |
| `triggered_upkeep_modifier` | Conditional upkeep modifier |
| `triggered_produces_modifier` | Conditional production modifier |

## Auto-Generated Modifiers

System auto-generates modifiers for:

1. **Species Archetypes**: `<archetype>_species_trait_points_add`
2. **Ethics**: `pop_ethic_[fanatic_]<ethic>_attraction_mult`
3. **Tech Categories**: `category_<category>_research_speed_mult`
4. **Ship Sizes**: `shipsize_<size>_build_speed_mult`, `shipsize_<size>_hull_mult/add`
5. **Ship Classes**: `shipclass_<class>_build_cost_mult`, `shipclass_<class>_hull/damage/evasion/disengage_mult`
6. **Building Tags**: `<building>_construction_speed_mult`, `<building>_build_cost_mult`
7. **Component Tags**: `<component>_weapon_damage_mult`, `<component>_weapon_fire_rate_mult`
8. **Planet Habitability**: `pc_<class>_habitability` (no GFX required)

## Static Modifiers

Static modifiers are game objects in `common/static_modifiers/xxx.txt`.

### Structure
```
example_modifier = {
    planet_stability_add = 10
    icon = path/to/icon.dds
    icon_frame = 1
    custom_tooltip = my_tt_key
}
```

### Integration
```
# Any modifier block can call:
example_modifier = 1.5  # Multiplies all contained modifiers by 1.5
```

## Triggered Modifiers

Triggered modifiers apply conditionally using scope-specific triggers:

```
triggered_produces_modifier = {
    key = planet_jobs_slave
    modifier_types = { mult }
    trigger = {
        is_pop_category = slave
    }
}
```

## Common Modifier Patterns

### Resource Modifiers
```
planet_buildings_minerals_cost_mult = 0.25      # Buildings cost 25% more minerals
planet_jobs_produces_mult = 0.10                # All jobs produce 10% more
ships_upkeep_mult = -0.15                       # Ships cost 15% less upkeep
```

### Multiplier vs. Reduction
```
pop_growth_speed = 0.25                         # 25% faster growth
pop_growth_speed_reduction = 0.25               # Growth multiplied by 0.75
```

Reduction applies **after** all add/mult calculations for stronger impact.

## See Also
- [Effects](effects.md) — `add_modifier` / `remove_modifier` effects
- [Building Modding](building_modding.md) — using modifiers in buildings
- [Technology Modding](technology_modding.md) — using modifiers in technologies
- [Dynamic Modding](dynamic_modding.md) — scripted modifiers (v3.4+)
