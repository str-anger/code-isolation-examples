#!/usr/bin/env bash
# One requirements file, two moments in time, two different environments.
set -u
source "$(dirname "${BASH_SOURCE[0]}")/../../scripts/lib.sh"
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if ! have uv; then
    warn "uv not installed — skipping"
    exit 0
fi

hdr "The requirements file the paper shipped with"
run cat "$HERE/requirements.in"

hdr "Resolved today"
runsh "uv pip compile --quiet --python-version 3.12 '$HERE/requirements.in' -o '$HERE/now.txt'"
runsh "grep -E '^(numpy|pandas|pytest)' '$HERE/now.txt'"

hdr "Resolved as if it were 1 January 2024"
runsh "uv pip compile --quiet --python-version 3.12 --exclude-newer 2024-01-01 '$HERE/requirements.in' -o '$HERE/then.txt'"
runsh "grep -E '^(numpy|pandas|pytest)' '$HERE/then.txt'"

hdr "Full diff"
runsh "diff '$HERE/then.txt' '$HERE/now.txt' | head -40 || true"

moral "'numpy>=1.26' meant numpy 1.26 in 2024 and numpy 2.x today — across the NEP 50
   break you just saw in demo 2a. The file did not change. The answer did.
   A lockfile is just this resolution, written down and committed."
