# Stellaris Dynamic Modding Reference

> Source: https://stellaris.paradoxwikis.com/Dynamic_modding

## Overview

Dynamic modding encompasses scripted effects, scripted triggers, scripted localization, scripted variables, scripted modifiers, flags, script values, and inline scripts.

## Scripted Effects

Custom effect blocks defined in `common/scripted_effects/xyz.txt`

```
example_scripted_effect = {
    shift_ethic = ethic_materialist
}
```

Called via: `example_scripted_effect = yes`

### Parameters

```
example_scripted_effect = {
    shift_ethic = ethic_$ETHIC$
}

# Called with:
example_scripted_effect = { ETHIC = materialist }
```

### Parameter Conditions

```
[[homeworld] set_species_homeworld = event_target:tempHomeworld]
[[!homeworld] fallback_effect]
```

Fallback values: `has_global_flag = crisis_stage_$STAGE|1$`

### Inline Math

```
add_monthly_resource_mult = {
    resource = unity
    value = $COUNT|1$
    min = @[ $COUNT|1$ * 10 ]
}
```

Operators: `+`, `-`, `*`, `/`

**Limitation:** Only the first `@[ ... ]` per effect evaluates correctly.

## Scripted Triggers

Custom condition blocks in `common/scripted_triggers/xyz.txt`

```
example_scripted_trigger = {
    has_ethic = ethic_materialist
    has_ethic = ethic_fanatic_materialist
}
```

Called via: `example_scripted_trigger = yes/no`

**Note:** Triggers with parameters cannot use `xyz = no` form; use `NOT = { … }` instead.

## Scripted Localization

Defined in `common/scripted_loc/xyz.txt`

```
defined_text = {
    name = GetAuthorityName
    text = {
        trigger = { has_authority = auth_democratic }
        localization_key = auth_democratic
    }
    text = {
        trigger = { has_authority = auth_oligarchic }
        localization_key = auth_oligarchic
    }
}
```

Usage in loc files: `[<scope>.GetAuthorityName]`

## Scripted Variables

Shared `@` variables in `common/scripted_variables/xyz.txt`

```
@example = 2
```

Accessible across all game files. File must end with blank or commented line.

## Scripted Modifiers (v3.4+)

Custom modifiers in `common/scripted_modifiers/`

```
pop_job_trade_mult = {
    icon = mod_trade_value_mult
    percentage = yes
    good = yes
    category = pop
}
```

Categories: pop, ship, station, fleet, country, army, leader, planet, component, deposit, megastructure, starbase, system, trade, federation, espionage

## Flags

Boolean values attachable to: leader, planet, country, fleet, ship, species, pop, federation, megastructure, espionage_operation, or global.

```
set_<scope>_flag = <flag_name>
set_timed_<scope>_flag = { flag = <flag_name> days = <int> }
remove_<scope>_flag = <flag_name>
has_<scope>_flag = <flag_name>
had_<scope>_flag = { flag = <flag_name> days = <duration> }
```

### Dynamic Flags

Flag names can incorporate scope variables using `@`:

```
from = { set_leader_flag = is_friend_of_@root }
```

Resolves to actual ID (e.g., `is_friend_of_140`).

## Script Values (v3.3+)

Dynamic numeric calculations in `common/script_values/`

Reference: `value:example_value`

```
example_value = {
    base = 10
    add = 100
    multiply = value:some_other_script_value
    round = yes
    modifier = {
        max = owner.max_example_variable
        owner = { is_variable_set = max_example_variable }
    }
    complex_trigger_modifier = {
        trigger = count_owned_planet
        trigger_scope = owner
        parameters = { limit = { num_pops > 10 } }
        mode = add
        mult = 5
    }
}
```

Math operations: set, weight, add, subtract, factor, mult, multiply, divide, modulo, round_to, max, min, pow, round, ceiling, floor, abs, square, square_root

Parameters supported: `value:my_value|PARAM1|value1|`

## Inline Scripts (v3.5+)

Reusable script blocks in `common/inline_scripts/`

**Definition** at `common/inline_scripts/edicts/upkeep_low.txt`:
```
resources = {
    category = edicts
    upkeep = {
        unity = 10
        multiplier = value:edict_size_effect
    }
}
```

**Usage:**
```
fortify_the_border = {
    inline_script = "edicts/upkeep_low"
    modifier = {
        starbase_upgrade_speed_mult = 0.50
    }
}
```

### Parameters
```
# Definition:
$KEY$ = {
    option = {
        name = "$KEY$_a"
        on_enabled = {
            add_modifier = { modifier = $MODIFIER_A$ days = 360 }
        }
    }
}

# Usage:
inline_script = {
    script = test_basic_policy
    KEY = test_1
    MODIFIER_A = evermore_science
}
```

### Limitations
- Not supported everywhere; check for "unexpected token" errors
- Cannot use within item lists
- Comments containing `$PARAM$` trigger unintended replacements

---

**Last verified:** Version 3.5

## See Also
- [Effects](effects.md) — all base effects (used inside scripted effects)
- [Conditions](conditions.md) — all base conditions (used inside scripted triggers)
- [Variables](variables.md) — variable system (distinct from scripted @variables)
- [Modifiers](modifiers.md) — scripted modifiers and modifier categories
- [Localisation Modding](localisation_modding.md) — using scripted localization in loc files
