#!/usr/bin/env bash
set -euo pipefail

# Default: run doorstop with whatever args were passed
exec doorstop "$@"
