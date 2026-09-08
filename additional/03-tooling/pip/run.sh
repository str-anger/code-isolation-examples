#!/usr/bin/env bash
# The oldest dialect, and the only one where hashes are opt-in.
set -uo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../../scripts/lib.sh"

cd "$REPO_ROOT/03-tooling/pip" || exit 1
export PIP_DISABLE_PIP_VERSION_CHECK=1

hdr "The intent a human wrote"
runsh "cat requirements.in"

hdr "Resolve it into an exact, hashed lock"
note "pip cannot do this on its own — pip-compile (pip-tools) or uv pip compile does it."
if have uv; then
    run uv pip compile requirements.in --generate-hashes --quiet -o requirements.txt
else
    warn "uv not installed; falling back to pip-tools"
    runsh "python3.12 -m pip install --quiet pip-tools && pip-compile --generate-hashes -o requirements.txt requirements.in"
fi
runsh "head -20 requirements.txt"

note ""
note "'numpy>=1.26,<2' became one exact version plus a sha256 for every wheel"
note "that could satisfy it on any platform. That list of hashes is the artefact"
note "guarantee — the version number alone is not."

hdr "Install from the lock, refusing anything unhashed"
rm -rf .venv
run python3.12 -m venv .venv
runsh "./.venv/bin/pip install --quiet --require-hashes -r requirements.txt"
runsh "./.venv/bin/python -c 'import numpy; print(\"numpy\", numpy.__version__)'"

hdr "Now corrupt the hashes and try again"
runsh "python3.12 tamper.py requirements.txt requirements.tampered.txt"
runsh "diff requirements.txt requirements.tampered.txt | head -4"
runsh "./.venv/bin/pip uninstall --quiet --yes numpy"
note "numpy ships 36 wheels, so pip lists 36 candidate hashes; trimmed here to the point."
runsh_expect_fail "./.venv/bin/pip install --quiet --require-hashes -r requirements.tampered.txt 2>&1 | grep -v 'Expected     or'"
rm -f requirements.tampered.txt

hdr "Constraints — pinning something you did not ask for directly"
runsh "cat constraints.txt"
note "PIP_CONSTRAINT applies these to transitive dependencies without adding them"
note "as direct requirements. It is also an environment variable, which means"
note "demo 4c applies to it too."

moral "requirements.in is the intent. requirements.txt is the evidence. Commit both."
