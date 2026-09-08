#!/usr/bin/env bash
# Your requirements file says "demo-pkg". An environment variable decides which one.
set -u
source "$(dirname "${BASH_SOURCE[0]}")/../../scripts/lib.sh"

cd "$REPO_ROOT/04-env-leak/c-pip-config" || exit 1

# Keeps the echoed commands short enough to read on a projector.
export PIP_DISABLE_PIP_VERSION_CHECK=1
PIP="./.venv/bin/pip --quiet"
PY="./.venv/bin/python"
OFFICIAL="file://$PWD/index-official"
IMPOSTOR="file://$PWD/index-impostor"

if [[ ! -d index-official ]]; then
    hdr "Building the local indexes"
    run python3.12 make_index.py
fi

hdr "A clean venv, installing from the index we intended"
rm -rf .venv
run python3.12 -m venv .venv
runsh "$PIP install --index-url \$OFFICIAL demo-pkg"
runsh "$PY -c 'import demo_pkg; print(demo_pkg.hello())'"

hdr "Same command. Same requirements. One variable set somewhere else."
note "PIP_EXTRA_INDEX_URL lives in shell profiles, CI secrets and inherited Dockerfiles."
note "Nothing in the project records that it exists."
runsh "$PIP uninstall --yes demo-pkg"
runsh "PIP_EXTRA_INDEX_URL=\$IMPOSTOR $PIP install --index-url \$OFFICIAL demo-pkg"
runsh "$PY -c 'import demo_pkg; print(demo_pkg.hello())'"

note ""
note "pip merged both indexes and took the highest version it could see."
note "Documented behaviour. Also exactly how dependency confusion works."

hdr "Mitigation 1 — pin the version.  Not enough."
note "The impostor publishes a 1.0.0 too. A pin narrows the range, it does not"
note "say anything about where the artefact came from."
runsh "$PIP uninstall --yes demo-pkg"
runsh "PIP_EXTRA_INDEX_URL=\$IMPOSTOR $PIP install --index-url \$OFFICIAL 'demo-pkg==1.0.0'"
runsh "$PY -c 'import demo_pkg; print(demo_pkg.hello())'"

hdr "Mitigation 2 — require hashes, so the bytes themselves must match"
WHEEL="index-official/demo-pkg/demo_pkg-1.0.0-py3-none-any.whl"
HASH="$(python3.12 -c "import hashlib,sys;print(hashlib.sha256(open(sys.argv[1],'rb').read()).hexdigest())" "$WHEEL")"
runsh "printf 'demo-pkg==1.0.0 --hash=sha256:%s\\n' '$HASH' > requirements.txt"
runsh "cat requirements.txt"
runsh "$PIP uninstall --yes demo-pkg"
runsh_expect_fail "PIP_EXTRA_INDEX_URL=\$IMPOSTOR $PIP install --index-url \$IMPOSTOR --require-hashes -r requirements.txt"
note "Same name, same version, different bytes — and pip refuses to continue."

hdr "Mitigation 3 — do not let the variable through at all"
runsh "env -i $PY -c 'import os; print(\"PIP_EXTRA_INDEX_URL\" in os.environ)'"
note "uv equivalent: uv run --isolated, and --index-strategy to opt into merging explicitly."

moral "An index URL is a dependency. If it is not in the repo, it is not pinned."
