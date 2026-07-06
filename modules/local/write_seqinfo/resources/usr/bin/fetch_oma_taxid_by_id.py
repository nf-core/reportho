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

from utils import safe_get, handle_http_response # noqa: E402


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
    url = f"https://omabrowser.org/api/protein/{uniprot_id}/"
    res = safe_get(url, headers=headers)

    retry, json = handle_http_response(res)
    if retry:
        res = safe_get(url, headers=headers)
        _, json = handle_http_response(res)

    if not json:
        warn("ID not found")
        print("1")

    try:
        print(json["species"]["taxon_id"])
    except KeyError:
        print("1") # default to root if no taxid is found


if __name__ == "__main__":
    main()
