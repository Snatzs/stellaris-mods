# Stellaris Mods

A collection of custom Stellaris mods developed for a 7-player multiplayer campaign.

## Project Overview

This repository contains multiple Stellaris mods designed to work together. The mods are primarily developed using AI coding agents (Claude Code, Codex) with human oversight and review.

**Game version target:** Stellaris 4.3

**Players:** 7 (3 developers + 4 players)

## Repository Structure

```
stellaris-mods/
├── CLAUDE.md              # AI agent instructions and conventions
├── docs/                  # Shared research, references, and design docs
│   ├── design-vision.md   # Design goals and planned changes (read first)
│   ├── ROADMAP.md         # What's done, in progress, and still to do
│   ├── wiki/              # Local Stellaris wiki modding references
│   ├── modding-reference.md
│   ├── multiplayer-balance.md
│   └── compatibility.md
├── mods/                  # All mod projects
│   └── <mod-name>/        # Each mod follows standard Stellaris structure
│       ├── descriptor.mod
│       ├── README.md
│       └── common/, events/, localisation/, etc.
├── tools/                 # Helper scripts (deploy, validate, etc.)
└── .github/               # PR templates, CI workflows
```

## Getting Started

### Prerequisites

- Stellaris (same version as the group)
- Git
- GitHub account with repo access

### Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/Snatzs/stellaris-mods.git
   ```

2. Deploy mods to your Stellaris mod folder:
   ```bash
   # Windows — run from repo root
   bash tools/deploy.sh
   ```

3. Launch Stellaris and enable the mods in the launcher.

### Creating a New Mod

1. Create a new folder under `mods/` with your mod name (kebab-case).
2. Add a `descriptor.mod` file (see existing mods for template).
3. Add a `README.md` describing the mod's purpose and design.
4. Follow standard Stellaris mod folder structure inside your mod folder.

## Contributing

- Create a feature branch for your work (`feature/mod-name-description`).
- Open a PR for review before merging to `master`.
- `master` branch should always be playable — test before merging.
- Update `docs/compatibility.md` if your mod overrides vanilla files.

## Developers

- **Snatzs**
- **AttiiK**
- **manzano5**
- **AI agents** — Claude Code, Codex (primary development)
