# Galaxy Setup

## Overview

Map/galaxy-generation tweaks for the 7-player MP campaign. Currently adds a **1200-star
galaxy size** above vanilla's max (Huge = 1000), to create more empty, contested frontier
**without** adding pops or empires.

## Design Goals

Pillars 1 & 2 (`docs/design-vision.md`) — **geography matters** and **scarcity drives
strategy**. More systems at a fixed empire count = larger frontier per empire = more
unclaimed space and chokepoints to fight over. Pairs with low habitable-world density so
the extra space is *empty* (territory to contest), not more colonizable land.

## Changes

- **New galaxy size "Colossal (1200 Stars)"** — `map/setup_scenarios/galaxy_setup_1200.txt`,
  a NEW additive setup_scenario (does NOT override vanilla `huge.txt`). Based on Huge:
  - `num_stars` 1000 → **1200** (+20% systems).
  - `radius` 450 → **495** — scaled by ~√1.2 so per-star spacing ≈ Huge (kept <500 per the
    vanilla radius warning). Breathing room comes from more systems at fixed empire count.
  - **Empire / fallen / marauder / nomad counts: IDENTICAL to Huge** (default 15 empires).
    Deliberately not raised — the whole point is more space per empire, and no extra AI load.
  - `colonizable_planet_odds` left at 1.0 — habitable density is the slider's job (see below).

## Why this is the cheap lag dimension

Late-game / MP slowdown is driven by **pops** (per-pop monthly recalculation), then empire
count, then fleets. Raw system count — especially *empty* systems — is comparatively cheap.
So +200 empty systems at a fixed empire count and a fixed habitable-world count adds
frontier with little perf cost. MP runs in lockstep (at the slowest player's CPU), so
late-game pop load is the real ceiling — which this does not raise. **Smoke-test for the
slowest player's framerate at late game before committing.**

## Recommended in-game settings (the host sets these — not part of the mod)

To get the intended planet-scarcity curve on top of this size:

- **Habitable Worlds: ~0.25x** (very low ambient density).
- **Guaranteed Habitable Worlds: 1–2** (a per-empire *floor*).

Low ambient density + a guaranteed floor approximates the desired **sub-linear** curve:
small empires get headroom from the floor; big empires don't drown in planets (each marginal
system adds little, and the engine can't make spawn density depend on empire size, so the
floor + low density is how you fake the anti-snowball shape). Rough model at ~0.05 habitable/
system + 2 guaranteed: 20-system empire ≈ 3 worlds, ~250-system (quarter-galaxy) ≈ 14–16.

## Compatibility

No vanilla files overridden — the scenario is purely additive (new file, new `name` loc key
`galaxy_setup_colossal`). Logged in `docs/compatibility.md`. Independent of `economy_overhaul`
and `migration_overhaul`.
