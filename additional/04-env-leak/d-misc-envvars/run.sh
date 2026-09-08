#!/usr/bin/env bash
# A tour of the other variables that quietly change how your code behaves.
set -u
source "$(dirname "${BASH_SOURCE[0]}")/../../scripts/lib.sh"

hdr "PYTHONHASHSEED — string hashing is randomised per process"
runsh "python3.12 -c 'print(hash(\"isolate\"))'"
runsh "python3.12 -c 'print(hash(\"isolate\"))'"
note "Two runs, two values. Now fix the seed:"
runsh "PYTHONHASHSEED=0 python3.12 -c 'print(hash(\"isolate\"))'"
runsh "PYTHONHASHSEED=0 python3.12 -c 'print(hash(\"isolate\"))'"
note "Anything that iterates a set of strings and takes the first element is"
note "reproducible only if this is pinned. Common in sampling and shuffling code."

hdr "LC_ALL / LANG — sort order is locale-dependent"
runsh "LC_ALL=C python3.12 -c \"
import locale; locale.setlocale(locale.LC_ALL, '')
words = ['zebra', 'Ähre', 'apple', 'Banana']
print(sorted(words, key=locale.strxfrm))\""
runsh "LC_ALL=en_US.UTF-8 python3.12 -c \"
import locale; locale.setlocale(locale.LC_ALL, '')
words = ['zebra', 'Ähre', 'apple', 'Banana']
print(sorted(words, key=locale.strxfrm))\""
note "Same list, same Python, same code. Different order, and therefore different"
note "output files, different diffs, different test results."

hdr "PYTHONWARNINGS — turns advisories into failures"
runsh "python3.12 -c 'import warnings; warnings.warn(\"heads up\", DeprecationWarning); print(\"survived\")'"
runsh_expect_fail "PYTHONWARNINGS=error python3.12 -c 'import warnings; warnings.warn(\"heads up\", DeprecationWarning); print(\"survived\")'"
note "Useful in CI on purpose. Confusing when it is set globally by accident."

hdr "PYTHONDONTWRITEBYTECODE / PYTHONPYCACHEPREFIX"
runsh "python3.12 -c 'import sys; print(\"writes .pyc:\", not sys.dont_write_bytecode)'"
runsh "PYTHONDONTWRITEBYTECODE=1 python3.12 -c 'import sys; print(\"writes .pyc:\", not sys.dont_write_bytecode)'"

hdr "What is actually set in this shell right now?"
runsh "env | grep -E '^(PYTHON|PIP_|VIRTUAL_ENV|LC_|LANG|OMP_|OPENBLAS_|MKL_|VECLIB_)' | sort || echo '  (nothing — unusually clean)'"

moral "Run that last command on the machine where the bug does not reproduce."
