# 1b — the wall between 3.11 and 3.12

**Claim.** There is no single interpreter on this machine that can run all four of these
files. Two need 3.12+, two need ≤3.11.

```bash
make s1b
```

| file | ≤ 3.11 | 3.12+ | what it uses |
|---|---|---|---|
| `pep701.py` | **SyntaxError** | ok | quote reuse inside an f-string |
| `pep695.py` | **SyntaxError** | ok | `def f[T](...)`, `type X = ...` |
| `removed_stdlib.py` | ok | **ModuleNotFoundError** | `import distutils` (PEP 632) |
| `test_legacy_unittest.py` | ok | **AttributeError** | `self.assertEquals` (gh-89325) |

**The important detail.** The first two fail at *parse* time. Not when the function is
called — when the file is read. No `try/except` can catch it, no feature flag helps, and a
single new-syntax line anywhere in a module makes the whole module unimportable on an older
interpreter.

**Punchline.** The removals hurt more than the additions. `distutils` and `assertEquals`
are in thousands of old `setup.py` files and test suites; upgrading to 3.12 is where a
research codebase from 2019 goes to die. This is why `requires-python` in `pyproject.toml`
exists — and why nobody fills it in honestly.
