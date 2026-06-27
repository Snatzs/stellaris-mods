# Economy Overhaul — Space vs. Planets (Design Note)

> Design record for the Economy goals in [design-vision.md](design-vision.md) (pillars 1–4).
> Captures the decisions reached 2026-06-20 so implementation can proceed without
> re-litigating them. **Status:** design agreed; implementation pending. Supersedes
> `economy_overhaul` **slice 1** (the flat per-pop output nerf), which is replaced by the
> structural approach below.
>
> All facts here were verified against vanilla **4.4.3** game files; file:line citations
> are inline. Mod-side principle (as in `migration_overhaul`): prefer additive content;
> overrides are sometimes unavoidable but kept to a tiny, documented set.

---

## ⚠️ v2 — Revised decisions (2026-06-23, supersede the drift below)

The first in-game test exposed both **mechanism bugs** and **design drift** from the group's
actual intent. This section is now authoritative; the original tracks below are kept for rationale
but their *mechanisms* and a few choices are corrected here.

**Verified Stellaris 4.4.3 mechanics (the hard lessons):**
- **Scripted variables CANNOT be overridden by redefinition** (`error.log: Variable name X is
  already taken` — vanilla wins). They must be changed by **whole-file replacement** of the
  defining file. (DB objects — civics/techs — and defines DO override by last-wins; don't conflate.)
- **on_actions reject a bare `effect = {}`** (`Unexpected token: effect`). Use `events = { <id> }`
  + a hidden `is_triggered_only` event.
- **4.4 employment model:** jobless pops become low-stakes **civilians** (no growth penalty);
  **houseless/overcrowding is the real pressure** — growth stops at 1.15× over-housing, pops decline
  at 1.25× (`NPop` defines). ⇒ The old "keep housing surplus → overpopulation pressure" idea was
  **backwards**: surplus housing does nothing. We now **cut housing toward scarcity.**
- **City/urban districts grant ZERO jobs in 4.4** — only housing. **Specialist jobs come from ZONES**
  (`@scaling_district_*_job`). So "nerf city-district jobs" = cut the zone job variables.
- **`@habitable_planet_max_size` does not reliably cap procedural galaxy worlds** (the homeworld uses
  `@homeworld_max_size`; gas giants/special systems use explicit sizes). Whether it caps *ordinary*
  procedural habitables is **under in-game test**; if not, use an `on_game_start` resize event.

**Revised Track 1 lever set — BUILT & in-game-verified 2026-06-24 (except where noted):**
| Goal | Lever | Mechanism | Value | Status |
|---|---|---|---|---|
| Space is primary | **Buff deposit base yields** (flat +50% station modifier REMOVED to avoid base×mult×repeatable bloat) | whole-file `01_orbital_deposits.txt`, **per-resource** `produces` ×N | **minerals ×1.40, energy ×1.60, research ×1.15**; alloys/food/CG/trade vanilla (was uniform ×1.75 v2 → ×1.40 v2.4 → per-resource v2.5, item #4) | ✅ space>job ratio held; absolute supply re-tuned down to fix glut (re-test pending) |
| Space scales (late, infinite) | station gatherer/researcher repeatables | new techs | +3%/level | ✅ |
| Space scales (mid, finite ramp — **lever #6**) | escalating finite station techs (`tech_space_mining_1..5` / `tech_space_science_1..5`) | whole-tech override, `zzz_econ_finite_station_techs.txt` | mining +10/20/30/40/50 (+150% cum.); research +10/15/20/25/30 (+100% cum.) | ✅ **2026-06-27** — fills the post-tier-3 dead zone; reachable at 2x tech cost. Mining covers minerals+energy (shared category); research gentler per Track 2 |
| AI stays functional | AI-only housing relief (AI can't perceive the overcrowding growth-stall) | `econ_ai_planet_relief` static modifier, `is_ai = yes` gate in `econ_overhaul.1` | `planet_housing_mult +0.30` | ✅ **2026-06-27** — all 7 players human, so human-facing scarcity intact; tune down if AI over-sprawls |
| Planet basic-resource down | rural district jobs | ~~`100_…zones.txt`~~ | ~~200→150~~ | ❌ **REVERTED 2026-06-27** — too many planet-down levers stacked; planet-down now via size cap + housing only |
| Specialist VOLUME down (not output) | ~~zone job vars `@scaling_district_*`~~ | ~~`100_…zones.txt`~~ | ~~−~30%~~ | ❌ **REVERTED 2026-06-27** (same reason; the whole-file override was deleted) |
| Housing scarcity | **urban (city/hive/nexus) district housing** (replaced the global `planet_housing_mult` — that also cut rural/wide housing) | whole-file `00_urban_districts.txt`, urban `planet_housing_add` ×0.70 | **−30%** | ✅ working in-game |
| Housing bites sooner | overcrowding thresholds (+ machine variants) | `NPop` defines merge | 1.15→**1.10**, 1.25→**1.20** | ✅ |
| Planet size ≤18 | **`on_game_start` resize event** (the scripted var does NOT govern procedural gen; that 623-line override was DROPPED) | event `econ_overhaul.2`, `every_system { every_system_planet }`, 19-25 → 16/17/18, capitals excluded | max **18** | ✅ confirmed ~no >18 worlds |
| Tame kilostructures | Arc Furnace / Dyson Swarm per-tier output | whole-file `07_…machine_age.txt` | **×0.4** + cap −1 | ✅ |
| Pop generation parity — MECHANICAL assembly | `planet_pop_assembly_mult` | **`econ_organic_assembly_nerf`** (machine-EXEMPT, gated `is_machine_empire = no` in `econ_overhaul.1`) | **−33% organics only** | ✅ **v2.3 2026-06-25** — moved OUT of `econ_space_primacy`; machines exempt (they grow only by assembly & are already late-capped by vanilla Country Growth Scale); organics keep it so robot assembly can't stack tax-free on logistic growth |
| Pop generation parity — HIVE/organic flat growth | spawning/budding/clone drones emit `bonus_pop_growth` (FLAT, doesn't slow as planet fills), not assembly, so `planet_pop_assembly_mult` missed them | `bonus_pop_growth_mult` on `econ_space_primacy` (`@econ_growth_nerf`) | **−33%** | ✅ **VERIFIED in-game 2026-06-25** — shows under pop-group **Bonus Growth** as "Galactic Resource Distribution −33%" scaling the Spawning Drone flat add; **Base (logistic) Growth untouched** (Hive Mind / Fertility Preacher / A New Life all full) — exactly the parity target |

Specialist *output* is deliberately NOT nerfed (only job count per zone). Research stays
planet-primary (Track 2 unchanged in intent).

**Open items (next session):**
0a. ✅ **BUILT 2026-06-27 — lever #6, escalating finite station ramp.** First in-game test (77yr,
   400-system, machine empire, **2x tech cost**) showed space income "doesn't scale" — diagnosed: the
   repeatables gate behind the tier-3 chain end (far out at 2x cost, never reached), and the only
   mid-game ramp was vanilla's flat +10%/tier (+50% by tier-3) then a dead zone. Fix: escalating
   finite ramp (mining +150% cum., research +100% cum.). NOTE: the small galaxy also starved
   *expansion*-scaling (the primary early/mid driver, on-vision); the real game is **1000 systems**,
   where expansion runway is far longer — re-test there before further tech-side tuning.
0b. ✅ **BUILT 2026-06-27 — AI economic relief (planetary side).** Confirmed in-game: the AI cannot
   handle planet capacity as a growth constraint — its planner is deficit-driven and our overcrowding
   nerf stalls growth BEFORE homelessness, so it sees no signal and never builds residences →
   economic stall. Compensated with an `is_ai = yes`-gated `planet_housing_mult +0.30`. Props the AI
   up; doesn't make it good. Harsh galaxy settings (Deficit Logistics 5x, Habitable 0.5x + Guaranteed
   Off) compound AI weakness independently — reconsider those for the real game. **Pattern to extend:**
   several planetary/pop nerfs likely hit the AI harder than players; AI-only compensation is the
   clean MP-fair lever (all players human). Growth/assembly AI-exemption is the obvious next toggle.
1. ✅ **RESOLVED 2026-06-25 — Hive/organic flat-growth parity (the spawning-pool gap).**
   Investigation overturned the assumption that gated this: the spawning-drone job emits
   `bonus_pop_growth` (a FLAT additive growth, scaled by `bonus_pop_growth_mult`), while
   Fertile / Rapid Breeders use a *different* modifier, `logistic_growth_mult`. So
   `bonus_pop_growth_mult` is NOT "too blunt" — it touches only the flat-additive channel
   (hive spawning drones + plantoid/lithoid budding + clone vats) and leaves base logistic
   growth and the breeder traits untouched. Chosen over the surgical job-copy because copying
   the 200-line `spawning_drone` job would be another brittle whole-file dependency (the exact
   patch-staleness trap re-confirmed by the 4.4.4 update). Built as `bonus_pop_growth_mult =
   @econ_growth_nerf` (−33%, = the assembly nerf) on `econ_space_primacy`. Catching budding +
   clone-vat flat growth is intentional parity, not collateral. **VERIFIED in-game 2026-06-25:**
   a hive Tech-World's pop-group growth breakdown shows the −33% under **Bonus Growth** (labelled
   "Galactic Resource Distribution", our `econ_space_primacy` loc name) scaling the Spawning Drone
   flat add, while **Base/logistic Growth** (Hive Mind +25%, Fertility Preacher +5%, A New Life
   +10%, Cultivation Drones +10%) is untouched — confirming the flat-vs-logistic split is correct.
   NOTE: the per-JOB tooltip never shows country-scope growth mults — read the pop-GROUP breakdown.
2. **Planet bulk output (decision B).** Need a *regular colony's* minerals/energy (not the capital,
   which is uncapped & district-heavy) to decide whether to enable the reserved per-pop output nerf
   (`planet_miners_minerals` / `planet_technician_energy_produces_mult` −30% on `econ_space_primacy`).
3. **Mono-specialised mega-planets** (100%-research ecumenopoli) vs healthy specialization (forge
   world + a little food). Distinct design problem; housing cut doesn't solve it. Candidate
   directions: diminishing returns on stacking one designation, or amenity/upkeep penalties for
   zero-diversity builds. Parked.
4. **🟠 ADDRESSED (supply-down, v2.4/2026-06-26) — re-test pending — Mineral (and some energy) GLUT
   (observed 2026-06-25).** At year ~20, *every* empire big or small was stacked with triple-digit
   mineral production; some energy too. The `×1.75` deposit-yield buff (Track 1, "space is primary")
   overshot the *absolute* supply level and undercut the **scarcity pillar** — abundant minerals =
   no trade-offs, no conflict over resources. Decision (group, 2026-06-26): **supply-down** — chosen
   over sink-up because it's the smallest/most reversible lever and keeps space *relatively* primary
   without an absolute flood (sink-up has a broader blast radius and is harder to calibrate without
   measurement; it remains a future option if supply-down alone doesn't restore scarcity). **Action
   (v2.4 → refined v2.5):** dropped the uniform ×1.75, and instead of a flat ×1.40, went **per-resource**
   (`01_orbital_deposits.txt`, regenerated from vanilla by a tools-side script):
   **minerals ×1.40, energy ×1.60, research ×1.15**; **alloys / food / consumer_goods / trade left at
   vanilla ×1.0.** Rationale: minerals were the main glut culprit (lowest of the bulk pair); energy
   tolerates a hotter buff (more late-game sinks, drains faster); research stays a *supplement* per
   Track 2 (planet-primary), so only +15%; alloys are a refined/STRATEGIC output the vision wants kept
   scarce (the few natural orbital alloy deposits stay un-inflated); food/CG deposits barely-or-never
   spawn (`d_food_4..10` & the CG deposit are `always = no`; `d_food_3` ~0 weight) so buffing them is
   noise. Verification caught that trade and these dead deposits should NOT be scaled — regenerated from
   vanilla, not hand-edited. **Still needed (in-game):** confirm these restore scarcity at yr 20/40 —
   baseline typical minerals (and energy) income for a small vs large empire; if minerals still glut,
   cut toward ~×1.3 and/or add sinks (lever (b)); if space no longer feels primary, ease back up.
   Connects to Track 4 (strategic-resource supply scaling) — this baseline informs slice 4.
5. **🟡 INCONCLUSIVE — Is the housing cut biting? (contradictory observations 2026-06-25, needs
   controlled testing — do NOT act yet).** The cut we have is the **per-district URBAN housing
   reduction** (`planet_housing_add ×0.70` on city/hive/nexus) + tightened overcrowding (1.10/1.20).
   Two conflicting reads in different games:
   - **(a) Too weak:** planets field large populations without real drawbacks; empires not forced
     to build residences.
   - **(b) Actually biting:** 19-size CAPITAL planets struggle with planet capacity when no
     residences are built.
   So it may already be working and just situational (planet size, designation, species housing
   density, fill level). **Next step is MEASUREMENT, not a change:** on several developed planets,
   compare housing vs housing-needs and how close it runs to the 1.10 overcrowding wall, across
   sizes/designations. **DESIGN CONSTRAINT if we ever do tune it — do NOT re-introduce a global/flat
   `planet_housing_mult`:** it was deliberately removed because it also cut RURAL housing and made
   early/wide play miserable; the urban-only cut exists precisely to spare rural/early game. Any
   future adjustment must stay targeted (deepen the URBAN cut, or attack CAPACITY) — never broad.
6. **Country Growth Scale — confirmed mechanic (2026-06-25), keep in mind for all growth work.**
   Vanilla `GROWTH_SCALE` (galaxy setting, default 0.25) taxes the FLAT growth channels
   (assembly + `bonus_pop_growth`) by total empire pop count, and **EXEMPTS logistic growth — verified
   even for hives** (a large hive's Base/logistic growth shows NO Country Growth Scale line; only its
   Bonus/Spawning line carries it). Consequence: machines (flat-only) are the archetype most reined
   late-game; hive/organic logistic is unreined empire-wide. This is WHY the assembly nerf went
   machine-exempt (item in the table). In-game spot-check 2026-06-25: a hive colony (+3.43/mo) and an
   organic individualist (+3.5/mo) were ~even — the flat double-tax (our −33% + CGS) had already
   pulled hive growth to organic parity, so **no hive-specific logistic nerf is warranted yet**
   (revisit only if a later save shows hives pulling ahead).

---

## The core idea

Vanilla's economy is planet-centric and scales to infinity (repeatable tile-output techs,
ascension, stacking bonuses), while space stations plateau early and fall behind. We want
the inverse of the *feel* — space as the primary bulk economy, planets as modest, defensible
anchors — **without** reintroducing the late-game number-bloat that 4.3 "Cetus" fought.

The unifying principle across the whole rework is **parity of scaling curves**: every
producer type should have a comparable growth curve so none runs away or falls behind. The
*baseline ratios* between curves are then set to express the design goals. This splits the
economy into **three tracks that share the parity principle but diverge on baseline and shape**:

| Track | Goal | Shape |
|---|---|---|
| **1. Bulk (minerals, energy)** | Space **outproduces** planets in aggregate | Dominance flip + bounded scaling + structural planet nerfs |
| **2. Research** | Stays **planet-primary**; space kept *relevant* | Station parity only; planet research trimmed *indirectly* |
| **3. Strategic resources** | **Geographically concentrated**; supply matched to a growing demand curve | Concentrate + gut planet/refining + scale supply with demand |

Key framing decision: **"space > planets" is achieved by bringing planets DOWN, not by
inflating space.** Inflating base yields compounds with multipliers (megastructures, civics)
into bloat. Deflating planets makes space *relatively* dominant with no absolute inflation.

We target the **aggregate** claim ("an empire's space mineral/energy income exceeds its
planetary income"), **not** "a single deposit beats a single planet" (that needs richer
deposits → re-lights the bloat fuse). Out of scope.

---

## Track 1 — Bulk resources (minerals & energy): the dominance flip

### The mental model
`planetary output ≈ (#planets) × (districts/planet) × (jobs/district) × (output/job)`
`space output ≈ (#deposits) × (base yield) × (tech-scaled station %)`

### Four levers
1. **Baseline ratio** (space modestly above planets): amplify vanilla's finite station techs
   **+** the structural planet nerfs below. Planets-down does most of the work; absolute
   numbers stay sane. Keep **base deposit yields ≈ vanilla** to avoid multiplier compounding.
2. **Parity over time:** vanilla has `tech_repeatable_improved_tile_mineral_output` /
   `_tile_energy_output` (planets scale forever, `levels = -1`) and **no station repeatable**
   — that asymmetry is why stations fall behind. **Add** a station repeatable mirroring the
   tile ones so space tech advances alongside planetary tech.
3. **Bloat control:** set a **gentler per-level %** on *both* the tile repeatables (nerf
   vanilla) **and** the new station repeatable, so both curves climb together but gently.
4. **Research:** see Track 2 (kept out of the bulk flip).

### Structural planet nerfs (replace slice 1's flat per-pop nerf)
The 4.4 reality (verified): a rural district (mining/generator/farming) grants **200 jobs**
(`@base_rural_district_jobs = 200`, `common/scripted_variables/100_scripted_variables_zones.txt:11`)
+ 200 housing + a zone slot; **#districts ≈ planet size** (engine-calculated, NOT the
`DEFAULT_MAX_DISTRICTS_PER_PLANET` define, which is a red herring); habitable size range is
**12–25** (`@habitable_planet_min_size = 12` / `@habitable_planet_max_size = 25`).

