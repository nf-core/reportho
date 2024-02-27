#!/usr/bin/env python3

from typing import Any
import requests
import sys

def fetch_seq(url: str):
    res = requests.get(url)
    if not res.ok:
        print(f"HTTP error. Code: {res.status_code}")
        return (False, dict())
    json: dict[str, Any] = res.json()
    return (True, json)


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
