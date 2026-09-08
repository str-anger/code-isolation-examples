#!/usr/bin/env bash
# Same file, same numpy, two architectures, two different numeric types.
set -u
source "$(dirname "${BASH_SOURCE[0]}")/../../scripts/lib.sh"
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

hdr "Natively — macOS on Apple Silicon (arm64)"
if need_demo_venv; then
    run "$DEMO_PY" "$HERE/longdouble.py"
fi

hdr "The identical file, inside linux/amd64 (emulated)"
if need_image "$IMG_AMD64"; then
    runsh "docker run --rm --platform linux/amd64 -v '$HERE':/demo:ro $IMG_AMD64 python /demo/longdouble.py"
fi

hdr "And inside linux/arm64, to prove it is the CPU and not Linux"
if need_image "$IMG_ARM64"; then
    runsh "docker run --rm --platform linux/arm64 -v '$HERE':/demo:ro $IMG_ARM64 python /demo/longdouble.py"
fi

moral "np.longdouble is 64-bit on arm64 and 80-bit on x86-64. np.float128 does not even
   exist here. Your dtype is a property of the machine, not of your source code."
