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

### Economy — deposit-yield glut fix → per-resource multipliers (v2.4 → v2.5 / 2026-06-26)
- **Decision:** Replace the uniform deposit `produces` buff with **per-resource** multipliers in
  `01_orbital_deposits.txt`: **minerals ×1.40, energy ×1.60, research (society/physics/eng) ×1.15**;
  **alloys / food / consumer_goods / trade left at vanilla ×1.0.** Chosen lever for the glut:
  **supply-down** (reduce the buff) over **sink-up** (raise resource costs/upkeep). (History: v2 shipped
  a uniform ×1.75; v2.4 cut it to a uniform ×1.40; v2.5 made it per-resource.)
- **Reason:** First in-game test (2026-06-25) showed ×1.75 overshot **absolute** supply — every empire,
  large or small, was drowning in minerals (triple-digit income by yr ~20), and some in energy. That
  directly undercuts the **scarcity pillar** (pillar 2): if minerals are free, there are no trade-offs
  and nothing to fight over. The "space is *primary*" goal is **relative**, so trimming absolute yield
  preserves the space>planet ratio while restoring scarcity.
- **Why per-resource (not a single number):** the resource types have different roles, so one multiplier
  is the wrong tool. **Minerals** were the main glut culprit → kept lowest of the bulk pair (×1.40).
  **Energy** tolerates a hotter buff (×1.60) — it's the universal upkeep currency with far more late-game
  sinks, so it drains rather than piles up. **Research** only ×1.15 — Track 2 keeps research
  *planet-primary*; space research is a supplement, not a source to lean on. **Alloys** left at vanilla:
  alloys are a refined/STRATEGIC output the vision wants kept **scarce**, so the few natural orbital alloy
  deposits (only `d_alloys_1/2` spawn; the rest are `pc_junk`-only) stay un-inflated. **Food / consumer
  goods** left at vanilla because those orbital deposits barely-or-never spawn (`d_food_4..10` and the CG
  deposit are `always = no`; `d_food_3` is ~0 weight) — buffing dead content is pure noise.
- **Why supply-down, not sink-up:** smallest, most reversible edit; sink-up has a much broader blast
  radius (touches building/ship cost-balance everywhere) and is harder to calibrate without measurement.
  Sink-up is kept on the table as a *follow-up* if supply-down alone doesn't bring scarcity back.
- **MP-fairness:** Symmetric — same deposits for every empire, no randomness, no per-player choice.
- **Implementation note:** regenerated auditably from vanilla by a tools-side script (not hand-edited);
  verification caught that trade + the dead food/CG deposits must NOT be scaled.
- **Tuning:** all four multipliers are calibration guesses, **not yet re-tested**. Re-measure
  small-vs-large minerals & energy income at yr 20/40: cut minerals toward ~×1.3 and/or add sinks if
  still glutted; ease back up if space stops feeling like the primary source. Feeds the Track-4
  strategic-supply calibration. See [economy-overhaul-design.md](economy-overhaul-design.md) Open Item #4.

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
