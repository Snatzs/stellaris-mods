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
