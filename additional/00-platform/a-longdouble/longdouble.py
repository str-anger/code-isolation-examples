"""What `long double` means depends on the CPU you are standing on."""

import platform
import sys

import numpy as np

print(f"machine            : {platform.machine()}")
print(f"platform           : {sys.platform}")
print(f"numpy              : {np.__version__}")
print()

ld = np.dtype(np.longdouble)
info = np.finfo(np.longdouble)
print(f"np.longdouble size : {ld.itemsize} bytes")
print(f"  mantissa bits    : {info.nmant + 1}")
print(f"  decimal digits   : {info.precision}")
print(f"  eps              : {info.eps}")
print(f"np.float128 exists : {hasattr(np, 'float128')}")
print()

# 1 + eps_float64/2 is the smallest step float64 cannot represent but 80-bit can.
step = np.longdouble(np.finfo(np.float64).eps) / 2
one = np.longdouble(1.0)
print(f"1 + eps64/2 > 1    : {bool(one + step > one)}")

total = np.longdouble(0.0)
for _ in range(10):
    total += np.longdouble("0.1")
print(f"sum of ten 0.1s    : {total!r}")
print(f"  ... == 1.0       : {bool(total == np.longdouble(1.0))}")
