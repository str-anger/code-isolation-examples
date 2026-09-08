# 2b — pytest 8 stops calling your `setup()`

**Claim.** "The tests pass" is a statement about your test runner's version, not only about
your code.

```bash
make s2b
```

| | pytest 7 | pytest 8 |
|---|---|---|
| `setup()` on a test class | called before each test | **silently not called** |
| result | 2 passed | 2 errors — `AttributeError: 'TestExperiment' object has no attribute 'samples'` |

**Why.** pytest 8.0 [removed nose-style](https://docs.pytest.org/en/stable/deprecations.html#support-for-tests-written-for-nose)
`setup()` / `teardown()` methods. The rename to `setup_method()` happened years ago; the
compatibility shim finally went away.

**Punchline.** Here the failure is loud, which is the lucky case. The dangerous variant is a
`setup()` that only *populates optional state* — then pytest 8 leaves it unset, the
assertions still pass, and you have a green suite that no longer tests what it claims to.

**What this section is really about.** Your test dependencies are dependencies too. A
`pytest` with no upper bound in a `[dev]` group is an unpinned input to every claim your CI
badge makes.
