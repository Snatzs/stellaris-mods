# Stellaris On Actions Reference

> Source: https://stellaris.paradoxwikis.com/On_actions

## Introduction

On actions provide event triggering mechanisms beyond standard polling. The vanilla game registers numerous events in `Stellaris\common\on_actions\00_on_actions.txt`. Registered events should use `is_triggered_only = yes`.

## Custom On Actions

Define custom on_actions via the `fire_on_action` effect:

```
fire_on_action = {
    on_action = <string>
    scopes = { from = X fromfrom = Y }
}
```

**Scope Notes:** Non-event_target scopes require `prev` prefix (`from = prev` scopes to the firing context).

## Performance

For planet, system, starbase, leader, and pop events, use "pre_triggers" (fast checks evaluated before standard triggers).

## Order of Events

Multiple events fire sequentially. Within files, events fire as listed. Across files, ASCII-betical order applies.

## Firing Behavior

1. Processing `events = {}` block — excludes false triggers, fires valid events
2. Processing `random_events = {}` block — excludes false triggers, rolls weights, fires one random valid event

## Vanilla On Actions Reference

### Periodic Pulses

| Name | Scope | Description |
|------|-------|-------------|
| `on_game_start` | No scope | Game initialization |
| `on_game_start_country` | — | Country game start |
| `on_monthly_pulse` | No scope | Monthly tick |
| `on_yearly_pulse` | No scope | Yearly tick |
| `on_bi_yearly_pulse` | No scope | Bi-yearly tick |
| `on_five_year_pulse` | No scope | 5-year tick |
| `on_decade_pulse` | No scope | Decade tick |
| `on_mid_game_pulse` | No scope | Mid-game tick |
| `on_late_game_pulse` | No scope | Late-game tick |
| `on_monthly_pulse_country` | this = country | Country monthly (requires `has_pulse_events = yes`) |
| `on_yearly_pulse_country` | this = country | Country yearly |
| `on_bi_yearly_pulse_country` | this = country | Country bi-yearly |
| `on_five_year_pulse_country` | this = country | Country 5-year |
| `on_decade_pulse_country` | this = country | Country decade |
| `on_mid_game_pulse_country` | this = country | Country mid-game |
| `on_late_game_pulse_country` | this = country | Country late-game |

### Colony Pulses

| Name | Scope | Description |
|------|-------|-------------|
| `on_colony_1_year_old` through `on_colony_10_years_old` | — | Colony age milestones |
| `on_colony_25_years_old` | — | Colony 25 year milestone |
| `on_colony_yearly_pulse` | — | All planets including homeworld |
| `on_colony_5_year_pulse` | — | All planets 5-year |
| `on_colony_10_year_pulse` | — | 10-year pulse |

### First Contact & Diplomacy

| Name | Scope |
|------|-------|
| `on_first_contact` | This = Empire 1; From = Empire 2; Fromfromfrom = contact system |
| `on_first_contact_finished` | This = first contact scope; From = other country |
| `on_pre_communications_established` | This = establishing; From = other |
| `on_post_communications_established` | This = establishing; From = other |
| `on_custom_diplomacy` | This = target; From = source |

### Ground Combat

| Name | Scope |
|------|-------|
| `on_ground_combat_started` | This = planet; From = attacker country |
| `on_planet_attackers_win` | This = attacker; From = planet owner; FromFrom = planet |
| `on_planet_attackers_lose` | This = attacker; From = planet owner; FromFrom = planet |
| `on_planet_defenders_win` | Root = planet owner; From = attacker; FromFrom = planet |
| `on_planet_defenders_lose` | This = planet owner; From = attacker; FromFrom = planet |

### Space Combat

| Name | Scope |
|------|-------|
| `on_entering_battle` | This = Fleet 1 owner; From = Fleet 2 owner; FromFrom = Fleet 1; FromFromFrom = Fleet 2 |
| `on_ship_destroyed_victim` | This = destroyed owner; From = combatant; FromFrom = ship; FromFromFrom = combatant ship |
| `on_ship_destroyed_perp` | This = combatant; From = destroyed owner; FromFrom = ship; FromFromFrom = destroyed ship |
| `on_fleet_destroyed_victim` | This = destroyed owner; From = combatant; FromFrom = fleet |
| `on_fleet_destroyed_perp` | This = combatant; From = destroyed owner; FromFrom = fleet |
| `on_space_battle_won` | This = winner; From = loser; FromFrom = fleet; FromFromFrom = loser fleet |
| `on_space_battle_lost` | This = loser; From = winner; FromFrom = fleet; FromFromFrom = winner fleet |
| `on_starbase_destroyed` | This = starbase; From = destroying fleet |
| `on_starbase_disabled` | This = starbase; From = disabling fleet |

