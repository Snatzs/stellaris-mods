# Stellaris Effects Reference

> Source: https://stellaris.paradoxwikis.com/Effects

## Introduction

Effects are scripts that modify game state, unlike Triggers which only return true/false. Effects can apply modifiers, create/destroy objects, and change game variables. The complete reference includes engine-built effects plus scripted effects in `common/scripted_effects`. Custom effects can be written there and reused across events.

## Effect Categories

### Control Flow
- **if** - Executes effects conditionally based on triggers
- **else_if** - Secondary condition if preceding if/else_if fails
- **switch** - Executes effects based on trigger evaluation
- **break** - Prevents subsequent effect execution in same block
- **random_list** - Picks one random effect set weighted by values
- **locked_random_list** - Picks one random set per event scope

### Flag Management
- **set_[object]_flag** - Sets arbitrary flag on scope objects (country, planet, fleet, star, leader, pop, war, etc.)
- **remove_[object]_flag** - Removes specified flag
- **set_timed_[object]_flag** - Sets flag with expiration (days/months/years)
- **set_saved_date** - Creates date flag for localization references

### Variable Operations
- **set_variable** - Creates/sets named variable with value
- **change_variable** - Increments variable by amount
- **subtract_variable** - Decrements variable
- **multiply_variable** - Multiplies variable value
- **divide_variable** - Divides variable value
- **modulo_variable** - Applies modulo operation (X % Y)
- **round_variable** - Rounds to closest integer
- **floor_variable** - Rounds down
- **ceiling_variable** - Rounds up
- **round_variable_to_closest** - Rounds to nearest multiple
- **clear_variable** - Removes variable

### Export Operations
- **export_modifier_to_variable** - Exports modifier value to variable
- **export_trigger_value_to_variable** - Exports trigger result to variable
- **export_resource_stockpile_to_variable** - Exports resource amount
- **export_resource_income_to_variable** - Exports monthly resource income

### Planet & Planetary Objects
- **add_building** - Begins construction of building
- **remove_building** - Removes specific building instance
- **remove_last_built_building** - Removes most recently built
- **remove_all_buildings** - Removes all non-capital buildings
- **disable_building** - Disables building without removing
- **ruin_building** - Ruins single building instance
- **downgrade_buildings_of_type** - Downgrades specific building type
- **add_district** - Begins construction of district
- **remove_district** - Removes specific district
- **remove_last_built_district** - Removes most recently built district
- **remove_all_districts** - Removes all districts
- **change_pc** - Changes planet class
- **change_planet_size** - Increases/decreases planet size
- **set_capital** - Sets as empire capital
- **set_planet_name** - Sets custom planet name
- **set_planet_entity** - Changes entity/graphical appearance
- **remove_planet** - Removes planet from scope
- **set_ring** - Adds/removes planetary ring
- **add_planet_devastation** - Adds devastation points
- **set_surveyed** - Marks as surveyed/unsurveyed
- **clear_blockers** - Removes all blockers
- **remove_deposit** - Removes resource deposit
- **set_deposit** - Replaces with specified deposit
- **add_blocker** - Adds blocker with control options
- **add_random_non_blocker_deposit** - Adds random deposit
- **every_deposit** - Iterates deposits matching limit
- **random_deposit** - Random deposit matching limit
- **reroll_deposits** - Rebuilds resource deposits
- **reroll_planet_modifiers** - Rebuilds planet modifiers
- **clear_planet_modifiers** - Removes all modifiers
- **set_colony_type** - Sets colony designation
- **set_sector_capital** - Sets sector capital
- **add_colony_progress** - Advances colonization
- **start_colony** - Begins colonization
- **check_planet_employment** - Evaluates jobs immediately

### Population Management
- **create_pop** - Creates new pop on planet
- **kill_pop** - Instantly destroys pop
- **create_half_species** - Creates hybrid species pop
- **resettle_pop** - Instantly moves pop to planet/tile
- **unemploy_pop** - Removes pop from job
- **clear_pop_category** - Resets pop category
- **every_owned_pop** - Iterates owned pops matching limit
- **random_owned_pop** - Random owned pop matching limit
- **random_pop** - Random pop (deprecated)
- **every_galaxy_pop** - Iterates all galaxy pops
- **set_pop_faction** - Assigns to faction
- **set_pop_flag** - Sets flag on pop
- **set_timed_pop_flag** - Sets timed flag on pop
- **remove_pop_flag** - Removes pop flag
- **pop_force_add_ethic** - Adds ethic regardless restrictions
- **pop_change_ethic** - Changes pop ethic
- **force_faction_evaluation** - Evaluates faction attraction immediately

### Species Management
- **create_species** - Creates new species with traits
- **modify_species** - Modifies existing species
- **change_species** - Changes object species
- **mutate_species** - Randomly mutates species
- **rename_species** - Renames species
- **set_species_flag** - Sets species flag
- **set_timed_species_flag** - Sets timed species flag
- **remove_species_flag** - Removes species flag
- **set_species_identity** - Makes species evaluate as another
- **set_species_homeworld** - Defines homeworld
- **change_species_portrait** - Changes portrait
- **change_species_characteristics** - Modifies sapience, immortality, etc.

