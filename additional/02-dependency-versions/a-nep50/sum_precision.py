"""Summing ten million float32s. The accumulator dtype decides how wrong you are."""

import math

import numpy as np

rng = np.random.default_rng(0)
a = rng.random(10_000_000, dtype=np.float32)

naive = a.sum()
widened = a.sum(dtype=np.float64)
exact = math.fsum(a.tolist())

print(f"  numpy {np.__version__}")
print(f"  a.sum()                 = {naive!r}")
print(f"  a.sum(dtype=np.float64) = {widened!r}")
print(f"  math.fsum(a)            = {exact!r}")
print(f"  naive error             = {abs(float(naive) - exact):.6f}")
