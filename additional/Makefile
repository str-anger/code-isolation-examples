.DEFAULT_GOAL := help
SHELL := /bin/bash

# ★ marks the demo that gets run live in the 45-minute version.

.PHONY: help preflight versions clean check
help:
	@echo ""
	@echo "  Code Isolation — demo runner"
	@echo ""
	@echo "  make preflight   install/build everything needed before the talk"
	@echo "  make versions    show the interpreters on this machine"
	@echo "  make check       run every demo end to end"
	@echo "  make clean       remove generated venvs, indexes, build dirs"
	@echo ""
	@echo "  0  platform: OS + CPU architecture"
	@echo "    make s0a       longdouble precision changes with the arch   ★"
	@echo "    make s0b       fork vs spawn vs forkserver"
	@echo "    make s0c       wheel roulette: pins that cannot be installed"
	@echo ""
	@echo "  1  interpreter version (3.10 - 3.14)"
	@echo "    make s1a       sum([0.1]*10) changes in 3.12                ★"
	@echo "    make s1b       syntax and stdlib walls between versions"
	@echo "    make s1c       free-threading: the GIL is now optional"
	@echo ""
	@echo "  2  dependency versions"
	@echo "    make s2a       numpy 1.26 vs 2.x quietly changes results    ★"
	@echo "    make s2b       pytest 8 silently stops running your setup"
	@echo "    make s2c       the same requirements file, resolved twice"
	@echo ""
	@echo "  3  declaring intent: pip / uv / poetry"
	@echo "    make s3pip     pip + pip-compile + hashes"
	@echo "    make s3uv      uv add / lock / sync"
	@echo "    make s3poetry  poetry add / lock / install"
	@echo "    make s3pre     what --pre does to your lock"
	@echo ""
	@echo "  4  the global environment leaks in"
	@echo "    make s4a       thread env vars change speed and results"
	@echo "    make s4b       PYTHONPATH walks straight into your venv     ★"
	@echo "    make s4c       pip config can swap the package you install"
	@echo "    make s4d       assorted PYTHON* variables"
	@echo ""
	@echo "  5  docker, and what it does not fix"
	@echo "    make s5arch    same image spec, two architectures           ★"
	@echo "    make s5env     -e still overrides everything inside"
	@echo "    make s5drift   'python:3.12-slim' is a moving target"
	@echo ""

preflight: ; @bash scripts/preflight.sh
versions:  ; @bash scripts/versions.sh
clean:     ; @bash scripts/reset.sh

.PHONY: s0a s0b s0c s1a s1b s1c s2a s2b s2c s3pip s3uv s3poetry s3pre s4a s4b s4c s4d s5arch s5env s5drift
s0a: ; @bash 00-platform/a-longdouble/run.sh
s0b: ; @bash 00-platform/b-fork-vs-spawn/run.sh
s0c: ; @bash 00-platform/c-wheel-roulette/run.sh

s1a: ; @bash 01-python-version/a-float-sum/run.sh
s1b: ; @bash 01-python-version/b-syntax-wall/run.sh
s1c: ; @bash 01-python-version/c-freethreading/run.sh

s2a: ; @bash 02-dependency-versions/a-nep50/run.sh
s2b: ; @bash 02-dependency-versions/b-pytest-nose/run.sh
s2c: ; @bash 02-dependency-versions/c-unpinned-drift/run.sh

s3pip:    ; @bash 03-tooling/pip/run.sh
s3uv:     ; @bash 03-tooling/uv/run.sh
s3poetry: ; @bash 03-tooling/poetry/run.sh
s3pre:    ; @bash 03-tooling/prerelease/run.sh

s4a: ; @bash 04-env-leak/a-threads/run.sh
s4b: ; @bash 04-env-leak/b-pythonpath/run.sh
s4c: ; @bash 04-env-leak/c-pip-config/run.sh
s4d: ; @bash 04-env-leak/d-misc-envvars/run.sh

s5arch:  ; @bash 05-docker/run-both-arches.sh
s5env:   ; @bash 05-docker/run-env-override.sh
s5drift: ; @bash 05-docker/run-base-drift.sh

check:
	@bash scripts/check.sh
