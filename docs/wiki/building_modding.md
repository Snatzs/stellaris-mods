# Stellaris Building Modding Reference

> Source: https://stellaris.paradoxwikis.com/Building_modding

## Basic Structure

```
building_sample_monument = {
    # Building properties go here
}
```

Localization keys:
- `building_sample_monument`: "Display Name"
- `building_sample_monument_desc`: "Description text"

## Core Properties

### Build & Upgrade
| Property | Type | Description |
|----------|------|-------------|
| `base_buildtime` | int | Days to construct or upgrade |
| `upgrades` | list | Buildings this can upgrade into |
| `can_build` | bool | Whether buildable (default: yes) |
| `can_demolish` | bool | Whether demolishable (default: yes) |
| `can_be_ruined` | bool | Whether can become ruined (default: yes) |
| `can_be_disabled` | bool | Whether can be turned off (default: yes) |

### Organization
| Property | Type | Description |
|----------|------|-------------|
| `icon` | key | Icon filename from gfx folder |
| `category` | key | GUI filter: pop_assembly, government, resource, manufacturing, research, trade, amenity, unity, army |
| `position_priority` | int | Building slot placement (default: 200, lower = front) |

### Restrictions
| Property | Type | Description |
|----------|------|-------------|
| `base_cap_amount` | int | Maximum per planet |
| `empire_limit` | block | Total empire-wide limit |
| `is_capped_by_modifier` | bool | Auto-generate modifier for caps |
| `prerequisites` | list | Required technologies |
| `potential` | conditions | When buildable on planet |
| `allow` | conditions | When enabled in GUI |
| `show_tech_unlock_if` | conditions | Show tech unlock tooltip |

### Special Types
| Property | Type | Description |
|----------|------|-------------|
| `capital` | bool | Capital building flag |
| `branch_office_building` | bool | Branch office flag |
| `planetary_ftl_inhibitor` | bool | FTL inhibitor flag |

### Triggers
| Property | Type | Description |
|----------|------|-------------|
| `abort_trigger` | conditions | Remove from queue if true |
| `ruined_trigger` | conditions | Set to ruined if true |
| `destroy_trigger` | conditions | Destroy building if true |
| `convert_to` | list | Replacement buildings on destroy |

## Resources & Economy

```
resources = {
    category = planet_buildings
    cost = {
        minerals = 100
        energy = 100
    }
    upkeep = {
        energy = 2
    }
    produces = {
        food = 4
        minerals = 2
    }
}
```

### Conditional Resources

```
upkeep = {
    trigger = { num_districts { type = district_farming value >= 2 } }
    energy = 4
}
produces = {
    trigger = { num_districts { type = district_farming value >= 2 } }
    food = 8
}
```

## Modifiers

```
planet_modifier = { <modifiers> }

triggered_planet_modifier = {
    potential = { <conditions> }
    modifier = { job_farmer_add = 2 }
}

country_modifier = { <modifiers> }

triggered_country_modifier = {
    potential = { <conditions> }
    <modifiers>
}
```

## Jobs Example

```
triggered_planet_modifier = {
    potential = {
        exists = owner
        owner = { is_regular_empire = yes }
    }
    modifier = {
        job_farmer_add = 2
    }
}

triggered_planet_modifier = {
    potential = {
        exists = owner
        owner = { is_gestalt = yes }
    }
    modifier = {
        job_agri_drone_add = 2
    }
}
```

## Events & Effects

| Property | Type | Description |
|----------|------|-------------|
| `on_queued` | effects | Executes when added to queue |
| `on_unqueued` | effects | Executes when removed from queue |
| `on_built` | effects | Executes on completion |
| `on_destroy` | effects | Executes on demolition/destruction |

## AI Configuration

```
ai_weight = {
    factor = 100
    modifier = {
        factor = 0.5
        <conditions>
    }
}

ai_resource_production = {
    minerals = 10
    trigger = { <conditions> }
}
```

## Upgrade Pattern

```
building_sample_1 = {
    base_buildtime = 240
    resources = { ... }
    upgrades = { building_sample_2 }
    triggered_planet_modifier = { ... }
}

building_sample_2 = {
    base_buildtime = 240
    can_build = no
    resources = { ... }
    triggered_planet_modifier = { ... }
}
```

Best practice: numbered suffixes (_1, _2) for upgrades, `can_build = no` on upgraded versions.

## Tooltips

```
triggered_desc = {
    trigger = <conditions>
    text = "localisation_key"
}
```

Job effect descriptions: `job_<job_key>_effect_desc`

## Version 4.0 (Phoenix Update)

Modern buildings use zone slots and zones (District Specializations). Buildings are organized into building sets.

### Migration from 3.* to 4.0.*
- Add `default_starting_district = yes` to mark primary district
- Primary districts require 3 slots: `slot_city_government`, `slot_city_01`, `slot_city_02`
- Specify zone slot for every district
- Reference: `common/zones/99_HOW_TO_ZONE.txt`

---

**Last Updated**: Version 3.0+

## See Also
- [Modifiers](modifiers.md) — modifier keys for `planet_modifier` and `country_modifier`
- [Technology Modding](technology_modding.md) — technologies used as `prerequisites`
- [Conditions](conditions.md) — conditions used in `potential`, `allow`, and triggered modifiers
- [Effects](effects.md) — `add_building`, `remove_building` effects
- [Localisation Modding](localisation_modding.md) — localisation for building names and descriptions
