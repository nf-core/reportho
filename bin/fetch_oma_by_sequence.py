#!/usr/bin/env python3

from typing import Any
import requests
import sys
from Bio import SeqIO
from warnings import warn

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

    seqs = SeqIO.parse(sys.argv[1], "fasta")
    seq = next(seqs).seq
    if next(seqs, None) is not None:
        warn("Multiple sequences passed, only using the first one.")
    success, json = fetch_seq(f"https://omabrowser.org/api/sequence/?query={seq}")

    if not success:
        raise ValueError("Fetch failed, aborting")

    entry: dict = dict()
    for it in json["targets"]:
            if it["is_main_isoform"]:
                entry = it
                break
    if entry == dict():
        if len(json["targets"][0]["alternative_isoforms_urls"]) > 0:
            isoform = json["targets"][0]["alternative_isoforms_urls"][0]
            success, json = fetch_seq(isoform)
            if not success:
                raise ValueError("Isoform fetch failed, aborting")
            if json["is_main_isoform"]:
                entry = json
            else:
                raise ValueError("Isoform not found")
    print(entry["canonicalid"], file=open(sys.argv[2], "w"))
    print(entry["species"]["taxon_id"], file=open(sys.argv[3], "w"))


if __name__ == "__main__":
    main()
