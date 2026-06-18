# Vanilla 4.4 — Population & Slavery Architecture

> Verified against Stellaris 4.4.3 (Pegasus). 4.0+ pop-GROUP model confirmed: pops are organized into pop groups; modifiers use `pop_group_modifier` / `triggered_pop_group_modifier` and group flags use `has_pop_group_flag`. The strata/category model below still holds.

## Pop Categories (Strata)

Defined in `common/pop_categories/00_social_classes.txt`. (Gestalt drones in `01_gestalt_drones.txt`; other categories — incl. Nomads cruise-passenger — in `02_other_categories.txt`.)

| Category | Rank | Change Job Threshold | Reshuffle Interval |
|----------|------|---------------------|--------------------|
| `ruler` | 4 | 1.14 | 13 |
| `specialist` | 3 | 1.07 | 7 |
| `worker` | 2 | 1.03 | 3 |

Each category has: `pop_group_modifier` (housing/amenity usage, e.g. `pop_housing_usage_base`/`pop_amenities_usage_base`), `automation_resources`, `resources` (upkeep/production per category), `triggered_planet_modifier`, `allow_resettlement`, and inline scripts for resettlement cost and living-standard production (`pop_categories/living_standard_<cat>_production`, `pop_categories/social_classes_triggered_modifiers`, `pop_categories/indentured_assets_slave_produce`).

---

## Slavery Types

Defined in `common/species_rights/slavery_types/00_slavery_types.txt`.

### Vanilla Types

| Type | Key | Specialist Access | Pop Group Modifier | Notes |
|------|-----|-------------------|-------------------|-------|
All happiness modifiers below are the `pop_happiness` key inside `pop_group_modifier`. Military/army modifiers are in `modifier` (country-scope), not `pop_group_modifier`.

| Chattel Slavery | `slavery_normal` | NO | `pop_bonus_workforce_mult = 0.10`, `pop_happiness` neg | Default slave type |
| Domestic Servitude | `slavery_domestic` | NO | `pop_happiness` neg | No production bonus |
| Battle Thralls | `slavery_military` | NO | `modifier`: `army_damage_mult`, `soldier_jobs_bonus_workforce_mult`; `pop_group_modifier`: `pop_happiness` neg | Military focus |
| Indentured Servitude | `slavery_indentured` | YES | `pop_happiness` neg, `pop_political_power = 0.50` | Only type allowing specialist jobs (see gate below) |
| Livestock | `slavery_livestock` | NO | `pop_happiness` neg | Requires xenophobe/gestalt (or guided-sapience machine) |
| Matrix | `slavery_matrix` | NO | `pop_happiness` neg | Machine empire only (non-guided-sapience) |
| Guided Matrix | `slavery_matrix_guided_sapience` | NO | `pop_happiness` pos | `potential` gated on `has_machine_age_dlc = yes` (Machine Age DLC) |
| Orderly | `slavery_orderly` | NO | — (no `pop_group_modifier`) | Twisted experimenters only |

### Slavery Type Structure

Each type has:
- `pop_group_modifier` — modifiers applied to enslaved pops of this type
- `modifier` — country/empire-wide modifiers (e.g., `army_damage_mult`)
- `potential` — when the type appears as an option
- `allow` — when it can be selected
- `ai_will_do` — AI weight with conditional modifiers

### New Slavery Types: Confirmed Possible

New entries in `common/species_rights/slavery_types/` ARE loaded by the game. Proven by existing mods (e.g., "Extra Slavery Types" on Steam Workshop). No hardcoded limit on number of types.

---

## Specialist Job Access Gate

**Critical file:** `common/scripted_triggers/01_scripted_triggers_jobs.txt` — `can_fill_specialist_job_trigger` (4.4.3: starts at line ~273; the old line 261 reference is stale).

The trigger is now wrapped in `custom_tooltip = SPECIALIST_JOB_TRIGGER` + `hidden_trigger`, and the slavery OR is only one of several conditions:

