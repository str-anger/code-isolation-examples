# 2a — numpy 1.26 vs 2.x: the same code, quietly different numbers ★

Same OS. Same CPU. Same `python3.12`. Only the dependency version changes.

```bash
make s2a          # runs both halves
bash run-manual.sh   # two venvs, built by hand
bash run-uv.sh       # the same result as two one-liners
```

**What changes** ([NEP 50](https://numpy.org/neps/nep-0050-scalar-promotion.html), shipped in numpy 2.0):

| expression | numpy 1.26 | numpy 2.x |
|---|---|---|
| `np.float32(1.0) + 1e-100` | promotes to **float64**, keeps the perturbation | stays **float32**, perturbation vanishes |
| `np.uint8(200) + 100` | widens to int16 → `300` | **overflows** → `44` |
| `repr(np.float32(1.0) * 2)` | `2.0` | `np.float32(2.0)` |
| `np.NaN`, `np.float_`, `np.in1d` | fine | **gone** |

**Punchline.** Only the last row raises an exception. The first three change your *results*
with no error, no warning, and no traceback. A pipeline that used to accumulate in float64
by accident now accumulates in float32, and the only symptom is that the fourth decimal
place moved.

**The `run-manual` / `run-uv` pairing is deliberate.** First the honest version — two
`python3.12 -m venv` directories, two `pip install`s. Then the same experiment as
`uv run --with "numpy==1.26.4"`. The lesson is not "uv is faster"; it is that comparing two
dependency sets should be cheap enough that you actually bother to do it.

**The repr change is the sleeper.** Every doctest and every log line that printed a numpy
scalar now prints something else. That is a test suite full of failures that say nothing
about your science.
