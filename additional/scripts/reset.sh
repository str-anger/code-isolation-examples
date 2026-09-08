#!/usr/bin/env bash
# Remove everything preflight and the demos generate. Does not touch Docker images.
set -u
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

cd "$REPO_ROOT"

hdr "Removing generated artifacts"
runsh "find . -name '__pycache__' -type d -prune -exec rm -rf {} + 2>/dev/null; true"
runsh "find . -name '.venv*' -maxdepth 3 -type d -prune -exec rm -rf {} + 2>/dev/null; true"
runsh "find . -name '.pytest_cache' -type d -prune -exec rm -rf {} + 2>/dev/null; true"
runsh "rm -rf 04-env-leak/c-pip-config/index-official 04-env-leak/c-pip-config/index-impostor"
runsh "rm -f 04-env-leak/c-pip-config/requirements.txt"
runsh "rm -rf 03-tooling/prerelease/index-local"
runsh "rm -f 03-tooling/pip/requirements.txt 03-tooling/pip/requirements.tampered.txt"
runsh "rm -rf 02-dependency-versions/c-unpinned-drift/now.txt 02-dependency-versions/c-unpinned-drift/then.txt"
runsh "rm -rf /tmp/isolate-wheels /tmp/isolate-warm"

moral "Clean. Run 'make preflight' to rebuild before the talk."
