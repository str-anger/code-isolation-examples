"""Rewrites every sha256 in a requirements file so the install must fail."""

import re
import sys

src, dst = sys.argv[1], sys.argv[2]
text = open(src).read()
tampered, count = re.subn(r"(--hash=sha256:)[0-9a-f]{64}", r"\g<1>" + "0" * 64, text)
open(dst, "w").write(tampered)
print(f"replaced {count} hashes with zeroes")
