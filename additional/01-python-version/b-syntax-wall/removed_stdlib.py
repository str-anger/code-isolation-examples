"""distutils was removed in 3.12 (PEP 632). Plenty of setup.py files still import it."""

import sys

print(f"  python : {sys.version.split()[0]}")

try:
    import distutils.version

    print(f"  import distutils -> OK  ({distutils.__file__})")
    print(f"  LooseVersion('1.9') < LooseVersion('1.10') = "
          f"{distutils.version.LooseVersion('1.9') < distutils.version.LooseVersion('1.10')}")
except ModuleNotFoundError as exc:
    print(f"  import distutils -> ModuleNotFoundError: {exc}")
