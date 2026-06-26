#!/usr/bin/env python3

# Written by Igor Trujnara, released under the MIT license
# See https://opensource.org/license/mit for details

"""Map OMA IDs to UniProt IDs using the OMA browser API."""

import argparse

from map_uniprot import map_uniprot


def main() -> None:
    """Map IDs from OMA to UniProt IDs."""
    parser = argparse.ArgumentParser(
        description="Map OMA IDs to UniProt IDs using the OMA browser API."
    )
    parser.add_argument(
        "-i",
        "--oma-group-file",
        required=True,
        help="Path to the input file containing OMA group IDs.",
    )
    args = parser.parse_args()

    oma_ids: list[str] = []

    with open(args.oma_group_file) as f:
        for line in f:
            oma_ids.append(line.strip())
    oma_ids_mapped = map_uniprot(oma_ids)

    for i in oma_ids_mapped:
        print(i)

if __name__ == "__main__":
    main()
