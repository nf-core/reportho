#!/usr/bin/env python3

# Written by Igor Trujnara, released under the MIT license
# See https://opensource.org/license/mit for details

"""Fetch OMA entry for a given protein sequence from the OMA browser API."""

import argparse
import sys
from warnings import warn

from Bio import SeqIO
from omadb import Client as OmaClient

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
    seq = str(next(seqs).seq)

    print(type(seq), file=sys.stderr)

    # Only use the first sequence, ignore all others
    if next(seqs, None) is not None:
        warn("Multiple sequences passed, only using the first one.")

    oma = OmaClient()

    prot = oma.proteins.search(seq)

    if not prot.targets:
        raise ValueError("Nothing found for the given sequence, aborting")

    entry: dict = dict()

    # Find the main isoform
    for it in prot.targets:
        if it.is_main_isoform:
            entry = it
            break

    # Write exact match status
    if prot.identified_by == "exact match":
        print("true", file=open(args.exact_out, "w"))
    else:
        print("false", file=open(args.exact_out, "w"))

    # If main isoform not found, check the first alternative isoform
    if entry == dict():
        if len(prot.targets[0].alternative_isoforms_urls) > 0:
            isoform = prot.targets[0].alternative_isoforms_urls[0]
            prot = oma.proteins[isoform.omaid]
            if not prot:
                raise ValueError("Isoform fetch failed, aborting")
            if prot.is_main_isoform:
                entry = prot
            else:
                raise ValueError("Isoform not found")

    print(entry.canonicalid, file=open(args.id_out, "w"))
    print(entry.species.taxon_id, file=open(args.taxid_out, "w"))


if __name__ == "__main__":
    main()
