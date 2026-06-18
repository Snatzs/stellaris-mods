# Migration Overhaul

## Overview

Reworks population movement and species relations toward the "species relations should matter" and
"realistic migration" goals. Currently implements **Angle A** of the species-relations system
(inter-empire phenotype distrust). Timed resettlement, migration restrictions, and Angle B
(intra-empire cohesion → ethnic secession) are planned — see
[`docs/species-relations-design.md`](../../docs/species-relations-design.md) and
[`docs/ROADMAP.md`](../../docs/ROADMAP.md).

## Design Goals

Addresses [design-vision.md](../../docs/design-vision.md) pillars **#5 Diplomacy with teeth** and
**Population & Migration**: different species phenotypes should distrust each other, modulated by
ethics, so geopolitics reflects who you are — not just what you do.

## Changes

### Angle A — phenotype distrust (inter-empire opinion)
- Adds three auto-applied opinion modifiers graded by **phenotype family distance**:
  - `migr_opinion_phenotype_near` — same family, different class (e.g. mammalian vs reptilian)
  - `migr_opinion_phenotype_far` — different organic family (e.g. mammalian vs fungoid / lithoid)
  - `migr_opinion_phenotype_alien` — organic vs synthetic (most alien)
- Each is **laddered by the observer's ethics**: fanatic xenophobe harshest → fanatic xenophile zero.
- Phenotype families defined in `common/scripted_triggers/migr_phenotype_triggers.txt`
  (animalic / flora / mineral / synthetic), reusable by future Angle B.
- **Additive** over vanilla's mild `triggered_opinion_xenophobes/xenophiles`; values are first-pass
  and TUNABLE (see [multiplayer-balance.md](../../docs/multiplayer-balance.md)).

## Compatibility

**No vanilla files overridden** — pure additions to `common/scripted_triggers/` and
`common/opinion_modifiers/`. No `docs/compatibility.md` entry required. Opinion values stack with the
vanilla xeno opinion modifiers by design (revisit if double-counting is too strong).

## Manual Testing

1. `bash tools/deploy.sh`, enable the mod, start a game with empires of differing phenotypes
   (e.g. a Mammalian and a Fungoid and a Machine empire).
2. Open the diplomacy view between two empires and check the opinion breakdown shows
   "Unfamiliar Phenotype" / "Alien Phenotype" / "Wholly Alien Biology" at the expected tier.
3. Verify magnitude scales with ethics: a xenophobe should show a much larger penalty than a
   xenophile toward the same target; a fanatic xenophile should show none.
4. Confirm two same-class empires (e.g. both Mammalian) show **no** phenotype modifier (Tier 0).
