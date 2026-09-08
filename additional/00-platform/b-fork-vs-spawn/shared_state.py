"""A global built at import time. Whether the workers can see it depends on the OS."""

import multiprocessing as mp
import os

# Deliberately built at import time, the way a module-level dataset or model usually is.
TABLE = list(range(5_000_000))
LOADED_BY = os.getpid()


def probe(i):
    return {
        "worker_pid": os.getpid(),
        "table_len": len(TABLE),
        "table_was_inherited": os.getpid() != LOADED_BY and len(TABLE) > 0,
    }


def main():
    print(f"start method  : {mp.get_start_method()}")
    print(f"parent pid    : {os.getpid()}")
    print(f"TABLE built by: pid {LOADED_BY}, {len(TABLE):,} rows")

    with mp.Pool(2) as pool:
        results = pool.map(probe, range(2))

    for r in results:
        print(
            f"  worker {r['worker_pid']}: sees {r['table_len']:,} rows"
            f"  inherited={r['table_was_inherited']}"
        )

    if mp.get_start_method() == "fork":
        print("\n=> fork: the child got the parent's memory for free. No re-import, no pickling.")
    else:
        print(f"\n=> {mp.get_start_method()}: the child re-imported this module from scratch.")
        print("   Everything at module level ran again, in every worker.")


if __name__ == "__main__":
    main()
