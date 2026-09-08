#!/usr/bin/env bash
# The explicit way: build two venvs by hand and look at the same file in each.
set -u
source "$(dirname "${BASH_SOURCE[0]}")/../../scripts/lib.sh"
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

for pin in "1.26.4" "2.3.5"; do
    venv="$HERE/.venv-np$pin"
    if [[ ! -x "$venv/bin/python" ]]; then
        hdr "Building a venv for numpy==$pin"
        run python3.12 -m venv "$venv"
        runsh "'$venv/bin/pip' install --quiet --upgrade pip"
        runsh "'$venv/bin/pip' install --quiet 'numpy==$pin'"
    fi
done

hdr "Same interpreter (3.12), same file, numpy 1.26.4"
run "$HERE/.venv-np1.26.4/bin/python" "$HERE/promotion.py"

hdr "Same interpreter (3.12), same file, numpy 2.3.5"
run "$HERE/.venv-np2.3.5/bin/python" "$HERE/promotion.py"

moral "Nothing crashed. Nothing warned. The numbers are just different."
