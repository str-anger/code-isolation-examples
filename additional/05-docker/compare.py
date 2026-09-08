"""Compare two probe.py outputs and print only what disagrees."""

import sys


def load(path: str) -> dict[str, str]:
    rows = {}
    with open(path) as fh:
        for raw in fh:
            if not raw.strip():
                continue
            key, _, value = raw.rstrip("\n").partition("  ")
            rows[key.strip()] = value.strip()
    return rows


left_label, left_path, right_label, right_path = sys.argv[1:5]
left, right = load(left_path), load(right_path)

keys = list(left)
differing = [k for k in keys if left.get(k) != right.get(k)]
same = [k for k in keys if k not in differing]

kw = max((len(k) for k in keys), default=0)
lw = max([len(left_label)] + [len(left[k]) for k in differing], default=0)

print(f"{'':<{kw}}  {left_label:<{lw}}  {right_label}")
for k in differing:
    print(f"{k:<{kw}}  {left.get(k, ''):<{lw}}  {right.get(k, '')}")

print()
print(f"identical on both: {', '.join(same)}")
