# Multiplayer Balance Notes

Design decisions and balance considerations for our 7-player campaign.

See [design-vision.md](design-vision.md) for the overarching design goals that inform these decisions.

## General Principles

- No mod should give a player who picks specific content a decisive advantage over others.
- If a mod adds new options (civics, traits, etc.), they should be roughly in line with vanilla power levels.
- Buffs to one playstyle should come with trade-offs.
- All decisions should align with the [design pillars](design-vision.md#design-pillars).

## Balance Decisions

Document balance decisions here as mods are developed. Include the rationale so future changes don't undo past reasoning.

<!-- Example:
### Mod Name — Feature
- **Decision:** X gives +10% instead of +20%
- **Reason:** +20% was too strong compared to vanilla equivalents
-->

### Economy — full design (three-track model)
- **See [economy-overhaul-design.md](economy-overhaul-design.md)** for the complete, agreed design
  (2026-06-20). Summary of balance-relevant decisions: (1) **bulk minerals/energy** flip to
  space-primary by bringing *planets down* (size cap ~18, unpaired jobs-per-district cut), not by
  inflating space; bounded scaling via a new station repeatable matched to nerfed tile repeatables
  (Cetus-safe). (2) **Research** stays planet-primary (no direct nerf; trimmed indirectly by the
  structural levers); research stations get parity only. (3) **Strategic resources** concentrated
  into few contested clusters, planetary/refining supply gutted, but supply **scaled with
  repeatables to match the growing late-game demand curve** (ship complexity + upgradable
  buildings) — the knife's-edge calibration is the #1 playtest target. (4) **Multiplier audit:**
  disable Astro-Mining Drones + Privatized Exploration civics; nerf+limit Arc Furnace / Dyson
  Swarm; halve `PLANET_ASCENSION_MODIFIER_SCALE`. All symmetric across empires → MP-fair.

### Economy — "Space > Planets" rebalance (economy_overhaul slice 1 — SUPERSEDED)
> Superseded by the structural approach in the design doc. Kept for history.
- **Decision:** Shift the resource economy so space outproduces planets, via one permanent country
  modifier (`econ_space_primacy`) granted to **every empire** at game start. First-pass values:
  mining-station output **+50%** (`station_gatherers_produces_mult`), research-station output **+50%**
  (`station_researchers_produces_mult`), and planetary **−50%** each on mineral / energy / food jobs
  (`planet_miners_minerals` / `planet_technician_energy` / `planet_farmers_food` `_produces_mult`).
  Planetary **research is NOT nerfed** in this slice.
- **Reason:** Implements the Economy pillar "space should be the primary resource source, not planets"
  + "planetary primary collection should be less efficient" (design-vision). Makes systems worth
  fighting over (pillars 1–2) and nudges wide over tall (pillar 3) by cutting per-pop planetary output
  while leaving station output to scale with territory.
- **MP-fairness:** **Symmetric** — identical modifier on all empires (player + AI), no randomness, no
  per-player content choice involved, so it confers no individual advantage. Research left alone partly
  to avoid swinging the whole match's tech *pace* (a global research nerf would slow everyone, changing
  game length rather than the space/planet balance we're targeting).
- **Implementation note:** Zero vanilla overrides; applied via additive `on_game_start_country`. Uses
  the exact per-resource modifiers vanilla economy techs apply at country scope, so they cascade to all
  owned planets. All 5 numbers in one scripted_variables file.
- **Tuning:** −50% is a conservative first pass; the design target for mining is ~−66% ("3 → 1 minerals
  per 100 pops"). **Re-tune after playtest** — watch that early-game planets don't feel worthless and
  that the station buff doesn't trivialise early expansion. Untested in-game — see mod README checklist.

### Nomadic empires (Nomads DLC) — banned from the campaign
- **Decision:** Nomadic empires are **not allowed** in our 7-player MP match. Nomadic origins should be removed from empire selection (and AI use should be prevented — see open sub-question below).
- **Reason:** Judged both **overpowered** and **game-concept-breaking** — the arkship/waystation/wayline model is a separate, asymmetric ruleset (no territory, space-only economy, partial-outcome war goals) that doesn't balance cleanly against settled empires.
- **Scope note:** This is a *ban*, not a balance pass. We still intend to **mine** Nomads mechanics as reference implementations for our own mods (space>planets economy, border access-gating, partial war goals) — see [vanilla/patch-4.4-changes.md](vanilla/patch-4.4-changes.md).
- **Open sub-question:** does "ban" cover only player selection, or also AI-controlled empires (filler AIs could still roll nomadic)? Decide before building the ban mod.

## Known Vanilla Balance Issues

Track any vanilla balance concerns the group wants to address:

(No entries yet.)

## Related Documents

- [design-vision.md](design-vision.md) — design goals and planned changes
- [ROADMAP.md](ROADMAP.md) — implementation status
- [compatibility.md](compatibility.md) — vanilla file override tracking
