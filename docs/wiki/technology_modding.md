# Stellaris Technology Modding Reference

> Source: https://stellaris.paradoxwikis.com/Technology_modding

## Basic Structure

```
technology_name = {
    cost = @tier1cost1
    area = society              # physics, society, or engineering
    tier = 1                    # 0-5
    category = { biology }      # Single category only
    weight = @tier1weight1
    prerequisites = { "tech_name" }

    potential = { }             # Conditions to access tech
    modifier = { }              # Game effects
    weight_modifier = { }       # Draw probability modifiers
    ai_weight = { }             # AI research preferences
}
```

## Key Fields

| Field | Description | Values |
|-------|-------------|--------|
| `cost` | Research points required | Integer or constant |
| `area` | Research department | physics, society, engineering |
| `tier` | Technology level | 0-5 |
| `category` | Expertise bonus category | See categories below |
| `weight` | Base draw likelihood | Integer |
| `prerequisites` | Required techs | Array of tech IDs |
| `levels` | Repeatable count | -1 (infinite), integer, or omitted |
| `ai_update_type` | Auto-update ships | military, all |
| `start_tech` | Starting technology | yes/no |
| `is_rare` | Purple display | yes/no |
| `is_dangerous` | Red display | yes/no |

## Standard Cost Variables

```
@tier1cost1 = 2000    @tier2cost1 = 4000    @tier3cost1 = 8000
@tier1cost2 = 2500    @tier2cost2 = 5000    @tier3cost2 = 10000
@tier1cost3 = 3000    @tier2cost3 = 6000    @tier3cost3 = 12000

@tier4cost1 = 16000   @tier5cost1 = 32000
@tier4cost2 = 20000   @tier5cost2 = 40000
@tier4cost3 = 24000   @tier5cost3 = 48000
```

## Standard Weight Variables

```
@tier1weight1 = 100   @tier2weight1 = 85    @tier3weight1 = 65
@tier1weight2 = 95    @tier2weight2 = 75    @tier3weight2 = 60
@tier1weight3 = 90    @tier2weight3 = 70    @tier3weight3 = 50

@tier4weight1 = 45    @tier5weight1 = 30
@tier4weight2 = 40    @tier5weight2 = 25
@tier4weight3 = 35    @tier5weight3 = 20
```

## Categories

**Physics:** field_manipulation, particles, computing

**Society:** psionics, new_worlds, statecraft, biology, military_theory

**Engineering:** materials, rocketry, voidcraft, industry

## Tier Requirements

Tiers unlock after researching a minimum number of technologies in the previous tier:

- Tier 0: Starting techs
- Tier 1: 0 techs required
- Tier 2: 6 techs from Tier 1
- Tier 3: 6 techs from Tier 2
- Tier 4: 6 techs from Tier 3
- Tier 5: 6 techs from Tier 4

## Weight Modifiers

```
weight_modifier = {
    factor = 1.5
    modifier = {
        factor = 0.75
        has_ethic = ethic_pacifist
    }
    modifier = {
        add = 3
        has_ethic = ethic_militarist
    }
}
```

### Research Leader Modifiers

```
research_leader = {
    area = society
    has_trait = "leader_trait_expertise_biology"
    has_level > 2
}
```

## AI Weight

```
ai_weight = {
    modifier = {
        factor = 1.25
        has_ethic = ethic_pacifist
    }
}
```

## Example Technology

```
tech_example = {
    cost = @tier2cost2
    area = engineering
    tier = 2
    category = { materials }
    prerequisites = { "tech_advanced_metallurgy_1" }
    weight = @tier2weight2

    modifier = {
        ship_armor_mult = 0.10
    }

    weight_modifier = {
        modifier = {
            factor = 1.5
            research_leader = {
                area = engineering
                has_trait = "leader_trait_expertise_materials"
            }
        }
    }
}
```

## Advanced Features

- **Repeatable Technologies:** `levels = -1` with `cost_per_level = @value`
- **Feature Flags:** `feature_flags = { flag_name }` for localization tooltips
- **Reverse Engineering:** `is_reverse_engineerable = yes` (component techs only)
- **Prerequisite Display:** `prereqfor_desc` shows what this tech unlocks

---

**Last verified:** Version 3.1

## See Also
- [Modifiers](modifiers.md) — modifier keys used in tech `modifier` blocks
- [Conditions](conditions.md) — `has_technology`, `can_research_technology` conditions
- [Building Modding](building_modding.md) — buildings that require technologies via `prerequisites`
- [Localisation Modding](localisation_modding.md) — localisation for tech names and descriptions
