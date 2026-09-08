"""A local index with a stable release and a prerelease, plus an app that depends
on it. Used to show that --pre is not scoped to the package you asked for."""

import base64
import hashlib
import shutil
import zipfile
from io import BytesIO
from pathlib import Path

HERE = Path(__file__).parent
ROOT = HERE / "index-local"


def build_wheel(name: str, version: str, requires: list[str]) -> bytes:
    mod = name.replace("-", "_")
    init = f'VERSION = "{version}"\n'.encode()

    meta = [
        "Metadata-Version: 2.1",
        f"Name: {name}",
        f"Version: {version}",
        f"Summary: {name} for the prerelease demo.",
    ]
    meta += [f"Requires-Dist: {r}" for r in requires]
    metadata = ("\n".join(meta) + "\n").encode()

    wheel = (
        "Wheel-Version: 1.0\nGenerator: make_index.py\n"
        "Root-Is-Purelib: true\nTag: py3-none-any\n"
    ).encode()

    distinfo = f"{mod}-{version}.dist-info"
    entries = [
        (f"{mod}/__init__.py", init),
        (f"{distinfo}/METADATA", metadata),
        (f"{distinfo}/WHEEL", wheel),
    ]

    def rec(body: bytes) -> str:
        return "sha256=" + base64.urlsafe_b64encode(hashlib.sha256(body).digest()).rstrip(b"=").decode()

    lines = [f"{n},{rec(b)},{len(b)}" for n, b in entries] + [f"{distinfo}/RECORD,,"]

    buf = BytesIO()
    with zipfile.ZipFile(buf, "w", zipfile.ZIP_DEFLATED) as zf:
        for n, b in entries:
            zf.writestr(n, b)
        zf.writestr(f"{distinfo}/RECORD", ("\n".join(lines) + "\n").encode())
    return buf.getvalue()


RELEASES = {
    "demo-lib": [("1.0.0", []), ("2.0.0rc1", [])],
    "demo-app": [("1.0.0", ["demo-lib>=1.0"])],
}

if ROOT.exists():
    shutil.rmtree(ROOT)
ROOT.mkdir(parents=True)

for name, releases in RELEASES.items():
    pkg_dir = ROOT / name
    pkg_dir.mkdir()
    links = []
    for version, requires in releases:
        fn = f"{name.replace('-', '_')}-{version}-py3-none-any.whl"
        (pkg_dir / fn).write_bytes(build_wheel(name, version, requires))
        links.append(f'<a href="{fn}">{fn}</a>')
        print(f"  {name:<10} {version}")
    (pkg_dir / "index.html").write_text(
        "<!DOCTYPE html><html><body>\n" + "\n".join(links) + "\n</body></html>\n"
    )

(ROOT / "index.html").write_text(
    "<!DOCTYPE html><html><body>\n"
    + "\n".join(f'<a href="{n}/">{n}</a>' for n in RELEASES)
    + "\n</body></html>\n"
)
