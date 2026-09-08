#!/usr/bin/env bash
# "FROM python:3.12-slim" names a moving target. Digests do not move.
set -u
source "$(dirname "${BASH_SOURCE[0]}")/../scripts/lib.sh"

if ! have docker || ! docker info >/dev/null 2>&1; then
    warn "docker is not running — skipping"
    exit 0
fi

cd "$REPO_ROOT/05-docker" || exit 1

hdr "What does the tag point at right now?"
run docker pull --platform linux/arm64 python:3.12-slim
runsh "docker image inspect python:3.12-slim --format '{{index .RepoDigests 0}}'"

hdr "What is actually inside it today"
runsh "docker run --rm python:3.12-slim sh -c 'cat /etc/debian_version; python -VV; openssl version 2>/dev/null || true'"

hdr "The pinned Dockerfile"
runsh "grep -A1 '^# resolved' Dockerfile.pinned"

note ""
note "Both Dockerfiles say 'python 3.12 slim'. Only one of them will still mean"
note "the same thing next quarter: the base image is rebuilt for every security"
note "update to Debian, OpenSSL and CPython itself."
moral "A tag is a bookmark. A digest is a pin."
