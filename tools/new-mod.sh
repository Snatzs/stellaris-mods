#!/bin/bash
# Scaffold a new Stellaris mod with standard directory structure.
# Usage: bash tools/new-mod.sh <mod-name> [display-name]
#
# Arguments:
#   mod-name      — directory name (snake_case, e.g. "economy_overhaul")
#   display-name  — human-readable name for descriptor.mod (optional, defaults to mod-name)
#
# Example:
#   bash tools/new-mod.sh border_rework "Border Rework"

set -e

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MODS_DIR="$REPO_ROOT/mods"
GAME_VERSION="4.3"

if [ -z "$1" ]; then
	echo "Usage: bash tools/new-mod.sh <mod-name> [display-name]"
	echo ""
	echo "  mod-name      Directory name (snake_case)"
	echo "  display-name  Human-readable name (optional)"
	echo ""
	echo "Example: bash tools/new-mod.sh border_rework \"Border Rework\""
	exit 1
fi

MOD_NAME="$1"
DISPLAY_NAME="${2:-$MOD_NAME}"
MOD_DIR="$MODS_DIR/$MOD_NAME"

# Validate mod name (snake_case only)
if ! echo "$MOD_NAME" | grep -qE '^[a-z][a-z0-9_]*$'; then
	echo "Error: mod name must be snake_case (lowercase letters, digits, underscores)"
	exit 1
fi

# Check if mod already exists
if [ -d "$MOD_DIR" ]; then
	echo "Error: mod '$MOD_NAME' already exists at $MOD_DIR"
	exit 1
fi

echo "Creating mod: $DISPLAY_NAME ($MOD_NAME)"
echo ""

# Create directory structure
directories=(
	"common/buildings"
	"common/technologies"
	"common/traditions"
	"common/civics"
	"common/traits"
	"common/governments"
	"common/pop_jobs"
	"common/districts"
	"common/megastructures"
	"common/ship_sizes"
	"common/component_templates"
	"common/policies"
	"common/edicts"
	"common/decisions"
	"common/diplomatic_actions"
	"common/species_rights"
	"common/static_modifiers"
	"common/scripted_effects"
	"common/scripted_triggers"
	"common/scripted_variables"
	"common/on_actions"
	"events"
	"localisation/english"
	"gfx"
	"interface"
)

for dir in "${directories[@]}"; do
	mkdir -p "$MOD_DIR/$dir"
done

# Create descriptor.mod
cat > "$MOD_DIR/descriptor.mod" << EOF
name = "$DISPLAY_NAME"
path = "mod/$MOD_NAME"
supported_version = "$GAME_VERSION.*"
tags = {
	"Gameplay"
}
EOF

# Create localisation stub (UTF-8 with BOM)
loc_file="$MOD_DIR/localisation/english/${MOD_NAME}_l_english.yml"
printf '\xEF\xBB\xBF' > "$loc_file"
cat >> "$loc_file" << EOF
l_english:
 # Add localisation keys below
 # Format: KEY:0 "Displayed text"
EOF

# Create README
cat > "$MOD_DIR/README.md" << EOF
# $DISPLAY_NAME

## Overview

*Brief description of what this mod does.*

## Design Goals

*Which design vision pillars does this mod address? Reference \`docs/design-vision.md\`.*

## Changes

*List the specific gameplay changes this mod makes.*

## Compatibility

*Note any vanilla files overridden — and update \`docs/compatibility.md\`.*
EOF

echo "  Created directory structure"
echo "  Created descriptor.mod"
echo "  Created localisation stub"
echo "  Created README.md"
echo ""
echo "Mod scaffolded at: $MOD_DIR"
echo ""
echo "Next steps:"
echo "  1. Edit $MOD_DIR/README.md with mod details"
echo "  2. Update docs/compatibility.md if overriding vanilla files"
echo "  3. Run 'bash tools/validate.sh $MOD_NAME' to check for issues"
