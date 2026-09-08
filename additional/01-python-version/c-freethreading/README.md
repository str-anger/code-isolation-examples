# 1c — same version number, different runtime

**Claim.** `python3.14` and `python3.14t` report the same version and behave completely
differently under threads. Free-threaded CPython is officially supported as of
[PEP 779](https://peps.python.org/pep-0779/).

```bash
brew install python-freethreading   # provides python3.14t
make s1c
```

| build | `sys._is_gil_enabled()` | speedup on N threads |
|---|---|---|
| `python3.12` / `3.13` / `3.14` | `True` | ~1x (threads take turns) |
| `python3.14t` | `False` | ~Nx (real parallelism) |

**Punchline.** For twenty years the correct advice was "threads don't help CPU-bound Python,
use multiprocessing". That advice is now build-dependent. The same script, on the same
machine, on the same Python *version*, is either serial or parallel depending on which
binary you invoked.

**Why researchers should care.** This is the first case in the tutorial where the thing you
failed to pin is not a version number at all — it is a *compile-time option of the
interpreter*. `requirements.txt` has no field for it. `.python-version` has no field for it.
Only the base image or an explicit interpreter path records it.

> If `python3.14t` is not installed the demo still runs and simply shows three flat ~1x
> results, which makes the point less vividly.