```
can_fill_specialist_job_trigger = {
    custom_tooltip = SPECIALIST_JOB_TRIGGER
    hidden_trigger = {
        NOT = { has_ethic = ethic_gestalt_consciousness }
        exists = owner
        OR = {
            is_enslaved = no
            has_slavery_type = { type = slavery_indentured }
        }
        is_being_purged = no
        is_being_assimilated = no
        NOT = { has_trait = trait_syncretic_proles }
        can_think = yes
        NOT = { has_pop_group_flag = cant_work }     # 4.0+ pop-group flag
        has_disconnected_drone_citizenship_type = no
        # ... + trait_mechanical/tech_droid_workers, organic_trophy /
        #       cruise_passenger (Nomads) citizenship exclusions, divinity right-to-work
    }
}
```

This OR is still THE gate for whether slaves can work specialist jobs. To enable a new slavery type for specialist work, add it to that OR block. Note the surrounding conditions have grown (pop-group flags, more citizenship-type exclusions) — when overriding, copy the *current* full trigger, not just the OR. Overriding this vanilla file — **track in `docs/compatibility.md`**.

Some individual specialist jobs also have `is_enslaved = no` in their `possible_pre_triggers` (and many specialist jobs ship slave-variant definitions guarded by `is_enslaved = yes`) — enabling a new slavery type at specialist tier may need per-job overrides in `common/pop_jobs/`.

---

## Key Modifiers for Slave Economy

### Output
- `pop_bonus_workforce_mult` — bonus workforce percentage (used in `pop_group_modifier` on slavery types)
- `planet_jobs_slave_produces_mult` — multiplier on ALL job output from slave-category pops (generated by economic category system)
- Per-job variants: `planet_jobs_researcher_produces_mult`, `planet_jobs_metallurgist_produces_mult`, etc.

### Cost Advantages (Built-In for Slaves)
- Slaves generally use less housing/amenities and less consumer-goods upkeep than free specialists (exact multipliers not copied — verify in living-standards / pop-category inline scripts). Base `pop_group_modifier` for ruler/specialist/worker categories is `pop_housing_usage_base = 1` / `pop_amenities_usage_base = 1`; slave reductions come from living standards + slavery-type modifiers, not the base category. (UNVERIFIED 4.4 — was 4.3: prior doc cited 0.75 housing/amenity and 50-energy resettlement; not re-confirmed.)

### Stability & Happiness
- Slave political power / happiness are controlled via `pop_cat_*_political_power` and `pop_happiness`-family modifiers (e.g. indentured: `pop_political_power = 0.50`). Exact slave political-power percentage not copied. (UNVERIFIED 4.4 — was 4.3: prior doc cited a `pop_cat_slave_political_power` of -75%; modifier name/value not re-confirmed in 4.4.3.)
- Slaves cannot join factions.
- Low stability with slaves triggers dangerous events at a lower stability threshold than non-slave planets. (UNVERIFIED 4.4 — was 4.3: specific 40 vs 25 thresholds not re-confirmed.)

---

## 4.0+ Workforce System

Stellaris 4.0 changed production bonuses. Species traits now give "+X% Bonus Workforce for [Job] Jobs" instead of "+X% [Resource] from Jobs".

- Regular workforce: if a pop generates more than needed, fewer pops fill the job but output caps at maximum
- **Bonus workforce**: CAN exceed the job's maximum output — scales production UP

This means `pop_bonus_workforce_mult` in slavery types directly scales output beyond job caps. More slaves with bonus workforce = more total output. This inherently rewards wide play.

---

## Species Rights Structure

Located in `common/species_rights/` with subdirectories:

| Subdirectory | Controls |
|-------------|----------|
| `citizenship_types/` | Full citizenship, residence, slavery, purge status |
| `slavery_types/` | Chattel, domestic, military, indentured, etc. |
| `living_standards/` | Subsistence, normal, academic privilege, utopian, etc. |
| `purge_types/` | Displacement, processing, extermination, etc. |
| `migration_controls/` | Migration policies per species |
| `colonization_controls/` | Colonization rights per species |
| `population_controls/` | Population growth controls |
| `military_service_types/` | Military service policies |
| `subspecies_integration_types/` | Subspecies integration (4.0+) |

