#!/usr/bin/env bash
# Same job as uv, different vocabulary — and one operator worth reading carefully.
set -u
source "$(dirname "${BASH_SOURCE[0]}")/../../scripts/lib.sh"

have poetry || { warn "poetry is not installed — skipping"; exit 0; }
cd "$REPO_ROOT/03-tooling/poetry" || exit 1

# Keep the venv beside the project so 'make clean' can find it.
export POETRY_VIRTUALENVS_IN_PROJECT=1

hdr "The declaration"
runsh "cat pyproject.toml"

hdr "What does ^1.26 actually mean?"
note "Caret allows changes that do not modify the left-most non-zero digit."
runsh "poetry check --quiet && echo 'pyproject is valid'"
note "  ^1.26   ->  >=1.26, <2.0.0     will not take numpy 2"
note "  ^0.3    ->  >=0.3,  <0.4       below 1.0 the rule shifts right"
note "  ~1.26   ->  >=1.26, <1.27.0    tilde is tighter"
note ""
note "This is the single most misread line in a Python project. '^1.26' looks"
note "permissive and is in fact the thing standing between you and demo 2a."

hdr "Resolve it"
run poetry lock
runsh "grep -m1 -A2 'name = \"numpy\"' poetry.lock"

hdr "Install, then check what landed"
run poetry install
runsh "poetry run python -c 'import numpy; print(\"numpy\", numpy.__version__)'"

hdr "The dependency tree poetry believes in"
runsh "poetry show --tree"

hdr "Production install drops the dev group — or does it?"
run poetry install --without dev
runsh "poetry run python -c \"
import importlib.util
print('pytest present:', importlib.util.find_spec('pytest') is not None)\""
note "Still there. 'install' is additive: it installs what is missing and removes"
note "nothing. A long-lived venv accumulates packages no lockfile mentions."
note ""
note "'sync' is the one that makes the environment match the lock exactly:"
run poetry sync --without dev
runsh "poetry run python -c \"
import importlib.util
print('pytest present:', importlib.util.find_spec('pytest') is not None)\""
note "uv's equivalent is 'uv sync', which is why uv sync has no additive mode."

hdr "Restore the dev group for the next run"
run poetry sync

hdr "Which interpreter is this environment built on?"
runsh "poetry env info --path"
runsh "poetry run python -VV"
note "poetry env use python3.12  switches it. Like uv, the interpreter is explicit."

moral "Read the caret. '^1.26' is a range, and ranges are how surprises arrive."
