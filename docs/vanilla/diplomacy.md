# Vanilla 4.4 — Diplomacy Architecture

## Opinion Modifiers

### File Location
`common/opinion_modifiers/00_opinion_modifiers.txt` (core). 4.4 splits DLC opinion modifiers into many sibling files in the same dir: `00_opinion_modifiers_federation.txt`, `..._nemesis.txt`, `..._megacorp.txt`, `..._machine_age.txt`, `..._nomads_dlc.txt`, etc., plus `01_personality_opinions.txt`. `opinion_claims_on_us` still lives in the core file.

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

### Vote Weight

Weighted voting DOES exist as a federation law (`common/federation_laws/07_vote_weight.txt`):
- `vote_weight_equal` — one-member-one-vote (`set_equal_voting_power = yes`)
- `vote_weight_diplomatic` — weighted by diplomatic weight (`set_equal_voting_power = no`; requires Federations DLC + centralization 3)

The engine effect `set_equal_voting_power = yes/no` is the only lever — weighting is by diplomatic weight, NOT freely scriptable by fleet power or economy directly. The `law_category_voting_weight` category gates which laws are available.

### Limitations

- **No fully custom vote weighting** — only the two engine modes above (`set_equal_voting_power` on/off). You can't define an arbitrary per-member weight formula.
- **No internal factions/coalitions** — no subgroups, opposition blocs, or voting blocs within a federation
- **No tiered membership** — all members have the same status (president vs. member is the only distinction). Can simulate tiers with flags and conditional law effects, but UI won't reflect it.
- **Succession types** are limited to engine values: strongest, diplomatic_weight, rotation, challenge, random (see `common/federation_laws/03_succession_type.txt`, set via `set_federation_succession_type`)

---

## Diplomatic Actions

### File Location
`common/diplomatic_actions/00_actions.txt` (single file; all vanilla + DLC actions live here in 4.4)

### Structure

Each diplomatic action has:
- `potential` / `possible` — when the action appears and can be used
- Effects on accept/decline
- AI acceptance weights

### Modding Scope

You **CANNOT add entirely new diplomatic-action TYPES from script alone** — each action ID is bound to engine/DLC code (the Nomads `action_form_waystation_pact` shipped with DLC code, not pure script). But you CAN modify `potential`/`possible` conditions on existing actions to require ethics compatibility, species alignment, etc.

### Key Actions for Our Purposes (verified 4.4)

- `action_make_claims_diplomacy_view` (line ~536) — claim-related
- `action_form_defensive_pact` / `action_form_non_aggression_pact` / `action_form_commercial_pact` / `action_form_research_agreement` / `action_form_migration_pact` — each has a `possible` block gateable with ethic/species triggers
- `action_invite_to_federation`, `action_offer_federation_association_status` — federation gating
- `action_open_borders` / `action_close_borders` (lines ~3788 / ~3877) — the actual border-toggle diplomatic actions
- `action_form_waystation_pact` / `action_break_waystation_pact` (Nomads DLC, lines ~1390 / ~1870) — see Nomads section under Borders

---

## Borders

### How Borders Work

