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

### Species relations — phenotype trust (Angle A, opinion modifier)
- **Decision:** Add empire-to-empire **phenotype distrust** opinion modifiers, **graded by phenotype
  family** (not vanilla's binary same-class) and **laddered by ethics** (fanatic xenophobe harshest →
  fanatic xenophile zero). First-pass values: Tier 1 / Tier 2 / Tier 3 = roughly -20/-40/-50 (fanatic
  xenophobe) down to 0/0/0 (fanatic xenophile) — full table in
  [species-relations-design.md](species-relations-design.md).
- **Reason:** Vanilla's existing `triggered_opinion_xenophobes/xenophiles` are too mild (±5…±20) and
  binary; the vision wants species relations to genuinely shape diplomacy ("Diplomacy with teeth").
- **Implementation note:** Additive on top of vanilla (no override of `00_opinion_modifiers.txt`);
  auto-applied via the engine's `trigger`-block mechanism, so it is **pure data / MP-safe** (no
  on_action, no desync surface). Values are starting points — **re-tune after playtest**, and watch
  for double-counting with the vanilla pair.
- **Scope note:** This is the inter-empire half. The intra-empire half (Angle B: cohabiting free xenos
  → instability → ethnic secession, with slaves/purged excluded) is **designed but deferred** to a
  follow-up mod — see [species-relations-design.md](species-relations-design.md).

### Species relations — species-clustering (minority discomfort)
- **Decision:** Pops who are a fraction-minority of their **own species** on a planet take a happiness
  penalty: **< 25%** of planet → minor (**-0.10** pop_happiness), **< 10%** → severe (**-0.20**). Soft
  discouragement only (engine can't hard-block migration). Gestalts exempt (v1); conquered planets get
  a 10-year grace.
- **Reason:** Serves "pops shouldn't freely move where few of their kind exist" (design-vision →
  Population). Vanilla handles the *habitability* half already (see [patch-4.4-changes.md](vanilla/patch-4.4-changes.md) §4),
  so clustering is the genuinely new restriction. Magnitudes referenced against vanilla Noxious
  (~-0.05/pop) — start mild, tune after playtest.
- **Implementation note:** No vanilla override (timed static modifiers applied via on_action recompute;
  on_actions merge). MP-safe: deterministic, event-driven + debounced + yearly sweep. Untested in-game —
  see the mod README runtime-verification checklist.

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
