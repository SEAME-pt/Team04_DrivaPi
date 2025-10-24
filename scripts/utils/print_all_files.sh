#!/usr/bin/env bash
# Print every file's name and content recursively, excluding .venv and other
# common directories. Safe by default: run with --dry-run to only list files.
set -euo pipefail

OUT_MAX_LINES=200
DRY_RUN=0
SHOW_PATTERNS=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=1; shift ;;
    --max-lines) OUT_MAX_LINES="$2"; shift 2 ;;
    --show) SHOW_PATTERNS+=("$2"); shift 2 ;;
    --help) echo "Usage: $0 [--dry-run] [--max-lines N] [--show <glob>] [<path>]"; exit 0 ;;
    *) TARGET_DIR="$1"; shift ;;
  esac
done

TARGET_DIR=${TARGET_DIR:-.}

# Directories to exclude
EXCLUDES=(".venv" ".git")

EXPR=( )
for e in "${EXCLUDES[@]}"; do
  EXPR+=( -path "./${e}" -prune -o )
done
EXPR+=( -type f -print )


if [[ "$DRY_RUN" -eq 1 ]]; then
  echo "Dry-run: listing files under $TARGET_DIR (excluding: ${EXCLUDES[*]})"
  # list file names only using find with -prune
  find "$TARGET_DIR" "${EXPR[@]}" | sort
  exit 0
fi

if [[ ${#SHOW_PATTERNS[@]} -eq 0 ]]; then
  echo "Listing files under $TARGET_DIR (excluding: ${EXCLUDES[*]})."
  echo "Note: file contents are suppressed by default. Use --show '<glob>' to include contents for matching files."
else
  echo "Printing files under $TARGET_DIR (excluding: ${EXCLUDES[*]}). Max lines per file: $OUT_MAX_LINES"
  echo "Showing contents for patterns: ${SHOW_PATTERNS[*]}"
fi

# Collect files with null delimiter into an array (portable)
files=()
while IFS= read -r -d '' f; do
  files+=("$f")
done < <(find "$TARGET_DIR" "${EXPR[@]}" -print0)

# Sort file paths (safe for filenames with newlines) and iterate
IFS=$'\n'
sorted=( $(printf '%s\n' "${files[@]}" | sort) )
for file in "${sorted[@]}"; do
  printf '\n=== %s ===\n' "$file"

  # If user did not opt-in to show contents, display a suppression notice
  show_this=0
  if [[ ${#SHOW_PATTERNS[@]} -gt 0 ]]; then
    # Convert file path to a relative path without leading ./ for matching
    relpath="${file#./}"
    for pat in "${SHOW_PATTERNS[@]}"; do
      case "$relpath" in
        $pat) show_this=1; break ;;
      esac
    done
  fi

  if [[ $show_this -eq 0 ]]; then
    echo "[contents suppressed; use --show '<glob>' to include]"
    continue
  fi

  # show file type and skip large binary files heuristically
  if file --mime-type "$file" | grep -qE '^(.*):(.*)binary'; then
    echo "[binary file skipped]"
    continue
  fi

  # print at most OUT_MAX_LINES lines (use sed for portability)
  if [[ "$OUT_MAX_LINES" -eq 0 ]]; then
    # unlimited: stream full file through redaction
    # Use perl to redact common secret patterns conservatively
    perl -0777 -pe '
      s/-----BEGIN [^-]+-----[\s\S]*?-----END [^-]+-----/REDACTED PRIVATE KEY\n/g;
      s/AKIA[0-9A-Z]{16}/REDACTED_AWS_ACCESS_KEY/g;
      s/AIza[0-9A-Za-z_\-]{35}/REDACTED_GOOGLE_API_KEY/g;
      s/(?:aws_access_key_id|AWS_ACCESS_KEY_ID)\s*[=:]\s*\S+/REDACTED_AWS_ACCESS_KEY/g;
      s/(?:aws_secret_access_key|AWS_SECRET_ACCESS_KEY)\s*[=:]\s*\S+/REDACTED_AWS_SECRET/g;
      s/[A-Za-z0-9_\-]{40}/REDACTED_TOKEN/g;
      s/(?:BEGIN PUBLIC KEY|BEGIN RSA PRIVATE KEY|BEGIN PRIVATE KEY)/REDACTED KEY/g;
    ' "$file" || true
  else
    sed -n "1,${OUT_MAX_LINES}p" "$file" | perl -pe '
      s/AKIA[0-9A-Z]{16}/REDACTED_AWS_ACCESS_KEY/g;
      s/AIza[0-9A-Za-z_\-]{35}/REDACTED_GOOGLE_API_KEY/g;
      s/(?:aws_access_key_id|AWS_ACCESS_KEY_ID)\s*[=:]\s*\S+/REDACTED_AWS_ACCESS_KEY/g;
      s/(?:aws_secret_access_key|AWS_SECRET_ACCESS_KEY)\s*[=:]\s*\S+/REDACTED_AWS_SECRET/g;
      s/[A-Za-z0-9_\-]{40}/REDACTED_TOKEN/g;
    '
  fi
done

echo "\nDone. Printed up to $OUT_MAX_LINES lines for each file."
