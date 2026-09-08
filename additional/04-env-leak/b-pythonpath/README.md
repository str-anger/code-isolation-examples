# 4b — PYTHONPATH walks straight into your venv  ★

The demo everyone thinks they already understand, right up until the moment it
bites them in CI.

```
make s4b
```

`ghostlib` is not installed. It is not in any lockfile, `pip list` does not show
it, and `pip freeze` will never mention it. One environment variable makes it
importable inside an otherwise pristine virtual environment.

Four steps: a clean venv that correctly fails to import it; the identical
command with `PYTHONPATH` set; a `--system-site-packages` venv for comparison;
then the three ways to shut the door (`-I`, `env -i`, `uv run --isolated`).

## Why this one is the primary

It is fully deterministic, needs no network, no Docker and no third-party
packages, and it runs in about two seconds. If the conference wifi dies this is
the demo that still works.

The point to land: a venv is a *search path*, not a sandbox. Reproducing a bug
means reproducing `sys.path`, not just `requirements.txt`.
