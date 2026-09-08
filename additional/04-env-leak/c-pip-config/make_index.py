"""Builds two local PEP 503 indexes that both offer a package called demo-pkg.

One of them is the package you meant. The other one is not, and it has a higher
version number. No network, no PyPI account, nothing to clean up afterwards.
"""

import base64
import hashlib
import shutil
import zipfile
from io import BytesIO
from pathlib import Path

HERE = Path(__file__).parent
DIST = "demo_pkg"


def record_hash(data: bytes) -> str:
    digest = base64.urlsafe_b64encode(hashlib.sha256(data).digest()).rstrip(b"=")
    return f"sha256={digest.decode()}"


def build_wheel(version: str, whoami: str) -> bytes:
    init = (
        f'WHOAMI = "{whoami}"\n'
        f'VERSION = "{version}"\n\n'
        'def hello():\n'
        '    return f"demo_pkg {VERSION} — {WHOAMI}"\n'
    ).encode()

    metadata = (
        "Metadata-Version: 2.1\n"
        f"Name: demo-pkg\n"
        f"Version: {version}\n"
        "Summary: A package used to demonstrate index confusion.\n"
    ).encode()

    wheel = (
        "Wheel-Version: 1.0\n"
        "Generator: make_index.py\n"
        "Root-Is-Purelib: true\n"
        "Tag: py3-none-any\n"
    ).encode()

    distinfo = f"{DIST}-{version}.dist-info"
    entries = [
        (f"{DIST}/__init__.py", init),
        (f"{distinfo}/METADATA", metadata),
        (f"{distinfo}/WHEEL", wheel),
    ]

    record_lines = [f"{name},{record_hash(body)},{len(body)}" for name, body in entries]
    record_lines.append(f"{distinfo}/RECORD,,")
    record = ("\n".join(record_lines) + "\n").encode()

    buf = BytesIO()
    with zipfile.ZipFile(buf, "w", zipfile.ZIP_DEFLATED) as zf:
        for name, body in entries:
            zf.writestr(name, body)
        zf.writestr(f"{distinfo}/RECORD", record)
    return buf.getvalue()


def build_index(root: Path, releases: list[tuple[str, str]]) -> None:
    if root.exists():
        shutil.rmtree(root)
    pkg_dir = root / "demo-pkg"
    pkg_dir.mkdir(parents=True)

    links = []
    for version, whoami in releases:
        filename = f"{DIST}-{version}-py3-none-any.whl"
        (pkg_dir / filename).write_bytes(build_wheel(version, whoami))
        links.append(f'<a href="{filename}">{filename}</a>')
        print(f"  {root.name:<16} demo-pkg {version:<6} {whoami}")

    (root / "index.html").write_text(
        '<!DOCTYPE html><html><body>\n<a href="demo-pkg/">demo-pkg</a>\n</body></html>\n'
    )
    (pkg_dir / "index.html").write_text(
        "<!DOCTYPE html><html><body>\n" + "\n".join(links) + "\n</body></html>\n"
    )


build_index(HERE / "index-official", [("1.0.0", "the package you meant")])

# The impostor shadows the real version number as well as offering a higher one,
# so that pinning alone is not enough to save you.
build_index(
    HERE / "index-impostor",
    [("1.0.0", "NOT the package you meant"), ("9.9.9", "NOT the package you meant")],
)
