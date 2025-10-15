#!/usr/bin/env bash
# Helper for common trudag + git tasks (non-destructive)
set -euo pipefail

cmd="$1" || true

case "$cmd" in
  lint)
    echo "Running trudag manage lint..."
    trudag manage lint
    ;;
  status)
    echo "Showing git status and listing reqs files"
    git status --short || true
    ls -R reqs || true
    ;;
  baseline)
    echo "Preparing baseline. Make sure all reviewed fields are set and changes are committed."
    echo "You will be prompted for tag name and message."
    read -rp "Tag name (e.g. BASELINE-SWD-V1.0): " TAG
    read -rp "Tag message: " MSG
    git tag -a "$TAG" -m "$MSG"
    echo "Tag $TAG created locally. Push with: git push origin $TAG"
    ;;
  *)
    echo "Usage: $0 {lint|status|baseline}"
    exit 2
    ;;
esac
