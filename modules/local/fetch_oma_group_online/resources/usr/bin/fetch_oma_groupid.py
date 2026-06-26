#!/usr/bin/env python3

# Written by Igor Trujnara, released under the MIT license
# See https://opensource.org/license/mit for details

"""Get OMA group ID from a UniProt ID."""

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
    parser = argparse.ArgumentParser(
        description="Get OMA group ID from a UniProt ID."
    )
    parser.add_argument(
        "-p",
        "--protein-id",
        required=True,
        help="UniProt protein ID used to query OMA.",
    )
    args = parser.parse_args()

    prot_id = args.protein_id
    headers = {"User-Agent": "pyomadb/2.1.0"}
    res = safe_get(f"https://omabrowser.org/api/protein/{prot_id}", headers=headers)

    if res.status_code == 404:
        warn("ID not found")
        print("0")
        return
    elif not res.ok:
        raise ValueError("Fetch failed, aborting")

    json = res.json()
    entry: dict = dict()
    if json["is_main_isoform"]:
        entry = json

    # If main isoform not found, check the first alternative isoform
    if entry == dict():
        if len(json["alternative_isoforms_urls"]) > 0:
            res = safe_get(json["isoforms"], headers=headers)
            json2 = res.json()
            for isoform in json2:
                if isoform["is_main_isoform"]:
                    entry = isoform
                    break
            if entry == dict():
                raise ValueError("Isoform not found")
    print(entry['oma_group'])


if __name__ == "__main__":
    main()
