#!/usr/bin/env python3

# Written by Igor Trujnara, released under the MIT license
# See https://opensource.org/license/mit for details

import sys
from warnings import warn

from utils import safe_get


def main() -> None:
    if len(sys.argv) < 2:
        raise ValueError("Not enough arguments. Usage: fetch_oma_by_sequence.py <fasta> <id_out> <taxid_out>")

    uniprot_id = sys.argv[1]
    res = safe_get(f"https://omabrowser.org/api/protein/{uniprot_id}")

    if res.status_code == 404:
        warn("ID not found")
        print("1")
    elif not res.ok:
        raise ValueError("Fetch failed, aborting")

    try:
        print(res.json()["species"]["taxon_id"])
    except KeyError:
        print("1") # default to root if no taxid is found


if __name__ == "__main__":
    main()
