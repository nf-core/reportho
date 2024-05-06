#!/usr/bin/env python3

# Written by Igor Trujnara, released under the MIT license
# See https://opensource.org/license/mit for details

import sys

from utils import fetch_seq


def main() -> None:
    if len(sys.argv) < 2:
        raise ValueError("Not enough arguments. Usage: fetch_oma_by_sequence.py <fasta> <id_out> <taxid_out>")

    uniprot_id = sys.argv[1]
    success, json = fetch_seq(f"https://omabrowser.org/api/protein/{uniprot_id}")

    if not success:
        raise ValueError("Fetch failed, aborting")

    print(json["species"]["taxon_id"])


if __name__ == "__main__":
    main()
