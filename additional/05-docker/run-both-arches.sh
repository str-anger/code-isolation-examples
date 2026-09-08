#!/usr/bin/env bash
# Same Dockerfile, same uv.lock, same probe.py. Two architectures.
set -u
source "$(dirname "${BASH_SOURCE[0]}")/../scripts/lib.sh"

need_image "$IMG_ARM64" || exit 0
need_image "$IMG_AMD64" || exit 0

out_arm="$(mktemp)"
out_amd="$(mktemp)"
trap 'rm -f "$out_arm" "$out_amd"' EXIT

hdr "linux/arm64"
runsh "docker run --rm --platform linux/arm64 $IMG_ARM64 > $out_arm"
cat "$out_arm"

hdr "linux/amd64  (emulated)"
runsh "docker run --rm --platform linux/amd64 $IMG_AMD64 > $out_amd"
cat "$out_amd"

hdr "What actually differs"
python3.12 "$REPO_ROOT/05-docker/compare.py" arm64 "$out_arm" amd64 "$out_amd"

note ""
note "Byte-for-byte identical uv.lock. Same CPython, same numpy, same glibc,"
note "same OpenBLAS. The dependency graph is not the variable here — the CPU is."
moral "Docker isolates the environment. It does not isolate you from the hardware."