Border closure is controlled per-country-type in `common/country_types/` and per-pair via the `action_open_borders` / `action_close_borders` diplomatic actions (`common/diplomatic_actions/00_actions.txt`).
- `enforces_borders` — country_type binary toggle (default `yes`; if `no`, others are "always free to enter" per the in-file comment). Many special country types (line ~519 onward in `00_country_types.txt`) set `enforces_borders = no`.
- Border status is **binary**: open or closed. No granularity (can't allow civilian but block military).
- See the Nomads section below for the one place vanilla 4.4 expresses border access as scriptable policy flags + pacts.

### What Closed Borders Actually Block

- **Ship movement** — military and science ships cannot enter
- **Migration treaties** — cannot be active with closed borders

### What Closed Borders Do NOT Block (Hardcoded)

- **Sensor range** — no modifier to block visibility based on diplomatic status
- **Trade route pathing** — routes calculate through territory regardless; you can increase piracy but can't block the route
- **Enclave contact** — enclave interactions are hardcoded diplomatic actions, not affected by border status
- **Intel/information** — no border-based intel blocking
- **Border *access status* is not script-exposed** (deep-checked 4.4.3, ~90% confident it's unmoddable):
  - No scriptable **effect** to open/close/set borders exists anywhere in `common/`/`events/` (no `open_borders`/`set_border_access`/`grant_border_access`). Without a border-setting effect, even the war-end hooks below can't change border state.
  - `needs_border_access` (103 uses) is an **engine trigger** (not in `common/scripted_triggers/`) — it *checks* access (factoring war/treaties), can't be overridden to *set* it.
  - Nomads `arkship_open_borders` is just a `set_country_flag` for Nomad event logic — **not** a real border-opening effect.
  - Border state is set ONLY by: `action_open_borders`/`action_close_borders` diplo actions (their `possible`/`potential` blocks ARE moddable — gates *when* players toggle), the `enforces_borders` country-type binary, and hardcoded war status.
  - **Hooks that DO exist:** `on_war_ended`, `on_status_quo`, `on_truce_end` on_actions — but useless for borders without a border-setting effect to call.
  - Consequence: **post-war / truce border behavior is not directly moddable.** Could not even confirm a truce auto-opens borders; the "borders feel open after a war" effect is likely hardcoded stranded-fleet safe-passage (also not moddable). Only related define is `TRUCE_YEARS = 10`.
  - **⚠️ CORRECTION (2026-06-18): the post-war passage IS moddable — via the truce, not border access.** Earlier conclusion ("~unmoddable") was wrong: those searches looked for a *border-access* lever, but the passage is granted by the **truce STATUS**, and truce is scriptable. **`set_truce = { target = X type = war }`** and **`end_truce = X`** are real effects (vanilla: `common/war_goals/00_war_goals.txt`, `common/council_agendas/`). Ending the truce removes the passage override → borders revert to normal/closed. Confirmed by the Steam mod *End Truce & Close Borders* (id 2493028212), which does exactly this.
  - **Caveat — truce is a coupled bundle:** it grants passage AND blocks re-declaring war (`TRUCE_YEARS = 10`). `end_truce` removes **both** — you can't keep the war-cooldown while closing borders. Hence that mod treats early border-closing as a hostile act with diplomatic penalties (-150 opinion, etc.).
  - **Two complementary levers (see ROADMAP "Truce ≠ free passage"):** (A) an **End-Truce action/decision** — `end_truce` + scripted opinion/diplo-weight penalties, lets a player force borders shut (accepting re-war exposure); (B) **passive trespass punishment** — event-driven `on_entering_system_fleet` → opinion/attrition for *lingering* fleets, which does NOT touch the truce/war-cooldown (mimics the Nomads `nomad_trespassing@<scope>` pattern).
  - Still true: there is no *direct* border-access setter, and `needs_border_access`/`can_access_community_territory` are engine-side — but truce manipulation makes the post-war passage addressable regardless.

### Workarounds (Known)

- Increase piracy modifiers near hostile borders (via `starbase_trade_protection_add` and related)
- Add opinion penalties for closed borders
- Use event-based trade value reduction when bordering hostile empires

### Workarounds (To Be Explored)

The initial feasibility assessment concluded sensor range, trade routes, and enclave access are hardcoded. **This needs re-exploration** — there may be indirect or "artificial" implementation paths not yet considered:

- **Hyper-relay route detection**: The game calculates direct hyper-relay connectivity between empires. If the engine exposes this as a trigger/condition, it could be leveraged to determine whether trade, sensors, or contact should be blocked (e.g., "no relay route through friendly space = no trade").
- **Sensor range suppression**: Could a negative `ship_sensor_range_add` or system-level modifier effectively blind empires to systems behind closed borders? Explore `intel` system modifiers (4.0+ intel/espionage rework may have added new levers).
- **Trade route manipulation**: Explore whether `trade_routes_available` or similar triggers exist. Could we destroy/block trade routes via scripted effects? Or apply a 100% piracy modifier to systems behind closed borders to effectively zero out trade?
- **Enclave access blocking**: Could enclave diplomatic actions be gated with a scripted trigger that checks border status between the empire and the enclave's system? Explore `diplomatic_actions` possible blocks for enclave-specific actions.
- **Custom implementation**: If no vanilla levers exist, explore whether event-driven systems could simulate these restrictions (e.g., periodic events that detect trade flowing through closed borders and apply compensating penalties).

**Status (updated 4.4):** The 4.4 Nomads DLC ships real, working examples of access-gating through borders and intel — see the Nomads section directly below. This demonstrates **partial feasibility**: border *policy flags*, pact-based access grants, a trespassing country_flag, and intel-gated construction all exist as patterns. These are precedents to copy, though several rely on Nomads-DLC engine hooks (`is_nomadic`, `is_waystation_starbase`) that don't generalize to ordinary empires. Full sensor/trade-route blocking between arbitrary empires still appears to require event-driven simulation rather than a native border lever. A dedicated research session should now study the Nomads files as the template before concluding any restriction is impossible.

---

### Nomads DLC — Working Border/Access Mechanics (Nomads-DLC-gated)

The Nomads DLC implements access-through-borders patterns directly relevant to the border-restriction goals above. **All gated behind `has_nomads_dlc = yes` / `is_nomadic`** — copy the patterns, but they won't apply to non-nomad empires without reimplementation. Dense pointers:

- **Open/closed nomad border policy** — `common/policies/05_policies_nomads.txt`, policy `nomad_border_policy` with options setting `policy_flags = { nomad_border_policy_open }` / `{ nomad_border_policy_closed }`. A scriptable per-empire flag controlling whether nomads may enter — a genuine binary access toggle expressed as a policy flag (checkable via `has_policy_flag`). Closed-AI weighting backs off when `num_waystation_pacts > 0`.
- **Waystation pact diplomatic actions** — `common/diplomatic_actions/00_actions.txt`: `action_form_waystation_pact` (~line 1390) and `action_break_waystation_pact` (~line 1870). Pact establishes access/cooperation; gated by `has_waystation_pact = from`, `is_nomadic`, and adjacency checks (`is_waystation_starbase`, `has_neighboring_waystation`). Diplo phrases in `common/diplo_phrases/00_diplo_phrases_nomads.txt`. Proves a pact can be the mechanism that grants/revokes a border-access state.
- **Trespassing country_flag** — `nomad_trespassing@<scope>` (scoped/targeted country flag). Set in `events/nomads_events_1.txt` (`flag = nomad_trespassing@root.owner`) and consumed as a casus belli trigger in `common/casus_belli/07_nomads_casus_belli.txt` (`has_country_flag = nomad_trespassing@from`). Demonstrates representing "X violated Y's borders" as a per-pair flag that downstream systems (CB, opinion, events) react to — exactly the indirect lever the workarounds section was looking for.
- **Intel-gated construction** — the nomad waystation megastructure `common/megastructures/30_nomad_waystation.txt` gates placement on intel: `possible` block with `fail_text = "requires_intel_waystation"` requiring `has_intel = { intel = intel_economy_systems_high }` on the target system (intel category `common/intel_categories/05_intel_diplo_pacts.txt`). Confirms construction CAN be gated on diplomatic/economic intel level — a viable pattern for "no intel = no presence behind borders."

These collectively show access-gating via borders is *partially* achievable with vanilla 4.4 patterns (policy flags, pact actions, scoped flags, intel checks), even if no single native "block sensors/trade at the border" switch exists.

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
