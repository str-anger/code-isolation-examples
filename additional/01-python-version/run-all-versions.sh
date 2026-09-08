#!/usr/bin/env bash
# Run one script under every CPython on this machine. Usage: run-all-versions.sh file.py
set -u
source "$(dirname "${BASH_SOURCE[0]}")/../scripts/lib.sh"

script="$1"
shift || true

for v in "${ALL_PYTHONS[@]}"; do
    if ! have "python$v"; then
        printf '\n%s── python%-5s not installed, skipping%s\n' "$DIM" "$v" "$RST"
        continue
    fi
    printf '\n%s── python%-5s %s%s\n' "$BOLD" "$v" "$(python"$v" -c 'import sys;print(sys.version.split()[0])')" "$RST"
    python"$v" "$script" "$@"
done
