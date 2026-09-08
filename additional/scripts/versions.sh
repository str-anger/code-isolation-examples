#!/usr/bin/env bash
# Which interpreters does this machine actually have? Demo 1a's opening slide.
set -u
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

hdr "Interpreters visible on PATH right now"
for v in "${ALL_PYTHONS[@]}" 3.14t; do
    if have "python$v"; then
        printf '  python%-6s %-9s %s\n' "$v" \
            "$(python"$v" -c 'import sys;print(sys.version.split()[0])')" \
            "$(command -v python"$v")"
    else
        printf '  python%-6s %s—%s\n' "$v" "$DIM" "$RST"
    fi
done

printf '\n'
note "And the ambiguous ones people actually type:"
for name in python python3; do
    if have "$name"; then
        printf '  %-8s -> %-9s %s\n' "$name" \
            "$($name -c 'import sys;print(sys.version.split()[0])')" \
            "$(command -v "$name")"
    else
        printf '  %-8s %s—%s\n' "$name" "$DIM" "$RST"
    fi
done

moral "'python3' is a symlink someone else chose for you. Name the version you mean."
