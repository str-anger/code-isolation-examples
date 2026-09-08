#!/usr/bin/env bash
# The same experiment as run-manual.sh, minus the venv bookkeeping.
set -u
source "$(dirname "${BASH_SOURCE[0]}")/../../scripts/lib.sh"
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if ! have uv; then
    warn "uv not installed — see run-manual.sh for the long-hand version"
    exit 0
fi

hdr "numpy 1.26.4"
run uv run --quiet --python 3.12 --with "numpy==1.26.4" "$HERE/promotion.py"

hdr "numpy 2.3.5"
run uv run --quiet --python 3.12 --with "numpy==2.3.5" "$HERE/promotion.py"

hdr "Accumulator precision, both versions"
run uv run --quiet --python 3.12 --with "numpy==1.26.4" "$HERE/sum_precision.py"
run uv run --quiet --python 3.12 --with "numpy==2.3.5" "$HERE/sum_precision.py"

moral "This is where uv earns its place: throwaway environments per experiment, no venv
   to name, activate, forget about, or accidentally reuse next month."
