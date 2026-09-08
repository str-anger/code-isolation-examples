# Expected output — 5 Docker

Captured on macOS 15 / Apple Silicon, 2026-09-03. Your hex values may differ if
numpy or the base image has moved; the *shape* of the result is the point.

## `make s5arch`

Both containers print the full probe. The comparison at the end:

```
                        arm64                   amd64
machine                 aarch64                 x86_64
longdouble digits       33                      18
matmul sum              -19615.8359375          -19615.830078125
matmul sum hex          -0x1.327f580000000p+14  -0x1.327f520000000p+14

identical on both: sys.platform, libc, python, numpy, blas, longdouble bytes,
has np.float128, sum([0.1]*10), OMP_NUM_THREADS, OPENBLAS_NUM_THREADS,
MKL_NUM_THREADS, VECLIB_MAXIMUM_THREADS, LANG
```

Exit code 0.

Everything that a lockfile can pin is identical: CPython 3.12.14, numpy 2.3.5,
glibc 2.41, scipy-openblas 0.3.30. The two things that differ are the two things
the lockfile has no opinion about — the instruction set, and what `long double`
means on it.

Note `longdouble bytes` is 16 on *both* Linux arches, but the precision is not:
aarch64 gives you a true 128-bit quad (33 digits), x86-64 gives you the old
80-bit extended type padded out to 16 bytes (18 digits). Checking `itemsize`
would have told you they matched. They do not.

## `make s5env`

Same image, no rebuild. Setting `-e OMP_NUM_THREADS=1 -e OPENBLAS_NUM_THREADS=1`
changes `matmul sum hex`, because a different thread count means the partial
sums are accumulated in a different order.

Exit code 0.

## `make s5drift`

Prints the digest `python:3.12-slim` currently resolves to, the Debian and
OpenSSL versions inside it, and the `FROM ...@sha256:` line from
`Dockerfile.pinned` for contrast.

Exit code 0.
