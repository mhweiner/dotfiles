#!/usr/bin/env python3
"""Reduce an iTerm2 plist to portable dotfiles template shape.

Saved window arrangements, window positions, and other machine-local state do
not belong in ~/dotfiles. Run after re-exporting prefs from iTerm2:

  python3 iterm2/sanitize_plist.py iterm2/com.googlecode.iterm2.plist
"""
from __future__ import annotations

import plistlib
import sys
from pathlib import Path
from typing import Any

DEPRECATED_KEYBOARD_KEYS = frozenset(
    {
        "0xf700-0x240000",
        "0xf701-0x240000",
        "0xf702-0x240000",
        "0xf703-0x240000",
    }
)

DROP_KEY_PREFIXES = (
    "NSWindow Frame",
    "NoSync",
    "NSNav",
    "NSToolbar",
    "NSSplitView",
    "AIFeature",
    "AITerm",
    "AIVector",
    "Aiterm",
    "SU",
)

DROP_KEYS = frozenset(
    {
        "Window Arrangements",
        "Default Arrangement Name",
        "iTerm Version",
        "AiMaxTokens",
        "AiModel",
        "AiResponseMaxTokens",
    }
)


def should_drop_key(key: str) -> bool:
    if key in DROP_KEYS:
        return True
    return any(key.startswith(prefix) for prefix in DROP_KEY_PREFIXES)


def strip_keyboard_maps(obj: Any) -> int:
    removed = 0
    if isinstance(obj, dict):
        km = obj.get("Keyboard Map")
        if isinstance(km, dict):
            for key in DEPRECATED_KEYBOARD_KEYS:
                if key in km:
                    del km[key]
                    removed += 1
        for value in obj.values():
            removed += strip_keyboard_maps(value)
    elif isinstance(obj, list):
        for item in obj:
            removed += strip_keyboard_maps(item)
    return removed


def sanitize_profile(profile: dict) -> None:
    profile.pop("Working Directory", None)
    profile["Custom Directory"] = "No"


def sanitize(data: dict) -> tuple[dict, int]:
    cleaned = {k: v for k, v in data.items() if not should_drop_key(k)}

    for bookmark in cleaned.get("New Bookmarks", []):
        if isinstance(bookmark, dict):
            sanitize_profile(bookmark)

    removed_keys = strip_keyboard_maps(cleaned)
    return cleaned, removed_keys


def main() -> int:
    if len(sys.argv) < 2:
        print("usage: sanitize_plist.py <plist>", file=sys.stderr)
        return 2

    target = Path(sys.argv[1]).resolve()
    try:
        with target.open("rb") as f:
            data = plistlib.load(f)
    except (plistlib.InvalidFileException, ValueError, OSError):
        return 0

    before_keys = len(data)
    cleaned, removed_mappings = sanitize(data)
    after_keys = len(cleaned)

    with target.open("wb") as f:
        plistlib.dump(cleaned, f, sort_keys=False)

    print(
        f"sanitized {target.name}: {before_keys} -> {after_keys} top-level keys, "
        f"removed {removed_mappings} deprecated key mapping(s)"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
