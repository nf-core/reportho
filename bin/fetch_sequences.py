#!/usr/bin/env python3

# Written by Igor Trujnara, released under the MIT license
# See https://opensource.org/license/mit for details

import sys

from utils import safe_get, safe_post


def fetch_seqs_oma(path: str, prefix: str) -> list[str]:
    """
    Fetch sequences for given UniProt IDs from the OMA database.
    """
    ids = []
    with open(path) as f:
        ids = f.read().splitlines()

    payload = {"ids": ids}

    res = safe_post("https://omabrowser.org/api/protein/bulk_retrieve/", json=payload)

    if not res.ok:
        raise ValueError(f"HTTP error: {res.status_code}")

    hits = []
    misses = []
    for entry in res.json():
        if entry["target"] is not None:
            hits.append((entry["query_id"], entry["target"]["sequence"]))
        else:
            misses.append(entry["query_id"])

    for hit in hits:
        print(f">{hit[0]}")
        print(hit[1])

    with open(f"{prefix}_seq_hits.txt", 'w') as f:
        for hit in hits:
            print(hit[0], file=f)

    return misses


def fetch_seqs_uniprot(oma_misses: list, prefix: str) -> None:
    """
    Fetch sequences for given UniProt IDs from the UniProt database. Done second because it is slower.
    """
    hits = []
    misses = []

    for id in oma_misses:
        res = safe_get(f"https://rest.uniprot.org/uniprotkb/{id}.fasta")
        if res.ok:
            try:
                hits.append((id, res.text.split("\n", 1)[1].replace("\n", "")))
            except IndexError:
                misses.append(id)
        else:
            misses.append(id)

    for hit in hits:
        print(f">{hit[0]}")
        print(hit[1])

    with open(f"{prefix}_seq_hits.txt", 'a') as f:
        for hit in hits:
            print(hit[0], file=f)

    with open(f"{prefix}_seq_misses.txt", 'w') as f:
        for miss in misses:
            print(miss, file=f)


def main() -> None:
    if len(sys.argv) < 3:
        raise ValueError("Too few arguments. Usage: fetch_sequences.py <path> <prefix>")
    oma_misses = fetch_seqs_oma(sys.argv[1], sys.argv[2])
    fetch_seqs_uniprot(oma_misses, sys.argv[2])


if __name__ == "__main__":
    main()
