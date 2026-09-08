#!/usr/bin/env bash
# Builds the same Dockerfile for both architectures. Called by preflight so the
# slow amd64 emulation happens long before you are on stage.
set -u
source "$(dirname "${BASH_SOURCE[0]}")/../scripts/lib.sh"

cd "$REPO_ROOT/05-docker" || exit 1

if ! have docker || ! docker info >/dev/null 2>&1; then
    warn "docker is not running — skipping image build"
    exit 0
fi

if [[ ! -f uv.lock ]]; then
    hdr "No uv.lock yet — resolving it once"
    run uv lock
fi

hdr "Building $IMG_ARM64 (native)"
run docker build --platform linux/arm64 -t "$IMG_ARM64" .

hdr "Building $IMG_AMD64 (emulated — this is the slow one)"
run docker build --platform linux/amd64 -t "$IMG_AMD64" .

moral "Both images built from one Dockerfile and one uv.lock."