Each has `potential`/`allow` conditions, modifiers, and AI weights. All are moddable — new entries can be added.

Living standards are split across files: `00_living_standards.txt` (core: `living_standard_normal`, `_good`, `_utopian`, `_academic_privilege`, `_shared_burden`, `_chemical_bliss`, `_stratified`, `_subsistence`, `_servitude`, `_decadent`, `_worker_ownership`, `_dystopian_society`, `_organic_trophy`, `_hive_mind`, `_protected`, `_none`), plus `00_biogenesis_living_standards.txt` and `01_assimilation_living_standards.txt`.

### Nomads DLC additions (Nomads-DLC-gated)

> All gated on `has_nomads_dlc = yes` + `origin_forever_cruise`.

- **Living standards:** `common/species_rights/living_standards/00_nomads_living_standards.txt` — `living_standard_cruise_passenger`, `living_standard_cruise_economy_passenger`. Use a `pop_cat_cruise_passenger_*` political-power family and tie to `citizenship_cruise_passenger`.
- **Jobs:** `common/pop_jobs/17_nomads_jobs.txt` — `cruise_passenger`, `cruise_passenger_unemployment`, `cruise_crew_overseer`(+`_drone`), `ark_waystation_trader`(+`_gestalt`), `ark_harvester`(+`_gestalt`), `ark_deep_sleep`.
- **Deep-sleep / cryo:** `ark_deep_sleep` job uses `category = deep_sleep` (pops held in cryo/stasis rather than working). The `can_fill_specialist_job_trigger` and several jobs explicitly exclude `citizenship_cruise_passenger` pops.

---

## Migration & Resettlement

### Resettlement
- Currently instant — no travel time
- Cost defined per pop category in `common/pop_categories/` via `inline_script = "pop_categories/resettlement_costs"`
- Resettlement can be restricted per species via `allow_resettlement` block in pop categories

### Migration
- Migration controls per species in `common/species_rights/migration_controls/`
- Migration pacts are diplomatic actions in `common/diplomatic_actions/`
- Closed borders inherently block migration treaties

### Habitability & migration defines (`common/defines/00_defines.txt`) — 4.4.3 verified
Two **distinct** systems — don't conflate (see [patch-4.4-changes.md](patch-4.4-changes.md) §4 for the correction history):
- **`HABITABILITY_AUTO_MIGRATION = 0.20`** (line 849) — minimum target habitability for **automatic** migration. Pops do **not** auto-migrate to planets below this. **Prime single-define lever** for "pops shouldn't migrate where habitability works against them" — raise it.
- **`RESETTLE_UNEMPLOYED_BASE_RATE = 10`** (1935) — base pop amount that can auto-migrate per planet per month.
- **`RESETTLE_ABROAD_MULTIPLIER = 0.8`** (1937) — score multiplier for auto-migration targets in *other* empires.
- **AI *manual* resettlement** is gated by pop-count, NOT habitability: `AI_LEAVE_POPS_WHEN_RESETTLING = 500` (2173), `AI_SKIP_RESETTLING_MANY_POPS = 50000` (2176). The old `AI_RESETTLE_*_HABITABILITY_THRESHOLD` defines were removed in 4.4.

### Hardcoded
- No native "travel time" mechanic for **forced/manual** resettlement — would need event-based simulation (move pop, apply debuff/penalty timer). This (instant, unrestricted forced resettlement) is the real gap for the "timed resettlement" goal — automatic migration is already habitability-gated by the define above.
- Pop automatic migration logic (growth-based) is engine-level, but tunable via the migration defines above.
- **⚠️ Habitability *weighting* in the auto-migration destination score is NOT moddable** (verified: no define/modifier exposes it). Above the `HABITABILITY_AUTO_MIGRATION` floor, how habitability competes with jobs/housing/unemployment in target selection is hardcoded. The only migration levers are: the **binary** floor define, rate defines (`RESETTLE_UNEMPLOYED_BASE_RATE`, `RESETTLE_ABROAD_MULTIPLIER`), the `mod_country_emigration_push_mult` modifier (emigration *push*, not destination choice), and per-species `migration_controls/` (binary allow/block). **To discourage migration to *mediocre* (20–50%) worlds you must either raise the binary floor or build a custom event-driven restriction — there is no "gently weight habitability" knob.**

