#!/usr/bin/env python3

# Written by Igor Trujnara, released under the MIT license
# See https://opensource.org/license/mit for details

"""Get OMA group ID from a UniProt ID."""

import argparse
import os
import subprocess
import sys

bin_dir = os.path.dirname(os.path.realpath(subprocess.check_output(["which", "utils.py"], text=True).strip()))
sys.path.insert(0, bin_dir)

from utils import handle_http_request  # noqa: E402


def main() -> None:
    parser = argparse.ArgumentParser(description="Get OMA group ID from a UniProt ID.")
    parser.add_argument(
        "-p",
        "--protein-id",
        required=True,
        help="UniProt protein ID used to query OMA.",
    )
    args = parser.parse_args()

    prot_id = args.protein_id
    headers = {"User-Agent": "pyomadb/2.1.0"}
    json = handle_http_request(f"https://omabrowser.org/api/protein/{prot_id}", headers=headers)

    if json == dict() or "oma_group" not in json:
        print("0")
        return

    entry: dict = dict()
    if json["is_main_isoform"]:
        entry = json

    # If main isoform not found, check the first alternative isoform
    if entry == dict():
        if len(json["alternative_isoforms_urls"]) > 0:
            json2 = handle_http_request(json["isoforms"], headers=headers)
            for isoform in json2:
                if isoform["is_main_isoform"]:
                    entry = isoform
                    break
            if entry == dict():
                raise ValueError("Isoform not found")
    print(entry["oma_group"])


if __name__ == "__main__":
    main()
