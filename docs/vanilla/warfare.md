# Vanilla 4.4 — Warfare Architecture

## Claims System

### How Claim Costs Work

The cost formula is: `(base + starbase_addon + colony_addon + distance_addon) * (1 + sum_of_all_mult_modifiers)`

**Defines** (`common/defines/00_defines.txt`, lines ~2029-2035):
- `CLAIM_COST_BASE` — base influence cost per claim
- `CLAIM_COST_MAX` — absolute cap per single claim
- `CLAIM_COST_STARBASE` — added if target system has upgraded starbase
- `CLAIM_COST_COLONY` — added if target system is colonized
- `CLAIM_COST_DISTANCE` — per hyperlane jump from owned territory
- `CLAIM_COST_MULT_OFFENSIVE_WAR` — claims during war cost more for attackers
- `CLAIM_COST_RIVAL_DISCOUNT` — claims on rivals cost less

(AI claim-priority defines `MAX_CLAIM_DISTANCE`, `CLAIM_BASE_VALUE`, `CLAIM_RESOURCE_FACTOR`, `CLAIM_COST_FACTOR`, etc. are separate, ~line 2576+.)

### Key Modifier

`country_claim_influence_cost_mult` — the main modifier for claim costs. Country-scoped, **global** (applies to all claims, not per-target). A second modifier `country_hostile_claim_influence_cost_mult` adjusts cost of claims on non-rivals/hostiles (used by the Unyielding tradition). Both are global, not per-target.

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
- Location: `common/on_actions/00_on_actions.txt:2651`

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

- Casus belli: `common/casus_belli/00_casus_belli.txt` (also `01_fallen_empire`, `02_event`, `03_megacorp`, `04_federation`, `05_nemesis`, `06_shroud`, `07_nomads` casus_belli files)
- War goals: `common/war_goals/00_war_goals.txt` (also `01_fallen_empire_war_goals.txt`, `02_event_war_goals.txt`, `03_nemesis_war_goals.txt`, `04_imperium_war_goals.txt`, `06_shroud_war_goals.txt`, `07_nomad_war_goals.txt`)
- `common/war_goals/wg_example.txt` — fully commented field reference; **read this first** when authoring a war goal.

### Casus Belli Structure

Defined in `common/casus_belli/`. Each CB has:
- `potential` — makes the CB invalid for certain country types (this = attacker/CB owner)
- `is_valid` — evaluated daily to create/destroy the CB automatically (this = attacker, from = defender); does not affect script-granted CBs
- `destroy_if` — evaluated daily to destroy script-granted CBs early
- `show_in_diplomacy` / `show_notification` — UI visibility flags
- `proxy_war_resources` / `on_proxy_war_start` — **Proxy War** support (see below); cost paid by the war's instigator when this CB is chosen for a proxy war
- Can be granted dynamically via `add_casus_belli` effect from events

### War Goal Structure

Defined in `common/war_goals/`. Field reference is `wg_example.txt`. Each war goal has:
- `casus_belli` — the CB this goal requires
- `potential` / `possible` — when available (FROM = target, THIS = actor)
- `on_accept` — effects when war is won / surrender accepted (full effect scripting: shift ethics, transfer systems, impose modifiers, etc.)
- `on_status_quo` — effects on stalemate / status-quo peace
- `on_wargoal_set` — effects when goal is selected (used by e.g. `wg_independence` to add claims)
- `cede_claims` — `yes` / `occupied_only` / `no`
- `release_occupied_systems_on_status_quo` — create new nations from occupation (`yes`/`no`)
- `total_war` — instant system transfer on occupation
- `war_exhaustion` — multiplier for how fast this side's exhaustion builds (2.0 = twice as fast)
- `surrender_acceptance` — base value for AI surrender willingness
- `set_defender_wargoal` — force defender to use a specific counter-goal
- `defender_default = yes` — goal the defender gets if none picked in time (first scripted wins)
- `threat_multiplier` — diplomatic threat from conquering systems/planets (default 1.0)
- `hide` — `never` / `always` / `no_cb`
- `forbidden_peace_offers = { demand_surrender/status_quo/surrender = <loc_key> }` — peace types this goal forbids (NOT `allowed_peace_offers`)
- `show_claims_in_description` / `show_agreement_terms` — tooltip flags
- `available_in_proxy_wars_only = yes` — restrict goal to Proxy Wars
- `galactic_community_joins_defender` / `secret_fealties_join_attacker` — multi-party war triggers

### Fully Moddable

New CB and war goals can be created freely. The `on_accept` block supports arbitrary effects — shift ethics, force policy changes, apply timed modifiers, transfer territory, destroy fleets, etc.

### War Exhaustion & Occupation

**Defines** (`common/defines/00_defines.txt`, `WAR_EXHAUSTION_*` block ~line 851+):
- War exhaustion multiplier is per-war-goal (`war_exhaustion` field)
- `country_war_exhaustion_mult` modifier exists at country level (confirmed, widely used)
- `WAR_EXHAUSTION_HIGH_THRESHOLD` (=1.0) is the point where the negative modifier/alert kicks in; `WAR_EXHAUSTION_PASSIVE_GAIN_*`, `WAR_EXHAUSTION_FULL_OCCUPATION_ATTRITION`, etc. tune accrual.
- Truce duration after peace: `TRUCE_YEARS` (=10) (UNVERIFIED 4.4 — was 4.3: the doc previously claimed a "24-month forced peace timer"; no such define found by that name, `TRUCE_YEARS` is the closest match).

