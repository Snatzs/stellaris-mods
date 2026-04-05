#!/bin/bash
# Deploy all mods to the Stellaris mod directory.
# Usage: bash tools/deploy.sh
#
# This creates symlinks from the Stellaris mod folder to each mod in this repo,
# so changes in the repo are immediately reflected in-game.

set -e

# Detect OS and set Stellaris mod directory
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" || "$OS" == "Windows_NT" ]]; then
	STELLARIS_MOD_DIR="$USERPROFILE/Documents/Paradox Interactive/Stellaris/mod"
elif [[ "$OSTYPE" == "darwin"* ]]; then
	STELLARIS_MOD_DIR="$HOME/Documents/Paradox Interactive/Stellaris/mod"
else
	STELLARIS_MOD_DIR="$HOME/.local/share/Paradox Interactive/Stellaris/mod"
fi

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MODS_DIR="$REPO_ROOT/mods"

echo "Stellaris mod directory: $STELLARIS_MOD_DIR"
echo "Repository mods directory: $MODS_DIR"
echo ""

# Create Stellaris mod directory if it doesn't exist
mkdir -p "$STELLARIS_MOD_DIR"

# Check if any mods exist
if [ ! -d "$MODS_DIR" ] || [ -z "$(ls -A "$MODS_DIR" 2>/dev/null)" ]; then
	echo "No mods found in $MODS_DIR"
	exit 0
fi

# Deploy each mod
for mod_dir in "$MODS_DIR"/*/; do
	mod_name=$(basename "$mod_dir")
	target="$STELLARIS_MOD_DIR/$mod_name"

	if [ -L "$target" ]; then
		echo "  [skip] $mod_name — symlink already exists"
	elif [ -d "$target" ]; then
		echo "  [WARN] $mod_name — directory already exists (not a symlink). Skipping."
	else
		if [[ "$OS" == "Windows_NT" ]]; then
			# Windows: use mklink (requires running as admin or developer mode)
			cmd //c "mklink /D \"$(cygpath -w "$target")\" \"$(cygpath -w "$mod_dir")\"" > /dev/null 2>&1 && \
				echo "  [done] $mod_name" || \
				echo "  [FAIL] $mod_name — try running as administrator or enable Developer Mode"
		else
			ln -s "$mod_dir" "$target"
			echo "  [done] $mod_name"
		fi
	fi
done

echo ""
echo "Deployment complete. Restart Stellaris launcher to see changes."
