"""Times a float32 matmul and reports how many threads the BLAS was allowed to use.

The thread-count variables are read by the BLAS at import time, so they must be set
before this process starts — which is exactly why they are so easy to set by accident.
"""

import os
import time

import numpy as np

VARS = (
    "OMP_NUM_THREADS",
    "OPENBLAS_NUM_THREADS",
    "MKL_NUM_THREADS",
    "VECLIB_MAXIMUM_THREADS",
)


def blas_name() -> str:
    try:
        cfg = np.show_config("dicts")
    except (TypeError, AttributeError):
        return "unknown"
    blas = (cfg or {}).get("Build Dependencies", {}).get("blas", {})
    return f"{blas.get('name', 'unknown')} {blas.get('version', '')}".strip()


settings = " ".join(f"{v}={os.environ[v]}" for v in VARS if v in os.environ) or "<none set>"
print(f"numpy {np.__version__} via {blas_name()}")
print(f"env:  {settings}")

rng = np.random.default_rng(0)
a = rng.standard_normal((2000, 2000), dtype=np.float32)
b = rng.standard_normal((2000, 2000), dtype=np.float32)

timings = []
for _ in range(3):
    start = time.perf_counter()
    c = a @ b
    timings.append(time.perf_counter() - start)

total = float(c.sum())
print(f"time: {min(timings):.3f}s (best of 3)")
print(f"sum:  {total!r}")
print(f"hex:  {total.hex()}")
