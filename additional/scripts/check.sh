#!/usr/bin/env bash
# Run every demo. Nothing here asserts output; it proves the scripts still execute
# and lets you eyeball the results against each EXPECTED.md.
set -u
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

cd "$REPO_ROOT"

demos=(s0a s0b s0c s1a s1b s1c s2a s2b s2c s3pip s3uv s3poetry s3pre
       s4a s4b s4c s4d s5arch s5env s5drift)

failed=()
for d in "${demos[@]}"; do
    hdr "make $d"
    if make -s "$d"; then
        printf '%s✓ %s finished%s\n' "$GRN" "$d" "$RST"
    else
        printf '%s✗ %s exited non-zero%s\n' "$RED" "$d" "$RST"
        failed+=("$d")
    fi
done

hdr "Summary"
if ((${#failed[@]})); then
    warn "non-zero exit from: ${failed[*]}"
    note "some demos are designed to end on a failing command — check against EXPECTED.md"
else
    moral "all ${#demos[@]} demos ran"
fi
