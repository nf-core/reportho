#!/usr/bin/env python3

import requests
import sys

def fetch_seqs_oma(path: str):
    ids = []
    with open(path, "r") as f:
        ids = f.read().splitlines()

    payload = {"ids": ids}

    res = requests.post("https://omabrowser.org/api/protein/bulk_retrieve/", json=payload)

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

    with open("hits.txt", 'w') as f:
        for hit in hits:
            print(hit[0], file=f)

    return misses


def fetch_seqs_uniprot(oma_misses: list):
    hits = []
    misses = []

    for id in oma_misses:
        res = requests.get(f"https://rest.uniprot.org/uniprotkb/{id}.fasta")
        if res.ok:
            hits.append((id, res.text))
        else:
            misses.append(id)

    for hit in hits:
        print(f">{hit[0]}")
        print(hit[1])

    with open("hits.txt", 'a') as f:
        for hit in hits:
            print(hit[0], file=f)

    with open("misses.txt", 'w') as f:
        for miss in misses:
            print(miss, file=f)



def main() -> None:
    if len(sys.argv) < 2:
        raise ValueError("Too few arguments. Usage: fetch_sequences.py [path]")
    oma_misses = fetch_seqs_oma(sys.argv[1])
    fetch_seqs_uniprot(oma_misses)


if __name__ == "__main__":
    main()
