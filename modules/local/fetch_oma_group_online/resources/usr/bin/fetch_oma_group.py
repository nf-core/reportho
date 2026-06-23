#!/usr/bin/env python3

# Written by Igor Trujnara, released under the MIT license
# See https://opensource.org/license/mit for details

"""Fetch members of an OMA group by ID."""

import os
import subprocess
import sys
from warnings import warn

bin_dir = os.path.dirname(os.path.realpath(subprocess.check_output(
    ['which', 'utils.py'], text=True).strip()))
sys.path.insert(0, bin_dir)

from utils import safe_get


def main() -> None:
    if len(sys.argv) < 2:
        raise ValueError("Too few arguments. Usage: fetch_oma_group_by_id.py <id>")

    id = sys.argv[1]
    headers = {"User-Agent": "pyomadb/2.1.0"}

    res = safe_get(f"https://omabrowser.org/api/group/{id}", headers=headers)

    if res.status_code == 404:
        warn("ID not found")
        return
    elif not res.ok:
        raise ValueError(f"HTTP error: {res.status_code}")

    json = res.json()
    for member in json["members"]:
        print(f"{member['canonicalid']}")

if __name__ == "__main__":
    main()
