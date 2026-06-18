# Species Relations — Phenotype Trust & Cohesion (Design Note)

> Design record for the "species relations should matter" goal in
> [design-vision.md](design-vision.md) → Population & Migration. Captures decisions made
> 2026-06-18 so implementation can resume without re-litigating them.
>
> **Status:** Angle A (inter-empire opinion) — *in implementation* inside `mods/migration_overhaul`.
> Angle B (intra-empire cohesion → ethnic secession) — *designed, deferred* to a follow-up mod.

---

## The core idea

Different species **phenotypes** (mammalian, fungoid, lithoid, machine, …) should distrust each
other. This is **ethics-modified**: xenophobe empires distrust harder, xenophiles barely at all,
fanatic xenophiles not at all (and keep the usual xeno-friendly buffs). Two separate scopes were
identified — they are **complementary, not alternatives**:

| | Angle A | Angle B |
|---|---|---|
| **Scope** | Empire ↔ empire (diplomacy) | Pop ↔ pop, within one empire |
| **Pillar** | Diplomacy with teeth | Population & Migration + wide > tall |
| **Mechanic** | Opinion modifier in the diplo window | Cohabiting free xenos → unhappiness/instability → ethnic secession |
| **Status** | **Ship now** (cheap, MP-safe, pure data) | **Follow-up** (needs recompute pipeline + revolt tuning) |

Decision (2026-06-18): **build Angle A now; document Angle B and build it as a separate, deliberate
system later.** The shared phenotype-family data model (below) is built in Angle A so Angle B reuses it.

---

## Shared data model — phenotype families

