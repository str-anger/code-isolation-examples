#!/usr/bin/env bash
# Shared helpers for every demo's run.sh. Source it, don't execute it.

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export REPO_ROOT

# The venv preflight builds for demos that need numpy without a package manager in frame.
DEMO_PY="$REPO_ROOT/.venv-demo/bin/python"
export DEMO_PY

# Image tags built by 05-docker/build-images.sh
IMG_ARM64="isolate-demo:arm64"
IMG_AMD64="isolate-demo:amd64"
export IMG_ARM64 IMG_AMD64

ALL_PYTHONS=(3.10 3.11 3.12 3.13 3.14)

if [[ -t 1 ]]; then
    BOLD=$'\033[1m'; DIM=$'\033[2m'; RED=$'\033[31m'; GRN=$'\033[32m'
    YLW=$'\033[33m'; CYN=$'\033[36m'; RST=$'\033[0m'
else
    BOLD=""; DIM=""; RED=""; GRN=""; YLW=""; CYN=""; RST=""
fi

hdr() { printf '\n%s══ %s ══%s\n' "$BOLD$CYN" "$*" "$RST"; }
note() { printf '%s%s%s\n' "$DIM" "$*" "$RST"; }
warn() { printf '%s!! %s%s\n' "$YLW" "$*" "$RST"; }
moral() { printf '\n%s➜  %s%s\n' "$BOLD$GRN" "$*" "$RST"; }

# Echo a command, then run it. Use for simple argv commands.
run() { printf '\n%s$ %s%s\n' "$DIM" "$*" "$RST"; "$@"; }

# Echo a shell snippet, then eval it. Use when you need env prefixes, pipes or redirection.
runsh() { printf '\n%s$ %s%s\n' "$DIM" "$1" "$RST"; eval "$1"; }

# Same as runsh but announces that a non-zero exit is the expected outcome.
runsh_expect_fail() {
    printf '\n%s$ %s%s\n' "$DIM" "$1" "$RST"
    if eval "$1"; then
        warn "expected this to fail, but it succeeded"
    else
        printf '%s   ^ exit %d — this failure is the point%s\n' "$GRN" "$?" "$RST"
    fi
}

have() { command -v "$1" >/dev/null 2>&1; }

# Returns 1 and prints a hint if the given python is not installed.
need_py() {
    if have "python$1"; then
        return 0
    fi
    warn "python$1 not installed — skipping this run"
    case "$1" in
        3.14t) note "   install with: brew install python-freethreading" ;;
        *)     note "   install with: brew install python@$1" ;;
    esac
    return 1
}

need_demo_venv() {
    if [[ -x "$DEMO_PY" ]]; then
        return 0
    fi
    warn "shared numpy venv missing — run: make preflight"
    return 1
}

need_image() {
    if docker image inspect "$1" >/dev/null 2>&1; then
        return 0
    fi
    warn "docker image $1 not built — run: make preflight"
    return 1
}
