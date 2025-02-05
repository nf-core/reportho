#!/usr/bin/env python3

# Written by Igor Trujnara, released under the MIT license
# See https://opensource.org/license/mit for details

import sys

from utils import list_to_file, safe_post, SequenceInfo, split_ids


def fetch_slice(ids: list[str]) -> list[SequenceInfo]:
    """
    Fetch sequences for given UniProt IDs from the OMA database.
    """
    payload = {"ids": ids}

    res = safe_post("https://omabrowser.org/api/protein/bulk_retrieve/", json=payload)

    if not res.ok:
        raise ValueError(f"HTTP error: {res.status_code}")

    hits = []

    for entry in res.json():
        if entry["target"] is not None:
            hits.append(SequenceInfo(prot_id = entry["query_id"],
                                     taxid = entry["target"]["species"]["taxon_id"],
                                     sequence = entry["target"]["sequence"]))

    return hits


def fetch_seqs_oma(ids: list[str]) -> list[SequenceInfo]:
    seqs = []
    for s in split_ids(ids, 100):
        seqs = seqs + fetch_slice(s)
    return seqs


def main() -> None:
    if len(sys.argv) < 3:
        raise ValueError("Too few arguments. Usage: fetch_oma_sequences.py <ids_path> <prefix>")

    with open(sys.argv[1]) as f:
        ids = f.read().splitlines()

    seqs = fetch_seqs_oma(ids)
    seqs_valid = [i for i in seqs if i.is_valid()]

    for i in seqs_valid:
        print(i)

    ids_valid = set([i.prot_id for i in seqs_valid])
    ids_invalid = set(ids) - ids_valid

    prefix = sys.argv[2]
    list_to_file(list(ids_valid), f"{prefix}_oma_seq_hits.txt")
    list_to_file(list(ids_invalid), f"{prefix}_oma_seq_misses.txt")


if __name__ == "__main__":
    main()
