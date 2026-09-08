# 5 — Docker, and what it does not fix

This is the closing loop. Everything up to here was fixed one layer at a time:
the interpreter, the dependency versions, the environment variables. Docker
finally lets us ship all of it as one artefact.

Then we run that one artefact on two architectures and the numbers still disagree.

`probe.py` is the payload. It prints the arch, the libc, the numpy build, the
`longdouble` width, `sum([0.1]*10)` and a float32 matmul checksum in hex — one
`key: value` per line so two runs diff cleanly.

This folder is deliberately **standalone**: its own `pyproject.toml` and `uv.lock`,
so you can share just `05-docker/` and it still builds.

| command | what it shows |
| --- | --- |
| `make s5arch`  ★ | one Dockerfile, one lock, two arches, different bits |
| `make s5env` | `-e` reaches into the "isolated" container and changes the result |
| `make s5drift` | `python:3.12-slim` is a bookmark, not a pin |

`make preflight` builds both images ahead of time. Do not skip that — the
amd64 build runs under emulation and is far too slow to do live.

## What to say

The lockfile is byte-for-byte identical on both sides. Same numpy, same CPython,
same Debian. The dependency graph is not the variable here — the CPU is. Different
SIMD width means the BLAS blocks the matrix differently, which means the partial
sums are added in a different order, which means a different answer in the last
few bits.

That is fine, and it is also exactly the kind of thing that turns into "the test
passes on my laptop and fails in CI" three months later.

Full isolation is the whole stack:

- platform (OS + CPU architecture)
- interpreter (`python3.12`, and *which* 3.12)
- dependencies (a lockfile, with hashes)
- environment (scrubbed, not inherited)
- image (pinned by digest, not by tag)

Anything on that list you leave unpinned, somebody else picks for you — usually
at the worst possible moment.
