# Code Isolation

*What do you actually mean when you say "this code works"?*

Every demo in this repository is the same experiment: take one file, change
exactly one thing about the world around it, and watch the answer change. No
tricks, no contrived edge cases — the numpy, pytest and CPython that everybody
already has.

The changes go from coarse to fine:

```
platform  →  interpreter  →  dependencies  →  environment  →  image
```

By the end there is a checklist. Everything on it that you do not pin, somebody
else pins for you.

---

## Quickstart

```bash
make preflight     # once, before the talk: builds venvs, indexes, docker images
make               # the menu
make s1a           # run one demo
make check         # run all of them
make clean         # remove everything preflight generated
```

Every demo is a folder with a `README.md` (the claim), a `run.sh` (the evidence)
and an `EXPECTED.md` (what it printed on the presenter's machine). The `run.sh`
scripts echo each command before running it, so you can follow along without
squinting at a prompt.

`★` marks the demo that gets shown live in the 45-minute version. The rest are
there so you can go deeper afterwards.

## Prerequisites

- `python3.10` … `python3.14` on `PATH` as separate binaries, plus `python3.14t`
  for the free-threading demo. Nothing here uses a version manager to fetch
  interpreters — pointing at `python3.12` explicitly *is* part of the lesson.
- `uv`, `poetry`, Docker Desktop.
- Missing pieces degrade gracefully: each demo skips with a note telling you the
  `brew install` line that would fix it.

---

## 0 — Platform: OS and CPU architecture

The floor everything else stands on. Two machines running "the same" Python and
the same numpy do not agree about what a floating-point number is.

| | |
| --- | --- |
| `make s0a` ★ | `np.longdouble` is 8 bytes on macOS arm64 and 16 on linux/amd64. `np.float128` does not exist on your laptop and does exist on your colleague's. |
| `make s0b` | macOS defaults to `spawn`, Linux to `fork` — and 3.14 changed Linux to `forkserver`. Whether your worker sees a module global depends on all three. |
| `make s0c` | A pin that cannot be installed: `numpy==1.19.5` has no arm64 wheel. The same pin resolves fine for `manylinux2014_x86_64`. |

The `longdouble` story has a third act that section 5 pays off: on **linux/arm64**
it is 16 bytes with 33 decimal digits (true quad), on **linux/amd64** it is
16 bytes with 18 digits (80-bit x87 padded out). Checking `itemsize` would have
told you they matched. They do not.

## 1 — Interpreter version (3.10 → 3.14)

Same machine, same files, five interpreters, invoked directly.

| | |
| --- | --- |
| `make s1a` ★ | `sum([0.1]*10) == 1.0` is `False` on 3.10/3.11 and `True` on 3.12+. Stdlib only — no imports, no dependencies. |
| `make s1b` | PEP 701 and PEP 695 syntax that ≤3.11 cannot even parse, next to `distutils` and `assertEquals`, which 3.12 removed. Nothing is green on every version. |
| `make s1c` | The GIL is now optional. Same threaded workload on `python3.13` and `python3.14t`. |

3.12 switched `sum()` to Neumaier compensated summation. It is *more* accurate,
which is what makes it dangerous: the change is invisible, beneficial, and
silently moves the output of every accumulation you have ever written.

## 2 — Dependency versions

Same OS, same CPU, same `python3.12`. Only the version of one library moves.

| | |
| --- | --- |
| `make s2a` ★ | numpy 1.26 vs 2.x under NEP 50. `np.float32(1) + 1e-100` keeps the perturbation on one and discards it on the other. `np.uint8(200) + 100` is `300` or `44`. |
| `make s2b` | pytest 8 removed nose-style `setup()`. Your fixture stops running and your suite does not tell you. |
| `make s2c` | One `requirements.in`, resolved twice, six months apart. |

Only the removals raise exceptions. The promotion changes alter your *results*
with no error, no warning and no traceback.

## 3 — Declaring the intent: pip, uv, poetry

The first three sections are the problem. This one is the vocabulary.

| | |
| --- | --- |
| `make s3pip` | `requirements.in` → compile → `--generate-hashes` → `--require-hashes`. Then corrupt a hash and watch pip refuse. |
| `make s3uv` | `uv lock`, `uv sync --frozen`, `--no-dev`, and the ephemeral `uv run --with` that section 2 leans on. |
| `make s3poetry` | What `^1.26` really expands to, and why `poetry install --without dev` does **not** remove pytest but `poetry sync` does. |
| `make s3pre` | `--pre` is global. Ask for one package, get a release candidate of a transitive dependency you never named. |

[`03-tooling/README.md`](03-tooling/README.md) has the full "same intent, three
dialects" table — every row is one thing you might want to say, in all three
languages.

## 4 — The global environment leaks in

You pinned the platform, the interpreter and the dependencies. The shell still
gets a vote.

| | |
| --- | --- |
| `make s4a` | Thread-count variables change wall time, and sometimes the last bits of the result. |
| `make s4b` ★ | `PYTHONPATH` makes a package that is in no lockfile importable inside a pristine venv. Then the three ways to shut the door. |
| `make s4c` | `PIP_EXTRA_INDEX_URL` swaps the package you install for one with a higher version number. Two local indexes, no network. This is dependency confusion. |
| `make s4d` | `PYTHONHASHSEED`, `LC_ALL`, `PYTHONWARNINGS` — and a command that dumps everything currently set in your shell. |

A virtual environment is a *search path*, not a sandbox. Reproducing a bug means
reproducing `sys.path`, not just `requirements.txt`.

## 5 — Docker, and what it does not fix

| | |
| --- | --- |
| `make s5arch` ★ | One Dockerfile, one `uv.lock`, two architectures. Same CPython, same numpy, same glibc, same OpenBLAS — different answer. |
| `make s5env` | `docker run -e` reaches into the "isolated" container and changes the result without rebuilding a layer. |
| `make s5drift` | `python:3.12-slim` is a bookmark. `@sha256:…` is a pin. |

Section 5 is where the loop closes: the dependency graph was never the variable.
The CPU was.

---

## The checklist

Five layers. Each one is a question with a written-down answer, or it is a
guess someone else makes on your behalf.

| layer | pinned by | demo |
| --- | --- | --- |
| platform — OS + CPU arch | base image, `--platform`, wheel tags | `s0a` `s5arch` |
| interpreter | `requires-python`, `.python-version`, the base image tag | `s1a` |
| dependencies | a lockfile — with hashes | `s2a` `s3pip` |
| environment | scrubbed, not inherited (`-I`, `env -i`, `--isolated`) | `s4b` `s4c` |
| image | `FROM …@sha256:`, not `FROM …:latest` | `s5drift` |

The honest version of "it works on my machine" is: *it works on this CPU
architecture, on this interpreter, against these exact artefacts, with this
environment, and I can prove all five.*

## Layout

```
scripts/          preflight, versions, reset, check
00-platform/      OS and CPU architecture
01-python-version/  3.10 → 3.14
02-dependency-versions/  numpy and pytest across major versions
03-tooling/       pip, uv, poetry, and prereleases
04-env-leak/      PYTHONPATH, pip config, thread and locale variables
05-docker/        cross-arch images; standalone, shareable on its own
```

`05-docker/` deliberately carries its own `pyproject.toml` and `uv.lock` so that
folder can be handed to someone in isolation and still build.
