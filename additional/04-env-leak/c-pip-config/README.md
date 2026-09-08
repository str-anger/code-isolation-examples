# 4c — pip config can swap the package you install

Two local indexes, both offering `demo-pkg`. The official one has 1.0.0. The
impostor has 9.9.9. No network involved — both are `file://` URLs built by
`make_index.py`.

```
make s4c
```

The install command never changes. `PIP_EXTRA_INDEX_URL` does, and pip
cheerfully picks the highest version it can see across every index it knows
about. That is documented behaviour, not a bug, and it is the mechanism behind
real dependency-confusion attacks.

Then three mitigations, in increasing order of how much they actually help:
pin the version, require hashes, or refuse to inherit the environment at all.

The uncomfortable part: nothing in your `requirements.txt` records which index
it was resolved against.
