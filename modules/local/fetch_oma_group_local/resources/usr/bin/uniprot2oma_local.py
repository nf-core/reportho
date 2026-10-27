#!/usr/bin/env python3

# Written by Igor Trujnara, released under the MIT license
# See https://opensource.org/license/mit for details

"""Map UniProt IDs to OMA IDs using a local ID mapping file."""

import argparse
import gzip


def uniprot2oma_local(uniprot_path: list[str], idmap_path: str) -> None:
    """Map a list of UniProt IDs to OMA IDs using a local ID mapping file."""
    with open(uniprot_path[0]) as f:
        uniprot_ids = f.read().splitlines()

    mapping = dict()
    with gzip.open(idmap_path, "rt") as f:
        for line in f:
            items = line.split()
            if items[1] not in mapping:
                mapping[items[1]] = items[0]

    ids_mapped = [mapping[i] for i in uniprot_ids if i in mapping]
    ids_unmapped = [i for i in uniprot_ids if i not in mapping]

    for i in ids_mapped + ids_unmapped:
        print(i)


def main() -> None:
    parser = argparse.ArgumentParser(description="Map UniProt IDs to OMA IDs using a local ID mapping file.")
    parser.add_argument(
        "-m",
        "--idmap-path",
        required=True,
        help="Path to gzipped ID mapping file.",
    )
    parser.add_argument(
        "-i",
        "--ids-path",
        required=True,
        help="Path to input file containing UniProt IDs.",
    )
    args = parser.parse_args()

    uniprot2oma_local([args.ids_path], args.idmap_path)


if __name__ == "__main__":
    main()