Vanilla only exposes `is_same_species_class` (binary: same class or not). The group wants distrust
**graded by family** — a fellow mammalian is less alien than a fungoid, which is less alien than a
machine. So we group the real 4.4 species classes (verified from
`D:\Stellaris\common\species_classes\`) into families:

| Family | Classes |
|--------|---------|
| **Animalic** (carbon, bilateral) | `MAM REP AVI ART MOL HUM NECROID AQUATIC TOX` |
| **Flora** | `PLANT FUN` |
| **Mineral** | `LITHOID` |
| **Synthetic** | `MACHINE ROBOT AI` |

Distance tiers (drives the magnitude of distrust in both angles):

- **Tier 0 — same class** (e.g. MAM↔MAM): no phenotype distrust (vanilla already covers kinship).
- **Tier 1 — same family, different class** (MAM↔REP): mild.
- **Tier 2 — different organic family** (MAM↔FUN, MAM↔LITHOID, FUN↔LITHOID): strong.
- **Tier 3 — organic ↔ synthetic** (MAM↔MACHINE): strongest (most alien).

**Unclassified classes** (pre-sapients `PRE_*`, enclaves/event classes `SHROUDWALKER SALVAGER
SWARM INF EXD PSIONIC PARAGON …`, and the ambiguous `CYBERNETIC`) get **no penalty** — a safe
default. `CYBERNETIC` is intentionally left ungrouped for now (it is organic-derived but mechanically
synthetic-adjacent); revisit if it matters in practice.

Implemented as scripted_triggers (`mods/migration_overhaul/common/scripted_triggers/`) so both the
opinion modifiers (Angle A) and the future cohesion recompute (Angle B) reference one source of truth.

---

## Angle A — inter-empire phenotype opinion (shipping now)

### Mechanism (verified against vanilla 4.4.3)

Vanilla **already does a mild version** of this in
`common/opinion_modifiers/00_opinion_modifiers.txt`: `triggered_opinion_xenophobes` (~line 2998)
and `triggered_opinion_xenophiles` (~line 3098) key on `is_same_species_class = FROM` and scale by
xenophile/xenophobe ethics, but only ±5…±20 and **binary**.

Crucial mechanic: an opinion modifier with a **top-level `trigger = { }` block is auto-applied by
the engine** for every empire pair — no `add_opinion_modifier`, no on_action, no polling. This makes
Angle A **pure data and fully MP-safe** (no desync surface, no performance cost). Inside, the
`opinion = { base = 0 modifier = { add = X trigger... } }` blocks re-evaluate dynamically, so the
value tracks live ethics changes. ROOT = the empire holding the opinion; FROM = the empire judged.

### Approach: additive, not override

We **add new** triggered opinion modifiers (`migr_opinion_phenotype_*`) that stack on top of
vanilla's, rather than overriding the 4500-line `00_opinion_modifiers.txt`. Rationale: pure addition
= no compatibility burden, no re-merging on patches. Cost: our values stack with vanilla's mild
±5…±20. That is acceptable for a first pass and is itself part of the "make this MATTER" intent; if
double-counting proves too strong we can later neutralize the vanilla pair via override (would then
be tracked in [compatibility.md](compatibility.md)).

### First-pass values (TUNABLE — logged in [multiplayer-balance.md](multiplayer-balance.md))

Magnitude by phenotype tier, then laddered by the **observer's** ethics. These are starting points
for playtest, not final:

| Observer ethics | Tier 1 (same family) | Tier 2 (diff organic family) | Tier 3 (organic↔synthetic) |
|---|---|---|---|
| Fanatic xenophobe | -20 | -40 | -50 |
| Xenophobe | -10 | -25 | -35 |
| Neutral (no xeno ethic) | -5 | -10 | -15 |
| Xenophile | -2 | -5 | -8 |
| Fanatic xenophile | 0 (+ keeps vanilla xeno buffs) | 0 | 0 |

Notes:
- Penalty is on the **founder species class** of each empire (multi-species empires judged by founder —
  a deliberate simplification matching vanilla's `owner_species`/`is_same_species_class` behavior).
- Gestalts (machine/hive) sit in the synthetic/own handling; ensure no nonsensical self-penalty.
- These are *opinion* only in Angle A — they feed diplomacy/trust naturally; no separate trust-cap
  modifier in v1 (could add `country_trust_cap_add` later if opinion alone is too soft).

---

## Angle B — intra-empire cohesion → ethnic secession (deferred follow-up)

A separate mod (working title **"species cohesion / xenophobia at home"**). Designed, not built.

> **Foundation now exists.** The migration mod's **species-clustering** system
> (`migration_overhaul/common/scripted_effects/migr_clustering_effects.txt`) already builds the
> per-planet species-composition recompute — the exact signal Angle B needs. Angle B layers an
> instability → ethnic-secession consequence on top of that same recompute instead of re-deriving
> composition. The clustering recompute applies a happiness penalty; Angle B would additionally feed
> planetary stability and trigger the guarded secession event.

### Mechanism

Free, full-citizen xeno pops sharing a planet with the dominant phenotype reduce **happiness /
planetary stability**, scaled by phenotype tier (same data model as Angle A) and by the empire's
ethics. **Slaves and purged pops are excluded** — see synergy below. Low stability then feeds the
**existing vanilla revolt/secession backend** (one stability-driven breakaway pipeline, not three).

### Decision: stability-driven, coexists with vanilla revolts (does NOT substitute)

Confirmed (2026-06-18) the approach is **"tune existing revolts," routed through stability** — i.e.
Angle B is a *third pressure source* on the same stability value alongside vanilla separatist and
slave-uprising triggers. It does **not replace** them. To keep the outcome legible (an *ethnic*
breakaway rather than an anonymous one) we add **one guarded ethnic-secession event** that fires when
ethnic tension is the dominant cause; decide at build time whether it suppresses the generic
separatist event (priority guard) or simply rides alongside.

### Synergy with the slavery pillar (intentional)

Because the penalty **excludes slaves and purged pops**, the "clean" way to run a wide multi-species
empire is to **enslave or purge** its aliens — directly feeding the slavery-as-viable-strategy pillar.
The two instability mechanics target different populations automatically:
- Planet of **enslaved** xenos → slave-revolt risk (slave happiness/stability).
- Planet of **free, mixed** xenos → ethnic-tension risk (Angle B).

So every wide multi-species empire pays *some* cohesion tax; which one depends on how it treats its
aliens. Tune the two so neither is strictly dominant.

### Implementation cautions (carry forward)

- **MP determinism:** the per-planet "count free non-same-family xeno pops" recompute must be
  `on_action`-driven writing a variable — **never** `mean_time_to_happen`, no `random`. Cadence must
  be coarse (not monthly-per-pop) for 7-player performance. 4.0 pop *groups* help here.
- **Verify the revolt pipeline** against live 4.4 files before coding — 4.4 reworked pops/jobs; the
  exact secession on_actions/events and 4.4-changed thresholds were **not** re-verified this session
  (see [vanilla/population.md](vanilla/population.md), [vanilla/patch-4.4-changes.md](vanilla/patch-4.4-changes.md) §2).
- **Mod boundary:** the phenotype-family scripted_triggers live in `migration_overhaul`. If Angle B
  ships as a separate mod it either depends on `migration_overhaul` (cross-mod dependency — CLAUDE.md
  prefers to minimize) or the triggers move to a tiny shared base mod. Decide at build time.

---

## Open items

- [ ] Tune Angle A first-pass values after playtest; decide whether to neutralize vanilla's mild pair.
- [ ] `CYBERNETIC` family placement (currently ungrouped → no penalty).
- [ ] Angle B: whole separate mod — recompute pipeline, revolt tuning, guarded ethnic-secession event.
- [ ] Angle B: priority-guard vs. ride-alongside for the ethnic-secession event.

## Related documents

- [design-vision.md](design-vision.md) → Population & Migration (the goals this serves)
- [ROADMAP.md](ROADMAP.md) → Population & Migration (status tracking)
- [multiplayer-balance.md](multiplayer-balance.md) → Angle A values + rationale
- [vanilla/diplomacy.md](vanilla/diplomacy.md) → opinion-modifier architecture
- [vanilla/population.md](vanilla/population.md) → pop/slavery/migration architecture