| Lever | Effect | Mechanism | Side effects |
|---|---|---|---|
| **Planet size cap** (primary) | Cap `@habitable_planet_max_size` 25 → **~18**. Truncating drops the average ~18.5 → ~15 for free → fewer districts → lower per-planet ceiling → wide>tall, mega-planets capped | Override the scripted variable (light, last-loaded-wins). See Q3 below | Galaxy-gen constant, no temporal nerf |
| **Jobs per district** (secondary, **unpaired**) | Cut `@base_rural_district_jobs` 200 → **~140**, **leaving housing at 200** → more housing than jobs → overpopulation/unemployment pressure → housing & amenities finally matter | Override the scripted variable | Deliberate: punishes cramming (on-vision). **Tune carefully** — too aggressive → death spiral. Start gentle (200→160ish) |
| **Per-pop output nerf** (optional fine-tune) | `planet_miners_minerals` / `planet_technician_energy` `_produces_mult` | Country modifier (slice-1 mechanism) | Clean, no side effects, but **light or zero** — don't stack hard on top of the structural cuts |

> **Planet-size cap — Option A vs B (Q3 resolved → A):**
> - **A — override `@habitable_planet_max_size` (chosen):** planets *generate* at 12–18; cap
>   also drops the average; smaller planets inherently cap districts. One-line, robust,
>   deterministic, hits all empires. Cost: a global-variable override (document in
>   `compatibility.md`; last-loaded-wins on conflict).
> - **B — on_game_start resize event:** no var override, full control of the distribution
>   curve, BUT only catches planets existing at game start, and shrinking *after* vanilla
>   places deposits/districts by original size risks mismatches. Reach for B-style logic only
>   if playtest shows we need a *specific* curve A can't give — layered on top of A, not instead.

