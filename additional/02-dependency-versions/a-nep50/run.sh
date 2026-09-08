#!/usr/bin/env bash
set -u
source "$(dirname "${BASH_SOURCE[0]}")/../../scripts/lib.sh"
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

bash "$HERE/run-manual.sh"
printf '\n%s%s%s\n' "$DIM" "────────── the same thing, without the venv bookkeeping ──────────" "$RST"
bash "$HERE/run-uv.sh"
