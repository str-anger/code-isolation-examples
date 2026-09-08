# 3 / uv — add, lock, sync, frozen

```
make s3uv
```

The thing worth pointing at here is `requires-python = ">=3.12,<3.13"` in
`pyproject.toml`. uv treats the interpreter as part of the resolution problem
rather than as something you were supposed to arrange beforehand — which is
exactly the gap section 1 was about.

The demo walks through `uv lock`, `uv sync --frozen`, `--no-dev`, and the
ephemeral `uv run --with` form that section 2 leans on.

Two flags to remember:

- `--frozen` — fail rather than silently re-resolve. This is the CI setting.
- `--no-dev` — the production install, without the dev group.

`uv.lock` records hashes by default, so the `--generate-hashes` step pip needs
has no equivalent here.
