#!/usr/bin/env python3

# Written by Igor Trujnara, released under the MIT license
# See https://opensource.org/license/mit for details

"""Fetch OMA taxon ID by UniProt ID."""

import os
import argparse
import subprocess
import sys
from warnings import warn

bin_dir = os.path.dirname(os.path.realpath(subprocess.check_output(
    ['which', 'utils.py'], text=True).strip()))
sys.path.insert(0, bin_dir)

from utils import safe_get # noqa: E402


def main() -> None:
    parser = argparse.ArgumentParser(description="Fetch OMA taxon ID by UniProt ID.")
    parser.add_argument(
        "-u",
        "--uniprot-id",
        required=True,
        help="UniProt ID to query in OMA.",
    )
    args = parser.parse_args()

    uniprot_id = args.uniprot_id
    headers = {"User-Agent": "pyomadb/2.1.0" }
    res = safe_get(f"https://omabrowser.org/api/protein/{uniprot_id}/", headers=headers)

    if res.status_code == 404:
        warn("ID not found")
        print("1")
    elif not res.ok:
        raise ValueError(f"Fetch failed (HTTP {res.status_code}), aborting\nResponse content: {res.headers}\n{res.text}")

    try:
        print(res.json()["species"]["taxon_id"])
    except KeyError:
        print("1") # default to root if no taxid is found


if __name__ == "__main__":
    main()
