#!/usr/bin/env bash
# One builtin. Five interpreters. Two different answers.
set -u
source "$(dirname "${BASH_SOURCE[0]}")/../../scripts/lib.sh"
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

bash "$REPO_ROOT/scripts/versions.sh"

hdr "sum([0.1] * 10) across every interpreter"
bash "$REPO_ROOT/01-python-version/run-all-versions.sh" "$HERE/float_sum.py"

moral "Python 3.12 switched sum() to Neumaier compensated summation (gh-100425).
   Same source, same input, different number. Nothing in your code changed;
   the meaning of a builtin did."
