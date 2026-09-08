"""CPU-bound work spread over threads. How much it helps depends on the build."""

import os
import sys
import threading
import time

WORK = 6_000_000


def burn(n):
    total = 0
    for i in range(n):
        total += i * i
    return total


def timed(n_threads):
    per_thread = WORK // n_threads
    threads = [threading.Thread(target=burn, args=(per_thread,)) for _ in range(n_threads)]
    start = time.perf_counter()
    for t in threads:
        t.start()
    for t in threads:
        t.join()
    return time.perf_counter() - start


gil = getattr(sys, "_is_gil_enabled", lambda: True)()
n = min(8, os.cpu_count() or 4)

print(f"  python        : {sys.version.split()[0]}")
print(f"  GIL enabled   : {gil}")
print(f"  threads used  : {n}")

baseline = timed(1)
parallel = timed(n)
print(f"  1 thread      : {baseline:6.3f}s")
print(f"  {n} threads     : {parallel:6.3f}s")
print(f"  speedup       : {baseline / parallel:5.2f}x")
