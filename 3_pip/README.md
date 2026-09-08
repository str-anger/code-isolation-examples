# 3_pip — minimal editable install with pip

Four files, no tooling beyond `venv` and `pip`.

```
pyproject.toml   name, dependencies, entry point
adder.py         add(a, b)
main.py          entry point, imports add
commands.sh      prints the commands below
```

Dependencies are declared in `pyproject.toml`:

```toml
dependencies = [
    "numpy>=2.0.0",
]
```

## Commands

`bash commands.sh` prints these without running anything.

```bash
python3.12 -m venv .venv
source .venv/bin/activate

pip install --upgrade pip
pip install -e .

demo-add          # console script from [project.scripts]
python main.py    # same thing, without the script

pip list
pip show demo-add

deactivate
```

If you would rather not activate, call the venv's pip directly:

```bash
./.venv/bin/pip install -e .
./.venv/bin/demo-add
```

## Notes

`-e` installs a link back to this directory rather than copying the code, so
edits to `adder.py` take effect without reinstalling. The dependency, `numpy`,
is installed normally — editable applies to *this* project, not to what it
depends on.

`py-modules = ["adder", "main"]` is needed because this is a flat layout with
top-level modules rather than a package directory. With a `demo_add/` package or
a `src/` layout, setuptools would find it on its own.
