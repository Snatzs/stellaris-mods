# Vanilla 4.4 — Situations System Architecture

> Verified against Stellaris 4.4.3 (Pegasus). Source of truth: `common/situations/99_README_SITUATIONS.txt` (Paradox's own in-file docs) + 20 live situation files in `common/situations/`.
>
> Situations track ongoing, stateful "stories" in an empire (planetary revolt, a starbase falling into a black hole, a resource deficit) via a progress bar with stages, player-selectable approaches, and recurring events. Reach for a Situation instead of a bare event chain when the mechanic is **stateful, multi-stage, player-steerable, and wants a UI presence.**

## Anatomy

A situation always has:
- a **TARGET** — typically a single **colony carrier** (a planet/colony) or the whole **country**, or no target. Targeting a colony carrier is the normal case for planet-scoped mechanics. *Targeting other scope types breaks `target_modifier` / `triggered_target_modifier` — target with caution.*
- a **PROGRESS BAR** (0 → completion), split into one or more **STAGES**.
- one or more **APPROACHES** (how the player interacts).
- monthly **EVENTS** (fixed and/or random).
- one or two **ENDINGS** (progress hits 0 → `on_fail`; hits completion → `on_progress_complete`).

**Scope rule:** inside a situation `this`/`root` = the situation; `owner` = the country; `target` = the target.

## Key fields

| Field | Purpose |
|---|---|
| `potential` | (country scope) whether a country can hold the situation; removed silently if it stops being true (no `on_abort`) |
| `abort_trigger` / `on_abort` | cancel + cleanup path |
| `on_start` | effects when created |
| `on_progress_complete` / `on_fail` | the two endings — **must call `destroy_situation = this`** (here or from an event they fire) |
| `permanent = yes/no` | if yes, does not auto-end at the extremes (finish manually) |
| `modifier` / `triggered_modifier` | applies to the country holding the situation |
| `target_modifier` / `triggered_target_modifier` | applies to the **target colony carrier** (only valid when target is a colony carrier) |
| `start_value` / `initial_progress` | progress floor and starting value (set `initial_progress` from a computed score to tilt the opening state) |
| `progress_direction` | `monodirectional` / `bidirectional`. **Bidirectional** = start mid-bar, two contrasting goals (one ending at each end) — ideal for a two-sided tug-of-war |
| `complete_category` / `fail_category` | tone (positive/negative) per direction, bidirectional only |

### Stages
`stages = { <key> = { … } }`, in order; at least one. Each: `icon`, `background`, `color`, `end` (value where it hands off / sets the situation's max), `on_first_enter`, `on_enter`, per-stage `modifier`/`triggered_modifier`/`target_modifier`, `custom_tooltip`.

### Monthly progress
`monthly_progress = { base = <n> modifier = { add = <n> desc = <loc_key> <triggers> } }` — standard weighted script-value fields (per `common/script_values/`). **Every `add` needs a loc tooltip or the game errors.**

### Approaches
`approach = { … }` — the player's strategic choice:
- `name` (localised), `icon`, `icon_background`
- `potential` (hide if false), `allow` (grey out if false)
- `on_select` (effect on pick)
- `default = yes` (auto-selected at start / when the current approach is invalidated — does **not** happen while the situation is locked)
- per-approach `modifier`/`triggered_modifier`/`target_modifier`
- `resources = { category = situations cost/upkeep/produces = {…} }`
- `ai_weight` — **AI picks the highest-weight approach** (so AI empires handle the situation autonomously)

**Forcing a choice:** `set_situation_locked` in `on_start`/`immediate` locks the situation (prevents default auto-pick), then an event presents the approaches and unlocks in `after`.

### Events
`on_monthly = { events = {…} random_events = {…} }` — this is an on_action named after the situation (so **don't** name a situation `on_monthly_pulse`). Events that change the situation (e.g. add progress) should put their effects in `immediate = {}` so players can't dodge outcomes by leaving them unopened; use `tooltip = {}` in options to regenerate tooltips.

## Effects & creation
- `start_situation` (tooltip uses the `<key>_type` loc string, since the situation doesn't exist yet)
- `destroy_situation = this`, `set_situation_locked`, situation progress effects
- Loc keys required: `<key>`, `<key>_type`, `<key>_desc`, `<key>_monthly_change_tooltip`.

## MP / determinism notes
- `on_monthly` is an on_action, not `mean_time_to_happen` — **MP-safe** by construction.
- Use deterministic progress inputs; for any randomness prefer `random_list` / `create_balanced_fleet` over weighted-random effects.
- AI empires can be situation targets — useful to simulate complex AI behaviour (e.g. Overlord mercenary enclaves use a hidden situation).

## Limitations
- One target per situation; a planet has one owner — multi-faction conflicts must be modelled with temporary event-countries + armies, not multiple situation targets.
- `target_modifier` only works for colony-carrier targets.
- Loc-tooltip strictness: missing `desc`/`monthly_change_tooltip`/progress-`add` tooltips throw errors.

## Key Files Summary

| Item | Path |
|---|---|
| In-file documentation (authoritative) | `common/situations/99_README_SITUATIONS.txt` |
| Vanilla examples (20 files) | `common/situations/` (e.g. `02_deficit_situations.txt`, `01_narrative_situations.txt`, `01_overlord_situations.txt`) |
| Used by | the ethnic-civil-war mod design — `docs/ethnic-civil-war-design.md` |