### Temporal shape (resolves the "flat modifier" problem)
- **Planets** are **structural constants from turn one** (smaller, lower ceilings). Early
  game thus feels "vanilla but scarcer land," not "everything halved" — no jarring per-pop cut.
- **Space** **ramps** over the game (bounded station techs + repeatable) and pulls ahead
  mid-game, then **plateaus**. No infinite scaling.

---

## Track 2 — Research: planet-primary, space kept relevant

Research is conceptually different: it's **game pace**, not a stock, and it drives the very
scaling techs we tune. A geography-driven research economy risks a **research → military →
more-systems snowball** (dangerous in a 7-player game), and scientists-on-planets is the
thematically central model.

**Decisions:**
- **No dominance flip for research.** Planetary research stays primary.
- **No direct `planet_researchers` nerf.** The planet-research trim happens **indirectly** via
  the Track-1 structural levers (fewer jobs/district + smaller planets shrink research
  districts/labs too) — agreed sufficient.
- **Research stations get parity only:** keep the vanilla finite `station_researchers` techs
  **+** add a research-station repeatable mirroring the bulk one, so a research-rich system
  stays a worthwhile prize without overturning the planet-centric model or destabilizing pace.

Research is the one domain where space remains a **supplement**, not the primary source.

---

## Track 3 — Strategic resources: concentration + supply matched to demand

