#!/usr/bin/env bash
# Usage: find-untagged-tests.sh <repo-path>
#
# Scans all *.test.ts, *.test.tsx, *.spec.ts, *.spec.tsx files under <repo-path>
# and prints every it() whose description has no [...] tag — neither a spec ID
# like [MAP-GOTO-01] nor an [UNKNOWN-TEST-CASE-N] marker.
#
# Output:
#   path/to/file.test.tsx
#     39: it('should do something', () => {
#     52: it('should do something else', () => {

set -euo pipefail

REPO="${1:-.}"

cd "$REPO"

while IFS= read -r file; do
  matches=$(awk '
    /^[ \t]*it\.each/ { each_next = 1; next }
    each_next {
      each_next = 0
      if ($0 !~ /\[/) print NR ": " $0
      next
    }
    /^[ \t]*it[(]/ {
      if ($0 !~ /\[/) print NR ": " $0
    }
  ' "$file")

  if [ -n "$matches" ]; then
    echo "$file"
    while IFS= read -r line; do
      echo "  $line"
    done <<< "$matches"
    echo
  fi
done < <(
  find . \
    \( -name "*.test.ts" -o -name "*.test.tsx" -o -name "*.spec.ts" -o -name "*.spec.tsx" \) \
    -not -path "*/node_modules/*" \
  | sort
)
