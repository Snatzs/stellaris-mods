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

## Pop-Group Script Access & Targeting (4.0+)

> Verified against 4.4.3. Relevant to any mod that reads/acts on the demographic + ethic composition of a planet (e.g. the ethnic-civil-war mod, `docs/ethnic-civil-war-design.md`).

### Iteration & filtering
- **Planet-scope iteration works:** `every_owned_pop_group` / `any_owned_pop_group` run in **planet scope** (and country scope). Verified: `events/ancient_relics_arcsite_events_1.txt:3234` (iterates on a planet, then `planet = {…}` / `set_owner` in the same scope), `:4247`.
- **Filter by species/phenotype:** inside the iterator, `species = { is_archetype = MACHINE/ROBOT/BIOLOGICAL/LITHOID }` or `is_species_class = MAM/REP/AVI/MOL/ART/FUN/PLANT/TOX/… ` (`scripted_triggers/08_scripted_triggers_shroud.txt:698+`).
- **Filter by ethic:** `has_ethic = ethic_xenophobe` etc. — ethics live on the pop **group** in 4.0 (the faction-membership model reads them this way: `pop_faction_types/00_imperialist.txt:755`). So you can filter a group by **species AND ethic at once** (e.g. "only militant-xenophobe natives").
- **Counting:** accumulate into a variable inside the loop, or use a `count_owned_pop_group = { limit = {…} count >= N }` trigger. Guard divisions against zero.

### Effects available on pop-group scope
- `kill_all_pop = yes` / `kill_pop` — `events/ancient_relics_arcsite_events_1.txt:3236`.
- `set_pop_group_flag = <flag>` / `has_pop_group_flag` — `:6079`. Pair a flag with a `triggered_pop_group_modifier` for per-group, per-planet effects (happiness, political power, faction access) with **no species-wide bleed**.

### ⚠️ Hard limitation — legal status is SPECIES-scope, not planet-scope
`set_citizenship_type` and `set_purge_type` operate on **`every_owned_species`** — a *(species, country)* pair, **not a planet** (`scripted_effects/galactic_community_effects.txt:452-453`). Consequences:
- You **cannot** confine a citizenship/slavery/purge *legal status* change to one planet. Changing "the xenos" changes every pop of that species empire-wide.
- **Per-planet differentiation of legal status requires speciation** (split the target pops into a new species first). No instant "reassign pop to new species" effect was found by obvious names in 4.4 — confirm before relying on it.
- **Workaround for per-planet "second-class" status:** use a pop-group flag + `triggered_pop_group_modifier` (above) instead of a citizenship change — it's surgical and planet-local.
- Purge types include `purge_displacement` (expulsion, not death).

### Ethic-attraction modifiers are planet-applicable
`pop_ethic_<ethic>_attraction_mult` (e.g. `pop_ethic_xenophobe_attraction_mult`, `pop_ethic_xenophile_attraction_mult`) appear inside **buildings** (`buildings/15_overlord_holdings.txt:1821-1830`, `buildings/23_shroud_buildings.txt`), so they apply at **planet scope** — a `triggered_planet_modifier` can carry them (e.g. shift ethics on a high-crime, diverse planet). Attraction drift is **slow** (years), so it models long-arc pressure, not instant flips.

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

### Hardcoded
- No native "travel time" mechanic for resettlement — would need event-based simulation (move pop, apply debuff/penalty timer)
- Pop automatic migration logic (growth-based) is engine-level

---

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
