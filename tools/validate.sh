#!/bin/bash
# Validate Stellaris mod files for common errors.
# Usage: bash tools/validate.sh [mod-name]
#
# Checks:
#   1. Bracket matching in script files (.txt, .mod)
#   2. Missing localisation keys (keys referenced in script but not defined in localisation)
#   3. descriptor.mod presence and basic format
#
# If mod-name is given, validates only that mod. Otherwise validates all mods.

set -e

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MODS_DIR="$REPO_ROOT/mods"

errors=0
warnings=0

# Colors (disabled if not a terminal)
if [ -t 1 ]; then
	RED='\033[0;31m'
	YELLOW='\033[0;33m'
	GREEN='\033[0;32m'
	NC='\033[0m'
else
	RED=''
	YELLOW=''
	GREEN=''
	NC=''
fi

error() {
	echo -e "${RED}  [ERROR] $1${NC}"
	errors=$((errors + 1))
}

warn() {
	echo -e "${YELLOW}  [WARN]  $1${NC}"
	warnings=$((warnings + 1))
}

ok() {
	echo -e "${GREEN}  [OK]    $1${NC}"
}

# --- Check 1: Bracket matching ---
check_brackets() {
	local file="$1"
	local rel_path="${file#$REPO_ROOT/}"

	# Count opening and closing braces
	local open close
	open=$(grep -o '{' "$file" 2>/dev/null | wc -l)
	close=$(grep -o '}' "$file" 2>/dev/null | wc -l)

	if [ "$open" -ne "$close" ]; then
		error "$rel_path — mismatched brackets: $open '{' vs $close '}'"
		return 1
	fi
	return 0
}

# --- Check 2: Missing localisation keys ---
# Collects keys used in script files and checks they exist in localisation files.
check_localisation() {
	local mod_dir="$1"
	local mod_name="$2"

	# Find all localisation files and extract defined keys
	local loc_dir="$mod_dir/localisation"
	local defined_keys=""

	if [ -d "$loc_dir" ]; then
		# Extract keys from localisation files (format: KEY:0 "value")
		defined_keys=$(grep -rh '^ *[A-Za-z_][A-Za-z_0-9.]*:[0-9]' "$loc_dir" 2>/dev/null \
			| sed 's/^ *\([A-Za-z_][A-Za-z_0-9.]*\):.*/\1/' | sort -u)
	fi

	# Find keys referenced in script files via common patterns:
	#   name = "key"  /  title = "key"  /  desc = "key"  /  custom_tooltip = "key"
	local script_keys=""
	script_keys=$(grep -rEoh '(name|title|desc|custom_tooltip|tooltip|text)\s*=\s*"?([A-Za-z_][A-Za-z_0-9.]*)"?' \
		"$mod_dir/common" "$mod_dir/events" 2>/dev/null \
		| grep -oE '"[A-Za-z_][A-Za-z_0-9.]*"' \
		| tr -d '"' | sort -u)

	if [ -z "$script_keys" ]; then
		return 0
	fi

	if [ ! -d "$loc_dir" ]; then
		warn "$mod_name — has script files referencing localisation keys but no localisation/ directory"
		return 0
	fi

	local missing=0
	for key in $script_keys; do
		if ! echo "$defined_keys" | grep -qx "$key"; then
			warn "$mod_name — localisation key '$key' referenced in scripts but not defined"
			missing=$((missing + 1))
		fi
	done

	if [ "$missing" -eq 0 ]; then
		ok "$mod_name — all referenced localisation keys are defined"
	fi
}

# --- Check 3: descriptor.mod ---
check_descriptor() {
	local mod_dir="$1"
	local mod_name="$2"
	local descriptor="$mod_dir/descriptor.mod"

	if [ ! -f "$descriptor" ]; then
		error "$mod_name — missing descriptor.mod"
		return 1
	fi

	# Check required fields
	if ! grep -q '^name\s*=' "$descriptor"; then
		error "$mod_name/descriptor.mod — missing 'name' field"
	fi
	if ! grep -q '^supported_version\s*=' "$descriptor"; then
		error "$mod_name/descriptor.mod — missing 'supported_version' field"
	fi
	if ! grep -q '^path\s*=' "$descriptor"; then
		warn "$mod_name/descriptor.mod — missing 'path' field"
	fi

	ok "$mod_name — descriptor.mod present"
}

# --- Main ---

# Determine which mods to validate
if [ -n "$1" ]; then
	if [ ! -d "$MODS_DIR/$1" ]; then
		echo "Error: mod '$1' not found in $MODS_DIR"
		exit 1
	fi
	mod_dirs=("$MODS_DIR/$1")
else
	mod_dirs=()
	if [ -d "$MODS_DIR" ]; then
		for d in "$MODS_DIR"/*/; do
			[ -d "$d" ] && mod_dirs+=("$d")
		done
	fi
fi

if [ ${#mod_dirs[@]} -eq 0 ]; then
	echo "No mods found in $MODS_DIR"
	exit 0
fi

for mod_dir in "${mod_dirs[@]}"; do
	mod_name=$(basename "$mod_dir")
	echo ""
	echo "=== Validating: $mod_name ==="

	# Check descriptor
	check_descriptor "$mod_dir" "$mod_name"

	# Check brackets in all script files
	bracket_ok=0
	bracket_total=0
	while IFS= read -r -d '' file; do
		bracket_total=$((bracket_total + 1))
		check_brackets "$file" || true
	done < <(find "$mod_dir" -type f \( -name '*.txt' -o -name '*.mod' \) -print0 2>/dev/null)

	if [ "$bracket_total" -gt 0 ]; then
		ok "$mod_name — checked $bracket_total script files for bracket matching"
	fi

	# Check localisation
	check_localisation "$mod_dir" "$mod_name"
done

# Summary
echo ""
echo "================================"
if [ "$errors" -gt 0 ]; then
	echo -e "${RED}Validation failed: $errors error(s), $warnings warning(s)${NC}"
	exit 1
elif [ "$warnings" -gt 0 ]; then
	echo -e "${YELLOW}Validation passed with $warnings warning(s)${NC}"
	exit 0
else
	echo -e "${GREEN}Validation passed — no issues found${NC}"
	exit 0
fi
