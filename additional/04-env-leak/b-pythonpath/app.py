"""Reports whether an unlocked package is importable, and where it came from."""

import os
import sys

print(f"sys.prefix    {sys.prefix}")
print(f"PYTHONPATH    {os.environ.get('PYTHONPATH', '<unset>')}")

try:
    import ghostlib
except ImportError as exc:
    print(f"import        FAILED — {exc}")
    sys.exit(0)

print(f"import        OK — {ghostlib.WHOAMI}")
