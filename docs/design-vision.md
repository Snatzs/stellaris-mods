# Design Vision — Stellaris Multiplayer Overhaul

**Status:** Draft — points are up for debate, subject to change, and many more to be added.

## Core Philosophy

Turn Stellaris into a **genuine 4X Grand Strategy**. The vanilla game currently feels like a deck-building game where diplomacy is shallow, geopolitics/geoeconomics are absent, and the meta incentivizes hyper-specific "builds" that exploit synergies rather than strategic play.

## Design Pillars

1. **Geography matters** — systems, borders, and territory should be worth fighting over
2. **Scarcity drives strategy** — resources should be scarce enough to force trade-offs and conflict
3. **Wide > tall** — more planets/pops/systems should always generally be good; hyper-optimized tall builds should not be viable (except extreme edge cases)
4. **Kill the "build" meta** — hyper-specific civic/origin/trait combos exploiting synergies should not dominate
5. **Diplomacy with teeth** — borders, federations, and diplomatic actions should have real strategic weight

---

## Open Questions

- If an Empire shares a border with another only through L-Gate/Wormhole or similar, can it logistically maintain that system connected to its core?
- Disable certain hyper-build-oriented origins like Knights of The Toxic Gods?

---

## Economy

### Goals

- Make strategic resources more STRATEGIC (less frequent, more concentrated, harder to produce)
- Make alloy production more important — scarcity should be real, not trivially solved
- More planets/pops/systems = always generally good (no viable tall builds except hyper-optimized ones)
- Systems should be substantially more important — wars over systems should be a thing
- Hyper-specialized gigantic (>16000 capacity) planets should be RADICALLY harder to maintain and suboptimal vs. semi-specialized planets
- Kill the "build" concept (hyper-specific civics/origins/traits exploiting synergies) — possibly impossible
- Borders should MATTER — restrict commerce, contacts (including enclaves), sensors, migration through borders
- Federations should be more distinct and politically harder to manage
- Resettlement should take time (not instant pop movement)
- Pops shouldn't freely move to planets where few of their kind exist or where habitability works against them

### Specific Mechanisms

#### Space Resources
- Space resource yields should scale as the game progresses (e.g., asteroid: 3 minerals early → 10 mid-game)
- Space strategic resources should be less common but more concentrated in fewer systems (e.g., a mid-game system might have 8 gases)

#### Planetary Economy
- Planetary primary and strategic resource collection should be LESS efficient (e.g., 3 minerals per 100 pops in mining district → 1 mineral per 100 pops)
- Reduce frequency of strategic resource modifiers on planets
- Limit max planet size (cap at 16–18)
- Change planet size distribution — more 12–14 size planets
- Reduce number of jobs per district (e.g., 300 researcher jobs per tech city district → 200)
- Increase debuffs for housing and amenities deficits

#### Empire & Fleet
- Reduce empire size per colony (back to ~10)
- Increase Naval Cap per anchorage (?)
- Decrease Federation buffs (and max Naval Cap from Federation Navy?)

---

## Diplomacy

*(To be expanded)*

## Borders & Geopolitics

*(To be expanded)*

## Population & Migration

*(To be expanded)*

---

## Related Documents

- [ROADMAP.md](ROADMAP.md) — tracks implementation status of all items from this vision
- [multiplayer-balance.md](multiplayer-balance.md) — logs specific balance decisions and their rationale
- [compatibility.md](compatibility.md) — tracks vanilla file overrides across mods
- [modding-reference.md](modding-reference.md) — index of local wiki references for implementation
