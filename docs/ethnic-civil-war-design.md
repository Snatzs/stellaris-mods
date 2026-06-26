# Ethnic Civil War — Design Document

> **Status:** Conceptual design, fully discussed and locked at the model level. **No implementation yet.**
> **Working mod name:** "Ethnic Tensions" (a new, self-contained mod — not yet scaffolded).
> **Target:** Stellaris 4.4.4 (Pegasus + Nomads).
> **Authored:** 2026-06-26, from a full design conversation. Captures every locked decision *with its rationale* so it survives a context reset and the other two devs (Snatzs, AttiiK, manzano5) can react.

This document is the single source of truth for the ethnic-civil-war mechanic. Numeric values throughout are **tuning placeholders** — they exist to convey intent and **must be validated by in-game batch testing**, not trusted as final.

---

## 1. Concept

A **multi-species empire whose different peoples are free but mistreated can tear itself apart along ethnic lines.** Not a slave revolt, not a machine uprising, not the empire vs. a breakaway state — a genuine **three-body conflict** on a single planet:

- the **native bloc** (the empire's founding "genetic stock"), radicalised into militant xenophobes, vs.
- the **xeno bloc** (everyone else, organised into self-defence militias), vs.
- **you**, the central administrator, who must decide whom (if anyone) to back.

This is the concrete, computable form of the long-standing design-vision thread *"species relations should matter"* and *"xenophile/xenophobe ethics amplify/reduce species-type effects"* (`design-vision.md` → Population & Migration; `ROADMAP.md` → same section). The vague intention becomes a mechanic.

### Vision alignment

| Pillar | How this serves it |
|--------|--------------------|
| **Wide > tall** | A large diverse empire stays *good*, but must be **actively governed**. Diversity is never punished outright — only *mismanaged* diversity bites. |
| **Scarcity drives strategy** | Cohesion becomes a resource you spend (upkeep, civic slots, influence, attention) — and that spend scales with how wide/diverse you've grown. |
| **Kill the build meta** | No free lunch for blob-stacking xeno pops; sprawling multi-species play carries a real, ongoing management cost. |
| **Diplomacy/management with teeth** | Every "crack down" choice has a coherent shadow cost; handling one war reverberates empire-wide (and, later, galaxy-wide). |
| **Ethics matter** | A genuinely xenophile or fully-egalitarian empire is **structurally immune** — a real mechanical reward for that playstyle. |

---

## 2. Core model: the three-body war

### Bloc definition — by **phenotype**, not ethics *(LOCKED)*

- **Native bloc** = pops sharing the empire's **primary/ruling species' phenotype** (`is_archetype` / `is_species_class`).
- **Xeno bloc** = **everyone else, aggregated into one coalition** of the excluded.

**Why aggregate the xenos:** keeps it a clean three-body war (player + 2 blocs) instead of an unmanageable N-species melee. The user's original "X, Y, Z species" intuition is honoured — more distinct xeno species raise the *xeno bloc's mass* and a minor *fragmentation* tension term — but they **fight as one coalition** against the persecuting majority.

**Ethics is the fuel, not the membership line.** Xenophobe attraction *radicalises* the natives into "militants"; oppression/low happiness *organises* the xenos into "militias." Drawing bloc lines by blood (phenotype) is what makes it an *ethnic* war; ethics only sets **how hot it burns** and **who takes up arms**.

**Consequence — moderates are bystanders.** Xenophile natives and content, well-integrated xenos are *not* belligerents. So whichever side you back, you alienate the moderates of the *other* phenotype. That asymmetry is the source of the agonising-choice texture.

### The free-xenos gate *(LOCKED — long-standing group decision)*

**An ethnic civil war can ignite if and only if the xeno bloc is FREE (not enslaved.)**

- **Mechanically airtight:** slaves cannot join factions (`population.md` → Slavery, "Slaves cannot join factions"), and the xeno-militia bloc depends on free pops having the agency to organise. Enslaved xenos rising up is the **slave-revolt** track — a separate, existing mechanic.
- **This cleanly divides the two failure modes of a diverse empire:**
  - **Free** multi-species empire → **ethnic civil war** risk.
  - **Slave-based** multi-species empire → **slave revolt** risk.
- It also gives every "crack down" choice a coherent shadow cost (see §6, Resolution): enslaving the losers doesn't *end* unrest, it **converts** it from ethnic-war risk into slave-revolt risk.

---

## 3. The vessel: a **Situation** *(LOCKED)*

The mechanic is implemented as a **Situation** (`common/situations/`), not bare events. The vanilla Situations README literally names *"a planetary revolt"* as the canonical example — it is almost purpose-built for this.

| Design piece | Situation primitive |
|---|---|
| The war is *about one planet* | **target = the colony carrier** (planet targeting is the *normal* case; `target_modifier` applies to it) |
| Tide of war between the two blocs | **bidirectional progress bar** (README: "start in the middle, choose between two contrasting goals") |
| Who's winning at fire-time | `initial_progress` tilted by the composition score (stronger bloc starts the bar leaning their way) |
| Escalation phases | **stages**, each with its own modifiers/background |
| **Side with xenophobes / xenos / fight both** | **approaches** — each with own upkeep `resources`, modifiers, `on_select`, `ai_weight`; can `set_situation_locked` to *force* a choice |
| Friction/incident events | **`on_monthly` random_events** (on_action-based → MP-safe, no `mean_time_to_happen`) |
| Two outcomes (each bloc wins) | **`on_progress_complete` (→100) / `on_fail` (→0)** → resolution event |
| Player ignores it → secession | `abort_trigger` / on_fail lose-territory branch |

**Bar convention:** `100` = native/xenophobe bloc triumphs, `0` = xeno bloc triumphs, start ≈ `50` weighted by composition. "Back xenophobes" pushes right; "back xenos" pushes left; monthly drift also fed by relative army strength and pop counts. **The bar IS the war.**

**Free win:** Situations carry **AI weights on approaches**, so AI empires handle their own ethnic civil wars sensibly — important in a 7-player game with AI empires.

---

## 4. Lifecycle

```
Simmer (slow, recoverable, VISIBLE warning)
   → Ignition (the civil-war Situation spawns)
      → War (bidirectional bar; player picks an approach)
         → Resolution (winner's-spoils choice: kill / subjugate / expel)
            → Aftermath (local fate + empire-wide political ripple + possible contagion)
```

### Two-stage structure: Simmer → Ignition *(LOCKED)*

Ignition is **not** an instantaneous "tension > X → war." Instead:

1. **Simmer accumulator** — a per-planet `ethnic_tension` variable that ticks **up** while conditions are bad and **down** while good. Slow. Recoverable. **Visible** ("Simmering Tensions" planet modifier once high).
2. **Ignition** — when the accumulator maxes out, the Situation spawns.

This buys four things for free:
- tension must be **sustained** (not a transient spike);
- the player gets a **multi-year warning window** to act;
- the planet can **heal** if conditions are fixed;
- the high-simmer flag *is* the "top-tension stage" marker needed for **contagion eligibility** (§5, Tier 3).

---

## 5. Ignition system

### Layer 1 — Eligibility gate (cheap, binary, ALL must hold)

This is also the **MP-performance gate** — it keeps the expensive pop-group loop off the vast majority of planets:

- **Not gestalt** (hive/machine have no pop ethics, no factions — fully exempt). *(LOCKED)*
- **≥ 1 *free* xeno pop** (the free-xenos gate; short-circuits on first match). *(LOCKED)*
- **Both blocs present, minority bloc ≥ a floor** — in *both* absolute pops *and* share (excludes token 2-pop minorities and balanced-but-tiny outposts).
- **Stability below a "content" ceiling** (a genuinely happy planet never even simmers).

Only planets passing all four pay the cost of Layer 2. (The `min()`-based minority test is symmetric, so a planet where the *founder* species is itself a beleaguered minority is handled too.)

### Layer 2 — The tension score

Two blocs only (native = founder phenotype, xeno = everyone else). Let `N`, `X` = bloc pop counts, `T` = total.

```
tension =  Balance
         × ( NativeMilitancy + XenoGrievance )
         × ( 1 − Tolerance )
         × Disorder
         × FragmentationAmp
```

| Term | Meaning | Rough definition |
|---|---|---|
| **Balance** | powder-keg factor; peaks near parity, ≈ 0 for a token presence | `min(N,X)/T`, scaled to ≈ 1 at 50/50 |
| **NativeMilitancy** | radicalised majority | xenophobe share of the native bloc (fanatic ×2) |
| **XenoGrievance** | aggrieved-but-*free* minority | low xeno happiness + share on *limited* (not full) citizenship |
| **Tolerance** | the damper | xenophile share of the whole planet |
| **Disorder** | state capacity — *the player's active lever* | `crime + (1 − stability)` |
| **FragmentationAmp** | minor: many distinct xeno species-classes are harder to integrate | small multiplier, secondary |

The accumulator ticks up in proportion to how far `tension` exceeds a neutral band, and **drains** when below it.

### Sanity checks (what the formula *means*)

- **Happy, fully-equal, free multi-species empire → tension ≈ 0.** Diversity *alone* is safe. Protects "wide > tall"; rewards genuine egalitarianism.
- **The danger zone is "free but second-class":** xenos with rights and the agency to organise, but mistreated by a xenophobe-leaning majority on a low-order planet.
- **A xenophile empire essentially cannot have ethnic civil wars** (NativeMilitancy ≈ 0, Tolerance high) — a real mechanical reward for the playstyle.
- **Disorder is the lever you actively pull:** garrison, enforcers, amenities, stability buildings suppress an otherwise-tense planet; neglect lets it boil.

---

## 6. The civil war and its resolution

### Representation: two temporary event-countries

The engine has exactly one rebellion primitive — *one* faction breaks away into *one* hostile country (always binary). A true three-body war must be faked using the two tools the engine gives us: **countries and ground armies**. A planet has exactly one owner and armies belong to countries, so the belligerents are represented as **temporary event-countries** (as vanilla does for the Khan, marauders, crisis factions).

### Initial control — algorithmic, not RNG *(LOCKED)*

At fire-time, compute a militancy score per bloc:

```
native_score = native_pop_count × native_militancy   (xenophobe attraction, leadership lean)
xeno_score   = xeno_pop_count    × xeno_militancy     (oppression, low happiness, denied rights)
```

- The **higher-score bloc seizes the planet** → becomes the temporary holding country.
- The **lower-score bloc** spawns as the **assaulting militia** (ground armies).
- Sets the Situation's `initial_progress` tilt. **Deterministic** (MP-safe) and narratively sensible: the bigger/angrier group grabs the capital first; the other has to fight in.

**Does the fighting decide it?** Only as the tiebreak when the player *abstains* — and Stellaris ground combat is deterministic given army strengths + synced RNG, so even that is essentially settled by the opening composition. **The player's choice is the real determinant.**

### Player approaches *(LOCKED)*

1. **Back the militant xenophobes (natives).** Native bloc wins; planet returns to you **ethnically homogenised** (losing xenos meet the fate you choose below); empire tilts xenophobe; **xeno pops empire-wide get angry** (risking contagion on other mixed worlds). The nativist path.
2. **Back the xeno militias.** Xenos win; xenophobe ringleaders suppressed; empire tilts xenophile; **native-stock pops resent you.** The cosmopolitan-crackdown path.
3. **Fight both.** You commit *your own* armies and crush both factions. Most expensive (two enemy stacks); no ethic tilt; short-term martial-law stability hit + authoritarian/militarist flavour; both blocs resent you a little. The "no separatism on my watch" path. **Implementation note:** this approach does **not** ride the bar to an extreme — it ends the Situation *out of band* (`destroy_situation` + empire-reclaim outcome) once both belligerent stacks are destroyed.
4. **Abstain / let them fight.** Commit nothing. The stronger bloc wins and keeps the planet as a **permanent independent breakaway** — you **lose the territory.** This is what makes the slow-burn neglect actually *bite*.

### Winner's-spoils: fate of the losing bloc *(LOCKED)*

If you win (or back the winner), you choose the losing bloc's fate **on that planet**. All three are **surgically per-planet targetable** — iterate the planet's pop groups, filter by phenotype *and* ethic, so you hit only the belligerents and spare the moderates:

```
every_owned_pop_group = {
    limit = {
        species = { is_archetype = <losing phenotype> }
        has_ethic = ethic_xenophobe        # only the militants, e.g.
    }
    kill_all_pop = yes                      # or set_pop_group_flag = subjugated
}
```

| Fate | Mechanism | Scope |
|---|---|---|
| **Massacre** | `kill_all_pop` filtered by phenotype + ethic | planet-local, surgical |
| **Expel / displace** | kill-as-fled, or `purge_displacement` flavour | planet-local |
| **Subjugate (forced integration)** | `set_pop_group_flag = subjugated` + `triggered_pop_group_modifier` (low happiness, ~0 political power, no faction access, ethic pull toward the state) | planet-local, surgical |

**Severity scales the contagion** (§5 Tier 1): kill > expel > subjugate. The brutal option pacifies the planet hardest but radiates the widest backlash — a self-balancing moral-cost knob.

### The two-tier consequence model *(LOCKED — and the engine boundary HELPS here)*

A hard engine boundary: **legal status (citizenship/purge/slavery) is set per *species*, empire-wide — NOT per planet** (`set_citizenship_type` / `set_purge_type` operate on `every_owned_species`; see §9). You **cannot** legally enslave-only-this-planet without speciation tricks (which we deliberately avoid).

Far from a limitation, this gives a natural **two-tier structure**:

- **Local tier (this planet):** the physical fate above — kill / expel / subjugate, surgical.
- **Empire-wide tier (political aftermath):** the *legal/ethic* reverberation — e.g. a nativist victory shifts that xeno species' empire-wide rights toward `citizenship_limited` / `purge_displacement` and nudges national ethics xenophobe-ward. A xeno victory pushes the other way.

This means an ethnic civil war that ends in nativist victory **should** radicalise your whole empire's stance toward that phenotype — exactly the contagion we want, handed to us for free. **"Subjugate" → enslavement converts ethnic-war risk into slave-revolt risk** (see free-xenos gate, §2): the nativist "final solution" merely chooses which monster you'd rather fight.

> **Why we avoid per-planet speciation:** confining legal slavery/purge to one planet would require splitting the losing pops into a brand-new species first. We did not find an instant "reassign pop to new species" effect in 4.4 by the obvious names, and the trick is heavy (species proliferation, UI clutter). The kill / flag-and-subjugate local path + species-wide political ripple covers all four fates cleanly without it. *(Open: confirm whether such an instant-speciation effect exists, only if a future feature truly needs planet-confined legal status.)*

---

## 7. Contagion — four tiers *(model LOCKED; Tier 4 deferred to a later phase)*

**Key reframe:** for ethnicity, contagion spreads along **bloodlines, not borders.** The primary radius is *demographic* (which species/ethic groups react), not spatial — which is also the cheap, MP-safe path (filter by `species`/`has_ethic`, no per-planet distance checks).

| Tier | What | Status |
|---|---|---|
| **1 — Demographic reverberation** | At resolution, every pop of the relevant blocs reacts *regardless of location*. Losing bloc's kin everywhere → timed "Witnessed the [Massacre/Subjugation/Expulsion]" modifier (happiness/stability hit + attraction shift, **intensity scaled by chosen fate**); winning bloc's kin → loyalty/happiness boost. **Fades** over ~a decade. | Always on |
| **2 — Structural drift** | Backing a side *permanently* tilts the empire (species rights + national ethics). Does **not** fade. **Lowers the tension threshold on every mixed planet going forward** — one war makes the *next* one closer. This is what makes the mechanic compound over a game. | Always on |
| **3 — Cascade / copycat** | Contagion **raises tension** on eligible planets (dumps into their simmer accumulator) — it does **NOT** auto-spawn wars. Only planets already in the **top-tension stage** are eligible. Empire-wide **cooldown** after any war suppresses new ignitions for N years. **Hard cap on concurrent civil-war Situations** (tracked via our own empire variable). | Gated, damped |
| **4 — Cross-empire / galactic** | Xenophile neighbours lower opinion; a xeno breakaway seeks a protector; GalCom sanctions. The MP-geopolitics layer. | **Deferred** to a later phase |

**The whole risk is the un-fun snowball** — one mishandled war → empire-wide collapse, punishing the wide/diverse play the vision wants to *reward*. So contagion severity must be a **readout of prior governance**, not a fixed tax. Player levers that shrink it: backing the side that aligns with your empire's lean, xenophile ethics/civics/leaders (shock-absorbers), and a resolution option to spend influence/unity to "manage the fallout" (reduce the Tier-1 modifier magnitude).

> **Gradient of consequence:** a xenophile, high-amenity, well-garrisoned empire shrugs off an ethnic civil war with mild grumbling; a xenophobe-drifting, crime-ridden, neglected empire watches one war push three other planets to the brink.

---

## 8. Frequency & scale-with-size pressure

### Philosophy: a consequence meter, not a dice roll *(LOCKED)*

Frequency **emerges from playstyle** — it is condition-driven, not a fixed rate.

| Empire type | Expected ethnic civil wars per game |
|---|---|
| Mono-species / slaver / careful xenophile | **0** — by design |
| Average free-multi-species, decent management | **0–1**, late game only |
| Neglectful free-multi-species sprawl | **2–4**, mid-to-late, escalating |

**No hard lifetime cap** — an empire that refuses to learn *should* keep bleeding (the teeth). The throttle is **spacing** (cooldown + concurrent cap), not a ceiling.

### Timing: a mid-to-late-game phenomenon *(emergent, no hard date gate)*

Early empires are small and mostly the founder species; free xenos accumulate slowly via conquest/migration/immigration, and the simmer accumulator takes *years* to fill. So the natural arc is: expand wide → absorb a polyglot population → *then* the cost of governing it bites.

### Dials → targets

- **Rarity gate = tension floor / neutral band** (the most important rarity knob — set high enough that a decently-run planet never simmers).
- **Warning window = accumulator rate + ignition max** → **~5–10 in-game years** of *sustained* bad conditions from first visible simmer to ignition. Long, visible, recoverable → ignition feels *earned*, never random.
- **Spacing = cooldown + concurrent cap** (concurrent cap of 1, maybe 2 for very large empires; multi-year post-war cooldown).

### Scale-with-size pressure: "Diversity Load" *(LOCKED — chosen over pure immunity)*

> **It shrinks your margin for error; it does NOT add unavoidable tension.**

An empire-level **Diversity Load** value adds a small **baseline upward drift** to each eligible planet's simmer accumulator. Management terms push drift *down*; Diversity Load pushes it gently *up*. On a well-run planet the net stays comfortably negative — the Load just narrows the gap.

- **Driver (not raw size — a huge mono-species empire has zero Load):**
  `Diversity Load ≈ (free xeno pop count) × (distinct phenotype count)` — volume of xenos × how many different peoples they are.
- **Containability guarantee (two rules):**
  1. **Hard cap below max damping** — Load's contribution is capped (e.g. ≤ +1.5/month) while achievable management damping always exceeds it. By construction, a perfectly-run empire of *any* size holds the line.
  2. **Containment cost scales with size** — the empire-wide damping tools (xenophile civics, a "cohesion" edict, dedicated institution buildings, leader assignments) cost **upkeep, civic slots, influence.** Neutralising strain across a sprawling empire is a real, growing investment competing with military/economy. **You never "solve" it — you keep paying to manage it.**
- **Two-level management texture:** empire-level cohesion infrastructure **and** per-planet order/amenities/rights. A sprawling empire needs both → genuine build choices (military doctrine vs. multispecies cohesion).

**Illustrative drift (placeholders):** well-run planet ≈ −4/month from good management; Diversity Load ≈ +0.5…+1.5/month by scale; net stays −2.5…−3.5/month (calm). A neglected frontier colony in a huge empire is what tips positive and starts simmering.

---

## 9. Supporting systems

These were designed alongside the core and feed its inputs. Proposed for a later phase (see §12), but part of the intended whole.

### Crime → ethics drift

On a high-crime "melting pot" planet, xenophile attraction goes **down** and xenophobe attraction goes **up** — a `triggered_planet_modifier` gated on `crime > threshold` + a diversity check, carrying `pop_ethic_xenophile_attraction_mult` (negative) and `pop_ethic_xenophobe_attraction_mult` (positive). Verified planet-applicable (these modifiers appear in vanilla *buildings* — see §10).

This creates the **doom-loop** that the brakes are designed to counter:
```
crime + melting pot → xenophobe attraction ↑ → NativeMilitancy ↑ → tension ↑
   → simmer accumulates → civil war → empire ethic/rights drift (lowers other planets' thresholds)
   → contagion dumps into nearby accumulators → next simmer
```
…with brakes at **every** stage (full citizenship kills grievance; xenophile institutions raise Tolerance; stability/amenities/garrison crush Disorder; cooldown + concurrent cap throttle the cascade). Ethic attraction drifts *slowly* (years) — so this is a 20–30-year arc, the slow burn, not a switch. **Tune multipliers modest** so a well-run melting pot is fine and only a neglected one spirals.

### Friction / incident events

The **"spark"** layer between slow drift and the explosion. Fire from an `on_action` pulse (no `mtth`) with deterministic conditions. Strongest version gives the player **agency**:

- An inter-species riot/pogrom incident fires when crime + diversity + low stability align.
- Options: spend influence/unity to **defuse** (costly de-escalation) **vs. crack down** (instant stability, but a lasting resentment modifier + an attraction nudge xenophobe-ward).
- Each incident leaves a temporary tension modifier feeding the civil-war trigger.

The short-term-order-vs-long-term-grievance choice is exactly the "management with teeth" texture, and gives players a way to **fight** the doom-loop rather than watch it.

---

## 10. Performance & MP safety

**Verdict: cheap by Stellaris standards — *provided* it stays gated and staggered (which is built into the design, not bolted on).**

- **The 4.0 pop-GROUP model is what makes this feasible.** A planet has ~5–25 groups, not 100+ pops. Every loop iterates groups → an order of magnitude cheaper than the equivalent 3.x per-pop loop would have been.
- **Layer-1 gate culls most planets** before any loop (gestalt / mono-species / all-slave / no-free-xeno / content all skip; the gate checks are a country flag, one stability read, and a short-circuiting `any_owned_pop_group`).
- **Monthly-or-slower, staggered.** The simmer is a multi-year build — no daily granularity needed. Rotate which planets evaluate each tick → no monthly spike.
- **Diversity Load is cached** (maintained running value, not a from-scratch recount each tick).
- **Rough scale:** late-game ~17 empires × ~5–10 eligible planets each × ~10–25-group loops, run monthly & spread across 30 days ≈ **~100 group-reads/day galaxy-wide** — a rounding error next to vanilla's own per-planet pop-group passes for jobs/stability/amenities.

**Determinism (MP):** every formula input is a deterministic read — **no RNG in the tension math.** No `mean_time_to_happen` anywhere; all timing via `on_action` / Situation `on_monthly`. Any randomness uses synced/deterministic forms (`create_balanced_fleet`, `random_list`). Counts-and-divide (e.g. "xenophobe share of natives") accumulate into variables during the pop-group loop, then divide with a **zero-guard**.

**The cost lives entirely in implementation discipline, not the concept** — a naive (daily, ungated, recompute-from-scratch) implementation *would* lag a 7-player late-game tick. Mitigation: build data-driven, profile in a late-game MP save, and if a hot spot shows: widen the gate, slow the cadence, coarsen the stagger.

---

## 11. Verified engine primitives

All confirmed against live 4.4.4 files at `D:\Stellaris\`. (See also the `docs/vanilla/` additions made alongside this doc: `situations.md`, and the new sections in `population.md`.)

| Primitive | Verified | Evidence |
|---|---|---|
| Planet-scope pop-group iteration | ✅ | `every_owned_pop_group` / `any_owned_pop_group` work in planet scope — `events/ancient_relics_arcsite_events_1.txt:3234` (runs on a planet, then `planet = {…}` / `set_owner` in same scope), `:4247` |
| Filter pop groups by species/phenotype | ✅ | `species = { is_archetype = … }` / `is_species_class = …` — `scripted_triggers/02_…machine_age.txt:65`, `08_…shroud.txt:698+` (MAM/REP/AVI/MOL/FUN/PLANT/LITHOID/TOX…) |
| Filter pop groups by ethic | ✅ | `has_ethic` evaluated per pop group (4.0 faction-membership model) — `pop_faction_types/00_imperialist.txt:755` |
| Kill / flag pop groups | ✅ | `kill_all_pop = yes`, `set_pop_group_flag = …` on pop-group scope — `events/ancient_relics_arcsite_events_1.txt:3236`, `:6079` |
| **Citizenship/purge are SPECIES-scope, not planet** | ✅ (key limitation) | `set_citizenship_type` / `set_purge_type` operate on `every_owned_species` (species, country) — `scripted_effects/galactic_community_effects.txt:452-453`. Purge types incl. `purge_displacement`. |
| Ethic-attraction modifiers are planet-applicable | ✅ | `pop_ethic_xenophobe_attraction_mult` / `pop_ethic_xenophile_attraction_mult` used inside **buildings** → apply at planet scope — `buildings/15_overlord_holdings.txt:1821-1830`, `buildings/23_shroud_buildings.txt` |
| Situations are moddable, planet-targetable, with approaches | ✅ | `common/situations/` (20 vanilla files) + `99_README_SITUATIONS.txt` — target = colony carrier; bidirectional bar; approaches with `ai_weight`; `on_monthly` events; `on_progress_complete`/`on_fail` |
| ❔ Instant "reassign pop to a new species" effect | **Unverified** | Not found by obvious names in 4.4. Only needed if we ever want planet-confined *legal* slavery/purge (we currently avoid it). Confirm before relying on it. |

---

## 12. Implementation phasing *(proposed — not locked)*

A suggested build order so the core ships before the supporting systems:

- **Phase 0 — Scaffold.** `bash tools/new-mod.sh ethnic_tensions "Ethnic Tensions"`. All tuning constants in one `common/scripted_variables/` file.
- **Phase 1 — MVP core.** Eligibility gate → simmer accumulator → ignition → the Situation (two temp countries, three approaches + abstain) → resolution (kill/expel/subjugate, local tier) → Tier-1 demographic reverberation. *(Tension formula, free-xenos gate, gestalt exemption all here.)*
- **Phase 2 — Empire ripple & scale.** Tier-2 structural drift; Diversity Load + cohesion infrastructure.
- **Phase 3 — Doom-loop & sparks.** Crime → ethics drift; friction/incident events.
- **Phase 4 — Cascade.** Tier-3 contagion (gated, capped, cooldown).
- **Phase 5 (later/maybe) — Geopolitics.** Tier-4 cross-empire reactions; MP-exploit hardening.

Validate (`bash tools/validate.sh`) before every commit; profile a late-game MP save after Phase 1 and again after Phase 4.

---

## 13. Locked decisions (quick reference)

1. **Vessel** = a planet-targeted **Situation** (bidirectional bar, approaches, `on_monthly` events).
2. **Three-body model**: native (founder phenotype) bloc vs. aggregated xeno bloc vs. player.
3. **Bloc lines = phenotype**, not ethics; ethics is the *militancy fuel*; **moderates are bystanders**.
4. **Free-xenos gate**: ignites only if xenos are free — slaves route to the slave-revolt track.
5. **Gestalt empires fully exempt.**
6. **Two-stage**: recoverable, visible **Simmer** → **Ignition**.
7. **Ignition formula**: `Balance × (NativeMilitancy + XenoGrievance) × (1 − Tolerance) × Disorder × FragmentationAmp`, feeding the accumulator.
8. **Initial control** = deterministic composition score (not RNG); player's approach is the real determinant.
9. **Four approaches**: back xenophobes / back xenos / fight both / abstain (→ lose the planet).
10. **Winner's-spoils** (surgical, per-planet): kill / expel / subjugate; severity scales contagion.
11. **Two-tier consequences**: surgical *local* physical fate + species-wide *empire* political ripple (the engine's species-scope limit is leveraged as a feature).
12. **Subjugate→enslave converts** ethnic-war risk into slave-revolt risk.
13. **Contagion**: Tier-1 demographic (always), Tier-2 structural (always), Tier-3 cascade (gated/capped/cooldown), Tier-4 geopolitics (deferred).
14. **Frequency** = consequence meter; 0 for well-run/mono/slaver/xenophile; mid-late onset; ~5–10-yr warning; spacing via cooldown + concurrent cap; no lifetime cap.
15. **Scale-with-size = Diversity Load** baseline drift, capped below max damping; containment cost grows with size.
16. **Performance** via 4.0 pop-groups + cheap gate + monthly/staggered cadence + cached Load; no RNG/`mtth` (MP-safe).

---

## 14. Open questions / deferred

- **Multi-founder / syncretic empires** — how is "native bloc" defined with 2+ founding species? *Default proposal:* the **primary/ruling** species' phenotype = native, everyone else = xeno. **Unresolved — needs a call.**
- **Founder-as-minority planets** — handled by the symmetric `min()` minority test; flagged as resolved-by-design, worth a sanity test in play.
- **Tier-4 cross-empire geopolitics** — deliberately deferred (MP-exploit surface: a neighbour invading during your civil war, or recognising/protecting a xeno breakaway). Build Tiers 1–3 first.
- **Instant pop-speciation effect** — verify existence only if a future feature needs planet-confined *legal* status (currently avoided).
- **Mod home/name** — proposed new mod `ethnic_tensions` ("Ethnic Tensions"); not yet scaffolded.
- **All numeric values** — floor, neutral band, accumulator rate, ignition max, Load cap, cooldown length, drift magnitudes — are **placeholders pending in-game tuning.**

---

## Related documents

- [design-vision.md](design-vision.md) → Population & Migration (the species-relations thread this realises)
- [ROADMAP.md](ROADMAP.md) → Population & Migration (tracking entry)
- [vanilla/population.md](vanilla/population.md) → pop-group script access, per-planet vs species-scope targeting, attraction modifiers
- [vanilla/situations.md](vanilla/situations.md) → the Situations system architecture
- [multiplayer-balance.md](multiplayer-balance.md) → log the balance decisions here once tuning begins
