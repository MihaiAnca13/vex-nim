#!/usr/bin/env python3
"""Delete compiled test binaries from tests/ folder."""

import os
from pathlib import Path

TESTS_DIR = Path(__file__).parent.parent / "tests"


def main():
    if not TESTS_DIR.exists():
        print(f"Tests directory not found: {TESTS_DIR}")
        return

    deleted = 0
    for entry in TESTS_DIR.iterdir():
        if entry.is_file() and not entry.suffix and os.access(entry, os.X_OK):
            entry.unlink()
            print(f"Deleted: {entry.name}")
            deleted += 1

    print(f"\nDeleted {deleted} test binary(ies)")


if __name__ == "__main__":
    main()
