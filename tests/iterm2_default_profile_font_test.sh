#!/usr/bin/env bash
set -euo pipefail

PLIST_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)/iterm2/com.googlecode.iterm2.plist"

python3 - <<'PY' "${PLIST_PATH}"
import plistlib
import sys
from pathlib import Path

plist_path = Path(sys.argv[1])
if not plist_path.exists():
    print(f"Missing plist: {plist_path}")
    raise SystemExit(1)

with plist_path.open("rb") as f:
    data = plistlib.load(f)

default_guid = data.get("Default Bookmark Guid")
bookmarks = data.get("New Bookmarks", [])

default_profile = None
for bookmark in bookmarks:
    if bookmark.get("Guid") == default_guid:
        default_profile = bookmark
        break

if default_profile is None:
    print("Default iTerm profile was not found in New Bookmarks.")
    raise SystemExit(1)

expected_font = "HackNFM-Regular 14"
errors = []

if default_profile.get("Normal Font") != expected_font:
    errors.append(
        f"Normal Font mismatch: {default_profile.get('Normal Font')!r} != {expected_font!r}"
    )

if default_profile.get("Non Ascii Font") != expected_font:
    errors.append(
        f"Non Ascii Font mismatch: {default_profile.get('Non Ascii Font')!r} != {expected_font!r}"
    )

if default_profile.get("Use Non-ASCII Font") is not True:
    errors.append(
        f"Use Non-ASCII Font mismatch: {default_profile.get('Use Non-ASCII Font')!r} != True"
    )

if errors:
    print("\n".join(errors))
    raise SystemExit(1)

print("PASS: iTerm default profile uses Hack Nerd Font for all glyphs.")
PY
