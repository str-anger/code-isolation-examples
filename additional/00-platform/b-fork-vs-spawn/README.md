# 0b — fork, spawn, forkserver: three different programs

**Claim.** `multiprocessing.Pool` does not mean one thing. The default start method
depends on your operating system *and*, since 3.14, on your Python version.

```bash
make s0b
```

| | start method | workers inherit module globals? |
|---|---|---|
| macOS, any version | `spawn` | no — module is re-imported per worker |
| Linux, ≤ 3.13 | `fork` | yes — free, instant, copy-on-write |
| Linux, 3.14+ | `forkserver` | no — [gh-84559](https://github.com/python/cpython/issues/84559) |

**Punchline.** A researcher loads a 5-million-row table at module level and maps over it.
On the Linux cluster it is free. On the reviewer's MacBook every worker re-imports the
module and reloads the table — so the "parallel" version is slower than the serial one,
and any module-level side effect happens N times. In 3.14 the cluster starts behaving
like the MacBook.

**The fix is one line:** `mp.get_context("spawn")` — state the model you actually rely on
instead of inheriting the platform's default.

> Note: this demo is also a good place to mention that `fork` in a process that already has
> threads has always been unsafe, which is exactly why the default changed.
