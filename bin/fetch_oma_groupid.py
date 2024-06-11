#!/usr/bin/env python3

# Written by Igor Trujnara, released under the MIT license
# See https://opensource.org/license/mit for details

import sys
from warnings import warn

from utils import safe_get


def main() -> None:
    """
    Get OMA group ID from a UniProt ID.
    """
    if len(sys.argv) < 2:
        raise ValueError("Not enough arguments. Usage: fetch_oma_groupid.py <filename>")

    prot_id = sys.argv[1]
    res = safe_get(f"https://omabrowser.org/api/protein/{prot_id}")

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
            res = safe_get(json["isoforms"])
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
