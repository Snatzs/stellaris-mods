# Vanilla 4.3 — Warfare Architecture

## Claims System

### How Claim Costs Work

The cost formula is: `(base + starbase_addon + colony_addon + distance_addon) * (1 + sum_of_all_mult_modifiers)`

**Defines** (`common/defines/00_defines.txt`):
- `CLAIM_COST_BASE = 50` — base influence cost per claim
- `CLAIM_COST_MAX = 1000` — absolute cap per single claim
- `CLAIM_COST_STARBASE = 25` — added if target system has upgraded starbase
- `CLAIM_COST_COLONY = 25` — added if target system is colonized
- `CLAIM_COST_DISTANCE = 25` — per hyperlane jump from owned territory
- `CLAIM_COST_MULT_OFFENSIVE_WAR = 1.0` — claims during war cost +100%
- `CLAIM_COST_RIVAL_DISCOUNT = -0.20` — claims on rivals cost -20%

### Key Modifier

`country_claim_influence_cost_mult` — the ONLY modifier that affects claim costs. Country-scoped, **global** (applies to all claims, not per-target).

Used by vanilla in:
- Ethics: `ethic_fanatic_militarist` (-0.2), `ethic_militarist` (-0.1)
- Civics: `civic_distinguished_admiralty` (-0.15) — `common/governments/civics/00_civics.txt`
- Ascension perks: `ap_eternal_vigilance` (-0.20) — `common/ascension_perks/00_ascension_perks.txt`
- Federation perks: martial alliance perk (-0.10) — `common/federation_perks/00_perks.txt`
- Technologies: `tech_colonial_bureaucracy` (-0.1) — `common/technology/00_soc_tech.txt`
- Traditions: unyielding `country_hostile_claim_influence_cost_mult = 0.25` — `common/traditions/00_unyielding.txt`
- Councilors: general councilor (-0.025) — `common/governments/councilors/00_councilors.txt`

### On-Action

`on_claim_system` — fires when a country claims one or more systems.
- `This` = claiming country
- `From` = country owning the system
- Location: `common/on_actions/00_on_actions.txt:2519`

### Claim Triggers & Effects

**Triggers:**
- `has_claim = <country|system>` — checks if country has claims on target

**Effects:**
- `add_claims = { who = <country> num_of_claims = X }` — scope: galactic_object (system)
- `remove_claims = { who = <country> num_of_claims = X }` — scope: galactic_object (system)

### Limitation: No Per-Target Cost Modifier

`country_claim_influence_cost_mult` is global. There is no way to make claims on Empire A cost differently than claims on Empire B through the modifier alone. Workaround: use `on_claim_system` to apply/swap tiered modifiers based on active claim counts against the specific target.

---

## War Goals & Casus Belli

### File Locations

- Casus belli: `common/casus_belli/00_casus_belli.txt`
- War goals: `common/war_goals/00_war_goals.txt` (also `02_event_war_goals.txt`, `03_nemesis_war_goals.txt`, `04_imperium_war_goals.txt`)

### Casus Belli Structure

Defined in `common/casus_belli/`. Each CB has:
- `potential` / `is_valid` — condition blocks (ROOT = owner, FROM = target)
- `show_notification` — whether to alert the player
- Can be granted dynamically via `add_casus_belli` effect from events

### War Goal Structure

Defined in `common/war_goals/`. Each war goal has:
- `potential` / `possible` — when available
- `on_accept` — effects when war is won (full effect scripting: shift ethics, transfer systems, impose modifiers, etc.)
- `on_status_quo` — effects on stalemate
- `on_wargoal_set` — effects when goal is selected
- `cede_claims` — `yes` / `occupied_only` / `no`
- `release_occupied_systems_on_status_quo` — create new nations from occupation
- `total_war` — instant system transfer on occupation
- `war_exhaustion` — multiplier for exhaustion during this war
- `surrender_acceptance` — base value for AI surrender willingness
- `set_defender_wargoal` — force defender to use specific counter-goal
- `threat_multiplier` — diplomatic threat generation
- `allowed_peace_offers` — which peace types are available

### Fully Moddable

New CB and war goals can be created freely. The `on_accept` block supports arbitrary effects — shift ethics, force policy changes, apply timed modifiers, transfer territory, destroy fleets, etc.

### War Exhaustion & Occupation

**Defines** (`common/defines/00_defines.txt`):
- War exhaustion multiplier is per-war-goal (`war_exhaustion` field)
- `country_war_exhaustion_mult` modifier exists at country level
- Forced peace timer (24-month) is in defines and can be overridden

**Hardcoded:**
- Occupation % calculation (which systems/planets count and how much) — engine-level, not moddable
- Surrender acceptance formula weights (occupation, navy strength, exhaustion) — fixed weights, only the base `surrender_acceptance` value on war goals is adjustable

---

## Related Systems

- [Diplomacy](diplomacy.md) — opinion modifiers affect war acceptance; ethics gate casus belli conditions
- [Economy](economy.md) — claim costs are Influence-based; war goals can impose economic effects
- [Population](population.md) — war goals can liberate/resettle pops; occupation affects pop stability

## Key Files Summary

| System | Path |
|--------|------|
| Claim defines | `common/defines/00_defines.txt` (lines ~1980-1986) |
| Claim on_action | `common/on_actions/00_on_actions.txt:2519` |
| Casus belli | `common/casus_belli/00_casus_belli.txt` |
| War goals | `common/war_goals/00_war_goals.txt` |
| War-related AI defines | `common/defines/00_defines.txt` (lines ~2161, 2477-2524) |
