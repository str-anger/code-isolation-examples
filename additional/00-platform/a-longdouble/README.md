# 0a — `long double` is not a type, it is a hardware opinion ★

**Claim.** The same `.py` file, the same numpy version, produces a different numeric type
on different CPUs — and one of the names it uses does not exist on your laptop at all.

```bash
make s0a
```

**What to watch.**

| | macOS arm64 | linux/amd64 |
|---|---|---|
| `np.longdouble` size | 8 bytes | 16 bytes (80-bit x87) |
| decimal digits | 15 | 18 |
| `np.float128` | **does not exist** | exists |
| `1 + eps64/2 > 1` | `False` | `True` |

**Punchline.** On Apple Silicon `np.longdouble` is just `float64`. Code that reaches for
extra precision silently gets none. Worse, `np.float128` raises `AttributeError` here and
imports fine on your colleague's x86 box — so the bug report reads "works on my machine"
and it is literally true.

**Why it matters to a researcher.** Every convergence threshold, every "is this residual
small enough" comparison, is being evaluated at a precision your source code never states.
