#!/usr/bin/env bash
# A version pin is only installable if somebody built a wheel for *your* platform.
set -u
source "$(dirname "${BASH_SOURCE[0]}")/../../scripts/lib.sh"

WHEELS=/tmp/isolate-wheels
rm -rf "$WHEELS"; mkdir -p "$WHEELS"

hdr "What wheel tags does this interpreter accept?"
runsh "python3.12 -m pip debug --verbose 2>/dev/null | sed -n '/Compatible tags/,\$p' | head -12"
note "... (the full list is a few hundred entries long)"

hdr "Ask for numpy 1.19.5 on macOS arm64"
runsh_expect_fail "python3.12 -m pip download --only-binary=:all: --no-deps -d '$WHEELS' 'numpy==1.19.5' 2>&1 | tail -5"

hdr "The exact same pin, targeting linux x86-64 + cpython 3.9"
runsh "python3.12 -m pip download --only-binary=:all: --no-deps \
  --platform manylinux2014_x86_64 --python-version 3.9 --implementation cp --abi cp39 \
  -d '$WHEELS' 'numpy==1.19.5' 2>&1 | tail -3"
runsh "ls -1 '$WHEELS'"

hdr "And a version that does have an arm64 wheel"
runsh "python3.12 -m pip download --only-binary=:all: --no-deps -d '$WHEELS' 'numpy==2.3.5' 2>&1 | tail -3"
runsh "ls -1 '$WHEELS'"

rm -rf "$WHEELS"

moral "'numpy==1.19.5' is not a portable statement. The resolver's answer depends on OS,
   CPU, interpreter version and ABI — four things your requirements file never mentions."
