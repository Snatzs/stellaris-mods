# Roadmap

Track what needs to be done, what's in progress, and what's done.

---

## ▶ Current Focus / Session Handoff

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
- [~] Planet size cap (max 16–18) and size distribution shift (more 12–14) — **BUILT**: override `@habitable_planet_max_size` 25 → **18** (`zzz_economy_overhaul_overrides.txt`). Truncating drops the average too. First real vanilla override (logged in compatibility.md); load-order win is file-inspection-reasoned, **runtime-verify**.
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