### Navigation & Movement

| Name | Scope |
|------|-------|
| `on_system_first_visited` | Scope = Country; From = System |
| `on_entering_system_first_time` | Scope = Ship; From = System; FromFrom = Country |
| `on_entering_system` | Scope = Ship; From = System; FromFrom = Country |
| `on_entering_system_fleet` | Scope = Fleet; From = System |
| `on_crossing_border` | Scope = Fleet; From = origin; FromFrom = destination |
| `on_entering_gateway` | THIS = Fleet; FROM = destination; FROMFROM = origin |
| `on_entering_wormhole` | THIS = Fleet; FROM = destination; FROMFROM = origin |
| `on_fleet_enter_orbit` | From = Planet/Starbase/Megastructure; This = Fleet |
| `on_emergency_ftl` | This = fleet; From = origin system; FromFrom = destination |

### Survey & Exploration

| Name | Scope |
|------|-------|
| `on_survey` | Scope = Ship; From = Planet |
| `on_planet_surveyed` | Root = Planet; From = Country; FromFrom = survey fleet |
| `on_system_survey` | Root = Country; From = system; FromFrom = survey fleet |

### Colonization & Planets

| Name | Scope |
|------|-------|
| `on_colonization_started` | Scope = Planet |
| `on_colonized` | Scope = Planet |
| `on_colony_destroyed` | Scope = Planet (before owner/controller cleared) |
| `on_planet_transfer` | This = Planet; From = new owner; FromFrom = old owner |
| `on_planet_conquer` | This = Planet; From = new owner; FromFrom = former owner |
| `on_planet_occupied` | Root = Planet; From = Owner; FromFrom = Controller |
| `on_capital_changed` | this/root = new capital; from = old capital |
| `on_planet_bombarded` | This = Planet; From = bombarder |
| `on_planet_zero_pops` | This = Planet; From = bombarder |
| `on_terraforming_complete` | This = Planet; From = terraforming country |
| `on_planet_class_changed` | This = Planet |
| `on_blocker_cleared` | This = Planet |

### Population Events

| Name | Scope |
|------|-------|
| `on_pop_added` | Root = pop; From = planet |
| `on_pop_grown` | This = Planet; From = Country; FromFrom = Pop |
| `on_pop_assembled` | This = Planet; From = Country; FromFrom = Pop |
| `on_pop_purged` | This = Planet; From = Country; FromFrom = Pop |
| `on_pop_declined` | This = Planet; From = Country; FromFrom = Pop |
| `on_pop_resettled` | From = old planet; planet = {} new planet |
| `on_pop_abducted` | This = Pop; From = planet |
| `on_pop_enslaved` | This = Pop |
| `on_pop_emancipated` | This = Pop |
| `on_pop_rights_change` | This = pop |

### Leader Events

| Name | Scope |
|------|-------|
| `on_leader_death` | This = Country; From = Leader |
| `on_leader_fired` | This = Country; From = Leader |
| `on_leader_level_up` | Scope = Country; From = Leader |
| `on_leader_assigned` | Scope: Leader (after assignment) |
| `on_leader_unassigned` | Scope: Leader (before unassignment) |
| `on_leader_spawned` | scope: country, from: leader |
| `on_ruler_set` | This = Country |
| `on_ruler_removed` | From = Previous Ruler; This = Country |

### Building & Construction

| Name | Scope |
|------|-------|
| `on_building_complete` | This = Planet |
| `on_building_queued` | This = Planet |
| `on_building_demolished` | This = Planet |
| `on_building_upgraded` | This = Planet |
| `on_building_replaced` | This = Planet |
| `on_building_downgraded` | This = Planet |
| `on_district_complete` | This = Planet |
| `on_district_demolished` | This = Planet |
| `on_ship_built` | Root = Ship; From = Planet |
| `on_ship_designed` | Root = Country |
| `on_ship_upgraded` | Root = Ship |

### Station Construction

| Name | Scope |
|------|-------|
| `on_building_mining_station` | This = construction ship; From = planet |
| `on_building_research_station` | This = construction ship; From = planet |
| `on_building_starbase_outpost` | This = ship (starbase); From = owner |
| `on_building_observation_station` | This = construction ship; From = planet |

### War & Peace

| Name | Scope |
|------|-------|
| `on_entering_war` | This = country; From = opponent war leader |
| `on_war_beginning` | Root = Country; From = War |
| `on_war_ended` | Root = Loser; From = Main Winner |
| `on_war_won` | Root = Winner Warleader; From = Loser; FromFrom = War |
| `on_war_lost` | Root = Loser; From = Winner; FromFrom = War |
| `on_status_quo` | Root = Actor; From = Recipient; FromFrom = Attacker; FromFromFrom = Defender |
| `on_country_attacked` | This = attacked; From = attacker |

