# 4a — thread env vars change speed, and sometimes the answer

```
make s4a
```

One venv, one numpy, one script, run three times. The only difference is
`OMP_NUM_THREADS` / `OPENBLAS_NUM_THREADS` / `VECLIB_MAXIMUM_THREADS`, which the
BLAS reads at import time.

Wall time always changes. Whether the *result* changes depends on your BLAS: it
only moves if the library reassociates the accumulation differently at different
thread counts. On macOS, numpy 2.x links Accelerate and numpy 1.26 links
OpenBLAS — so even the name of the variable that controls this depends on a
dependency version.

If you want a reproducibility difference that is guaranteed rather than likely,
use `make s5arch`, which changes the architecture instead of the thread count.

## What to say

This is the one that ruins benchmarks. Somebody sets `OMP_NUM_THREADS=1` in
their shell profile two years ago, forgets, and then reports that the new
library is four times slower than the old one.
