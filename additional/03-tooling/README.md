# 3 — Declaring intent: pip, uv, poetry

Sections 0 to 2 showed that the platform, the interpreter and the dependency
versions all change your results. This section is about writing that down so a
machine can reproduce it.

All three tools do the same four things. They just disagree about the spelling.

## The same intent, three dialects

| intent | pip (+ pip-tools) | uv | poetry |
| --- | --- | --- | --- |
| declare a range | edit `requirements.in`:<br>`numpy>=1.26,<2` | `uv add "numpy>=1.26,<2"` | `poetry add "numpy@^1.26"` |
| pin exactly | `numpy==1.26.4` | `uv add "numpy==1.26.4"` | `poetry add "numpy@==1.26.4"` |
| add a dev dependency | a second `dev-requirements.in` | `uv add --dev pytest` | `poetry add --group dev pytest` |
| create the lock | `pip-compile requirements.in` | `uv lock` | `poetry lock` |
| install from the lock | `pip install -r requirements.txt` | `uv sync` | `poetry install` |
| make the env match the lock exactly | *(recreate the venv)* | `uv sync` (always exact) | `poetry sync` |
| install, refusing to re-resolve | `pip install --require-hashes -r ...` | `uv sync --frozen` | `poetry install` (fails on a stale lock) |
| exclude dev deps | use only the prod file | `uv sync --no-dev` | `poetry sync --without dev` |
| allow a prerelease | `pip install --pre` | `uv add "numpy" --prerelease=allow` | `allow-prereleases = true` |
| bump exactly one package | `pip-compile -P numpy` | `uv lock --upgrade-package numpy` | `poetry update numpy` |
| choose the interpreter | `python3.12 -m venv` first | `uv run --python 3.12` | `poetry env use python3.12` |
| verify artefact bytes | `--generate-hashes` + `--require-hashes` | hashes are in `uv.lock` by default | hashes are in `poetry.lock` by default |

## Caret and tilde, decoded

Poetry's `^` and pip's `~=` are the two that get misread most often.

| spec | means | note |
| --- | --- | --- |
| `^1.26` (poetry) | `>=1.26,<2.0.0` | will **not** take numpy 2 |
| `^0.3` (poetry) | `>=0.3,<0.4` | below 1.0 the rules change |
| `~=1.26` (pip) | `>=1.26,<2.0` | |
| `~=1.26.4` (pip) | `>=1.26.4,<1.27.0` | the extra component matters |
| `>=1.26` | anything newer, forever | this is how you get numpy 2 by surprise |

That last row is section 2's demo in one line.

## Run them

```
make s3pip      # compile, hashes, and a deliberately tampered hash
make s3uv       # add / lock / sync / --frozen
make s3poetry   # add / lock / install, and what ^ expands to
make s3pre      # what --pre does to a lock, via the dev group
```

Each folder is a real, working project — not a snippet. `make clean` removes the
venvs they create.

## The point

A lockfile is a claim that says: *given the same platform and the same
interpreter, these exact artefacts.* Every one of those tools produces one.
None of them pins the two things sections 0 and 5 are about.
