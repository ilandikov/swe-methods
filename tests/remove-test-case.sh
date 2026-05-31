#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: $0 --id <ID> --spec <spec-repo> --target <target-repo>"
  echo "Example: $0 --id LOCATION-CREATE-03 --spec ~/repos/linkup-docs --target ~/repos/linkup-web"
  exit 1
}

# Parse args
ID="" SPEC="" TARGET=""
while [[ $# -gt 0 ]]; do
  case $1 in
    --id)     ID="$2";     shift 2 ;;
    --spec)   SPEC="$2";   shift 2 ;;
    --target) TARGET="$2"; shift 2 ;;
    *) usage ;;
  esac
done

[[ -z "$ID" || -z "$SPEC" || -z "$TARGET" ]] && usage

# Extract prefix (e.g. LOCATION-CREATE-03 → LOCATION-CREATE)
PREFIX="${ID%-*}"

# Check 1: ID must NOT exist anywhere in spec repo
FOUND_IN_SPEC=$(grep -rl "$ID" "$SPEC" --include="*.md" 2>/dev/null || true)
if [[ -n "$FOUND_IN_SPEC" ]]; then
  echo "Error: \"$ID\" still mentioned in spec repo:"
  echo "$FOUND_IN_SPEC"
  echo "Remove it manually from the spec first, then re-run this script."
  exit 1
fi

# Check 2: ID must NOT exist in test files in target repo
FOUND_IN_TESTS=$(grep -rl "\[$ID\]" "$TARGET" \
  --include="*.test.ts" --include="*.test.tsx" --include="*.test.js" \
  --include="*.spec.ts" --include="*.spec.tsx" --include="*.spec.js" \
  2>/dev/null || true)
if [[ -n "$FOUND_IN_TESTS" ]]; then
  echo "Error: \"$ID\" is still referenced in tests:"
  echo "$FOUND_IN_TESTS"
  echo "Remove it from the test file first, then re-run this script."
  exit 1
fi

echo "\"$ID\" is gone from both spec and tests. Renumbering group ${PREFIX}..."

# Collect all IDs in the group from spec repo, sorted numerically by suffix
mapfile -t ALL_IDS < <(grep -roh "${PREFIX}-[0-9]\+" "$SPEC" --include="*.md" 2>/dev/null | sort -V | uniq)

# Build rename pairs: close gaps left by the removed ID
declare -a OLD_IDS=()
declare -a NEW_IDS=()
counter=1
for current in "${ALL_IDS[@]}"; do
  new_num=$(printf "%02d" "$counter")
  new_id="${PREFIX}-${new_num}"
  if [[ "$current" != "$new_id" ]]; then
    OLD_IDS+=("$current")
    NEW_IDS+=("$new_id")
  fi
  ((counter++)) || true
done

if [[ ${#OLD_IDS[@]} -eq 0 ]]; then
  echo "No renumbering needed."
  exit 0
fi

# Rename IDs in a file using two passes to prevent cascading substitutions:
# pass 1 replaces each old ID with a unique placeholder,
# pass 2 replaces placeholders with the final new IDs.
rename_in_file() {
  local file="$1"
  local changed=false

  for ((i=0; i<${#OLD_IDS[@]}; i++)); do
    if grep -qF "${OLD_IDS[$i]}" "$file"; then
      sed -i '' "s/${OLD_IDS[$i]}/__TCTEMP${i}__/g" "$file"
      changed=true
    fi
  done

  if $changed; then
    for ((i=0; i<${#OLD_IDS[@]}; i++)); do
      sed -i '' "s/__TCTEMP${i}__/${NEW_IDS[$i]}/g" "$file"
    done
    echo "  Updated: $file"
    return 0
  fi
  return 1
}

# Rename in spec repo
while IFS= read -r -d '' file; do
  rename_in_file "$file" || true
done < <(find "$SPEC" -not -path "*/.git/*" -name "*.md" -print0)

echo "Renumbered ${#OLD_IDS[@]} IDs in spec."

# Rename in target repo test files
RENAMED_FILES=0
while IFS= read -r -d '' file; do
  if rename_in_file "$file"; then
    RENAMED_FILES=$((RENAMED_FILES + 1))
  fi
done < <(find "$TARGET" \
  -not -path "*/node_modules/*" \
  -not -path "*/.git/*" \
  \( -name "*.test.ts" -o -name "*.test.tsx" -o -name "*.test.js" \
     -o -name "*.spec.ts" -o -name "*.spec.tsx" -o -name "*.spec.js" \) \
  -print0)

echo "Updated $RENAMED_FILES test file(s)."
