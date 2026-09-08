"""Adding up ten copies of 0.1. Standard library only, so this runs anywhere."""

import math
import sys

print(f"  python           : {sys.version.split()[0]}")

tenths = [0.1] * 10
total = sum(tenths)
print(f"  sum([0.1] * 10)  : {total!r}")
print(f"  ... == 1.0       : {total == 1.0}")

# Catastrophic cancellation: the 1.0 is lost entirely unless the sum compensates.
cancel = sum([1e100, 1.0, -1e100])
print(f"  sum(1e100,1,-1e100): {cancel!r}")

print(f"  math.fsum        : {math.fsum(tenths)!r}   (exact in every version)")