---

## Pop-group modding API (4.0+) — verified primitives

> Hard-won and verified against 4.4.3 while building `migration_overhaul`'s species-clustering system.
> These are the practical building blocks for any per-planet pop-composition logic (species-clustering,
> Angle B cohesion, timed resettlement). See that mod's `scripted_effects/migr_clustering_effects.txt`
> for a working example.

**Iteration (planet & country scope)**
- `every_owned_species` / `any_owned_species` / `count_owned_species` / `random_owned_species` — iterate the **distinct species** present (works in planet scope: the planet's species).
- `every_owned_pop_group` / `any_owned_pop_group` / `count_owned_pop_group` — iterate **pop groups** (works in planet scope: the planet's pop groups).

**Counting pops** — `count_owned_pop_amount = { limit = { <filter> } count >= N }` counts pop *units* by any filter (`is_enslaved`, `species = { … }`, `is_pop_category = …`, etc.). To get the *value* into a variable: `export_trigger_value_to_variable = { trigger = count_owned_pop_amount parameters = { limit = { … } } variable = X }` (vanilla template: `common/scripted_effects/00_scripted_effects.txt` → `count_drones_on_planet`).

**Fraction math** — `set_variable` / `multiply_variable` / `subtract_variable` / `divide_variable` + `check_variable = { which = X value < 0 }`. (Avoid variable-vs-variable compares by reducing to a single var vs a constant.)

**Flags** — pop-group: `set_pop_group_flag` / `set_timed_pop_group_flag` / `has_pop_group_flag` / `remove_pop_group_flag`. Species: `set_species_flag` / `set_timed_species_flag` / `has_species_flag` / `remove_species_flag`. ⚠️ **Species flags are GLOBAL to the species (not per-planet)** — to use one as a per-planet marker, set→use→remove it synchronously within one iteration.

**Applying a modifier to a pop group** — there is **no `add_modifier` effect on a bare pop_group scope**. The working pattern is `add_modifier` *inside* `every_owned_pop_group` iteration (planet scope), with `days = N` for a timed, self-expiring modifier (vanilla example: `pop_drought` in `events/colony_events_1.txt:2413`). The modifier is a `static_modifier` with `pop_*` content. Declarative alternative: `triggered_pop_group_modifier` — but it can only be **hosted** inside `pop_categories` / `living_standards` / `traits` (so a new one requires overriding a vanilla file; the `add_modifier`-in-iteration route avoids that).

**Relevant on_actions** (scopes verified in `common/on_actions/00_on_actions.txt`): `on_pop_group_added` (this = pop group), `on_pop_group_resettled` (this = pop group, from = previous colony, `local_pop_amount` var), `on_colony_conquer` (this = colony, from = new owner, fromfrom = former owner), `on_yearly_pulse_country` (this = country). **on_actions MERGE across files** — adding your own block appends to vanilla rather than overriding.

## Related Systems

- [Economy](economy.md) — economic categories generate per-job and per-category production modifiers; district jobs feed into pop output
- [Diplomacy](diplomacy.md) — ethics and species-type checks affect opinion modifiers and federation eligibility

## Key Files Summary

| System | Path |
|--------|------|
| Pop categories | `common/pop_categories/00_social_classes.txt` (+ `01_gestalt_drones.txt`, `02_other_categories.txt`) |
| Slavery types | `common/species_rights/slavery_types/00_slavery_types.txt` |
| Specialist job gate | `common/scripted_triggers/01_scripted_triggers_jobs.txt` → `can_fill_specialist_job_trigger` (~line 273) |
| Living standards | `common/species_rights/living_standards/00_living_standards.txt` (+ nomads/biogenesis/assimilation files) |
| Nomads living standards / jobs (DLC) | `.../living_standards/00_nomads_living_standards.txt`, `common/pop_jobs/17_nomads_jobs.txt` |
| Species rights (all) | `common/species_rights/` |
| Pop jobs | `common/pop_jobs/` |
| Economic categories | `common/economic_categories/` |
