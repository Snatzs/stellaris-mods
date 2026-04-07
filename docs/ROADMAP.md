# Roadmap

Track what needs to be done, what's in progress, and what's done.

## Status Legend

- **[ ]** — Not started
- **[~]** — In progress
- **[x]** — Done

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
- [x] Vanilla 4.3 architecture reference docs (`docs/vanilla/`)

## Mods — Economy & Resources

*(Changes from `docs/design-vision.md` — Economy section)*

- [ ] Space resources as primary source (outproduce planets)
- [ ] Space resource scaling (yield increases with game progression)
- [ ] Strategic resource rebalance (less frequent, more concentrated)
- [ ] Planetary resource efficiency nerf (less output per pop/district)
- [ ] Planet size cap (max 16–18) and size distribution shift (more 12–14)
- [ ] Reduce jobs per district
- [ ] Increase housing/amenities deficit penalties
- [ ] Hyper-specialized mega-planet penalties

## Mods — Empire & Fleet

- [ ] Reduce empire size per colony (~10)
- [ ] Adjust Naval Cap per anchorage
- [ ] Reduce Federation buffs / Federation Navy cap

## Mods — War & Conflict

- [ ] More casus belli types with distinct conditions and effects
- [ ] Claim limits proportional to defender empire size
- [ ] War exhaustion / status quo rework (partial occupation → partial results)
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

- [ ] New slavery type(s) allowing specialist jobs (override `can_fill_specialist_job_trigger`)
- [ ] Slave output modifiers tuned for wide play (volume over per-pop efficiency)
- [ ] Stability/happiness trade-offs (manageable, not crippling)
- [ ] Authoritarian/xenophobe ethics synergies with slavery economy

## Mods — Population & Migration

- [ ] Timed resettlement (not instant)
- [ ] Pop movement restrictions (habitability, species clustering)
- [ ] Species-type diplomacy modifiers (phenotype-based trust/distrust)
- [ ] Xenophile/xenophobe ethics amplify/reduce species-type effects

## Mods — Meta & Balance

- [ ] Evaluate/disable exploitable origins (Knights of The Toxic Gods, etc.)
- [ ] Kill "build" meta synergies (approach TBD)

## Open Design Questions

*(Pending group discussion — see `docs/design-vision.md` Open Questions section)*

- [ ] L-Gate/Wormhole logistics: can an empire maintain a system connected to core only through L-Gate/Wormhole?
- [ ] Disable certain hyper-build-oriented origins (Knights of The Toxic Gods)?

---

*This roadmap is updated as the design vision evolves. Items may be added, removed, or reprioritized.*
