# Vanilla 4.3 Game Architecture Reference

These docs capture **how vanilla Stellaris 4.3 systems work at the modding level** — file locations, key modifiers/triggers/on_actions, how systems connect, and what's hardcoded.

**Purpose:** Save agents from re-researching the same vanilla files every session. Read the relevant file before starting work on a mod.

**This is NOT:**
- A modding syntax guide (that's `docs/wiki/`)
- A copy of vanilla balance numbers (read the game files directly at `D:\Stellaris\`)
- Exhaustive — only systems relevant to our design vision are documented

## Index

| You're working on... | Read |
|----------------------|------|
| Resource rebalancing, deposits, districts, space vs. planet economy | [economy.md](economy.md) |
| Claims, war goals, casus belli, war exhaustion, occupation | [warfare.md](warfare.md) |
| Opinion modifiers, ethics, federations, diplomatic actions | [diplomacy.md](diplomacy.md) |
| Slavery, species rights, pop categories, jobs, migration | [population.md](population.md) |

## Vanilla Game Files Location

Local install: `D:\Stellaris\`

Key directories mirror mod structure: `common/`, `events/`, `localisation/`, etc.

## Maintaining These Docs

**When to update an existing file:**
- You discover a new modifier, on_action, trigger, or effect relevant to that system while working on a mod
- You find that a documented modifier/path doesn't work as described (correct it)
- You discover a hardcoded limitation not yet documented (add it to the Limitations section)
- You find a workaround for a documented limitation (add it)

**When to create a new file:**
- You're working on a vanilla system not yet covered (e.g., technology tree, traditions, megastructures, espionage)
- Add the new file to the index table above AND to `docs/modding-reference.md` AND to the reference table in `CLAUDE.md`

**What NOT to add:**
- Vanilla balance numbers (those change and should be read from `D:\Stellaris\` directly)
- Full file contents or exhaustive lists
- Anything an agent can find with a single grep in under 5 seconds

**Format:** Follow the existing structure — file locations, key modifiers/identifiers, architecture notes, limitations, key files summary table. No prose.

## Version Note

All file paths, line numbers, and identifiers verified against Stellaris 4.3. If the game updates, re-verify against the new files.
