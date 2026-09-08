# 2c — the same requirements file, resolved twice

**Claim.** `requirements.in` is not an environment. It is a *query*. The answer depends on
when you ask.

```bash
make s2c
```

`uv pip compile` is run twice on an unchanged three-line file — once against today's index,
once with `--exclude-newer 2024-01-01`:

| | Jan 2024 | today |
|---|---|---|
| `numpy>=1.26` | `1.26.x` | `2.x` |
| `pandas` | `2.1.x` | `2.x` (newer) |
| `pytest` | `7.4.x` | `8.x` / `9.x` |

**Punchline.** Both resolutions satisfy the stated constraints perfectly. And between them
sit *both* of the breaking changes from this section — NEP 50 (demo 2a) and the pytest
`setup()` removal (demo 2b). A paper that shipped this file is not reproducible, and
`pip install -r requirements.txt` will tell you it succeeded.

**The point of `--exclude-newer`.** It is a time machine for resolution, which makes it an
excellent way to *test* whether your pins are doing anything. If pinning worked, both
outputs would be identical.

**What a lockfile actually is.** Exactly this — one resolution, captured with exact versions
and hashes, committed to the repo. That is the whole of section 3.
