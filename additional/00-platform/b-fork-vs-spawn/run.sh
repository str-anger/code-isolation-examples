#!/usr/bin/env bash
# The default multiprocessing start method varies by OS *and* by Python version.
set -u
source "$(dirname "${BASH_SOURCE[0]}")/../../scripts/lib.sh"
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

hdr "macOS, python3.13 — default is 'spawn'"
if need_py 3.13; then
    run python3.13 "$HERE/shared_state.py"
fi

hdr "macOS, python3.14 — still 'spawn'"
if need_py 3.14; then
    run python3.14 "$HERE/shared_state.py"
fi

hdr "linux/arm64, python3.13 — default is 'fork'"
runsh "docker run --rm --platform linux/arm64 -v '$HERE':/demo:ro python:3.13-slim python /demo/shared_state.py"

hdr "linux/arm64, python3.14 — default changed to 'forkserver' (gh-84559)"
runsh "docker run --rm --platform linux/arm64 -v '$HERE':/demo:ro python:3.14-slim python /demo/shared_state.py"

moral "One source file, three different execution models. Code that relies on inherited
   globals works on Linux 3.13, breaks on macOS, and breaks again on Linux 3.14.
   If you care, say so: mp.get_context('spawn')."
