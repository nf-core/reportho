#!/usr/bin/env python3

# Written by Igor Trujnara, released under the MIT license
# See https://opensource.org/license/mit for details

"""Fetch protein sequences from the OMA database using the OMA REST API."""

import argparse
import os
import subprocess
import sys

bin_dir = os.path.dirname(os.path.realpath(subprocess.check_output(["which", "utils.py"], text=True).strip()))
sys.path.insert(0, bin_dir)

from utils import SequenceInfo, handle_http_request, list_to_file, split_ids  # noqa: E402


def fetch_slice(ids: list[str]) -> list[SequenceInfo]:
    """Fetch sequences for given UniProt IDs from the OMA database."""
    payload = {"ids": ids}
    headers = {"User-Agent": "pyomadb/2.1.0"}
    json = handle_http_request(
        "https://omabrowser.org/api/protein/bulk_retrieve/", method="POST", json=payload, headers=headers
    )

    hits = []

    for entry in json:
        if entry["target"] is not None:
            hits.append(
                SequenceInfo(
                    prot_id=entry["query_id"],
                    taxid=entry["target"]["species"]["taxon_id"],
                    sequence=entry["target"]["sequence"],
                )
            )

    return hits


def fetch_seqs_oma(ids: list[str]) -> list[SequenceInfo]:
    """Fetch sequences for given UniProt IDs from the OMA database in slices of 100."""
    seqs = []
    for s in split_ids(ids, 100):
        seqs = seqs + fetch_slice(s)
    return seqs


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Fetch protein sequences from the OMA database using the OMA REST API."
    )
    parser.add_argument(
        "-i",
        "--ids-path",
        required=True,
        help="Path to file containing UniProt IDs, one per line.",
    )
    parser.add_argument(
        "-p",
        "--prefix",
        required=True,
        help="Prefix used for hits and misses output files.",
    )
    args = parser.parse_args()

    with open(args.ids_path) as f:
        ids = f.read().splitlines()

    seqs = fetch_seqs_oma(ids)
    seqs_valid = [i for i in seqs if i.is_valid()]

    for i in seqs_valid:
        print(i)

    ids_valid = set([i.prot_id for i in seqs_valid])
    ids_invalid = set(ids) - ids_valid

    prefix = args.prefix
    list_to_file(list(ids_valid), f"{prefix}_oma_seq_hits.txt")
    list_to_file(list(ids_invalid), f"{prefix}_oma_seq_misses.txt")


if __name__ == "__main__":
    main()