**This is the make-or-break track.** Goal (from design-vision) is the *opposite* of Track 1:
*scarce, concentrated, fought-over* — NOT a volume flip.

### Two kinds of scarcity (don't conflate them)
- **Distributional scarcity (geography):** *how many* sources and where. **Few + concentrated
  → controlling them is decisive.** This is where the strategic value lives.
- **Volumetric scarcity (supply vs demand):** how tight total supply is vs spend.

**Scarcity lives in the *number* of sources, not the yield per source.** Scaling a cluster's
output does NOT make the resource un-scarce if only a few clusters exist — it makes
*controlling those clusters* even more decisive.

### Why supply MUST scale (the killer argument)
Late-game strategic **demand grows**: ship components get more complex (more strategic
upkeep/build cost per hull), and upgradable buildings cost strategics at higher tiers — so
demand scales with tech + empire size. If we gut supply (frequency + natural-deposit
efficiency + **especially** synthetic/refining) **and freeze it** while demand climbs, we get
a **late-game strategic choke** — unmaintainable fleets, unrunnable buildings. Game-breaking.

So strategic **supply must scale with repeatables too, calibrated so supply scaling ≈ demand
scaling.** Controlling your fair share of clusters keeps your fleets fed; losing them starves you.

### The model
1. **Concentrate** strategic deposits into few clusters / single rich systems (distributional
   scarcity → control is decisive).