**Hardcoded:**
- Occupation % calculation (which systems/planets count and how much) — engine-level, not moddable
- Surrender acceptance formula weights are define-tunable, not war-goal-tunable: `PEACE_*` and `SURRENDER_ACCEPTANCE_*` defines (~lines 2528+, 2588+) set the weights for occupation, navy strength, exhaustion, ceded-claim severity (`PEACE_DEFENDING_CLAIM_SYSTEM/STARBASE/PLANET_FACTOR`), etc. The per-war-goal `surrender_acceptance` value is an additive base on top of these.

---

## Proxy Wars (4.4)

Several CBs now carry `proxy_war_resources = { category = proxy_war cost = { influence = N } }` and `on_proxy_war_start = { pay_proxy_war_additional_resources = { VALUE = -N } }`. War goals can be flagged `available_in_proxy_wars_only = yes`. This is the engine hook for sponsoring a third party's war for a resource cost rather than fighting directly — relevant to "diplomacy with teeth" and indirect/partial conflict design.

---

## Nomads (Nomads-DLC-gated)

**Reference template for proportional / partial-outcome wars.** These goals win *something concrete* on partial resolution instead of requiring total conquest — a model for our partial-war-goal design.

Files:
- `common/war_goals/07_nomad_war_goals.txt` — `wg_nomad_raid`, `wg_expel_nomads`, `wg_heirs_call_of_the_satrapies` (plus `wg_end_threat_vs_heir_khan`, `wg_raid_contract`, dyson-gun goals)
- `common/casus_belli/07_nomads_casus_belli.txt` — `cb_nomad_raid`, `cb_expel_nomads` (plus `cb_nomad_raid_contract`, `cb_stop_dyson_gun` / `cb_fired_dyson_gun`)

Partial / status-quo resolution patterns to study:
- **`wg_expel_nomads`** (CB `cb_expel_nomads`, `set_defender_wargoal = wg_humiliation`): `on_status_quo` destroys the enemy's waystations (`expel_nomads_destroy_waystation_effect`); `on_accept` additionally loots the stockpile (`expel_nomads_destroy_waystation_and_take_stockpile_effect`). Status quo still inflicts a real, scoped loss — no territory transfer needed. Applied across overlord + subjects + war participants.
- **`wg_nomad_raid`** (CB `cb_nomad_raid`, symmetric `set_defender_wargoal = wg_nomad_raid`): `on_accept` seizes ark + loots waystations (`nomad_raid_seize_ark_effect`, `nomad_raid_loot_waystations_effect`, `nomad_raid_seize_disabled_waystations_effect`); `on_status_quo` keeps only the lighter `nomad_raid_seize_disabled_waystations_effect`. Two graded outcome tiers (win vs. stalemate) on the same goal — the clearest partial-outcome template.
- **`wg_heirs_call_of_the_satrapies`** (CB `cb_imposed_inclusion`, *not* a dedicated nomad CB): `on_accept` vassalizes via `set_subject_of preset = preset_relic_satrapy`; `on_status_quo` only subjugates a freshly-released country if one exists. `war_exhaustion = 0.5`, `release_occupied_systems_on_status_quo = yes`.

Note: nomad CBs gate on `is_nomadic` / waystation-network adjacency (`benefits_from_waystation_network`, `has_waystation_pact`, `is_waystation_starbase`) and carry `proxy_war_resources` — they are tightly coupled to the Nomads waystation system, so the *resolution structure* (graded on_accept vs on_status_quo effects) is the reusable lesson, not the triggers.

---

## Related Systems

- [Diplomacy](diplomacy.md) — opinion modifiers affect war acceptance; ethics gate casus belli conditions
- [Economy](economy.md) — claim costs are Influence-based; war goals can impose economic effects
- [Population](population.md) — war goals can liberate/resettle pops; occupation affects pop stability

## Key Files Summary

| System | Path |
|--------|------|
| Claim defines | `common/defines/00_defines.txt` (lines ~2029-2035) |
| Claim on_action | `common/on_actions/00_on_actions.txt:2651` |
| Casus belli | `common/casus_belli/00_casus_belli.txt` |
| War goals | `common/war_goals/00_war_goals.txt` |
| War goal field reference | `common/war_goals/wg_example.txt` |
| Nomads war goals / CBs (DLC) | `common/war_goals/07_nomad_war_goals.txt`, `common/casus_belli/07_nomads_casus_belli.txt` |
| War / peace AI defines | `common/defines/00_defines.txt` (PEACE_* ~line 2528+, SURRENDER_ACCEPTANCE_* ~line 2588+) |
| War exhaustion defines | `common/defines/00_defines.txt` (WAR_EXHAUSTION_* ~line 851+) |
