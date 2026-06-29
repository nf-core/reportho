#!/usr/bin/env python3

# Written by Igor Trujnara, released under the MIT license
# See https://opensource.org/license/mit for details

"""Fetch OMA entry for a given protein sequence from the OMA browser API."""

import os
import argparse
import subprocess
import sys
from warnings import warn

bin_dir = os.path.dirname(os.path.realpath(subprocess.check_output(
    ['which', 'utils.py'], text=True).strip()))
sys.path.insert(0, bin_dir)

from Bio import SeqIO
from utils import fetch_seq

# Script overview:
# Fetches the OMA entry for a given protein sequence
# The sequence is passed as a FASTA file
# If the sequence is not found, the script exits with an error
# It outputs 3 files:
# 1. The canonical ID of the sequence
# 2. The taxonomy ID of the species
# 3. A boolean indicating if the sequence was an exact match

def main() -> None:
    parser = argparse.ArgumentParser(
        description="Fetch OMA entry for a given protein sequence from the OMA browser API."
    )
    parser.add_argument(
        "-f",
        "--fasta",
        required=True,
        help="Path to input FASTA file.",
    )
    parser.add_argument(
        "-i",
        "--id-out",
        required=True,
        help="Output file path for canonical ID.",
    )
    parser.add_argument(
        "-t",
        "--taxid-out",
        required=True,
        help="Output file path for taxonomy ID.",
    )
    parser.add_argument(
        "-e",
        "--exact-out",
        required=True,
        help="Output file path for exact match flag.",
    )
    args = parser.parse_args()

    seqs = SeqIO.parse(args.fasta, "fasta")
    seq = next(seqs).seq
    headers = {"User-Agent": "pyomadb/2.1.0"}

    # Only use the first sequence, ignore all others
    if next(seqs, None) is not None:
        warn("Multiple sequences passed, only using the first one.")

    success, json = fetch_seq(f"https://omabrowser.org/api/sequence/?query={seq}", headers=headers)

    if not success:
        raise ValueError("Fetch failed, aborting")

    entry: dict = dict()

    # Find the main isoform
    for it in json["targets"]:
        if it["is_main_isoform"]:
            entry = it
            break

    # Write exact match status
    if json["identified_by"] == "exact match":
        print("true", file=open(args.exact_out, 'w'))
    else:
        print("false", file=open(args.exact_out, 'w'))

    # If main isoform not found, check the first alternative isoform
    if entry == dict():
        if len(json["targets"][0]["alternative_isoforms_urls"]) > 0:
            isoform = json["targets"][0]["alternative_isoforms_urls"][0]
            success, json = fetch_seq(isoform, headers=headers)
            if not success:
                raise ValueError("Isoform fetch failed, aborting")
            if json["is_main_isoform"]:
                entry = json
            else:
                raise ValueError("Isoform not found")

    print(entry["canonicalid"], file=open(args.id_out, "w"))
    print(entry["species"]["taxon_id"], file=open(args.taxid_out, "w"))


if __name__ == "__main__":
    main()
