#!/usr/bin/env bash
# One tool for the interpreter, the resolve, the lock and the run.
set -u
source "$(dirname "${BASH_SOURCE[0]}")/../../scripts/lib.sh"

have uv || { warn "uv is not installed — skipping"; exit 0; }
cd "$REPO_ROOT/03-tooling/uv" || exit 1

hdr "The declaration"
runsh "cat pyproject.toml"
note "Note requires-python. uv treats the interpreter as part of the problem,"
note "not as something you arrange beforehand."

hdr "Resolve it"
run uv lock
runsh "grep -A2 'name = \"numpy\"' uv.lock | head -6"
note "uv.lock records hashes by default — no --generate-hashes needed."

hdr "Install exactly what the lock says, and nothing else"
run uv sync --frozen
runsh "uv run --frozen python -c 'import numpy; print(\"numpy\", numpy.__version__)'"
note "--frozen means: fail rather than re-resolve. That is what you want in CI."

hdr "Production install drops the dev group"
run uv sync --frozen --no-dev
runsh "uv run --frozen --no-dev python -c \"
import importlib.util
print('pytest present:', importlib.util.find_spec('pytest') is not None)\""

hdr "Dev install brings it back"
run uv sync --frozen
runsh "uv run --frozen python -c \"
import importlib.util
print('pytest present:', importlib.util.find_spec('pytest') is not None)\""

hdr "Ephemeral dependencies, without touching the project at all"
note "This is the idiom demo 2a uses to show two numpy versions in ten seconds:"
runsh "uv run --python 3.12 --with 'numpy==1.26.4' --no-project python -c 'import numpy;print(numpy.__version__)'"
runsh "uv run --python 3.12 --with 'numpy>=2' --no-project python -c 'import numpy;print(numpy.__version__)'"

hdr "Bumping one package without disturbing the rest"
runsh "uv lock --upgrade-package numpy 2>&1 | tail -3"

moral "pyproject.toml is the intent, uv.lock is the evidence, --frozen is the enforcement."