### Federation & Alliance

| Name | Scope |
|------|-------|
| `on_join_federation` | This = Federation leader; From = Joining member |
| `on_leave_federation` | This = Federation leader; From = Leaving member |
| `on_federation_new_leader` | This = new leader; From = previous |
| `on_federation_law_vote_succeed` | This = Federation leader; From = initiator |
| `on_federation_law_vote_failed` | This = Federation leader; From = initiator |

### Diplomacy & Treaties

| Name | Scope |
|------|-------|
| `on_sign_commercial_pact` | This = acceptor; From = proposer |
| `on_sign_defensive_pact` | This = acceptor; From = proposer |
| `on_sign_migration_pact` | This = acceptor; From = proposer |
| `on_sign_non_aggression_pact` | This = acceptor; From = proposer |
| `on_sign_research_act` | This = acceptor; From = proposer |
| `on_becoming_subject` | This = subject; From = overlord |
| `on_subject_integrated` | This = overlord; From = subject |
| `on_released_as_vassal` | This = vassal; From = overlord |

### Technology & Research

| Name | Scope |
|------|-------|
| `on_tech_increased` | This = Country (use last_increased_tech) |
| `on_tradition_picked` | THIS = country |
| `on_ascension_perk_picked` | THIS = country |
| `on_modification_complete` | This = Country; From = Species (post-mod) |
| `on_uplift_completion` | This = planet; From = uplifted species |

### Government

| Name | Scope |
|------|-------|
| `on_policy_changed` | This = Country (use last_changed_policy) |
| `on_pre_government_changed` | THIS = country (before change) |
| `on_post_government_changed` | THIS = country (after change) |
| `on_election_started` | scope: country |
| `on_election_ended` | scope: country |

### Megastructures

| Name | Scope |
|------|-------|
| `on_megastructure_built` | Root = Country; From = Megastructure; FromFrom = System; FromFromFrom = Fleet |
| `on_megastructure_upgraded` | Root = Country; From = Megastructure; FromFrom = System |
| `on_megastructure_change_owner` | this = new owner; from = megastructure; fromfrom = old owner |

### Systems & Territory

| Name | Scope |
|------|-------|
| `on_system_lost` | This = former owner; From = system; FromFrom = new owner |
| `on_system_gained` | This = new owner; From = system; FromFrom = former owner |
| `on_system_occupied` | THIS = System; FROM = Conqueror; FROMFROM = Original owner |
| `on_system_controller_changed` | THIS = System; FROM = New controller; FROMFROM = Old controller |
| `on_starbase_transfer` | THIS = Starbase; FROM = Former Owner |

### Galactic Community

| Name | Scope |
|------|-------|
| `on_resolution_passed` | this/root = proposer; use last_resolution_changed |
| `on_resolution_failed` | this/root = proposer; use last_resolution_changed |
| `on_galactic_community_formed` | This = Country, first member |
| `on_add_community_member` | This = Country |

### Espionage & Spying

| Name | Scope |
|------|-------|
| `on_spynetwork_formed` | this = owner, from = spynetwork |
| `on_operation_chapter_finished` | THIS = Espionage operation; FROM = Target |
| `on_operation_finished` | THIS = Espionage operation; FROM = Target |
| `on_operation_cancelled` | THIS = Espionage operation |

### Archaeological Sites

| Name | Scope |
|------|-------|
| `on_arch_stage_finished` | This = Fleet (science vessel); From = Archaeological Site |
| `on_arch_site_finished` | — |

### Miscellaneous

| Name | Scope |
|------|-------|
| `on_fleet_disbanded` | This = fleet owner; From = disbanded fleet |
| `on_relic_activated` | This = Country |
| `on_country_created` | This = created; From = root context initiator |
| `on_country_destroyed` | This = destroyed; From = destroyer |
| `on_debris_researched` | this = country; from = debris; fromfrom = destroyed ship controller |
| `on_branch_office_established` | THIS = Planet; FROM = Branch office owner |
| `on_branch_office_closed` | THIS = Planet; FROM = Branch office owner |
| `on_cloaking_activated` | This = Fleet |
| `on_cloaking_deactivated` | This = Fleet |
| `on_destroy_star_system` | This = system; From = destroyer |
| `on_single_player_save_game_load` | No scope; skips multiplayer saves |

---

**Last Updated:** Version 3.7

## See Also
- [Event Modding](event_modding.md) — event structure (use `is_triggered_only = yes` for on_action events)
- [Scopes](scopes.md) — understanding THIS/FROM/FROMFROM scope chains
- [Effects](effects.md) — `fire_on_action` effect for custom on_actions
- [Dynamic Modding](dynamic_modding.md) — scripted effects/triggers for on_action event logic
