# Stellaris Conditions Reference

> Source: https://stellaris.paradoxwikis.com/Conditions

## Logical Boolean Operators

| Operator | Function | Example |
|----------|----------|---------|
| `if/else_if/else` | Conditional branching | `if = { limit = { condition } effects }` |
| `AND` | All conditions true (default) | `AND = { condition1 condition2 }` |
| `OR` | At least one true | `OR = { condition1 condition2 }` |
| `NOT` | Inverts single condition | `NOT = { condition }` |
| `NOR` | None true | `NOR = { condition1 condition2 }` |
| `NAND` | Not all true | `NAND = { condition1 condition2 }` |
| `calc_true_if` | Count matching conditions | `calc_true_if = { amount >= 3 cond1 cond2 }` |

## Common Scopes

| Scope | Returns |
|-------|---------|
| `root` | Object script belongs to |
| `this` | Current scope in iteration |
| `from` | Object's location |
| `owner` | Controlling country |
| `capital` | Country's capital planet |
| `prev/prevprev` | Previous scope(s) |
| `planet` | Associated planet |
| `pop` | Associated population |

## Core Condition Categories

### Empire/Country Conditions
- `has_technology`, `can_research_technology`
- `has_ethic`, `has_civic`, `has_authority`
- `has_ascension_perk`, `num_ascension_perks`
- `has_edict`, `has_policy_flag`
- `empire_size`, `empire_sprawl`, `empire_sprawl_over_cap`
- `is_at_war`, `is_at_war_with`, `recently_lost_war`
- `has_federation`, `is_federation_leader`
- `opinion`, `trust`, `their_opinion`

### Planet/System Conditions
- `is_planet_class`, `is_star_class`
- `planet_size`, `planet_devastation`, `planet_stability`
- `planet_crime`, `has_ring`, `is_moon`
- `is_colonizable`, `is_colony`, `colony_age`
- `has_building`, `has_active_building`, `num_buildings`
- `has_district`, `num_districts`, `free_district_slots`
- `has_deposit`, `has_strategic_resource`
- `habitability`, `free_housing`, `free_amenities`
- `has_owner`, `has_ground_combat`, `is_occupied_flag`

### Pop/Species Conditions
- `pop_has_ethic`, `pop_has_trait`
- `has_job`, `is_unemployed`, `has_level`
- `happiness`, `is_enslaved`, `is_being_purged`
- `is_sapient`, `is_robot_pop`, `can_live_on_planet`
- `num_pops`, `num_unemployed`
- `is_species_class`, `is_archetype`
- `species_portrait`, `species_gender`

### Fleet/Ship Conditions
- `num_ships`, `is_ship_class`, `is_ship_size`
- `num_fleets`, `fleet_power`, `fleet_size`
- `is_in_combat`, `is_damaged`, `has_hp`
- `is_disabled`, `is_mobile`
- `is_civilian`, `is_designable`

### Diplomatic/Relations
- `has_commercial_pact`, `has_research_agreement`
- `has_defensive_pact`, `has_non_aggression_pact`
- `has_communications`, `has_established_contact`
- `is_neighbor_of`, `is_inside_border`
- `is_friendly_to`, `is_hostile_to`, `is_rival`

### War/Conflict
- `any_war`, `any_attacker`, `any_defender`
- `attacker_war_exhaustion`, `defender_war_exhaustion`
- `can_declare_war`, `has_casus_belli`
- `using_war_goal`, `is_war_leader`

### Resource/Economy
- `has_resource`, `has_deficit`, `balance`
- `income`, `expenses`, `trade_income`
- `resource_income_compare`, `resource_expenses_compare`
- `has_country_resource`, `num_minerals/physics/society/engineering`

### Iteration Triggers
- `any_country`, `any_playable_country`
- `any_owned_fleet`, `any_owned_ship`, `any_owned_pop`
- `any_planet_within_border`, `any_system_planet`
- `any_deposit`, `any_moon`, `any_relation`

### Flag/Variable Conditions
- `has_global_flag`, `has_country_flag`, `has_planet_flag`
- `has_fleet_flag`, `has_ship_flag`, `has_army_flag`
- `is_variable_set`, `check_variable`, `check_variable_arithmetic`

### Utility Conditions
- `exists`, `always`, `is_scope_type`
- `distance`, `compare_distance`, `closest_system`
- `days_passed`, `years_passed`, `colony_age`
- `custom_tooltip`, `hidden_trigger`, `log`

## See Also
- [Effects](effects.md) — effects that modify game state (the write counterpart to conditions)
- [Scopes](scopes.md) — scope system used by all conditions
- [Variables](variables.md) — `check_variable` and variable-based conditions
- [Event Modding](event_modding.md) — using conditions in event triggers and pre-triggers
- [Dynamic Modding](dynamic_modding.md) — scripted triggers for reusable condition blocks