2. **Gut** natural planetary strategic deposits **and** refining (esp. synthetic) — you can't
   self-supply by sprawling or synthesizing; you must *hold the clusters*.
3. **Scale** the surviving (mostly space-cluster) supply with a **strategic-specific
   repeatable**, matched to the demand curve.

### Guard-rails (the two failure modes)
- **Supply lags demand → choke** (game stalls / strategic-holder wins by default).
- **Supply outpaces demand → trivial** (geography stops mattering; concept fails).
- Target = the knife's edge: **supply-per-controlled-cluster (scaled) ≈ the strategic spend of
  a proportionally-sized empire.** Dynamic balance → **#1 playtest tuning target.**
- **Refining survives as a costly, inefficient fallback** (not a clean substitute) → an empire
  that loses all clusters can limp/trade/rebuild rather than instantly die (comeback potential;
  raw extraction stays strictly better).
- **Multiple contested clusters, not one super-system** → strategic supply must be contestable
  among several of the 7 players, or one empire monopolizes and snowballs.

### Mechanism (verified levers)
- Strategic orbital deposits ride `category = orbital_mining_deposits` (child of
  `station_gatherers`) — so the **bulk** station scaling *spills onto* space strategics. To
  scale/control strategics **independently**, use the per-resource globals:
  `exotic_gases_produces_mult` / `volatile_motes_produces_mult` / `rare_crystals_produces_mult`
  (a strategic-specific repeatable built on these).
