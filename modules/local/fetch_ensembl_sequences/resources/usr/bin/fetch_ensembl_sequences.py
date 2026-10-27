#!/usr/bin/env python3

# Written by Igor Trujnara, released under the MIT license
# See https://opensource.org/license/mit for details

"""Fetch protein sequences from Ensembl using the Ensembl REST API."""

import argparse
import csv
import os
import subprocess
import sys

bin_dir = os.path.dirname(os.path.realpath(subprocess.check_output(["which", "utils.py"], text=True).strip()))
sys.path.insert(0, bin_dir)

from utils import SequenceInfo, list_to_file, safe_post, split_ids  # noqa: E402, I001


def fetch_slice(ids: list[str], idmap: dict[str, str]) -> list[SequenceInfo]:
    """Fetch taxon IDs and sequences for given protein IDs from Ensembl."""
    hits = {}
    # fetch taxon information
    payload = {"ids": ids}
    headers = {"Content-Type": "application/json", "Accept": "application/json"}
    res1 = safe_post("https://rest.ensembl.org/lookup/id", json=payload, headers=headers)
    json1 = res1.json()
    if json1:
        for entry in json1:
            if not json1[entry]:
                continue
            hits[entry] = SequenceInfo(prot_id=entry, taxid=idmap[json1[entry]["species"]], sequence=None)

    # fetch sequence information
    params = {"type": "protein"}
    res2 = safe_post("https://rest.ensembl.org/sequence/id", json=payload, headers=headers, params=params)
    json2 = res2.json()
    if json2:
        for entry in json2:
            if type(entry) is not type(dict()):
                continue
            if hits.get(entry["query"], None) is not None:
                hits[entry["query"]].sequence = entry["seq"]

    return [i for i in hits.values() if i.is_valid()]


def fetch_ensembl(ids: list[str], idmap_path: str) -> list[SequenceInfo]:
    """Fetch taxon IDs and sequences for given protein IDs from Ensembl in slices of 100."""
    taxon_map = {}
    with open(idmap_path) as f:
        for it in csv.reader(f):
            taxon_map[it[0]] = it[1]

    seqs = []
    for s in split_ids(ids, 100):
        seqs = seqs + fetch_slice(s, taxon_map)
    return seqs


def main():
    parser = argparse.ArgumentParser(description="Fetch protein sequences from Ensembl using the Ensembl REST API.")
    parser.add_argument(
        "-i",
        "--ids-path",
        required=True,
        help="Path to file with Ensembl IDs, one per line.",
    )
    parser.add_argument(
        "-m",
        "--idmap-path",
        required=True,
        help="Path to species-to-taxid mapping CSV file.",
    )
    parser.add_argument(
        "-p",
        "--prefix",
        required=True,
        help="Prefix for output hit/miss files.",
    )
    args = parser.parse_args()

    f = open(args.ids_path)
    ids = f.read().splitlines()
    seqs = fetch_ensembl(ids, args.idmap_path)
    seqs_valid = [i for i in seqs if i.is_valid()]

    for i in seqs_valid:
        print(i)

    ids_valid = set([i.prot_id for i in seqs_valid])
    ids_invalid = set(ids) - ids_valid

    prefix = args.prefix
    list_to_file(list(ids_valid), f"{prefix}_ensembl_seq_hits.txt")
    list_to_file(list(ids_invalid), f"{prefix}_ensembl_seq_misses.txt")


if __name__ == "__main__":
    main()
