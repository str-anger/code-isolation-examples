# 3 / prerelease — what `--pre` really does

```
make s3pre
```

A local index (no network) with:

- `demo-app 1.0.0`, which depends on `demo-lib>=1.0`
- `demo-lib 1.0.0` and `demo-lib 2.0.0rc1`

Install `demo-app` normally and you get `demo-lib 1.0.0`. Add `--pre` — still
asking only for `demo-app` — and you get `demo-lib 2.0.0rc1`.

That is the point. `--pre` is a property of the entire resolution, not of the
package you named. It reaches transitive dependencies you have never heard of.

The usual way this happens: someone needs a prerelease of one dev tool, adds
`--pre` to the shared install command, and every production dependency quietly
becomes eligible for release candidates at the same time.

The fix is to name the thing you actually want:

| tool | scoped to one package |
| --- | --- |
| pip | pin it: `demo-lib==2.0.0rc1` |
| uv | `uv add "demo-lib==2.0.0rc1"` — `uv lock --prerelease=allow` is global |
| poetry | `allow-prereleases = true` on that dependency only |
