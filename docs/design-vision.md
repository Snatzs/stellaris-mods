# Design Vision — Stellaris Multiplayer Overhaul

**Status:** Draft — points are up for debate, subject to change, and many more to be added.

## Core Philosophy

Turn Stellaris into a **genuine geopolitical simulator in space** — a real 4X Grand Strategy. The vanilla game currently feels like a deck-building game where diplomacy is shallow, geopolitics/geoeconomics are absent, and the meta incentivizes hyper-specific "builds" that exploit synergies rather than strategic play.

## Design Pillars

1. **Geography matters** — systems, borders, and territory should be worth fighting over
2. **Scarcity drives strategy** — resources should be scarce enough to force trade-offs and conflict
3. **Wide > tall** — more planets/pops/systems should always generally be good; hyper-optimized tall builds should not be viable (except extreme edge cases). Having many enemies should generally be worse than having fewer — geopolitics should punish overextension and diplomatic isolation
4. **Kill the "build" meta** — hyper-specific civic/origin/trait combos exploiting synergies should not dominate. Some quirky builds can exist, but "normal" empires following consistent strategic rules should be competitive
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
- **Space should be the primary resource source, not planets** — a mineral-rich asteroid belt should outproduce a mining planet; energy from a star should dwarf planetary energy. Habitable planets are scarce and useful, but they don't defy the laws of physics
- Space resource yields should scale as the game progresses (e.g., asteroid: 3 minerals early → 10 mid-game)
- Space strategic resources should be less common but more concentrated in fewer systems (e.g., a mid-game system might have 8 gases)
- Controlling systems (space) should be strategically comparable to or more valuable than controlling planets

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

## Slavery & Labor

### Goals

- Slavery should be a **viable economic strategy** for wide empires — maximizing raw total output even if less efficient per-pop
- The current meta favors tall gameplay with free specialists, making slavery suboptimal — this needs to flip
- Slavery should work for **all strata including specialists** — an authoritarian slaver empire running enslaved researchers/metallurgists should be a valid (if ethically horrifying) playstyle
- Wide slaver empires should compete with free specialist economies by sheer volume of output
- Trade-offs should exist (stability, happiness, revolt risk) but not make slavery categorically worse

### Specific Mechanisms

- Rework slave types to allow specialist slavery with appropriate trade-offs
- Tune slave output modifiers to reward wide play (many slaves = competitive total output)
- Adjust stability/happiness penalties to be manageable, not crippling
- Ensure authoritarian/xenophobe ethics synergize with slavery as a genuine economic model

---

## War & Conflict

### Goals

- Wars should NOT be all-or-nothing — vanilla forces total system claims and full occupation to impose any outcome, which is unrealistic and unfun
- War goals should be varied and meaningful beyond just "conquer territory" — ideology imposition, trade agreements, demilitarization, liberation, humiliation, etc.
- The number of systems/planets claimable in a single war should be **proportional to defender size** — you can't swallow a large empire in one war (balance + MP experience)
- Partial occupation should be sufficient to impose proportional goals — attackers shouldn't need to occupy every last system and planet
- Wars should be a strategic tool, not a game-ending event — losing a war costs you territory or concessions, not your entire empire

### Specific Mechanisms

- More casus belli types with distinct conditions and effects
- Claim limits tied to defender empire size (e.g., can only claim X% of their systems per war)
- War exhaustion and status quo reworked so partial occupation yields partial results
- New war goals: force ethics shift, impose trade deals, demilitarize border systems, liberate species, vassalize specific sectors

## Diplomacy

### Goals

- Diplomacy should feel like real interstate relations, not a menu of buttons
- Federations should be **living, complex political entities** — not passive buff providers (+10% research, +10% trade value, auto-defense pact). Internal politics, power struggles, voting, unequal members, expulsion threats
- Ethics and ideology should be a **hard constraint** on deep cooperation — two empires with opposing ethics might trade or have non-aggression pacts, but forming a tight federation or ideological bloc should be very difficult or impossible
- Ethics differences should create meaningful opinion modifiers and trust caps

### Specific Mechanisms

- Federation rework: more federation types, internal politics, meaningful votes, power dynamics
- Ethics-based diplomacy modifiers: larger opinion penalties for opposing ethics, hard blocks on federation formation for fanatic opposites
- More diplomatic actions with real strategic weight

## Borders & Geopolitics

### Goals

- Borders should be **real barriers** — not just lines on the map
- Closing borders should actually restrict: commerce, sensor range, migration, and even contact with enclaves behind those borders
- Controlling space (systems, chokepoints, hyperlanes) should matter as much as or more than controlling planets

### Specific Mechanisms

- Border restrictions: block trade, sensors, migration, enclave access through closed borders
- Chokepoint and hyperlane strategic value (design TBD)

## Population & Migration

### Goals

- Pop movement should be realistic — resettlement takes time, not instant teleportation
- Pops shouldn't freely migrate to planets where few of their species exist or where habitability works against them
- **Species relations should matter** — non-xenophile empires should see inter-species distrust, especially across species types (e.g., lithoid vs mammalian, fungoid vs humanoid). Collaboration is possible, but tight integration should be harder
- Different species types should affect opinion, trust, and willingness to integrate

### Specific Mechanisms

- Timed resettlement (not instant)
- Migration restrictions based on habitability and existing species presence
- Species-type diplomacy modifiers (phenotype-based trust/distrust)
- Xenophile/xenophobe ethics should amplify or reduce species-type effects

---

## Related Documents

- [ROADMAP.md](ROADMAP.md) — tracks implementation status of all items from this vision
- [multiplayer-balance.md](multiplayer-balance.md) — logs specific balance decisions and their rationale
- [compatibility.md](compatibility.md) — tracks vanilla file overrides across mods
- [modding-reference.md](modding-reference.md) — index of local wiki references for implementation
- [Vanilla 4.3 architecture references](vanilla/README.md) — file paths, modifiers, levers, and limitations per system
