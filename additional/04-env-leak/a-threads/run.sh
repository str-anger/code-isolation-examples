#!/usr/bin/env bash
# Same venv, same code, same numpy. The caller's shell decides how fast it runs.
set -u
source "$(dirname "${BASH_SOURCE[0]}")/../../scripts/lib.sh"

need_demo_venv || exit 0
cd "$REPO_ROOT/04-env-leak/a-threads" || exit 1

hdr "As inherited from your shell"
runsh "$DEMO_PY matmul.py"

hdr "Pinned to a single thread"
runsh "OMP_NUM_THREADS=1 OPENBLAS_NUM_THREADS=1 VECLIB_MAXIMUM_THREADS=1 $DEMO_PY matmul.py"

hdr "Pinned to two"
runsh "OMP_NUM_THREADS=2 OPENBLAS_NUM_THREADS=2 VECLIB_MAXIMUM_THREADS=2 $DEMO_PY matmul.py"

note ""
note "Nothing about the project changed between those three runs. No reinstall,"
note "no lockfile edit, no code edit. Only variables that live outside the repo."
note ""
note "Wall time always moves. Whether the last bits of the sum move depends on"
note "which BLAS you linked and whether it reassociates the accumulation —"
note "see 'make s5arch' for the version of this that is guaranteed to differ."
moral "Your benchmark measured the environment as much as the code."