### Leader Management
- **add_trait** - Adds trait to leader
- **add_timed_trait** - Adds temporary trait
- **remove_trait** - Removes trait
- **add_skill** - Increases skill level
- **set_skill** - Sets skill to value
- **set_immortal** - Sets immortality status
- **set_gender** - Sets leader gender
- **change_leader_portrait** - Changes portrait
- **kill_leader** - Kills or fires leader
- **add_experience** - Adds experience points
- **exile_leader_as** - Exiles with custom name
- **set_leader** - Reinstates exiled leader
- **recruitable** - Makes leader recruitable
- **set_cooldown** - Locks in role for days
- **assign_leader** - Assigns to country/fleet/army
- **unassign_leader** - Unassigns from post
- **set_leader_flag** - Sets flag on leader
- **set_timed_leader_flag** - Sets timed flag
- **remove_leader_flag** - Removes flag
- **add_ruler_trait** - Adds ruler-specific trait
- **remove_ruler_trait** - Removes ruler trait
- **every_owned_leader** - Iterates owned leaders
- **random_owned_leader** - Random owned leader
- **clone_leader** - Clones last created
- **create_saved_leader** - Creates saved leader
- **remove_saved_leader** - Removes saved leader
- **activate_saved_leader** - Moves saved to active

### Fleet & Ship Management
- **create_fleet** - Creates new fleet
- **create_ship** - Creates ship in fleet
- **create_army_transport** - Creates army transport ship
- **destroy_fleet** - Destroys fleet with death graphics
- **delete_fleet** - Deletes fleet without graphics
- **destroy_ship** - Destroys ship with graphics
- **delete_ship** - Deletes ship without graphics
- **clear_orders** - Clears fleet orders
- **order_forced_return** - Forces retreat to friendly space
- **set_event_locked** - Disables fleet for events
- **set_location** - Sets fleet/object location
- **set_fleet_stance** - Sets aggressive/passive/evasive
- **set_fleet_bombardment_stance** - Sets bombardment mode
- **set_aggro_range** - Sets aggro range in units
- **set_aggro_range_measure_from** - Measures from self/return point
- **queue_actions** - Adds to action queue
- **clear_fleet_actions** - Clears action queue
- **set_mission** - Sets observation mission
- **set_home_base** - Sets home starbase
- **reduce_hp** - Reduces hull points by amount
- **reduce_hp_percent** - Reduces hull by percentage
- **repair_ship** - Restores all hull points
- **repair_percentage** - Restores percentage of hull
- **set_disable_at_health** - Hull threshold for disable
- **dismantle** - Dismantles orbital station
- **set_formation_scale** - Scales formation spacing
- **set_fleet_formation** - Sets custom formation
- **auto_move_to_planet** - Auto-moves to target
- **remove_auto_move_target** - Cancels auto-move
- **auto_follow_fleet** - Auto-follows target
- **every_owned_fleet** - Iterates owned fleets
- **random_owned_fleet** - Random owned fleet
- **every_owned_ship** - Iterates owned ships
- **random_owned_ship** - Random owned ship
- **every_fleet_in_system** - Iterates system fleets
- **random_fleet_in_system** - Random system fleet
- **fleet_action_research_special_project** - Fleet researches project

### Army Management
- **create_army** - Creates new army
- **modify_army** - Modifies army properties
- **remove_all_armies** - Removes all armies on planet
- **set_army_flag** - Sets army flag
- **set_timed_army_flag** - Sets timed flag
- **remove_army_flag** - Removes flag

### Country & Government
- **create_country** - Creates new country with settings
- **destroy_country** - Destroys country
- **set_owner** - Sets owner instantly
- **set_controller** - Sets controller instantly
- **win** - Country wins game
- **set_name** - Sets country name
- **set_adjective** - Sets country adjective
- **set_ship_prefix** - Sets fleet name prefix
- **set_origin** - Sets country origin
- **country_add_ethic** - Adds ethic
- **country_remove_ethic** - Removes ethic
- **shift_ethic** - Shifts toward ethic
- **clear_ethos** - Removes all ethics
- **copy_ethos_and_authority** - Copies from target
- **set_player** - Assigns player control
- **change_country_flag** - Changes flag visuals
- **change_dominant_species** - Changes dominant species
- **set_graphical_culture** - Sets graphical culture
- **set_city_graphical_culture** - Sets city graphics
- **set_closed_borders** - Changes border status
- **set_policy** - Sets policy option
- **set_policy_cooldown** - Applies policy cooldown
- **set_government_cooldown** - Locks government (days/default/no)
- **enable_faction_of_type** - Forces faction evaluation
- **clear_resources** - Clears all resources
- **add_research_option** - Adds tech option
- **add_random_research_option** - Adds random tech
- **copy_random_tech_from** - Copies random tech from target
- **give_technology** - Instantly grants tech
- **add_tradition** - Adds tradition
- **copy_techs_from** - Copies all techs with exceptions
- **every_planet_within_border** - Iterates planets in borders
- **set_market_leader** - Sets Galactic Market leader
- **set_visited** - Marks system as visited
- **clear_uncharted_space** - Clears uncharted fog
- **add_monthly_resource_mult** - Adds resources as income multiple

