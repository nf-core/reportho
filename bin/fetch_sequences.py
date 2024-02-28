#!/usr/bin/env python3

import requests
import sys

def fetch_seqs(path: str):
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

    for miss in misses:
        print(miss, file=sys.stderr)

def main() -> None:
    if len(sys.argv) < 2:
        raise ValueError("Too few arguments. Usage: fetch_sequences.py [path]")
    fetch_seqs(sys.argv[1])

if __name__ == "__main__":
    main()
