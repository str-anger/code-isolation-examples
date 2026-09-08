#!/usr/bin/env bash
# Four small files. Each one is fine on exactly one side of the 3.11 / 3.12 line.
set -u
source "$(dirname "${BASH_SOURCE[0]}")/../../scripts/lib.sh"
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RUNALL="$REPO_ROOT/01-python-version/run-all-versions.sh"

hdr "PEP 701 — reusing quotes inside an f-string (new in 3.12)"
note "this fails at PARSE time on <=3.11: the file never starts running"
bash "$RUNALL" "$HERE/pep701.py" 2>&1 | sed 's/^/  /'

hdr "PEP 695 — def largest[T](...) and the 'type' statement (new in 3.12)"
bash "$RUNALL" "$HERE/pep695.py" 2>&1 | sed 's/^/  /'

hdr "distutils — removed in 3.12 (PEP 632)"
bash "$RUNALL" "$HERE/removed_stdlib.py" 2>&1 | sed 's/^/  /'

hdr "unittest.assertEquals — removed in 3.12 (gh-89325)"
bash "$RUNALL" "$HERE/test_legacy_unittest.py" 2>&1 | sed 's/^/  /'

moral "Two of these files only run on old interpreters, two only on new ones.
   There is no single Python that runs all four. 'Just use Python 3' is not a spec."
