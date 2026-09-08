import numpy as np

print(f"  numpy {np.__version__}")

# 1. A tiny float64 added to a float32 scalar.
#    numpy 1.x promoted to float64 and kept the value; 2.x stays float32 and loses it.
x = np.float32(1.0)
r = x + 1e-100
print(f"  np.float32(1.0) + 1e-100  -> dtype={r.dtype}  value={float(r) - 1.0:.3e} above 1.0")

# 2. Integer overflow that used to silently widen.
u = np.uint8(200)
try:
    with np.errstate(over="ignore"):
        s = u + 100
    print(f"  np.uint8(200) + 100       -> dtype={s.dtype}  value={s}")
except OverflowError as exc:
    print(f"  np.uint8(200) + 100       -> OverflowError: {exc}")

# 3. The repr changed, which breaks every doctest that printed a scalar.
print(f"  repr(np.float32(1.0) * 2) -> {np.float32(1.0) * 2!r}")

# 4. Names that simply vanished.
for name in ("NaN", "float_", "in1d"):
    print(f"  np.{name:7s}                -> {getattr(np, name, '<removed in 2.0>')}")
