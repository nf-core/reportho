#!/usr/bin/env python3

# Written by Igor Trujnara, released under the MIT license
# See https://opensource.org/license/mit for details

"""Split a list of protein IDs into different files based on their identifier format.

The splitting is done based on official accession regexes for UniProt, Ensembl, and RefSeq.
The regex for OMA is inferred based on the format description."""

import os
import argparse
import subprocess
import sys

bin_dir = os.path.dirname(os.path.realpath(subprocess.check_output(
    ['which', 'utils.py'], text=True).strip()))
sys.path.insert(0, bin_dir)

from utils import split_ids_by_format # noqa: E402


def split_ids(ids: list[str], prefix: str) -> None:
    """Split a list of protein IDs into different files based on their identifier format."""
    file_uniprot = open(f"{prefix}_uniprot_ids.txt", 'w')
    file_ensembl = open(f"{prefix}_ensembl_ids.txt", 'w')
    file_refseq = open(f"{prefix}_refseq_ids.txt", 'w')
    file_oma = open(f"{prefix}_oma_ids.txt", 'w')
    file_unknown = open(f"{prefix}_unknown_ids.txt", 'w')

    ids_format = split_ids_by_format(ids)

    for i in ids_format.get("uniprot", []):
        print(i, file = file_uniprot)
    for i in ids_format.get("ensembl", []):
        print(i, file = file_ensembl)
    for i in ids_format.get("refseq", []):
        print(i, file = file_refseq)
    for i in ids_format.get("oma", []):
        print(i, file = file_oma)
    for i in ids_format.get("unknown", []):
        print(i, file = file_unknown)

    file_uniprot.close()
    file_ensembl.close()
    file_refseq.close()
    file_oma.close()
    file_unknown.close()


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Split a list of protein IDs into different files based on their identifier format."
    )
    parser.add_argument(
        "-i",
        "--id-list",
        required=True,
        help="Path to input file containing one protein ID per line.",
    )
    parser.add_argument(
        "-p",
        "--prefix",
        required=True,
        help="Prefix used for output split files.",
    )
    args = parser.parse_args()
    with open(args.id_list) as f:
        ids = f.read().splitlines()
    split_ids(ids, args.prefix)


if __name__ == "__main__":
    main()
