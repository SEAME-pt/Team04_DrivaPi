#!/usr/bin/env bash

# Print every file in the repository (recursively) with a title and the file's content.
# Excludes `.venv` and `.git` directories. For binary/non-text files prints a notice instead
# of raw binary data.

set -euo pipefail
IFS=$'\n\t'

TEXT_ONLY=0
ROOT=.

# Simple arg parsing: --text-only|-t, --help|-h, optional root path
while [ "$#" -gt 0 ]; do
  case "$1" in
    --text-only|-t)
      TEXT_ONLY=1
      shift
      ;;
    --help|-h)
      cat <<'USAGE'
Usage: print_all_files.sh [--text-only|-t] [path]

If --text-only is provided, the script will print full contents only for text files.
For binary/non-text files it will print the title and a short "BINARY FILE" message.
If no path is provided the current directory is used.
USAGE
      exit 0
      ;;
    *)
      ROOT="$1"
      shift
      ;;
  esac
done

if [ ! -d "$ROOT" ] && [ ! -f "$ROOT" ]; then
  printf 'Provided path does not exist: %s\n' "$ROOT" >&2
  exit 2
fi

printf '# Repo files printout generated: %s\n' "$(date --iso-8601=seconds 2>/dev/null || date)"

# Find files, excluding .venv and .git. Use -print0 to safely handle special filenames.
find "$ROOT" \
  \( -path '*/.venv' -o -path '*/.venv/*' -o -path '*/.git' -o -path '*/.git/*' \) -prune -false -o -type f -print0 |
while IFS= read -r -d '' file; do
  # Print a clear title/header for each file
  printf '\n=== FILE: %s ===\n' "$file"

  # If the file is an SVG, treat it as omitted per user request (do not print its XML contents).
  # Lowercase filename for portable extension check (macOS / older bash don't support ${var,,}).
  lowercase_file="$(printf '%s' "$file" | tr '[:upper:]' '[:lower:]')"
  case "$lowercase_file" in
    *.svg)
      size="$(stat -f '%z bytes' "$file" 2>/dev/null || stat -c '%s bytes' "$file" 2>/dev/null || '')"
      if [ "$TEXT_ONLY" -eq 1 ]; then
        printf '%s\n' "---- SVG FILE ($size) OMITTED ----"
      else
        printf '[svg file omitted]\n'
      fi
      continue
      ;;
  esac

  # Detect if file is probably text. grep -Iq returns 0 for text, 1 for binary/non-text.
  if LC_ALL=C grep -Iq . -- "$file" 2>/dev/null; then
    # Text file: print full content
    size="$(stat -f '%z bytes' "$file" 2>/dev/null || stat -c '%s bytes' "$file" 2>/dev/null || '')"
    printf '%s\n' "---- CONTENT START ($size) ----"
    if ! cat -- "$file"; then
      printf '\n[error reading file: %s]\n' "$file" >&2
    fi
    printf '%s\n' "---- CONTENT END ($file) ----"
  else
    # Binary or non-text file
    if [ "$TEXT_ONLY" -eq 1 ]; then
      # Print only header and a short BINARY message
      size="$(stat -f '%z bytes' "$file" 2>/dev/null || stat -c '%s bytes' "$file" 2>/dev/null || '')"
      printf '%s\n' "---- BINARY FILE ($size) ----"
    else
      printf '[binary or non-text file omitted]\n'
    fi
  fi
done

exit 0
