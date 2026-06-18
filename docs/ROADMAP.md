# Roadmap

Track what needs to be done, what's in progress, and what's done.

---

## ▶ Current Focus / Session Handoff

**Last session (2026-06-18, cont.):** On branch `mod/migration-overhaul`. **Built TIMED FORCED RESETTLEMENT** — the last migration-mod piece (not yet committed). Two event-side levers on `on_pop_group_resettled`, **zero vanilla overrides, no polling**:
- **Resource surcharge** — extra energy/unity per resettlement, `add_resource { … mult = <variable> }` scaled by pops moved × empire/species factor (gestalt ×0.4, corvee/Adaptability ×0.5, `trait_nomadic` ×0.5, `trait_sedentary` ×1.5) × an **empire-size multiplier** `1 + (empire_size−100)×0.01` (vanilla tech/tradition *shape*, 5× steeper on our own variable, so it stays relevant late-game: size 600 → ×6). This is the answer to "cost scales by civics/traits without overriding vanilla cost files" — added on top of vanilla's flat cost instead of editing `pop_categories`.
- **Settling-in time penalty** — timed `migr_recent_relocation` debuff (happiness + bonus workforce, ~5 yr) on moved pops, since there's no native travel-time mechanic. Waived for gestalts + nomadic species.
- **Scoped to intra-empire** resettlement (`from.owner == owner`) so refugee/migration inflows aren't taxed. Files: `migr_resettlement_{variables,modifiers,effects,on_actions}` + loc.
- ⚠️ **File-inspection-verified only** — see the new "timed resettlement" runtime-verification checklist in the mod README. Key unknown: does `add_resource` `mult` accept a plain country variable (vs. only `trigger:`/literal)? Confirm in-game.

**Earlier this session:** Angle A (phenotype distrust — `926c83b`) + species-clustering (`b6e596c`) committed. Habitability-migration left to vanilla (`HABITABILITY_AUTO_MIGRATION = 0.20`). Borders/truce passage is moddable via `end_truce`/`set_truce` (future Borders mod, not built). Pop-group modding API documented in [`population.md`](vanilla/population.md).

**Next:**
1. **Commit** the timed-resettlement files + doc updates.
2. **In-game test pass** (task #5): Angle A + species-clustering + timed resettlement — all three are logic-untested. Run all three runtime-verification checklists in the mod README, watch `error.log`. Then merge `mod/migration-overhaul` → master.

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
- [ ] **Empire-size counter via dedicated admin worlds** — let wide empires offset sprawl penalties, but only through **flat** empire-size reductions on **single-purpose** admin jobs/buildings (need whole worlds = real opportunity cost). Explicitly NOT the percentage-stacking approach of the "Empire Size Rationalisation" workshop mod (id 3545107040, −1/−5/−15% on multi-purpose buildings → ~−300%). See [design-vision.md](design-vision.md) Empire & Fleet for the rationale.

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

- [~] Timed resettlement (not instant) — **BUILT** in `migration_overhaul` (logic-untested). Two event-side levers on `on_pop_group_resettled`, **no vanilla override, no polling**: (1) a resource **surcharge** scaled by pops moved × civics/traits/ethics via `add_resource { mult = <variable> }` — added on top of vanilla cost instead of editing `pop_categories`; (2) a timed **settling-in penalty** (`migr_recent_relocation`) simulating travel time. Intra-empire only (refugees excluded). See mod README + runtime-verification checklist.
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
