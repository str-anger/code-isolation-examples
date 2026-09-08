# 3 / poetry — add, lock, install

```
make s3poetry
```

Functionally the same story as uv, with different spelling. The part worth
slowing down for is the caret.

| spec | expands to |
| --- | --- |
| `^1.26` | `>=1.26,<2.0.0` |
| `^0.3` | `>=0.3,<0.4` |
| `~1.26` | `>=1.26,<1.27.0` |

`^1.26` is the line that stops numpy 2 from arriving unannounced — which, per
demo 2a, is the difference between `np.float32(1) + 1e-100` underflowing and not.

`^0.3` behaving differently from `^1.26` catches people out constantly: below
1.0, the caret protects the first non-zero component instead of the major.

The demo sets `POETRY_VIRTUALENVS_IN_PROJECT=1` so the environment lands in
`.venv/` next to the project and `make clean` can remove it. That is itself an
example of section 4: the tool is configured by an environment variable that is
not recorded anywhere in the project.
