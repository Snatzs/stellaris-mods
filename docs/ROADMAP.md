# Roadmap

Track what needs to be done, what's in progress, and what's done.

---

## ▶ Current Focus / Session Handoff

**Last session (2026-06-18):** On branch `mod/migration-overhaul`. **Committed:** Angle A (graded phenotype distrust opinion modifiers — `926c83b`) + **species-clustering** (fraction-based minority happiness penalty via on_action recompute, no vanilla override — `b6e596c`). Toolchain works end-to-end. **Decisions:** habitability-migration **left to vanilla** (`HABITABILITY_AUTO_MIGRATION = 0.20` suffices — not touched); species-clustering replaces the "habitability restriction" scope. **Borders/truce investigation:** post-war truce passage **IS moddable** via `end_truce`/`set_truce` (not border access) — logged as a future Borders mod (two levers, see Borders section); NOT built. Documented the **4.0+ pop-group modding API** in [`population.md`](vanilla/population.md) (the primitives used by clustering + needed for timed resettlement).

**Next: build TIMED FORCED RESETTLEMENT** — the last migration-mod piece. Everything else in Population & Migration is now done or descoped.
- **Goal:** forced/manual resettlement should take time + cost, not be instant. (Auto-migration habitability is already handled by vanilla; species-clustering is built. This is the remaining gap.)
- **⚠️ No native travel-time mechanic** — must event-simulate: intercept/penalize the move (move pop + apply a timed penalty / delay). See [patch-4.4-changes.md](vanilla/patch-4.4-changes.md) §4.
- **Verified hooks/levers (this session):** `on_pop_group_resettled` on_action (**this = pop group, from = previous colony**, `local_pop_amount` var) is the interception point; `common/inline_scripts/pop_categories/resettlement_costs.txt` / `resettlement_costs_low.txt` set cost; `allow_resettlement` per pop category (`common/pop_categories/`); `RESETTLE_DESTROY_COLONY_COST` define. Timed static modifiers + `set_timed_pop_group_flag` (see population.md pop-group API) are the tools for the "settling-in penalty" timer.
- **First step:** read [`population.md`](vanilla/population.md) (Migration & Resettlement + the new pop-group API section) before scripting.

**Pending (task #5):** in-game test of Angle A + species-clustering (see mod README runtime-verification checklist), then merge `mod/migration-overhaul` → master.

**Deferred (designed, not built):** Angle B (intra-empire cohesion → ethnic secession) — reuses the species-clustering composition recompute; needs revolt-file verification. Truce-borders mod. See [`species-relations-design.md`](species-relations-design.md) + Borders roadmap.

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
- [ ] **Truce ≠ free passage.** The 10-year truce grants mutual border passage (confirmed real). **It IS moddable** — via the **truce status** (`end_truce` / `set_truce` effects), not border access directly (no script setter for access); proven by the Steam mod *End Truce & Close Borders* (id 2493028212). See [vanilla/diplomacy.md](vanilla/diplomacy.md). **Two complementary levers — shipping both = the "double-down":**
  - **(A) End-Truce action/decision:** `end_truce` + scripted opinion/diplo-weight penalties lets a player force borders shut post-war. ⚠️ Truce is a coupled bundle (passage + 10-yr no-re-war), so `end_truce` also drops the war-cooldown → accept re-war exposure; that coupling is why it must carry diplomatic penalties.
  - **(B) Passive trespass punishment:** *punish* lingering rather than block it — opinion penalty / "trespassing during truce" incident and/or fleet attrition for fleets in your space, WITHOUT touching the truce (keeps the war-cooldown intact). Mimics the Nomads `nomad_trespassing` pattern.
  - **Event-driven design (build it THIS way — performance verified negligible, lighter than the species-clustering recompute):** hook `on_entering_system_fleet` (scope=fleet, from=system — the *recommended* per-fleet hook, NOT the per-ship `on_entering_system`). Tight short-circuiting trigger: system `exists = owner`, owner ≠ fleet owner, `owner = { has_truce = <fleet owner> }` → set a **timed fleet flag** (grace window). Clear it on `on_leaving_system_fleet`. A country pulse then iterates **only flagged fleets** (tiny set, usually 0) to apply the opinion incident + attrition once past grace. **Do NOT** poll every fleet on a timer, and **do NOT** use the per-ship `on_entering_system` — both are the expensive way. MP-deterministic (no random/MTTH).
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
