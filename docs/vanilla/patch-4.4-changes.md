# Patch 4.4 "Pegasus" + Nomads — Changes That Matter to This Project

> What changed from 4.3 → 4.4 that affects our modding, organized by impact on the design vision.
> Sourced from the official 4.4 patch notes (Stellaris Wiki / Dev Diary #424) and **verified against the live 4.4.4 files at `D:\Stellaris\`** where flagged. The in-install `ChangeLog.txt` is stale (frozen at 2.6.1) — do not use it.
>
> This is a *delta* doc. For current-state architecture, see the sibling `economy.md` / `warfare.md` / `diplomacy.md` / `population.md` (already re-verified against 4.4.4).

---

## 1. New modding levers (verified present in 4.4.4 files)

These are new scripting primitives the patch added. They directly enable roadmap items — reach for them before inventing workarounds.

**Triggers**
- `is_nomadic` (country) — ✅ `common/scripted_triggers/00_scripted_triggers.txt`
- `resource_stockpile_percent = { resource = <key> value >= <fraction> }` — ✅ widely used (ai_budget, achievements)
- `num_claims_on_system = { target = <country> count >= <n> }` — ✅ used in nomad inline scripts + `08_script_values_nomads.txt`. **Directly relevant to our "claim limits proportional to defender size" roadmap item.**
- `is_system_locked` — replaces old `is_moving`
- `is_megacorp = yes` — replaces `has_authority = auth_corporate`
- mission triggers: `has_contract`, `has_contract_of_type`, `is_contract_type`, `has_mission_flag`

**Effects**
- `create_country` now accepts `is_nomadic`
- `create_random_fleet` (weighted) — old deterministic version renamed `create_balanced_fleet`. **MP note: prefer `create_balanced_fleet` for determinism.**
- `set_resource_converter` (stockpile alternate-payment) — relevant to the Nomads "pay strategic resources instead of minerals" pattern
- `create_sector` (orphan colonies); `damage_ship` gains attacker-country param
- `steal_planet_output` — *(UNVERIFIED — claimed in patch notes, not found by grep in `common/`; may be event-scoped or renamed. Confirm before use.)*

**On-actions** (✅ `common/on_actions/00_on_actions.txt`)
- `on_megastructure_build_start`, `on_leaving_system_fleet`, `on_system_locked_ship_killed`
- missions: `on_fail` removed; `on_cancel` now runs regardless of end reason

**Modifiers**
- `planet_artificial_max_districts_add` — ✅ (`17_nomads_deposits.txt`, `00_first_contact_tech.txt`, `00_adaptability.txt`). Pairs with `planet_max_districts_add`/`_mult` for our planet-size-cap goal (habitats/ringworlds/arkships counted separately).
- `country_branch_office_influence_cost_mult`, `ship_size_damage_factor`
- `shared_capacity_modifier` pool replaces `inherits_capped_modifiers_from`

**Weapons** — new AoE/bounce fields: `collateral_damage`/`collateral_range`, `chain_damage`/`chain_range`/`chain_count`.

**Megastructures** — `tooltip_*` system-scoring fields, `show_in_build_menu`; potential/possible now see the constructing fleet scope; build/dismantle times must be > 0.

**Other** — `pop_group_can_join_factions` game rule; ethics support `triggered_country_modifier`; tradition swaps support `unlocks_agenda`; new `-logempirestats` TSV dump flag (useful for MP balance telemetry).

---

## 2. Pop & job system overhaul (affects slavery + pop mods)

**Unemployment tier removed — VERIFIED.** `ruler_unemployment` / `specialist_unemployment` (etc.) jobs no longer exist in `common/pop_jobs/`. Pops now fall directly to their **stratum fallback** job. Demotion/promotion blocks in pop-job scripts and the `pop_cat_X_unemployment_political_power` family + `pop_unemployment_demotion_time_mult` modifier are gone.
- **Implication for our slavery mod:** any plan that hooked unemployment jobs/demotion timing must be rebased onto the fallback-stratum model. The specialist-slavery approach (override `can_fill_specialist_job_trigger`) is unaffected — that gate still exists (see `population.md`).

**Job turnover slowed** (design intent: less pop-shuffle churn): Workers/Simple Drones reshuffle ~3 months, Specialists/Complex Drones ~7, Elites ~13. Gestalt pops have weaker job attachment. Nascent-stage colonies integrate pops gradually via a `forced_integration` block (`integration_rate`, `minimum_colony_age`).

---

## 3. Where vanilla 4.4 ALREADY moved toward our vision (rebaseline — less work for us)

| Pillar | Vanilla 4.4 change | Effect on our plan |
|--------|-------------------|--------------------|
| Scarcity | Endgame AI alloy target 2300→1300 (lets research compete); Unity culling conversion 1→3 | Mild scarcity nudge already in; our alloy-scarcity mod starts from a slightly tighter baseline |
| Scarcity / borders | Branch-office cost: energy→**trade**, influence-capped at 1000 (no longer distance-scaled) | Economic spread is reined in already; revisit our "borders restrict commerce" scope |
| Geography | Black Hole Observatory → **Stellar Observatory** (buildable anywhere, output depends on star type); Stellar Cannon needs neutron star/pulsar | Star/system *type* now carries value — aligned with "geography matters"; build on it |
| War teeth | Mid-war join/leave via negotiation (treachery opinion hit + truce); all-colonies-occupied → escalating War Exhaustion (+5%/mo) & Attrition | Partial movement toward "war as a tool, not all-or-nothing" — but see §5, the claim-size limit is still on us |
| Space>planets | Nomads waystation/wayline economy = working space-over-planets model | Reference implementation for our economy mod (see `economy.md` Nomads note) |
| War partial outcomes | Nomad war goals resolve via status-quo (destroy/loot waystations), not total conquest | Template for proportional war goals (see `warfare.md` Nomads section) |

---

## 4. ⚠️ Where vanilla 4.4 moved AGAINST our vision (needs a group decision)

**Migration / resettlement reversed direction.** Our vision (design-vision.md → Population & Migration) wants resettlement to be **harder, timed, and habitability-gated**. Vanilla 4.4 went the **opposite way**:
- The habitability-based resettlement defines (`AI_RESETTLE_FROM_LOW_HABITABILITY_THRESHOLD`, `AI_RESETTLE_TO_HIGH_HABITABILITY_THRESHOLD`) were **removed — VERIFIED absent** from `common/defines/`.
- AI now resettles pops from overpopulated → underpopulated planets **regardless of habitability**.
- **Decision needed:** our migration-restriction mod now has to *re-impose* friction the base game just removed, and fight the AI's new resettlement behavior. This raises the cost/risk of that roadmap item. Flag for group discussion before committing effort.

**`UNDERDEVELOPED_PLANET_LIMIT` softened** to a weight (applies only after ~15 years) and **abandon-colony cost cut 200→50 influence** — both lower the friction on wide sprawl. Net-helpful for "wide > tall," but also weakens any natural cap on overextension we were relying on.

---

## 5. Still entirely on us (vanilla 4.4 did NOT address)

- Claim limits proportional to defender size (but `num_claims_on_system` trigger now helps — §1)
- Planet size cap / size-distribution shift (use `planet_max_districts_*` + `planet_artificial_max_districts_add`)
- Reduce jobs per district; hyper-specialized mega-planet penalties (new AI zone-specialization defines exist — `AI_ZONE_SPECIALIZATION_AFFINITY_DELTA` etc. — but these steer AI, not caps)
- Space-resource-as-primary economy for *normal* (non-nomad) empires
- Federation internal-politics rework; ethics-as-hard-constraint diplomacy
- Border restrictions for ordinary empires (Nomads proves access-gating is *partially* feasible — see `diplomacy.md` — but it's `is_nomadic`/DLC-gated and doesn't generalize without reimplementation)
- Timed resettlement (now harder — see §4)

---

## 6. New build-meta / balance risks to watch (pillar 4: "kill the build meta")

The patch adds powerful new synergy surfaces. Audit these before the campaign:
- **Nomadic origins** (Voidfarers, Heirs of the Khan, Sacred Path, Forever Cruise) + **nomad civics** (Void Reavers raiding colonies via waystations, Star Seekers, Caravan Masters) — entirely new optimization space, asymmetric vs. settled empires. **Open question for the group: are nomadic empires even allowed in our 7-player campaign, or banned pending balance?**
- **Defender of the Galaxy Ambition** (5-level path, Paladin Initiative, hero ships) — new power spike.
- Commander **Roamer/Reaver/Plunderer** trait reworks (now scale by destroyed-ship naval capacity).
- New species traits: Photoadaptive/Solar Celled, Recursive Learners/Structural Awareness, Reaver, Terraphobic, Interconnected.

---

## Sources
- Stellaris Dev Diary #424 — "Nomads and 4.4 'Pegasus'" release notes
- Stellaris Wiki: Patch 4.4, Patch 4.4.X
- Cross-verified against live files at `D:\Stellaris\` (4.4.4 / Pegasus)
