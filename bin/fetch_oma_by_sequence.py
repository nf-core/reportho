#!/usr/bin/env python3

# Written by Igor Trujnara, released under the MIT license
# See https://opensource.org/license/mit for details

import sys
from warnings import warn

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
    if len(sys.argv) < 5:
        raise ValueError("Not enough arguments. Usage: fetch_oma_by_sequence.py <fasta> <id_out> <taxid_out> <exact_out>")

    seqs = SeqIO.parse(sys.argv[1], "fasta")
    seq = next(seqs).seq

    # Only use the first sequence, ignore all others
    if next(seqs, None) is not None:
        warn("Multiple sequences passed, only using the first one.")

    success, json = fetch_seq(f"https://omabrowser.org/api/sequence/?query={seq}")

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
        print("true", file=open(sys.argv[4], 'w'))
    else:
        print("false", file=open(sys.argv[4], 'w'))

    # If main isoform not found, check the first alternative isoform
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