- Refining nerf: `planet_refiners_produces_mult` / `planet_chemists_produces_mult`
  (jobs in `common/economic_categories/01_job_categories.txt:513` / `:531`).
- Concentration: deposit `drop_weight` rework in `common/deposits/02_sr_deposits.txt`.
  **Highest-effort, highest-risk piece** — vanilla scatters strategics thinly; clustering them
  into few rich systems likely needs spawn-weight rework and possibly a galaxy-gen pass.

---

## Cross-cutting: tame the multipliers (or the rework bloats)

Anything that multiplies `station_gatherers` / `station_researchers` / starbase collection in
the **same category** compounds with our buffs. Verified audit:

### Pickable civics to neuter (build-meta exploits — pillar 4)
| Source | Buff | File |
|---|---|---|
| **Astro-Mining Drones** (`civic_machine_astromining_drones`, machine/MegaCorp) | `station_gatherers_produces_mult = 0.5` (also self-nerfs planets) | `common/governments/civics/02_gestalt_civics.txt:2349` |
| **Privatized Exploration** (`civic_privatized_exploration`, corporate/First Contact) | `station_gatherers +0.25` **and** `station_researchers +0.25` | `common/governments/civics/03_corporate_civics.txt:1409` |

Both become near-auto-picks once space is the primary economy. **Decision:** **disable
Astro-Mining Drones** from selection (same treatment as the banned nomad origins); **disable or
cut Privatized Exploration** to ~+10%. (User approved the Astro-Mining disable; Privatized
Exploration newly found — same class, same recommendation.)

### Baseline stackers — LEAVE (not exploits; symmetric)
Prosperity tradition (`station_gatherers +0.20`, `00_prosperity.txt:4`), Discovery tradition
(`station_researchers +0.20`, `00_discovery.txt:78`), Machine Intelligence authority
(`station_gatherers +0.10` baseline). Everyone has access → no asymmetric advantage. **Calibrate
the finite-tech amplification assuming a typical empire already has these**, rather than trimming.

