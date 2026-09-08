#!/usr/bin/env bash
# The container is "isolated" — and the caller still gets to reach inside it.
set -u
source "$(dirname "${BASH_SOURCE[0]}")/../scripts/lib.sh"

need_image "$IMG_ARM64" || exit 0

hdr "As built"
run docker run --rm "$IMG_ARM64" | grep -E 'matmul sum hex|NUM_THREADS|LANG'

hdr "Same image, caller sets the environment"
runsh "docker run --rm -e OMP_NUM_THREADS=1 -e OPENBLAS_NUM_THREADS=1 -e LANG=C \"$IMG_ARM64\" | grep -E 'matmul sum hex|NUM_THREADS|LANG'"

note ""
note "Nothing in the image changed. No layer was rebuilt. The digest is the same."
note "A single -e flag changed how many threads the BLAS used, and with it the"
note "order the partial sums were combined in."
moral "Pinning the image pins the code, not the runtime configuration."
