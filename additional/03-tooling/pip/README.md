# 3 / pip — compile, hash, verify

```
make s3pip
```

`requirements.in` holds the intent (`numpy>=1.26,<2`). `uv pip compile
--generate-hashes` turns it into `requirements.txt`: one exact version plus a
sha256 for every wheel that could satisfy it on any platform.

Then the demo changes a single character in one hash and tries to install again.
pip refuses.

Worth saying out loud: pip is the only one of the three tools where hashes are
opt-in. `uv.lock` and `poetry.lock` both record them by default. A
`requirements.txt` full of `==` pins and no hashes tells you *which version*, not
*which bytes* — and demo 4c showed those are different questions.

`constraints.txt` covers the other half: pinning a transitive dependency without
promoting it to a direct one.
