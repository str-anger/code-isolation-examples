# 4d — the rest of the environment

A quick tour, no setup required:

```
make s4d
```

- `PYTHONHASHSEED` — string hashes are randomised per process. Anything that
  iterates a set and takes the first element is only reproducible if this is set.
- `LC_ALL` / `LANG` — `locale.strxfrm` sorting changes, so your output files and
  diffs change with it.
- `PYTHONWARNINGS=error` — promotes deprecation warnings to exceptions.
- `PYTHONDONTWRITEBYTECODE` — changes whether `.pyc` files appear.

The last command dumps every `PYTHON*`, `PIP_*`, `LC_*` and thread variable set
in your current shell. That is the one to run on the machine where the bug
*doesn't* reproduce.
