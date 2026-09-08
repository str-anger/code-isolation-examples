#!/usr/bin/env bash
# Your test suite is green. Is it green because the code works, or because of pytest 7?
set -u
source "$(dirname "${BASH_SOURCE[0]}")/../../scripts/lib.sh"
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if ! have uv; then
    warn "uv not installed — skipping"
    exit 0
fi

hdr "pytest 7 — nose-style setup() is still supported"
runsh "cd '$HERE' && uv run --quiet --python 3.12 --with 'pytest<8' -m pytest -q test_resource.py"

hdr "pytest 8 — setup() is no longer called"
runsh_expect_fail "cd '$HERE' && uv run --quiet --python 3.12 --with 'pytest>=8' -m pytest -q test_resource.py 2>&1 | tail -20"

moral "pytest 8.0 removed nose-style setup()/teardown(). The method is still there, still
   named setup, and is simply never invoked. A dependency bump turned a passing suite
   into a failing one without touching a line of test code."