### Diplomatic & Relations
- **add_opinion_modifier** - Adds opinion modifier
- **remove_opinion_modifier** - Removes opinion modifier
- **establish_contact** - Establishes first contact
- **establish_communications** - Establishes communications
- **establish_communications_no_message** - Silent communications
- **set_hostile** - Sets country as hostile
- **set_faction_hostility** - Sets faction aggro
- **add_favor** - Adds diplomatic favor
- **remove_favors** - Removes favor
- **set_relation_flag** - Sets relation flag
- **remove_relation_flag** - Removes relation flag
- **set_timed_relation_flag** - Sets timed relation flag
- **add_trust** - Adds trust toward target
- **end_rivalry** - Force-ends rivalry
- **set_truce** - Forces truce
- **end_truce** - Force-ends truce
- **add_casus_belli** - Adds casus belli against target
- **declare_war** - Declares war with goal
- **remove_war_participant** - Removes from war
- **join_war** - Joins war on side

### Subject & Alliance Systems
- **set_subject_of** - Makes subject of target
- **leave_alliance** - Leaves alliances
- **set_heir** - Sets heir
- **guarantee_country** - Guarantees country
- **every_subject** - Iterates subjects
- **random_subject** - Random subject

### Federation Systems
- **set_federation_leader** - Sets federation leader
- **set_federation_type** - Sets type
- **set_federation_succession_type** - Sets succession type
- **set_federation_succession_term** - Sets term length
- **set_federation_law** - Sets law
- **add_federation_experience** - Adds experience
- **add_cohesion** - Adds cohesion

### Galactic Community & Council
- **add_to_galactic_community** - Adds to community
- **remove_from_galactic_community** - Removes
- **add_to_galactic_council** - Adds to council
- **remove_from_galactic_council** - Removes from council
- **set_council_size** - Sets seat count

### Modifiers & Effects
- **add_modifier** - Adds modifier (days/months/years duration, -1 = permanent)
- **remove_modifier** - Removes modifier
- **calculate_modifier** - Forces modifier recalculation
- **add_threat** - Adds diplomatic threat

### Starbase & Megastructure
- **create_starbase** - Creates starbase in orbit
- **set_starbase_size** - Sets ship size
- **set_starbase_module** - Sets module in slot
- **set_starbase_building** - Sets building in slot
- **remove_starbase_module** - Removes module
- **remove_starbase_building** - Removes building
- **spawn_system** - Spawns system relative to location
- **set_star_class** - Sets star class
- **upgrade_megastructure_to** - Starts upgrade
- **finish_upgrade** - Completes upgrade
- **delete_megastructure** - Deletes megastructure
- **create_bypass** - Creates bypass (wormhole/gateway)
- **activate_gateway** - Activates gateway

### Hyperlane & Navigation
- **add_hyperlane** - Adds hyperlane between systems
- **remove_hyperlane** - Removes hyperlane
- **spawn_natural_wormhole** - Spawns wormhole
- **link_wormholes** - Links wormholes

### Events & Chains
- **save_event_target_as** - Saves scope as target
- **save_global_event_target_as** - Saves globally until cleared
- **clear_global_event_target** - Deletes global target
- **begin_event_chain** - Starts event chain
- **end_event_chain** - Ends event chain
- **add_event_chain_counter** - Increments chain counter
- **create_point_of_interest** - Creates situation log entry
- **remove_point_of_interest** - Removes entry

### Archaeological Sites
- **create_archaeological_site** - Creates archaeological site
- **destroy_archaeological_site** - Destroys site
- **add_stage_clues** - Adds stage clues
- **add_expedition_log_entry** - Adds log entry
- **reset_current_stage** - Resets current stage
- **finish_current_stage** - Completes stage
- **finish_site** - Completes entire site

### Notifications & UI
- **custom_tooltip** - Custom tooltip text
- **hidden_effect** - Hides effects from tooltip
- **create_message** - Creates message with variables
- **play_sound** - Plays sound effect

### Relics
- **add_relic** - Adds relic to country
- **remove_relic** - Removes relic
- **steal_relic** - Steals relic from target

## Scope Types

Available scopes for effect execution:
`all` | `country` | `planet` | `fleet` | `ship` | `leader` | `pop` | `pop_faction` | `species` | `megastructure` | `galactic_object` | `starbase` | `army` | `war` | `federation` | `sector` | `ambient_object` | `archaeological_site` | `first_contact` | `spy_network` | `espionage_operation` | `espionage_asset` | `agreement` | `situation` | `deposit`

---

**Note:** For complete, current effect listings, check `effects.log` in your `script_documentation` local data folder.

## See Also
- [Conditions](conditions.md) — triggers/conditions (the read-only counterpart to effects)
- [Scopes](scopes.md) — scope system used by all effects
- [Modifiers](modifiers.md) — modifier keys used with `add_modifier`
- [Event Modding](event_modding.md) — how to use effects inside events
- [Dynamic Modding](dynamic_modding.md) — scripted effects for reusable effect blocks
