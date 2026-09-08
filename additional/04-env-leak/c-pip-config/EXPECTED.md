# Expected output — 4c pip config

`make s4c`. Captured 2026-09-03, pip 26.0.

1. Clean install from the intended index:
   `demo_pkg 1.0.0 — the package you meant`

2. Identical command, with `PIP_EXTRA_INDEX_URL` pointing at the impostor:
   `demo_pkg 9.9.9 — NOT the package you meant`

3. Mitigation 1, pinning `demo-pkg==1.0.0`, still with the extra index set:
   `demo_pkg 1.0.0 — NOT the package you meant`

   The pin held. The provenance did not. Both indexes publish a 1.0.0 and pip
   picked one of them for you. Which one wins here depends on index ordering and
   your pip version — that unpredictability *is* the finding.

4. Mitigation 2, `--require-hashes`, exits 1 with pip's own wording:

```
ERROR: THESE PACKAGES DO NOT MATCH THE HASHES FROM THE REQUIREMENTS FILE.
If you have updated the package versions, please update the hashes. Otherwise,
examine the package contents carefully; someone may have tampered with them.
    demo-pkg==1.0.0 from .../index-impostor/demo-pkg/demo_pkg-1.0.0-py3-none-any.whl
        Expected sha256 6abc6577e29d2f96427227ad2d1baddd81dc94459c301434f419592fae547bc0
             Got        0d611652fa73e89c15507fe5bf7a02b950070d19bdc91b7445a253e19294aeb0
```

5. Mitigation 3 prints `False` — `env -i` dropped the variable entirely.

Overall exit code 0 (step 4's failure is caught and reported as expected).

The two hashes are regenerated on every `make preflight`, so the exact digests
above will not match yours. The `Expected`/`Got` mismatch is what matters.
