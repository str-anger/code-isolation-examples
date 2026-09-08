#!/usr/bin/env bash
# --pre is a property of the whole resolution, not of the package you named.
set -u
source "$(dirname "${BASH_SOURCE[0]}")/../../scripts/lib.sh"

cd "$REPO_ROOT/03-tooling/prerelease" || exit 1
export PIP_DISABLE_PIP_VERSION_CHECK=1

INDEX="file://$PWD/index-local"
PIP="./.venv/bin/pip --quiet"
PY="./.venv/bin/python"

hdr "A local index: one app, one library, one release candidate"
run python3.12 make_index.py
note "demo-app 1.0.0 depends on demo-lib>=1.0"
note "demo-lib exists as 1.0.0 (stable) and 2.0.0rc1 (prerelease)"

rm -rf .venv
run python3.12 -m venv .venv

hdr "Default resolution — prereleases are ignored"
runsh "$PIP install --index-url \$INDEX demo-app"
runsh "$PY -c 'import demo_lib, demo_app; print(\"demo-app\", demo_app.VERSION, \"| demo-lib\", demo_lib.VERSION)'"

hdr "Now add --pre, still asking only for demo-app"
runsh "$PIP uninstall --yes demo-app demo-lib"
runsh "$PIP install --pre --index-url \$INDEX demo-app"
runsh "$PY -c 'import demo_lib, demo_app; print(\"demo-app\", demo_app.VERSION, \"| demo-lib\", demo_lib.VERSION)'"

note ""
note "You asked for demo-app. You got a release candidate of something else."
note "--pre applies to every package in the resolution, including transitive"
note "dependencies you have never heard of."

hdr "Where this actually bites: the dev group"
note "A dev-only tool that needs a prerelease is a common reason people add --pre"
note "to a shared install command. The flag does not stay in the dev group —"
note "it changes how the production dependencies resolve too."
note ""
note "The scoped alternatives, per tool:"
note "  pip      no per-package scoping; pin the prerelease explicitly instead:"
note "           demo-lib==2.0.0rc1"
note "  uv       uv add 'demo-lib==2.0.0rc1'   (or prerelease = 'allow' per package"
note "           under [tool.uv.sources]); uv lock --prerelease=allow is global"
note "  poetry   allow-prereleases = true      set per dependency, not globally"

hdr "Pinning the RC explicitly keeps the rest stable"
runsh "$PIP uninstall --yes demo-app demo-lib"
runsh "$PIP install --index-url \$INDEX demo-app 'demo-lib==2.0.0rc1'"
runsh "$PY -c 'import demo_lib, demo_app; print(\"demo-app\", demo_app.VERSION, \"| demo-lib\", demo_lib.VERSION)'"
note "Same result, but now it is written down, and only that one package moved."

moral "--pre is global. If you need one release candidate, name it."
