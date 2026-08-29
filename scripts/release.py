#!/usr/bin/env python3
"""Release helper: bump toc version, commit, tag v*, push (CurseForge Release via Actions).

Usage:
  release.cmd              # auto bump last segment (0.1.3 -> 0.1.4)
  release.cmd 0.2.0        # explicit version
"""
from __future__ import annotations

import os
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
TOC = ROOT / "BGLite_Plus.toc"
VERSION_RE = re.compile(r"(?m)^## Version:\s*(.+?)\s*$")
RELEASE_FILES = [
    "BGLite_Plus.toc",
    ".github/workflows/release.yml",
    "scripts/release.py",
    "scripts/release.cmd",
    "scripts/release.ps1",
    "scripts/install-hooks.ps1",
    "README.md",
    "README.zh-CN.md",
    "CHANGELOG.md",
]


def run(args: list[str], check: bool = True) -> subprocess.CompletedProcess[str]:
    # Keep git http.proxy (e.g. 127.0.0.1:7890). Clearing it breaks push on this machine.
    env = os.environ.copy()
    env["GIT_TERMINAL_PROMPT"] = "0"
    print(">", " ".join(args))
    proc = subprocess.run(
        args,
        cwd=ROOT,
        env=env,
        text=True,
        encoding="utf-8",
        errors="replace",
    )
    if check and proc.returncode != 0:
        raise SystemExit(f"command failed ({proc.returncode}): {' '.join(args)}")
    return proc


def git_ok(args: list[str]) -> bool:
    return run(args, check=False).returncode == 0


def toc_version(text: str) -> str:
    m = VERSION_RE.search(text)
    if not m:
        raise SystemExit("missing ## Version in BGLite_Plus.toc")
    return m.group(1).strip()


def next_patch(ver: str) -> str:
    if not re.fullmatch(r"\d+(\.\d+)+", ver):
        raise SystemExit(f"cannot auto-bump version: {ver} (expected like 0.1.3)")
    parts = ver.split(".")
    parts[-1] = str(int(parts[-1]) + 1)
    return ".".join(parts)


def tag_exists(tag: str) -> bool:
    out = subprocess.run(
        ["git", "tag", "-l", tag],
        cwd=ROOT,
        capture_output=True,
        text=True,
        encoding="utf-8",
        errors="replace",
    )
    return bool(out.stdout.strip())


def main() -> None:
    if not TOC.is_file():
        raise SystemExit(f"toc not found: {TOC}")

    text = TOC.read_text(encoding="utf-8")
    current = toc_version(text)

    if len(sys.argv) > 1 and sys.argv[1].strip():
        version = sys.argv[1].strip()
        if version.lower().startswith("v"):
            version = version[1:]
        print(f"[BGLite_Plus] using explicit version: {version}")
    else:
        version = next_patch(current)
        while tag_exists(f"v{version}"):
            print(f"[BGLite_Plus] tag v{version} exists, bump again...")
            version = next_patch(version)
        print(f"[BGLite_Plus] auto bump: {current} -> {version}")

    if re.search(r"alpha|beta", version, re.I):
        raise SystemExit(f"version must not contain alpha/beta: {version}")
    if not re.fullmatch(r"\d+(\.\d+)+", version):
        raise SystemExit(f"invalid version: {version} (expected like 0.1.4)")

    tag = f"v{version}"
    if tag_exists(tag):
        raise SystemExit(f"tag already exists: {tag} (bump version and retry)")

    new_text, n = VERSION_RE.subn(f"## Version: {version}", text, count=1)
    if n != 1:
        raise SystemExit("failed to replace ## Version")
    TOC.write_text(new_text, encoding="utf-8", newline="\n")

    for rel in RELEASE_FILES:
        path = ROOT / rel
        if path.is_file():
            run(["git", "add", "--", rel])

    run(["git", "commit", "-m", f"release: {tag}"])
    run(["git", "tag", "-a", tag, "-m", f"release: {tag} (toc ## Version)"])

    # post-commit may already push the branch; still ensure branch + tag are on origin
    push_branch = run(["git", "push", "origin", "HEAD"], check=False)
    if push_branch.returncode != 0:
        print("[BGLite_Plus] WARNING: git push branch failed; run: git push origin HEAD")

    run(["git", "push", "origin", f"refs/tags/{tag}"])

    print("")
    print(f"[BGLite_Plus] toc ## Version -> {version}")
    print(f"[BGLite_Plus] tagged {tag} and pushed. Actions will upload CurseForge Release.")


if __name__ == "__main__":
    main()
