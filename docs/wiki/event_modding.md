# Stellaris Event Modding Reference

> Source: https://stellaris.paradoxwikis.com/Event_modding

## Event Types

1. **event** - Global game event
2. **country_event** - Empire-wide event
3. **planet_event** - Planet-specific event
4. **fleet_event** - Fleet-specific event
5. **ship_event** - Ship-specific event
6. **pop_faction_event** - Faction event
7. **pop_group_event** - Population unit event (v4.0+)
8. **observer_event** - Observer mode only
9. **system_event** - System/galactic object event (v3.0+)
10. **starbase_event** - Starbase event (v3.0+)
11. **leader_event** - Leader event (v3.0+)
12. **espionage_operation_event** - Espionage operations (v3.0+)
13. **first_contact_event** - First contact events (v3.0+)
14. **situation_event** - Situation events (v3.3+)
15. **agreement_event** - Subject agreement events (v3.4+)

## Core Structure

### Namespace and ID

```
namespace = example_namespace
country_event = {
    id = example_namespace.1
    ...
}
```

**Namespace rules:**
- Maximum verified length: 100 characters
- Can include numbers (e.g., `paragon_2`)
- IDs cannot contain letters or they'll be treated as `namespace.0`
- Leading zeros are truncated (`namespace.003` = `namespace.3`)

### Execution Modes

- `is_triggered_only = yes` - Only fires when explicitly called (best for performance)
- `mean_time_to_happen = { months = 5 }` - Random delay; checked regularly (expensive)
- `fire_only_once = yes` - Fires once then removes itself

**Warning:** `mean_time_to_happen` causes daily condition checks per scope. Vanilla has moved away from this in favor of on_action triggers.

### Pre-triggers

Fast yes/no checks executed before full triggers. Only for planet, pop, system, starbase, and leader scopes:

**Planet pre-triggers:**
```
pre_triggers = {
    has_owner = yes
    is_homeworld = no
    original_owner = yes
    has_ground_combat = no
    is_capital = no
    is_occupied_flag = no
    is_ai = no
}
```

**Pop pre-triggers:**
```
possible_pre_triggers = {
    has_owner = yes
    is_enslaved = no
    is_being_purged = no
    is_being_assimilated = no
    has_planet = yes
    is_sapient = yes
    is_robotic = yes
}
```

**System/Starbase pre-triggers:** `has_owner`, `is_capital`, `is_occupied_flag`

**Leader pre-triggers:** `has_owner`, `is_idle`

### Visibility

- `hide_window = yes` - Suppresses event window (background events)

### Code Execution

**Immediate block:** Executes when event fires:
```
immediate = {
    if = {
        limit = { some_condition = yes }
        some_effect = yes
    }
}
```

**Option blocks:** Visible events require at least one option:
```
option = {
    name = "option.text.key"
    trigger = { can_see_this = yes }
    allow = { can_choose_this = yes }
    ai_chance = { factor = 100 }
}
```

**After block:** Executes after any option is chosen.

## Calling Events

### Direct Event Calls
```
country_event = { id = my_event.1 }
```

**With delay:**
```
country_event = { id = crisis.2000 days = 200 random = 100 }
```
Fires 200-300 days later.

**With scope override (v3.0+):**
```
country_event = {
    id = some_event.1
    scopes = { from = fromfrom }
}
```

## Conditional Descriptions

```
desc = {
    trigger = { owner = { NOT = { has_authority = auth_machine } } }
    text = example.1.desc
}
desc = {
    trigger = { owner = { has_authority = auth_machine } }
    text = example.1.desc.mach
}
desc = example.1.desc.fallback
```

## Complete Event Parameters

```
country_event = {
    id = namespace.1

    # Display
    title = "localization.key"
    desc = "localization.key"
    picture = GFX_evt_image
    location = from

    # Audio
    show_sound = event_sound

    # Execution control
    is_triggered_only = yes
    fire_only_once = yes
    hide_window = yes

    # Diplomatic
    diplomatic = yes
    picture_event_data = {
        portrait = event_target:scope
        planet_background = event_target:scope
        room = event_target:scope.ruler
    }

    # Conditions
    pre_triggers = { has_owner = yes }
    trigger = { condition = yes }

    # Code execution
    immediate = { effect_statement = yes }

    # Options
    option = {
        name = "option.key"
        trigger = { visible = yes }
        allow = { enabled = yes }
        exclusive_trigger = { only_one = yes }
        custom_tooltip = "custom.tooltip"
        hidden_effect = { secret = yes }
        ai_chance = { factor = 100 }
    }

    # Post-execution
    after = { cleanup_effect = yes }

    # Abort
    abort_trigger = { should_cancel = yes }
    abort_effect = { cancellation_code = yes }

    # Inheritance (v3.4+)
    base = parent_event.id
    desc_clear = yes
    option_clear = yes
}
```

## Option Parameters

| Parameter | Function |
|-----------|----------|
| `name` | Display text localization key |
| `trigger` | Hides option if false |
| `allow` | Disables option if false (still visible) |
| `exclusive_trigger` | Disables all other options if true |
| `custom_tooltip` | Additional tooltip text |
| `hidden_effect` | Prevents tooltip generation from effects |
| `ai_chance` | AI decision weighting |
| `default_hide_option` | Default selection on Cancel press |

## Event Inheritance (v3.4+)

```
country_event = {
    id = child_event.1
    base = parent_event.1
    desc_clear = yes
    option_clear = yes
    desc = "new.description"
    option = { name = "new.option" }
}
```

Clearable properties: `desc_clear`, `option_clear`, `picture_clear`, `show_sound_clear`

## File Loading Order

Events use "First In Only Serve" (unlike most files which use Last In Only Serve). To override vanilla events, prefix filenames with `!`:

```
!!my_event_override.txt
```

## Best Practices

- Combine `hide_window = yes` with `is_triggered_only = yes` for background events
- Use `mean_time_to_happen` sparingly — prefer on_action registration
- Use "gatekeeper" events with quick-failing triggers to gate longer chains
- Build chains: gatekeeper (hidden) -> setup (hidden) -> display (visible) -> consequences
- Carefully manage scope through event chains

---

**Last verified:** Version 3.6

## See Also
- [On Actions](on_actions.md) — register events to game actions instead of polling
- [Effects](effects.md) — effects available in immediate/option/after blocks
- [Conditions](conditions.md) — conditions for triggers and pre-triggers
- [Scopes](scopes.md) — scope flow through events (ROOT, FROM, PREV)
- [Localisation Modding](localisation_modding.md) — localisation for event titles, descriptions, options
- [Dynamic Modding](dynamic_modding.md) — scripted effects/triggers for reusable event logic
