#!/usr/bin/env bash
# Everything that must happen BEFORE you stand in front of an audience.
# Safe to re-run; it is idempotent.
set -u
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

missing_py=()

hdr "Interpreters"
for v in "${ALL_PYTHONS[@]}" 3.14t; do
    if have "python$v"; then
        printf '  %s✓%s python%-6s %s\n' "$GRN" "$RST" "$v" "$(python"$v" -c 'import sys;print(sys.version.split()[0], sys.executable)')"
    else
        printf '  %s✗%s python%-6s not installed\n' "$RED" "$RST" "$v"
        missing_py+=("$v")
    fi
done

if ((${#missing_py[@]})); then
    warn "Missing interpreters. The demos will skip them, but you lose part of the story:"
    for v in "${missing_py[@]}"; do
        if [[ "$v" == "3.14t" ]]; then
            note "   brew install python-freethreading      # gives python3.14t (demo 1c)"
        else
            note "   brew install python@$v                 # (demo 1b needs 3.11 vs 3.12)"
        fi
    done
fi

hdr "Tooling"
for tool in uv poetry docker clang++; do
    if have "$tool"; then
        printf '  %s✓%s %s\n' "$GRN" "$RST" "$tool"
    else
        printf '  %s✗%s %s — some demos will skip\n' "$RED" "$RST" "$tool"
    fi
done

hdr "Shared numpy venv (.venv-demo)"
if [[ -x "$DEMO_PY" ]]; then
    note "already exists — $("$DEMO_PY" -c 'import numpy;print("numpy", numpy.__version__)')"
else
    run python3.12 -m venv "$REPO_ROOT/.venv-demo"
    run "$DEMO_PY" -m pip install --quiet --upgrade pip
    run "$DEMO_PY" -m pip install --quiet "numpy>=2"
    note "$("$DEMO_PY" -c 'import numpy;print("installed numpy", numpy.__version__)')"
fi

hdr "Local wheel indexes for the dependency-confusion demo"
run python3.12 "$REPO_ROOT/04-env-leak/c-pip-config/make_index.py"

hdr "Warming package caches (so a dead conference wifi cannot ruin your day)"
if have uv; then
    runsh "uv pip download --help >/dev/null 2>&1 || true"
    for spec in "numpy==1.26.4" "numpy>=2" "pytest<8" "pytest>=8"; do
        runsh "uv pip install --python 3.12 --target /tmp/isolate-warm \"$spec\" >/dev/null 2>&1 && echo '  cached $spec'"
    done
    rm -rf /tmp/isolate-warm
fi

hdr "Docker images"
if have docker && docker info >/dev/null 2>&1; then
    run bash "$REPO_ROOT/05-docker/build-images.sh"
    note "pre-pulling slim images used by the fork/spawn demo"
    runsh "docker pull --platform linux/arm64 python:3.13-slim >/dev/null && echo '  python:3.13-slim (arm64)'"
    runsh "docker pull --platform linux/arm64 python:3.14-slim >/dev/null && echo '  python:3.14-slim (arm64)'"
else
    warn "docker is not running — start Docker Desktop and re-run, or the cross-arch demos will skip"
fi

moral "Preflight done. Now run 'make check' to confirm every demo still behaves."
