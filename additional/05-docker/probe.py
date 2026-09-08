"""One payload, run identically everywhere. Output is one key/value per line so two
runs can be diffed straight against each other."""

import os
import platform
import sys

import numpy as np


def blas_name() -> str:
    try:
        cfg = np.show_config("dicts")
    except (TypeError, AttributeError):
        return "unknown"
    blas = (cfg or {}).get("Build Dependencies", {}).get("blas", {})
    return f"{blas.get('name', 'unknown')} {blas.get('version', '')}".strip()


def line(key: str, value: object) -> None:
    # Width must exceed the longest key so compare.py can always split on two spaces.
    print(f"{key:<24} {value}")


line("machine", platform.machine())
line("sys.platform", sys.platform)
line("libc", " ".join(platform.libc_ver()) or "n/a")
line("python", sys.version.split()[0])
line("numpy", np.__version__)
line("blas", blas_name())

line("longdouble bytes", np.dtype(np.longdouble).itemsize)
line("longdouble digits", np.finfo(np.longdouble).precision)
line("has np.float128", hasattr(np, "float128"))

line("sum([0.1]*10)", repr(sum([0.1] * 10)))

rng = np.random.default_rng(0)
a = rng.standard_normal((512, 512), dtype=np.float32)
b = rng.standard_normal((512, 512), dtype=np.float32)
total = float((a @ b).sum())
line("matmul sum", repr(total))
line("matmul sum hex", total.hex())

for var in (
    "OMP_NUM_THREADS",
    "OPENBLAS_NUM_THREADS",
    "MKL_NUM_THREADS",
    "VECLIB_MAXIMUM_THREADS",
    "LANG",
):
    line(var, os.environ.get(var, "<unset>"))
