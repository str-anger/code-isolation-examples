# Isolate and reproduce your solution

## Python is a living creature

Language syntax and backend of the language evolve.
There are changes in syntax and libraries, which are (moslty) incremental.

```bash
python3.10 1_syntax_and_libs.py
python3.13 1_syntax_and_libs.py
```

But also the implementation changes with time:

```bash
python3.10 1_implementation.py
python3.13 1_implementation.py
```

Here, python always had an accurate summation algorithm,
but **never had it as default for sum**.

[Kahan summation](https://en.wikipedia.org/wiki/Kahan_summation_algorithm) and 
[Neumaier modification for it](https://en.wikipedia.org/wiki/Kahan_summation_algorithm#Precision).

## Same python, different dependency versions

A lot of candidates submit `requirements.txt` files with dependencies like this:

```
numpy
pandas
...
```

Let's have a look at numpy [2.5.2](https://pypi.org/project/numpy/2.5.2/#files) and [1.19.3](https://pypi.org/project/numpy/1.19.3/#files).

What may change in 6 months, 5 years?

```bash
.venv310np1/bin/python 2_numpy_promotions.py
.venv310np22/bin/python 2_numpy_promotions.py
.venv313/bin/python 2_numpy_promotions.py
```

It is always worth reading warnings. Yes, they may be overwhelming, but
they are there to help you.
`pytest` eventually changed its setup/teardown approach
(which supported older `nose` tests):

```bash
.venv313pt7/bin/python -m pytest 2_pytest.py
.venv313pt8/bin/python -m pytest 2_pytest.py
.venv313/bin/python -m pytest 2_pytest.py
```

## Sandbox me. Pythonic way!

Can I just have my dependenices listed and work on the project?

If you treat your code a a package, you may do it in a few ways.

This is, first of all, useful, when you do python testing.
Code in `tests/` folder is not included into your python distribution,
and it treats content of `src/` as an external package when you
run tests.
But still, you are allowed to edit-save-rerun.

### Classic "hacker" way

```bash
python3.13 -m venv .venv313pip
.venv313pip/bin/pip install -e 3_pip

# now jump into
source .venv313pip/bin/activate
demo-add

# now edit the function, and repeat!
demo-add

# see your dependencies versions
pip freeze
```

### uv way

`uv` keeps a frozen list of dependencies as a separate file.
Commiting this file is good, when you develop an application,
and it is questionable, when you develop a library.
Why? You don't have control over user's environment, so you
prefer your library to be compatible with a wider range of
dependencies.

```bash
deactivate
cd 3_pip
uv lock
uv sync
uv run demo-add
```

Similar for the `poetry`, but requires different `pyproject.toml` format.

## Is this enough?

"Environment" -- settings in the operating system,
usually configuration files, environment variables,
ssh keys, ..., even a set of installed fonts,
which are individual for every machine. A very good example is
your `$PATH` environment variable, which decides where is your
python, where are binary dependencies, ...

```bash
cat ~/.zshrc
echo $PATH
```

Example of the effect:

```bash
# hash seed is taken from env var
PYTHONHASHSEED=0 python3.12 -c 'print(hash("isolate"))'
PYTHONHASHSEED=1 python3.12 -c 'print(hash("isolate"))'
```

The variable above can be set in `~/.bashrc` file, and you will
never know.

```bash
# locale:
# The C locale is a special locale that is meant to be
# the simplest locale. You could also say that while
# the other locales are for humans, the C locale is
# for computers. It uses ASCII.
LC_ALL=C python3.12 4_locale.py

python3.12 4_locale.py

# or explicitly specify the locale
LC_ALL=en_US.UTF-8 python3.12 4_locale.py
LC_ALL=ru_RU.UTF-8 python3.12 4_locale.py
```

## Platform (CPU + operating system)

If you literally want it to run ON THE SAME MACHINE.
2 levels of definition:
- docker file (~pyproject.toml)
- image (~uv.lock)

And then you may create a container based on the image.

### Prepare environments

```bash
# build docker images
docker build --network=host -t str-anger/u26p313 -f 0_platform.docker .
docker build --platform=linux/amd64 --network=host -t str-anger/u26p313x86 -f 0_platform.docker .

# run a docker container from that image
# arm
docker run -ti --entrypoint /bin/bash --volume .:/root/isolate str-anger/u26p313
# x86
docker run -ti --platform=linux/amd64 --entrypoint /bin/bash --volume .:/root/isolate str-anger/u26p313x86

# on both to see that the files were bridged
cd ~
ls isolate
```

Validate platform, and a dependency version:

```bash
uname -sm
python3.13 -c "import numpy as np; print(np.__version__)"
```

### How the same code runs on different platforms.

And then let's run the script:

```bash
python3.13 isolate/0_platform.py
```

also compare it with 3.13 on a mac:

```bash
.venv313/bin/python 0_platform.py
```

## Additional materials

Additional materials in [additional](./additional/) folder
are prepared with the help of AI and were not validated.
But they expose some other topics where behavior of the code
may diverge, including multithreading, code packaging, and other examples.
