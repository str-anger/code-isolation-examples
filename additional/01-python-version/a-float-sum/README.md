# 1a — `sum()` changed its mind in 3.12 ★

**Claim.** A builtin you have used since your first week returns a different number
depending on which interpreter runs it. No imports, no dependencies, no C extensions.

```bash
make s1a
```

| | 3.10 / 3.11 | 3.12 / 3.13 / 3.14 |
|---|---|---|
| `sum([0.1]*10)` | `0.9999999999999999` | `1.0` |
| `== 1.0` | `False` | `True` |
| `sum([1e100, 1.0, -1e100])` | `0.0` | `1.0` |

**Why.** Python 3.12 switched `sum()` to [Neumaier compensated summation](https://github.com/python/cpython/issues/100425)
for floats. It is strictly *more* accurate — which is exactly what makes it dangerous:
the change is invisible, beneficial, and silently alters the output of every accumulation
in your codebase.

**Punchline for researchers.** If a threshold in your pipeline is `if total == 1.0` or
`if abs(err) < tol`, upgrading Python can flip it. Your results are a function of your
interpreter version, and nothing in `requirements.txt` records that.

**The lesson, not the fix.** `math.fsum` is exact in every version — but the point is not
"use fsum". The point is that you did not know the semantics moved, so you did not know to
pin the interpreter. Section 3 shows where the interpreter version actually gets written down
(`requires-python`, `.python-version`, the lockfile, the Docker base image).
