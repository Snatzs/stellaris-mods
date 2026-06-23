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
| Space is primary | **Buff deposit base yields** (flat +50% station modifier REMOVED to avoid base×mult×repeatable bloat) | whole-file `01_orbital_deposits.txt`, all `produces` ×N | **×1.75** | ✅ space>job balance trending right by yr 20 |
| Space scales | station gatherer/researcher repeatables | new techs | +3%/level | ✅ |
| Planet basic-resource down | rural district jobs | `100_…zones.txt` | 200→**150** | ✅ |
| Specialist VOLUME down (not output) | zone job vars `@scaling_district_*` | `100_…zones.txt` | **−~30%** | ✅ |
| Housing scarcity | **urban (city/hive/nexus) district housing** (replaced the global `planet_housing_mult` — that also cut rural/wide housing) | whole-file `00_urban_districts.txt`, urban `planet_housing_add` ×0.70 | **−30%** | ✅ working in-game |
| Housing bites sooner | overcrowding thresholds (+ machine variants) | `NPop` defines merge | 1.15→**1.10**, 1.25→**1.20** | ✅ |
| Planet size ≤18 | **`on_game_start` resize event** (the scripted var does NOT govern procedural gen; that 623-line override was DROPPED) | event `econ_overhaul.2`, `every_system { every_system_planet }`, 19-25 → 16/17/18, capitals excluded | max **18** | ✅ confirmed ~no >18 worlds |
| Tame kilostructures | Arc Furnace / Dyson Swarm per-tier output | whole-file `07_…machine_age.txt` | **×0.4** + cap −1 | ✅ |
| Pop generation parity — MECHANICAL assembly | `planet_pop_assembly_mult` | `econ_space_primacy` | **−33%** | ✅ hits robots/machines |
| Pop generation parity — HIVE/organic growth | spawning/offspring/clone drones produce **Monthly Organic Pop GROWTH** (not assembly), so `planet_pop_assembly_mult` misses them | TODO — see open items | — | ❌ **NOT yet done** |

Specialist *output* is deliberately NOT nerfed (only job count per zone). Research stays
planet-primary (Track 2 unchanged in intent).

**Open items (next session):**
1. **Hive/organic pop-growth parity (the spawning-pool gap).** Verified in-game: the spawning-drone
   job converts food → *Monthly Organic Pop Growth* (a GROWTH channel), so our `−33%` assembly nerf
   doesn't touch it. Bring it in line with base logistic growth. Candidate levers: override the
   `spawning_drone`/`offspring_drone`/clone-vat jobs to cut their growth output (surgical), or a
   negative `bonus_pop_growth_mult` (broader — also hits trait growth bonuses like Fertile, so
   probably too blunt). Decide + build next session.
2. **Planet bulk output (decision B).** Need a *regular colony's* minerals/energy (not the capital,
   which is uncapped & district-heavy) to decide whether to enable the reserved per-pop output nerf
   (`planet_miners_minerals` / `planet_technician_energy_produces_mult` −30% on `econ_space_primacy`).
3. **Mono-specialised mega-planets** (100%-research ecumenopoli) vs healthy specialization (forge
   world + a little food). Distinct design problem; housing cut doesn't solve it. Candidate
   directions: diminishing returns on stacking one designation, or amenity/upkeep penalties for
   zero-diversity builds. Parked.

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
| 6 | Amplify finite station techs | from +50% baseline upward (bounded) | tech override or new techs |
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
