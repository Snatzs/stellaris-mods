#!/bin/bash
# Deploy this repo's mods to the Stellaris mod directory.
#
# For each mod under mods/, this creates the canonical local-mod layout INSIDE
# the Stellaris mod folder:
#   1. a directory link  mod/<name>      -> repo mods/<name>   (live, no copy)
#   2. a descriptor       mod/<name>.mod  with a RELATIVE path = "mod/<name>"
#
# Why not an absolute external path in the descriptor? The Stellaris engine
# registers such a mod (status ready_to_play) but does NOT actually load its
# content from an out-of-tree absolute path — verified via setup.log (June 2026).
# The content must live under the user mod dir; a directory junction puts it there
# while keeping the files in the repo (edits reflect live).
#
# On Windows the link is a junction (mklink /J) — works WITHOUT admin/Developer
# Mode (unlike symbolic links). On macOS/Linux it's a symlink.
#
# Target mod directory resolution (first match wins):
#   1. $STELLARIS_MOD_DIR              (env override — full path to the mod/ folder)
#   2. Irony Mod Manager's configured Stellaris UserDirectory + /mod
#   3. OS-default Paradox user directory + /mod (incl. OneDrive redirects)
#
# Usage:
#   bash tools/deploy.sh              # deploy all mods
#   bash tools/deploy.sh economy_overhaul   # deploy one mod

set -e

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MODS_DIR="$REPO_ROOT/mods"

# --- helpers -----------------------------------------------------------------

# Create a directory link  $2 (link) -> $1 (target).  Junction on Windows
# (no admin needed), symlink elsewhere. No-op if the link already exists.
make_dir_link() {
	local target="$1" link="$2"
	if [ -e "$link" ] || [ -L "$link" ]; then
		return 0
	fi
	if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" || "$OS" == "Windows_NT" ]]; then
		cmd //c mklink //J "$(cygpath -w "$link")" "$(cygpath -w "$target")" >/dev/null
	else
		ln -s "$target" "$link"
	fi
}

# Echo Irony's configured Stellaris UserDirectory (forward-slash form), or nothing.
read_irony_userdir() {
	local irony_dir db raw
	for irony_dir in \
		"$USERPROFILE/AppData/Roaming/Mario/IronyModManager" \
		"$APPDATA/Mario/IronyModManager" \
		"$HOME/.local/share/IronyModManager"; do
		[ -d "$irony_dir" ] || continue
		db=$(ls -1 "$irony_dir"/Database_*.json 2>/dev/null | sort -V | tail -1)
		[ -n "$db" ] || continue
		# UserDirectory is the last key of the Stellaris GameSettings object and
		# directly follows "Type":"Stellaris" — so it's unambiguous vs. other games.
		raw=$(sed -n 's/.*"Type":"Stellaris","UserDirectory":"\([^"]*\)".*/\1/p' "$db")
		[ -n "$raw" ] || continue
		# JSON escapes path separators as "\\"; normalise to single forward slashes.
		printf '%s' "$raw" | tr '\134' '/' | sed 's#/\{2,\}#/#g'
		return 0
	done
	return 1
}

# --- resolve target mod directory --------------------------------------------

IRONY_USERDIR=""
if [ -n "$STELLARIS_MOD_DIR" ]; then
	MOD_DIR="$STELLARIS_MOD_DIR"
	SRC="env override (\$STELLARIS_MOD_DIR)"
elif IRONY_USERDIR="$(read_irony_userdir)"; then
	MOD_DIR="$IRONY_USERDIR/mod"
	SRC="Irony UserDirectory ($IRONY_USERDIR)"
else
	if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" || "$OS" == "Windows_NT" ]]; then
		DEF=""
		for base in \
			"$USERPROFILE/Documents/Paradox Interactive/Stellaris" \
			"$USERPROFILE/OneDrive/Documents/Paradox Interactive/Stellaris" \
			"$USERPROFILE/OneDrive/Documentos/Paradox Interactive/Stellaris"; do
			if [ -d "$base" ]; then DEF="$base"; break; fi
		done
		MOD_DIR="${DEF:-$USERPROFILE/Documents/Paradox Interactive/Stellaris}/mod"
	elif [[ "$OSTYPE" == "darwin"* ]]; then
		MOD_DIR="$HOME/Documents/Paradox Interactive/Stellaris/mod"
	else
		MOD_DIR="$HOME/.local/share/Paradox Interactive/Stellaris/mod"
	fi
	SRC="OS default"
fi

echo "Target mod directory: $MOD_DIR"
echo "  (resolved via: $SRC)"
echo "Repository mods:      $MODS_DIR"
echo ""

mkdir -p "$MOD_DIR"

if [ ! -d "$MODS_DIR" ] || [ -z "$(ls -A "$MODS_DIR" 2>/dev/null)" ]; then
	echo "No mods found in $MODS_DIR"
	exit 0
fi

# --- deploy ------------------------------------------------------------------

ONLY="$1"
deployed=0
for mod_dir in "$MODS_DIR"/*/; do
	mod_name=$(basename "$mod_dir")
	if [ -n "$ONLY" ] && [ "$ONLY" != "$mod_name" ]; then continue; fi

	desc="$mod_dir/descriptor.mod"
	if [ ! -f "$desc" ]; then
		echo "  [skip] $mod_name — no descriptor.mod"
		continue
	fi

	src="$(cd "$mod_dir" && pwd)"
	link="$MOD_DIR/$mod_name"
	target="$MOD_DIR/$mod_name.mod"
	rel="mod/$mod_name"

	# 1. Link the content into the mod dir (junction/symlink, live).
	make_dir_link "$src" "$link"
	# 2. Write the descriptor with a relative path the engine will load.
	sed "s#^[[:space:]]*path[[:space:]]*=.*#path=\"$rel\"#" "$desc" > "$target"
	grep -q '^path=' "$target" || printf 'path="%s"\n' "$rel" >> "$target"

	if [ -e "$link" ]; then
		echo "  [done] $mod_name -> $target  (path=\"$rel\", linked content present)"
	else
		echo "  [WARN] $mod_name — descriptor written but link missing ($link); content may not load"
	fi
	deployed=$((deployed + 1))
done

echo ""
if [ "$deployed" -eq 0 ]; then
	echo "Nothing deployed${ONLY:+ (no mod named \"$ONLY\")}."
else
	echo "Deployed $deployed mod descriptor(s) (linked content + relative descriptor)."
	echo "Next: enable in your launcher/Irony collection (first time only), then Launch."
fi
