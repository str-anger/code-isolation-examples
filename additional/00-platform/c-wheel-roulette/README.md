# 0c — a version pin your machine cannot honour

**Claim.** `numpy==1.19.5` is not a fact about your project. Whether it installs depends on
four things your requirements file never states: OS, CPU architecture, interpreter version,
and ABI.

```bash
make s0c
```

**What happens.**

1. `pip debug --verbose` prints the *compatible tags* — the list of wheel filenames this
   interpreter is willing to accept. It is machine-specific.
2. `pip download numpy==1.19.5` on macOS arm64 → **no matching distribution**. numpy 1.19
   predates Apple Silicon; no such wheel was ever built.
3. The identical pin with `--platform manylinux2014_x86_64 --python-version 3.9` → downloads
   happily. Same requirement, different machine, different answer.
4. `numpy==2.3.5` → works natively, because someone built `macosx_11_0_arm64` wheels.

**Punchline.** Half of "it doesn't install on my laptop" is not a dependency problem, it is
a platform problem. Locking versions does not help if the version does not exist for you —
that is why the lockfiles in section 3 record *per-platform* resolutions, and why section 5
ends in a container.

> Without `--only-binary=:all:` pip would fall back to building from source, which is how a
> one-line pin turns into a twenty-minute compile and a wall of C errors.