### Megastructures
- **Scaling kilostructures — nerf + limit:** **Orbital Arc Furnace** *uncovers mineral deposits
  on every body* **and** grants a system `station_gatherers_produces_mult` (double-compounder),
  and **Dyson Swarm** grants "Star Output +X%" — both scale with deposit/station output. **Cut
  their per-tier mod-values AND lower their build limits** (`arc_furnace_limit` /
  `dyson_swarm_limit` are script values in `common/script_values/04_script_values_machine_age.txt:507–512`,
  driven by `..._limit_add` modifiers — clean to override). Keep them *worth building*, not
  economy-warping.
- **Fixed-output megastructures — LEAVE:** Dyson **Sphere** / Matter Decompressor produce flat
  `category = megastructures` output (separate silo, not touched by our station buffs).

### Planetary ascension (late/super-late planet scaler; 4.4 buffed it vs 4.3)
Nerf `PLANET_ASCENSION_MODIFIER_SCALE` **0.10 → 0.05** (`common/defines/00_defines.txt:1238`,
the per-tier designation-bonus amplifier) as the first knob; leave `PLANET_ASCENSION_HARD_CAP = 10`
(`:1230`) unless playtest still shows runaway.

---

## Consolidated lever table (starting values — all tunable, all for playtest)

| # | Lever | Start value | File |
|---|---|---|---|
| 1 | `@habitable_planet_max_size` | 25 → **18** | scripted_variables override |
| 2 | `@base_rural_district_jobs` (housing unchanged) | 200 → **~160** (gentle first pass) | scripted_variables override |
| 3 | Tile output repeatables (mineral/energy/food) per-level % | **lower** vs vanilla | `*_tech_repeatable.txt` override |
| 4 | New **station** repeatable (gatherers) | match #3's gentle rate | new tech |
| 5 | New **research-station** repeatable | match #3's gentle rate | new tech |
| 6 | Amplify finite station techs (ESCALATING ramp) | mining +10/20/30/40/50 (+150% cum.) / research +10/15/20/25/30 (+100% cum.) — ✅ BUILT 2026-06-27 | tech override (`zzz_econ_finite_station_techs.txt`) |
| 7 | New **strategic** repeatable (`exotic_gases`/`volatile_motes`/`rare_crystals_produces_mult`) | calibrate to demand curve | new tech |
| 8 | Refining nerf (`planet_refiners`/`planet_chemists_produces_mult`) | substantial | country modifier |
| 9 | Strategic deposit `drop_weight` (concentrate) | few rich clusters | `02_sr_deposits.txt` |
| 10 | Astro-Mining Drones civic | **disable** | civic override |
| 11 | Privatized Exploration civic | disable or → +0.10 | civic override |
| 12 | Arc Furnace / Dyson Swarm mod-values + build limits | cut + lower | machine_age vars / script_values |
| 13 | `PLANET_ASCENSION_MODIFIER_SCALE` | 0.10 → **0.05** | defines override |

---

## Suggested build order (slices)

1. **Bulk structural** — planet size cap (#1) + jobs cut (#2). Smallest, highest-leverage,
   pure variable overrides. Replaces slice 1.
2. **Bulk scaling parity** — tile-repeatable nerf (#3) + new station repeatables (#4, #5) +
   finite-tech amplification (#6).
3. **Multiplier taming** — civics (#10, #11), kilostructures (#12), ascension (#13). Cheap,
   high bloat-prevention value.
4. **Strategic resources** — refining nerf (#8) + strategic repeatable (#7), then the hard
   part: concentration/`drop_weight` rework (#9). Highest effort/risk; do last with most testing.

Each slice is bracket-validated + smoke-tested for clean load, then the whole stack goes into
one **batched** in-game test session (machine loads Stellaris slowly — see testing workflow).

---

## Open calibration targets (playtest, not paper)
- Jobs-cut magnitude — overpopulation pressure vs death-spiral.
- Where the bulk station ramp plateaus relative to planets.
- **Strategic supply scaling ≈ demand scaling** (the knife's edge) — the single most important
  number; expect several iterations.
- Concentration: enough contested clusters for 7 players; no monopoly super-system.

## Related documents
- [design-vision.md](design-vision.md) — Economy section (goals this implements)
- [ROADMAP.md](ROADMAP.md) — implementation status
- [multiplayer-balance.md](multiplayer-balance.md) — balance-decision log
- [compatibility.md](compatibility.md) — vanilla override registry (size/jobs vars, defines, civics go here)
- [vanilla/economy.md](vanilla/economy.md) — verified 4.4 economy architecture
