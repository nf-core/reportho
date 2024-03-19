#!/usr/bin/env python3

import requests
import sys

def fetch_structures(path: str, prefix: str):
    ids = []
    with open(path, "r") as f:
        ids = f.read().splitlines()

    hits = []
    misses = []
    for id in ids:
        url = f"https://alphafold.ebi.ac.uk/api/prediction/{id}"
        res = requests.get(url)
        if res.ok:
            pdb_url = res.json()[0]["pdbUrl"]
            version = res.json()[0]["latestVersion"]
            print(f"{id}: {version}", file=sys.stderr)
            res = requests.get(pdb_url)
            if res.ok:
                print(res.text, file=open(f"{id}.pdb", 'w'))
                hits.append(id)
            else:
                misses.append(id)
        else:
            misses.append(id)

    with open(f"{prefix}_hits.txt", 'w') as f:
        for hit in hits:
            print(hit, file=f)

    with open(f"{prefix}_misses.txt", 'w') as f:
        for miss in misses:
            print(miss, file=f)


def main() -> None:
    if len(sys.argv) < 3:
        raise ValueError("Too few arguments. Usage: fetch_structures.py [path] [prefix]")
    fetch_structures(sys.argv[1], sys.argv[2])


if __name__ == "__main__":
    main()
