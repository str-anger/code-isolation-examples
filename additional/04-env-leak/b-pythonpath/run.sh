#!/usr/bin/env bash
# A virtual environment is a search path, not a wall.
set -u
source "$(dirname "${BASH_SOURCE[0]}")/../../scripts/lib.sh"

cd "$REPO_ROOT/04-env-leak/b-pythonpath" || exit 1

hdr "1. A clean virtual environment"
rm -rf .venv
run python3.12 -m venv .venv
runsh "./.venv/bin/pip --quiet list --disable-pip-version-check"
note "Nothing installed but pip. ghostlib is not here, and is in no lockfile anywhere."
runsh "./.venv/bin/python app.py"

hdr "2. The same venv, the same command, one variable set in the shell"
runsh "PYTHONPATH=./outside ./.venv/bin/python app.py"
note "The venv did not change. pip list would still show nothing."
note "PYTHONPATH is prepended to sys.path before site-packages is even consulted."

hdr "3. A venv built with --system-site-packages"
rm -rf .venv-leaky
run python3.12 -m venv --system-site-packages .venv-leaky
runsh "./.venv-leaky/bin/python -c 'import sys; print(len(sys.path), \"entries on sys.path\")'"
runsh "./.venv/bin/python -c 'import sys; print(len(sys.path), \"entries on sys.path\")'"
note "Everything installed against the system python3.12 is importable in the leaky one."

hdr "4. Shutting the door"
note "-I ignores PYTHONPATH and the user site directory:"
runsh "PYTHONPATH=./outside ./.venv/bin/python -I app.py"
note ""
note "env -i starts from no environment at all:"
runsh "PYTHONPATH=./outside env -i ./.venv/bin/python app.py"
if have uv; then
    note ""
    note "uv run --isolated does the same for a uv-managed project."
fi

moral "If it imports on your laptop, ask which sys.path entry it came from."
