# Roadmap

Track what needs to be done, what's in progress, and what's done.

---

## ▶ Current Focus / Session Handoff

> **⚠️ Branch note:** this is the **`mod/economy-overhaul`** branch (off `master`). The
> "Last session (2026-06-18)" + migration handoff text below is `master`'s narrative and is
> **stale here** — the migration mod is built on `mod/migration-overhaul` and will arrive on
> `master` via its own merge. The economy handoff is the authoritative one for THIS branch.

**SESSIONS 2026-06-23/24 — economy_overhaul reworked to "v2" and **in-game tested** on `mod/economy-overhaul`.**
Slices 1–3 were found **broken in-game** (the original `zzz_` approach silently failed), then rebuilt and verified.
**Read [economy-overhaul-design.md](economy-overhaul-design.md) → "v2 — Revised decisions" (top) — it is authoritative.**

**Hard-won 4.4.3 mechanics (don't re-learn these):**
- **Scripted variables CANNOT be overridden by redefinition** (`error.log: Variable name X already taken`) → must
  **whole-file replace** the defining file. DB objects (civics/techs) + defines DO override last-wins.
- **on_actions reject bare `effect = {}`** → use `events = { id }` + a hidden `is_triggered_only` event.
- **`every_system_planet` is SYSTEM-scoped** → wrap in `every_system { … }` to hit the whole galaxy.
- **`@habitable_planet_max_size` does NOT cap procedural worlds** → cap via an `on_game_start` resize event.
- **4.4 pop pressure = HOUSELESSNESS** (overcrowding stops growth/decline), not joblessness (jobless→civilians).
- **Local dev mods need a junction into the game `mod/` dir + relative descriptor path** (external absolute path
  registers but never loads). `tools/deploy.sh` now does this automatically (reads Irony's UserDirectory).

**v2 state — BUILT & verified ✅ (see design-doc table for the full list):** deposit yields ×1.75 (flat +50%
modifier removed); rural jobs 200→150; specialist zone jobs −30%; **urban district housing −30%** (replaced the
global housing mult — spares rural/wide); overcrowding 1.10/1.20; **planet-size resize event** (≈no >18 worlds
confirmed); kilostructures ×0.4; **mechanical pop assembly −33%**; civics/repeatables/ascension unchanged from before.
All overrides re-logged in [compatibility.md](compatibility.md).

**4.4.4 UPDATE (2026-06-25):** game bumped to Pegasus v4.4.4 (5505). economy_overhaul verified compatible —
`supported_version = "4.4.*"` covers it; none of our 4 whole-file overrides (scripted_variables 07/100,
00_urban_districts, 01_orbital_deposits) were touched by the patch (all retain pre-patch mtime), and the 3 vanilla
repeatable-tech keys we override still exist. No changes were needed.

**▶ START HERE NEXT SESSION — open items (in priority order):**
1. ✅ **DONE + VERIFIED in-game 2026-06-25 — Hive/organic flat-growth parity (the spawning-pool gap).** Built
   `bonus_pop_growth_mult = @econ_growth_nerf` (−33%, matches assembly nerf) on `econ_space_primacy`. Investigation
   overturned the doc's premise: spawning drones / budding / clone vats emit `bonus_pop_growth` (flat), while
   Fertile/Rapid Breeders use `logistic_growth_mult` — so this lever is clean, NOT blunt, and is patch-robust (no
   brittle job-copy). **Confirmed in-game:** pop-GROUP growth breakdown shows the −33% under **Bonus Growth**
   (labelled "Galactic Resource Distribution") scaling the Spawning Drone flat add; **Base/logistic Growth untouched**.
   Gotcha for future testing: the per-JOB tooltip does NOT show country-scope growth mults — read the pop-GROUP panel.
1b. ✅ **DONE 2026-06-25 — Assembly nerf made machine-EXEMPT (v2.3).** Moved `planet_pop_assembly_mult −33%`
   out of the universal `econ_space_primacy` into a new `econ_organic_assembly_nerf`, applied only when
   `is_machine_empire = no` (event `econ_overhaul.1`). Machines grow solely by assembly and are already
   late-capped by vanilla **Country Growth Scale** (confirmed: a flat-channel, pop-count tax that EXEMPTS
   logistic even for hives), so stacking our −33% gutted them late. Organics keep it (prevents robot
   assembly stacking tax-free on logistic). **Test pending:** confirm machine empires show NO "Constrained
   Pop Assembly" modifier; organics/hives do.
1b'. ✅ **DONE 2026-06-25 — mid-game empires now covered + idempotency.** `econ_overhaul.1` was only hooked to
   `on_game_start_country`, so empires born mid-game (released vassals, rebellions, independence factions)
   escaped ALL economy modifiers — an MP hole. Added `on_country_created` hook; made the event idempotent
   (`has_modifier` guards) since static modifiers stack if added twice. **Note:** still won't retro-apply to
   EXISTING saves (event already fired) — test v2.2/v2.3 on a fresh game. Housing reminder: the cut is
   per-district URBAN only (×0.70); the global `planet_housing_mult` was removed on purpose — do NOT re-add it.
1c. **🔴 NEW calibration findings (2026-06-25) — see design-doc Open Items #4–5:**
   - **Mineral GLUT (HIGH):** all empires triple-digit minerals by yr 20 → `×1.75` deposit buff overshot,
     undercuts scarcity. Decide supply-down (cut toward ×1.3–1.4) vs sink-up before slice 4.
   - **Housing cut — INCONCLUSIVE (needs testing, don't act):** contradictory games — one shows planets
     carrying large pops pressure-free, another shows 19-size capitals choking on capacity with no
     residences. May already be biting situationally. MEASURE housing vs housing-needs across sizes first.
     (If ever tuned: urban-only or capacity — never re-add a global `planet_housing_mult`.)
2. **Decision B — planet bulk output.** Get a *regular colony's* minerals/energy (NOT the capital) to decide whether
   to enable the reserved per-pop nerf (`planet_miners_minerals`/`planet_technician_energy_produces_mult` −30%).
3. **Mono-specialised mega-planets** (100%-research ecumenopoli) — distinct design problem, parked. Design-doc Open #3.
4. **Then** slice 4 — strategic resources (refining nerf + strategic repeatable + `02_sr_deposits.txt` `drop_weight`
   concentration). The make-or-break track; do after the above settle.

**Calibration knobs to watch** (all first-pass, tunable in their files): deposit ×1.75, rural 150, zone jobs −30%,
urban housing ×0.70, overcrowding 1.10/1.20, assembly −33% **(organics only; machines exempt)**, **flat-growth (spawning/budding/clone) −33%**, kilostructures ×0.4.

**(C) Migration mod:** independent — `mod/migration-overhaul` still code-complete/untested, awaiting its own test + merge.

**Housekeeping:** parked git stash (`stash@{0}`, old migration-base doc edits) — harmless, drop when convenient.

---

### (Stale below — master's migration-build handoff, kept for the eventual merge)

**Last session (2026-06-18):** Bumped the whole repo from 4.3 → **4.4.3 "Pegasus" + Nomads**; re-verified all 4 `docs/vanilla/` architecture docs against live game files; mined the 4.4 changelog into [`docs/vanilla/patch-4.4-changes.md`](vanilla/patch-4.4-changes.md); logged two group decisions (nomads **banned**; migration mod **approved**). All merged to `master`. `mods/` is still empty — toolchain (`new-mod.sh`/`validate.sh`/`deploy.sh`) is **untested end-to-end**.

**Next session — build the migration mod FIRST.** Starting context so you can dive in:
- **Goal:** timed resettlement (not instant) + pop-movement restrictions by habitability & species clustering. See [design-vision.md](design-vision.md) → Population & Migration.
- **⚠️ Headwind:** vanilla 4.4 *removed* the habitability resettle defines and the AI now resettles regardless of habitability — this mod must actively counter the base AI (see [patch-4.4-changes.md](vanilla/patch-4.4-changes.md) §4). Account for this in the design, not just the player-facing rules.
- **Key vanilla 4.4.3 files (verified present):**
  - `common/species_rights/migration_controls/00_species_controls_migration.txt` — migration access controls
  - `common/pop_categories/00_social_classes.txt` (+ `01_gestalt_drones`, `02_other_categories`) — `allow_resettlement` per stratum
  - `common/inline_scripts/pop_categories/resettlement_costs.txt` / `resettlement_costs_low.txt` — resettlement cost (lever for "timed/costly")
  - `common/game_rules/00_rules.txt` — resettlement-related game rules
  - `common/federation_laws/11_free_migration.txt` — federation free-migration law
  - `common/defines/00_defines.txt` — note: the old `AI_RESETTLE_*_HABITABILITY_THRESHOLD` defines are now **gone**
- **First step:** `bash tools/new-mod.sh migration_overhaul "Migration Overhaul"`, then read `docs/vanilla/population.md` (migration section) before scripting. This is also the toolchain's first real shakeout — validate `new-mod.sh` output and run `bash tools/validate.sh` early.
- **Open sub-question (carry over):** migration restrictions are tightly coupled to the species-relations/phenotype-trust goal — decide whether those ship together or as a follow-up.

**Also queued:** nomad-ban mod (small, mostly disabling 4 origins; resolve player-only-vs-AI scope first — see [multiplayer-balance.md](multiplayer-balance.md)).

---

## Status Legend

- **[ ]** — Not started
- **[~]** — In progress
- **[x]** — Done
- **[!]** — Affected by Stellaris 4.4 — re-evaluate before starting (see [`docs/vanilla/patch-4.4-changes.md`](vanilla/patch-4.4-changes.md))

---

## Infrastructure & Tooling

- [x] Repository scaffolding (CLAUDE.md, docs/, tools/, mods/)
- [x] Deploy script (`tools/deploy.sh`)
- [x] PR template
- [x] Local wiki modding references (`docs/wiki/`)
- [x] Design vision document (`docs/design-vision.md`)
- [x] Roadmap (`docs/ROADMAP.md`)
- [x] Cross-references between all docs
- [x] Validation script — bracket matching, missing localisation keys (`tools/validate.sh`)
- [x] Mod scaffold script — generate boilerplate for new mods (`tools/new-mod.sh`)
- [x] Document vanilla game files location in CLAUDE.md
- [x] Document branching convention in CLAUDE.md
- [x] Vanilla 4.4 architecture reference docs (`docs/vanilla/`)

## Mods — Economy & Resources

*(Changes from `docs/design-vision.md` — Economy section. **Full design:
[economy-overhaul-design.md](economy-overhaul-design.md)** — three-track model: bulk
space>planet flip, research planet-primary, strategic-resource concentration + demand-matched
scaling. Read it before building any economy slice.)*

> **NOTE:** slices **1 (bulk structural)**, **2 (scaling parity)**, and **3 (multiplier taming)**
> are **BUILT** on `mod/economy-overhaul`. Slice 1 = planet size cap + unpaired jobs cut (primary
> planet-down lever; flat per-pop nerf neutralized to avoid double-nerf). Slice 2 = repeatable-tech
> parity. Slice 3 = disable Astro-Mining Drones + cut Privatized Exploration; cut Arc Furnace /
> Dyson Swarm per-tier output + build caps; halve `PLANET_ASCENSION_MODIFIER_SCALE`. Only **slice 4
> (strategic resources)** remains. All economy work is **logic-untested in-game.**

- [~] Space resources as primary source (outproduce planets) — **BUILT** in `economy_overhaul`, logic-untested. (a) Structural planet-down (below) makes space *relatively* dominant; (b) `econ_space_primacy` country modifier on all empires via `on_game_start_country`: `station_gatherers` / `station_researchers` `_produces_mult` +50%. See mod README checklist.
- [~] Space resource scaling (yield increases with game progression) — **BUILT** (slice 2), logic-untested. `zzz_econ_repeatable_techs.txt`: nerf the 3 vanilla tile repeatables +5%→+3%/level (override) + add station-gatherers/research-station repeatables at the same +3%/level (`@econ_repeatable_per_level`). One rate → planet & space scaling climb together, preserving slice-1's ratio. Finite-tech amplification (lever #6) deferred (slice-1 +50% baseline assumed sufficient).
- [ ] Strategic resource rebalance (less frequent, more concentrated) — *slice 4*
- [~] Planetary resource efficiency nerf (less output per pop/district) — **DONE structurally** (size cap + jobs cut below). Flat per-pop nerf retained only as an unused fine-tune lever (`@econ_planet_*_nerf`, default 0). Research deliberately untouched (primary-resource focus).
- [~] Planet size cap (max 16–18) and size distribution shift (more 12–14) — **BUILT + fixed 2026-06-23**: `@habitable_planet_max_size` 25 → **18** via a **whole-file replacement** of `00_scripted_variables.txt` (the original `zzz_` redefinition silently failed — scripted vars can't be redefined; see compatibility.md). Re-test in-game pending.
- [~] Reduce jobs per district — **BUILT**: override `@base_rural_district_jobs` 200 → **160** (housing stays 200 → deliberate overpopulation pressure). Gentle first pass; **#1 calibration target** (too aggressive → unemployment death spiral).
- [ ] Increase housing/amenities deficit penalties — *partially emergent from the unpaired jobs/housing cut; revisit after playtest*
- [ ] Hyper-specialized mega-planet penalties

## Mods — Empire & Fleet

- [ ] Reduce empire size per colony (~10)
- [ ] Adjust Naval Cap per anchorage
- [ ] Reduce Federation buffs / Federation Navy cap

## Mods — War & Conflict

- [ ] More casus belli types with distinct conditions and effects
- [!] Claim limits proportional to defender empire size — 4.4 added the `num_claims_on_system` trigger (helps); Nomad war goals are a partial-outcome template
- [!] War exhaustion / status quo rework (partial occupation → partial results) — 4.4 added mid-war join/leave + escalating WE/attrition when all colonies occupied; rebase on the new baseline
- [ ] New war goals: force ethics shift, impose trade deals, demilitarize, liberate species, vassalize sectors

## Mods — Diplomacy

- [ ] Federation rework (internal politics, voting, power dynamics, expulsion)
- [ ] Ethics-based diplomacy modifiers (opinion penalties, trust caps, federation hard blocks)
- [ ] More diplomatic actions with strategic weight

## Mods — Borders & Geopolitics

- [ ] Re-explore feasibility of sensor, trade route, and enclave blocking through closed borders (initial assessment may be incomplete — check hyper-relay route detection, intel system, trade route manipulation, enclave action gating)
- [ ] Border restrictions (commerce, contacts, sensors, migration, enclave access)
- [ ] Chokepoint and hyperlane strategic value
- [ ] L-Gate/Wormhole logistics question (design TBD)

## Mods — Slavery & Labor

- [!] New slavery type(s) allowing specialist jobs (override `can_fill_specialist_job_trigger`) — gate still exists, but 4.4 removed the unemployment-job tier (pops fall to stratum fallback); rebase any demotion/unemployment hooks (see patch-4.4-changes.md §2)
- [ ] Slave output modifiers tuned for wide play (volume over per-pop efficiency)
- [ ] Stability/happiness trade-offs (manageable, not crippling)
- [ ] Authoritarian/xenophobe ethics synergies with slavery economy

## Mods — Population & Migration

- [ ] Timed resettlement (not instant) — ✅ APPROVED (group, 2026-06-18) despite 4.4 conflict. Note: 4.4 removed habitability resettle defines & AI resettles regardless of habitability, so this mod must counter the base AI (see patch-4.4-changes.md §4)
- [ ] Pop movement restrictions (habitability, species clustering) — ✅ APPROVED; same base-AI conflict to overcome
- [ ] Species-type diplomacy modifiers (phenotype-based trust/distrust)
- [ ] Xenophile/xenophobe ethics amplify/reduce species-type effects

## Mods — Meta & Balance

- [ ] Disable nomadic empires for MP — ✅ DECIDED (group, 2026-06-18): nomads banned as OP + concept-breaking. Remove the 4 nomadic origins from selection; resolve player-only vs. AI-too sub-question before building (see multiplayer-balance.md). We still mine their mechanics (patch-4.4-changes.md §6).
- [!] Evaluate/disable other exploitable origins (Knights of The Toxic Gods, etc.) — 4.4 also added Defender of the Galaxy Ambition + reworked Commander traits to audit (see patch-4.4-changes.md §6)
- [~] Kill "build" meta synergies (approach TBD) — **partial:** economy_overhaul slice 3 neuters two space-economy auto-picks (Astro-Mining Drones civic **disabled**; Privatized Exploration **cut** to +10%) + tames Arc Furnace / Dyson Swarm / planetary ascension. More synergies TBD.

## Open Design Questions

*(Pending group discussion — see `docs/design-vision.md` Open Questions section)*

- [ ] L-Gate/Wormhole logistics: can an empire maintain a system connected to core only through L-Gate/Wormhole?
- [ ] Disable certain hyper-build-oriented origins (Knights of The Toxic Gods)?

---

*This roadmap is updated as the design vision evolves. Items may be added, removed, or reprioritized.*
