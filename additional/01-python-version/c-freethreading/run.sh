#!/usr/bin/env bash
# Since 3.14 the GIL is officially optional (PEP 779). Same code, different scaling.
set -u
source "$(dirname "${BASH_SOURCE[0]}")/../../scripts/lib.sh"
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

for v in 3.12 3.13 3.14; do
    hdr "python$v — stock build, GIL on"
    if need_py "$v"; then
        run python"$v" "$HERE/threaded_sum.py"
    fi
done

hdr "python3.14t — free-threaded build, GIL off"
if need_py 3.14t; then
    run python3.14t "$HERE/threaded_sum.py"
else
    note "   this is the whole point of the demo — install it before the talk"
fi

moral "'python3.14' and 'python3.14t' are the same version and a different runtime.
   Threading goes from ~1x to ~Nx. Nothing in requirements.txt can express that."
