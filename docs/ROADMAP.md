# Roadmap

Track what needs to be done, what's in progress, and what's done.

---

## ▶ Current Focus / Session Handoff

**Last session (2026-06-18):** Scaffolded **`mods/migration_overhaul`** (toolchain shaken out end-to-end — `new-mod.sh` + `validate.sh` both work, validation passes). Built **Angle A** of the species-relations system: graded-by-family phenotype distrust opinion modifiers, ethics-laddered, additive over vanilla, auto-applied (pure data, MP-safe). Resolved the carried-over sub-question: phenotype-trust **splits** into Angle A (inter-empire opinion, *shipped*) + Angle B (intra-empire cohesion → ethnic secession, *deferred*). Full design + tunable values: [`species-relations-design.md`](species-relations-design.md). Not yet committed; not yet in-game tested.

**Next session — two open threads, pick up either:**

**(1) Finish the migration mod core — timed resettlement + movement restrictions.** This is the bigger Population & Migration piece, still unbuilt.
- **Goal:** timed resettlement (not instant) + pop-movement restrictions by habitability & species clustering. See [design-vision.md](design-vision.md) → Population & Migration.
- **⚠️ Headwind:** vanilla 4.4 *removed* the habitability resettle defines and the AI now resettles regardless of habitability — this mod must actively counter the base AI (see [patch-4.4-changes.md](vanilla/patch-4.4-changes.md) §4). No native travel-time mechanic — timed resettlement needs event simulation (move pop + timed penalty).
- **Key vanilla 4.4.3 files (verified present):**
  - `common/species_rights/migration_controls/00_species_controls_migration.txt` — migration access controls
  - `common/pop_categories/00_social_classes.txt` (+ `01_gestalt_drones`, `02_other_categories`) — `allow_resettlement` per stratum
  - `common/inline_scripts/pop_categories/resettlement_costs.txt` / `resettlement_costs_low.txt` — resettlement cost (lever for "timed/costly")
  - `common/game_rules/00_rules.txt` — resettlement-related game rules
  - `common/federation_laws/11_free_migration.txt` — federation free-migration law
  - `common/defines/00_defines.txt` — old `AI_RESETTLE_*_HABITABILITY_THRESHOLD` defines are now **gone**
- **First step:** read `docs/vanilla/population.md` (migration section) before scripting.

**(2) Angle B — intra-empire cohesion → ethnic secession (separate follow-up mod).** Designed in [`species-relations-design.md`](species-relations-design.md). Reuses `migration_overhaul`'s `migr_phenotype_*` scripted triggers. Needs an `on_action` recompute pipeline (NEVER MTTH) + revolt tuning — **verify the 4.4 revolt/secession files first** (not re-verified yet). Decide mod-boundary/dependency at build time.

**Also pending:** in-game test + commit of Angle A; first-pass opinion values are tunable after playtest.

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

*(Changes from `docs/design-vision.md` — Economy section)*

- [ ] Space resources as primary source (outproduce planets)
- [ ] Space resource scaling (yield increases with game progression)
- [ ] Strategic resource rebalance (less frequent, more concentrated)
- [ ] Planetary resource efficiency nerf (less output per pop/district)
- [!] Planet size cap (max 16–18) and size distribution shift (more 12–14) — use `planet_max_districts_add`/`_mult` + new 4.4 `planet_artificial_max_districts_add` (habitats/ringworlds/arkships count separately)
- [ ] Reduce jobs per district
- [ ] Increase housing/amenities deficit penalties
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

- [ ] Timed resettlement (not instant) — ✅ APPROVED (group, 2026-06-18). Scope clarified: targets **forced/manual** resettlement (still instant + unrestricted) via `pop_categories` `resettlement_costs` + event-simulated travel time. NOT a fight against the base AI (see corrected [patch-4.4-changes.md](vanilla/patch-4.4-changes.md) §4)
- [~] Pop movement restrictions (habitability, species clustering) — ✅ APPROVED. **Habitability half left to vanilla** (`HABITABILITY_AUTO_MIGRATION = 0.20`; decided not to touch). **Species-clustering BUILT** in `migration_overhaul` (fraction-based minority happiness penalty via on_action recompute, no vanilla override; also builds Angle B's composition engine). ⚠️ Logic-untested in-game — see mod README runtime-verification checklist. Design: [species-relations-design.md](species-relations-design.md)
- [~] Species-type diplomacy modifiers (phenotype-based trust/distrust) — **Angle A in progress** in `mods/migration_overhaul`: graded-by-family opinion modifiers, ethics-laddered, additive over vanilla's mild `triggered_opinion_xenophobes/xenophiles`, auto-applied (pure data, MP-safe). Design + values: [species-relations-design.md](species-relations-design.md)
- [~] Xenophile/xenophobe ethics amplify/reduce species-type effects — folded into Angle A (the ethics ladder)
- [ ] **Angle B (deferred follow-up mod):** intra-empire cohesion — cohabiting free xenos → instability → ethnic secession (stability-driven, coexists with vanilla revolts; slaves/purged excluded → slavery-pillar synergy). Designed in [species-relations-design.md](species-relations-design.md); needs an `on_action` recompute pipeline + revolt tuning (verify 4.4 revolt files first)

## Mods — Meta & Balance

- [ ] Disable nomadic empires for MP — ✅ DECIDED (group, 2026-06-18): nomads banned as OP + concept-breaking. Remove the 4 nomadic origins from selection; resolve player-only vs. AI-too sub-question before building (see multiplayer-balance.md). We still mine their mechanics (patch-4.4-changes.md §6).
- [!] Evaluate/disable other exploitable origins (Knights of The Toxic Gods, etc.) — 4.4 also added Defender of the Galaxy Ambition + reworked Commander traits to audit (see patch-4.4-changes.md §6)
- [ ] Kill "build" meta synergies (approach TBD)

## Open Design Questions

*(Pending group discussion — see `docs/design-vision.md` Open Questions section)*

- [ ] L-Gate/Wormhole logistics: can an empire maintain a system connected to core only through L-Gate/Wormhole?
- [ ] Disable certain hyper-build-oriented origins (Knights of The Toxic Gods)?

---

*This roadmap is updated as the design vision evolves. Items may be added, removed, or reprioritized.*
