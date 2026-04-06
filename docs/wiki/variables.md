# Stellaris Variables Reference

> Source: https://stellaris.paradoxwikis.com/Variables

## Available Scopes

Variables can be set in: `megastructure`, `planet`, `country`, `ship`, `pop`, `fleet`, `galactic_object`, `leader`, `army`, `ambient_object`, `species`, `pop_faction`, `war`, `federation`, `starbase`, `deposit`, `sector`, `archaeological_site`, `first_contact`, `spy_network`, `espionage_operation`, `espionage_asset`

## Setting Variables

### Basic Assignment
```
set_variable = { which = star_temperature value = @G2V_star_temperature }
```

### Random Value (v3.6+)
```
set_variable_to_random_value = { which = <var> min = -100 max = 100 rounded = yes/no }
```

### Exporting Values
```
export_trigger_value_to_variable    # Converts trigger values to variables
export_modifier_to_variable = { modifier = <name> variable = <var> }
export_resource_stockpile_to_variable = { resource = <resource> variable = <var> }
export_resource_income_to_variable = { resource = <resource> variable = <var> }
get_galaxy_setup_value = { which = <var> setting = <option> scale_by = <float> }
```

Galaxy setup options: `num_empires`, `num_advanced_empires`, `num_fallen_empires`, `mid_game_year`, `end_game_year`, `victory_year`, `num_guaranteed_colonies`, `num_gateways`, `num_wormhole_pairs`, `habitable_worlds_scale`, `crisis_strength_scale`, `tech_costs_scale`

## Manipulating Variables

```
change_variable = { which = <var> value = <number>/<variable>/<trigger> }    # Add
subtract_variable = { which = <var> value = <number>/<variable>/<trigger> }  # Subtract
multiply_variable = { which = <var> value = <number>/<variable>/<trigger> }  # Multiply
divide_variable = { which = <var> value = <number>/<variable>/<trigger> }    # Divide
modulo_variable = { which = <var> value = <number>/<variable>/<trigger> }    # Modulo
clear_variable = <var>                                                       # Remove
```

### Dot-Scoping (v3.1+)
```
multiply_variable = {
    which = my_var
    value = fromfromfrom.owner.trigger:num_pops
}
```

## Checking Variable Values

```
check_variable = { which = <var> value = <number>/<trigger>/<modifier> }
```

Operators: `=`, `>=`, `>`, `<=`, `<`

Dot-scoping: `value = owner.capital_scope.my_var`

Trigger reference: `value = trigger:num_pops`

Combined: `value = owner.capital_scope.trigger:num_pops`

Modifier reference (v3.3+): `value = modifier:pop_growth_speed_reduction`

### Arithmetic Check (without modifying variable)
```
check_variable_arithmetic = {
    which = my_var
    add/subtract/multiply/divide/modulo = <value>
    value > 0.5
}
```

## Copying Variables Between Scopes

```
# Dot-scoping (v3.1+)
set_variable = { which = var1 value = owner.capital_scope.my_var }

# Same-name shorthand
set_variable = { which = var1 value = owner }

# Different variable names
set_variable = { which = var1 value = { scope = owner variable = var2 } }
```

## Rounding Operations

```
round_variable = <var>              # Round to nearest integer
floor_variable = <var>              # Round down
ceiling_variable = <var>            # Round up
round_variable_to_closest = <var>   # Round to nearest multiple
```

## Utility

```
is_variable_set = <var>    # Check if variable exists
```

## Usage Locations

Variables work in:
- Triggers comparing single numbers with `{ }` syntax
- Effects using single numbers
- While loop count parameters
- Modifier multipliers: `multiplier = my_var/trigger:num_pops`
- Resource multipliers in cost tables
- AI chance factors
- Ordered script lists for sorting
- Localization: `[This.my_var]` prints variable value

## Notes

- Variables default to zero if unset but will error if referenced before creation
- Floating-point precision: 5 digits
- Variables persist in their scope after creation

## See Also
- [Scopes](scopes.md) — scope system variables are attached to
- [Effects](effects.md) — variable manipulation effects (set_variable, change_variable, etc.)
- [Conditions](conditions.md) — `check_variable` and `is_variable_set` conditions
- [Dynamic Modding](dynamic_modding.md) — scripted variables (@variables) and script values
