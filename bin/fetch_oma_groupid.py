#!/usr/bin/env python3

import sys

from utils import fetch_seq


def main() -> None:
    """
    Get OMA group ID from a UniProt ID.
    """
    if len(sys.argv) < 2:
        raise ValueError("Not enough arguments. Usage: fetch_oma_groupid.py <filename>")

    prot_id = sys.argv[1]
    success, json = fetch_seq(f"https://omabrowser.org/api/protein/{prot_id}")

    if not success:
        raise ValueError("Fetch failed, aborting")

    entry: dict = dict()
    if json["is_main_isoform"]:
        entry = json

    # If main isoform not found, check the first alternative isoform
    if entry == dict():
        if len(json["alternative_isoforms_urls"]) > 0:
            isoform = json["alternative_isoforms_urls"][0]
            success, json = fetch_seq(isoform)
            if not success:
                raise ValueError("Isoform fetch failed, aborting")
            if json["is_main_isoform"]:
                entry = json
            else:
                raise ValueError("Isoform not found")
    print(entry['oma_group'])


if __name__ == "__main__":
    main()
