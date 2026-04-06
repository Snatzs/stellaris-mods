# Stellaris Scopes Reference

> Source: https://stellaris.paradoxwikis.com/Scopes

## Overview

Scopes provide access to game objects through script. Each object type (planets, pops, countries, etc.) has an associated scope that allows manipulation through code blocks.

**Syntax:** `<scope_type> = { }` with script inside brackets referring to the specific object.

## System Scopes

Special scopes referencing relationships between objects:

- **THIS** - Current scope reference
- **PREV** - Previous scope in chain (stackable up to 4 times: `prevprev`, `prevprevprev`, `prevprevprevprev`)
- **FROM** - Scope from which current script was called (stackable like PREV)
- **ROOT** - Main script scope (e.g., planet in planet_event)

## Scope Chaining

Simplify code using dot notation:
```
owner.capital_scope.solar_system = { … }
```
Equivalent to nested scopes without creating new PREV context.

## Scope Existence

Always verify scope exists before access to prevent errors:
```
planet = { exists = owner owner = { … } }
```

## Scope Types Reference

| Type | Key Scopes | Description |
|------|-----------|-------------|
| **country** | owner, controller, overlord, subject | Empire or faction |
| **sector** | sector | Administrative subdivision |
| **galactic_object** | solar_system | Map-visible object |
| **megastructure** | megastructure | Constructor-built system object |
| **planet** | planet, orbit, star | Colonizable or stellar entity |
| **pop** | pop | Individual population unit |
| **leader** | leader, ruler | Country official or commander |
| **ship** | starbase, fleet member | Space vessel or station |
| **fleet** | fleet | Ship collection |
| **species** | species | Population subspecies |
| **war** | war | Diplomatic conflict |
| **federation** | federation | Multi-empire alliance |

## Major Scope Accessors

| Accessor | Type | Function |
|----------|------|----------|
| owner | country | Entity controller |
| planet_owner | country | Planet owner |
| space_owner | country | System owner |
| capital_scope | planet | Empire capital |
| solar_system | galactic_object | Containing system |
| orbit | planet | Orbited celestial body |
| leader/ruler | leader | Commander or regent |
| home_planet | planet | Species origin world |

## Triggers and Scopes

Scope-changing triggers (prefixed with `any_`) iterate through objects and execute enclosed conditions in their implied scope.

Example: `any_planet_within_border = { is_planet_class = pc_gaia }` checks all country planets for Gaia class in planet scope.

## Effects and Scopes

Scope-changing effects:
- **every_** - Apply to all matching objects
- **random_** - Apply to single random match
- **limit = { }** - Narrow results

Example: `every_owned_planet = { limit = { is_planet_class = pc_continental } … }` applies effects to Continental planets in planet scope.

## Event Targets

Save scopes for later reference:

```
save_event_target_as = <name>          # Namespace-scoped
save_global_event_target_as = <name>   # Global access
```

Reference with: `event_target:<name> = { … }`

Dynamic targets (v3.5+): `save_event_target_as = something@root`

Clear when unused: `clear_global_event_target = <name>`

## Complete Scope List

### Country Scopes
- owner, controller, contact_country, federation_leader
- overlord, branch_office_owner, last_created_country
- galactic_emperor, galactic_custodian

### Planetary Scopes
- planet, capital_scope, capital_star, home_planet
- orbit, sector_capital, star, system_star

### Population Scopes
- pop, last_created_pop, unhappiest_pop
- species, owner_species, owner_main_species

### Military Scopes
- fleet, ship, starbase, army, last_created_army
- orbital_defence, orbital_station

### Structural Scopes
- sector, solar_system, last_created_system
- megastructure, ambient_object, deposit
- archaeological_site, design

### Diplomatic Scopes
- federation, alliance, associated_federation
- war, attacker, defender
- spy_network, spynetwork, target
- first_contact, espionage_operation

### Leadership Scopes
- leader, ruler, last_created_leader

---

**Version:** 3.2+ (check game for latest via `trigger_docs` console command or `scopes.log`)

## See Also
- [Effects](effects.md) — effects available within each scope
- [Conditions](conditions.md) — conditions available within each scope
- [Event Modding](event_modding.md) — how scopes flow through events (ROOT, FROM, event targets)
- [On Actions](on_actions.md) — scope assignments for each on_action
