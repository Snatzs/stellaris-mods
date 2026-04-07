# Vanilla 4.3 — Diplomacy Architecture

## Opinion Modifiers

### File Location
`common/opinion_modifiers/00_opinion_modifiers.txt`

### Structure

Opinion modifiers can be:
- **Static** — applied/removed by effects (`add_opinion_modifier`, `remove_opinion_modifier`)
- **Triggered** — auto-applied when conditions are met (checked periodically by engine)

Each modifier supports:
- `opinion = { base = X }` — base opinion value
- `opinion = { base = X modifier = { add = Y trigger = { ... } } }` — conditional scaling
- `decay` — monthly decay rate
- `accumulative` — whether multiple instances stack
- `unique` — only one instance allowed
- `min` / `max` — bounds on opinion value

### Triggered Opinion Modifiers

These are the key tool for ethics/species diplomacy. Example vanilla pattern:

```
opinion_claims_on_us = {
    opinion = { base = -X }
    # Auto-applied when another empire has claims on you
}
```

You can create triggered modifiers that check `has_ethic`, `is_species_class`, `is_xenophobe`, etc. on both ROOT and FROM.

### Key Triggers Available for Opinion Modifiers

- `has_ethic = ethic_X` / `has_ethic = ethic_fanatic_X`
- `is_xenophobe`, `is_xenophile`, `is_militarist`, `is_pacifist`, etc.
- `is_species_class = MAMMALIAN` (also REPTILIAN, AVIAN, ARTHROPOID, MOLLUSCOID, FUNGOID, LITHOID, PLANTOID, etc.)
- `owner_species` scope for checking founder species

### Species-Type Diplomacy: Approach

Create triggered opinion modifiers like:
```
lithoid_distrusts_mammalian = {
    opinion = { base = -30 }
    trigger = {
        owner_species = { is_species_class = LITHOID }
        FROM = { owner_species = { is_species_class = MAM } }
    }
}
```

This checks founder species only. For multi-species empires, you'd check dominant/founder species.

---

## Ethics System

### File Location
`common/ethics/00_ethics.txt`

### Structure

Each ethic has:
- `country_modifier` — permanent modifiers when empire has this ethic (e.g., `country_claim_influence_cost_mult`)
- `pop_modifier` — modifiers on pops with this ethic
- `country_attraction` — base attraction for this ethic
- `categories` — ethics categories (`ethics_category_authoritarian`, etc.)

### Vanilla Ethics Opinion

Vanilla already applies opinion modifiers for ethics alignment, but they're relatively mild. We can amplify these significantly and add hard blocks.

### Fanatic vs Regular

Each ethic has regular and fanatic variants. The fanatic version doubles the `country_modifier` effects. This is a natural scaling point — fanatic opposites should have much harsher penalties.

---

## Federations

### File Locations

| Component | Path |
|-----------|------|
| Federation types | `common/federation_types/` |
| Federation perks | `common/federation_perks/00_perks.txt` |
| Federation laws | `common/federation_laws/` |
| Federation law categories | `common/federation_law_categories/` |

### Federation Type Structure

Each federation type has:
- `potential` / `allow` — conditions for formation/joining (can include ethic checks, species checks, etc.)
- Level progression (1-5) with associated perks
- `leader_modifier` / `members_modifier` / `federation_modifier`
- `on_activate` / `on_deactivate` effects

### Hard Blocks on Federation Formation

The `allow` block on federation types accepts arbitrary conditions. You CAN add:
```
allow = {
    NOT = {
        any_federation_member = {
            has_ethic = ethic_fanatic_militarist
            ROOT = { has_ethic = ethic_fanatic_pacifist }
        }
    }
}
```

This prevents fanatic opposites from coexisting in a federation.

### Federation Laws

Fully moddable. Each law has `potential`/`allow` conditions, `modifier` blocks, `on_enact` effects, and `ai_weight`. Categories are also customizable.

### Cohesion

- `add_cohesion` effect exists
- Ethics differences already penalize cohesion: -0.15 per different ethic, -0.5 per opposed pair
- These values can be amplified

### Limitations

- **Voting is one-member-one-vote** — no weighted voting by diplomatic weight, fleet power, or economy. Options are: unanimous, majority, leader decides.
- **No internal factions/coalitions** — no subgroups, opposition blocs, or voting blocs within a federation
- **No tiered membership** — all members have the same status (president vs. member is the only distinction). Can simulate tiers with flags and conditional law effects, but UI won't reflect it.
- **Succession types** are limited to: strongest, diplomatic_weight, rotation, challenge, random

---

## Diplomatic Actions

### File Location
`common/diplomatic_actions/00_actions.txt`

### Structure

Each diplomatic action has:
- `potential` / `possible` — when the action appears and can be used
- Effects on accept/decline
- AI acceptance weights

### Modding Scope

You **CANNOT add entirely new diplomatic actions** — the available actions are engine-defined. But you CAN modify `possible` conditions on existing actions (defensive pact, federation invite, non-aggression pact, etc.) to require ethics compatibility, species alignment, etc.

### Key Actions for Our Purposes

- `action_make_claims_diplomacy_view` — claim-related
- Defensive pact, federation, non-aggression pact — all have `possible` blocks that can be gated with ethic/species triggers
- Migration treaty, commercial pact — can be similarly restricted

---

## Borders

### How Borders Work

Border closure is controlled per-country-type in `common/country_types/`.
- `enforces_borders` — binary toggle: empire respects borders or doesn't
- Border status is **binary**: open or closed. No granularity (can't allow civilian but block military).

### What Closed Borders Actually Block

- **Ship movement** — military and science ships cannot enter
- **Migration treaties** — cannot be active with closed borders

### What Closed Borders Do NOT Block (Hardcoded)

- **Sensor range** — no modifier to block visibility based on diplomatic status
- **Trade route pathing** — routes calculate through territory regardless; you can increase piracy but can't block the route
- **Enclave contact** — enclave interactions are hardcoded diplomatic actions, not affected by border status
- **Intel/information** — no border-based intel blocking

### Workarounds

- Increase piracy modifiers near hostile borders (via `starbase_trade_protection_add` and related)
- Add opinion penalties for closed borders
- Use event-based trade value reduction when bordering hostile empires
- **Cannot truly restrict** sensors, trade routes, or enclave access

---

## Trust System

### Key Modifiers

- `country_trust_cap_add` — modify max trust between empires
- `country_trust_growth` — modify how fast trust grows

Both can be applied conditionally via triggered modifiers on civics, ethics, or static modifiers added by events.

---

## Related Systems

- [Population](population.md) — species-type triggers (`is_species_class`) for phenotype-based diplomacy; ethics affect species rights
- [Warfare](warfare.md) — opinion modifiers influence war acceptance; ethics gate casus belli

## Key Files Summary

| System | Path |
|--------|------|
| Opinion modifiers | `common/opinion_modifiers/00_opinion_modifiers.txt` |
| Ethics | `common/ethics/00_ethics.txt` |
| Federation types | `common/federation_types/` |
| Federation perks | `common/federation_perks/00_perks.txt` |
| Federation laws | `common/federation_laws/` |
| Diplomatic actions | `common/diplomatic_actions/00_actions.txt` |
| Country types (borders) | `common/country_types/00_country_types.txt` |
